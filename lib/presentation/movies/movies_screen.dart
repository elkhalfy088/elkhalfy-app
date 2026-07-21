import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/iptv_service.dart';
import '../../data/models/movie_model.dart';
import '../../app/routes.dart';

class MoviesController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final IPTVService _iptvService = IPTVService();

  final RxList<MovieModel> movies = <MovieModel>[].obs;
  final RxList<MovieModel> filteredMovies = <MovieModel>[].obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxString selectedCategory = ''.obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMovies();
    ever(searchQuery, (_) => _filter());
    ever(selectedCategory, (_) => _filter());
  }

  Future<void> loadMovies() async {
    isLoading.value = true;
    try {
      final sources = await _firebaseService.getIPTVSources();
      final List<MovieModel> all = [];
      final Set<String> catIds = {};
      final List<Map<String, dynamic>> allCats = [];

      for (final src in sources) {
        if (src['show_movies'] != false) {
          final source = IPTVSource.fromMap(src);
          final m = await _iptvService.getMovies(source);
          final cats = await _iptvService.getVodCategories(source);
          all.addAll(m);
          for (final cat in cats) {
            final id = cat['category_id']?.toString() ?? '';
            if (!catIds.contains(id)) {
              catIds.add(id);
              allCats.add(Map<String, dynamic>.from(cat));
            }
          }
        }
      }
      categories.value = allCats;
      movies.value = all;
      filteredMovies.value = all;
    } catch (_) {}
    isLoading.value = false;
  }

  void _filter() {
    var result = movies.toList();
    if (selectedCategory.value.isNotEmpty) {
      result = result.where((m) => m.categoryId == selectedCategory.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((m) => m.name.toLowerCase().contains(q)).toList();
    }
    filteredMovies.value = result;
  }
}

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MoviesController());
    final controller = Get.find<MoviesController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.movies),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmer();
        }
        return Column(
          children: [
            if (controller.categories.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      return _Chip(
                        label: AppStrings.allChannels,
                        isSelected: controller.selectedCategory.value.isEmpty,
                        onTap: () => controller.selectedCategory.value = '',
                      );
                    }
                    final cat = controller.categories[index - 1];
                    return _Chip(
                      label: cat['category_name'] ?? '',
                      isSelected: controller.selectedCategory.value == cat['category_id']?.toString(),
                      onTap: () => controller.selectedCategory.value = cat['category_id']?.toString() ?? '',
                    );
                  },
                ),
              ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: controller.filteredMovies.length,
                itemBuilder: (_, index) {
                  final movie = controller.filteredMovies[index];
                  return _MovieCard(movie: movie);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showSearch(BuildContext context, MoviesController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(AppStrings.search, style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          onChanged: (v) => controller.searchQuery.value = v,
          decoration: const InputDecoration(hintText: 'اسم الفيلم...', hintStyle: TextStyle(color: AppColors.textSecondary)),
        ),
        actions: [
          TextButton(
            onPressed: () { controller.searchQuery.value = ''; Navigator.pop(context); },
            child: const Text(AppStrings.cancel, style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() => Shimmer.fromColors(
    baseColor: AppColors.shimmerBase,
    highlightColor: AppColors.shimmerHighlight,
    child: GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: 12,
      itemBuilder: (_, __) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
    ),
  );
}

class _MovieCard extends StatelessWidget {
  final MovieModel movie;
  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.movieDetail, arguments: movie),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.cardDark,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: movie.coverUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.cardDark,
                  child: const Icon(Icons.movie, color: AppColors.textSecondary, size: 40),
                ),
              ),
              const Positioned(
                bottom: 0, left: 0, right: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black87],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SizedBox(height: 60),
                ),
              ),
              Positioned(
                bottom: 6, left: 6, right: 6,
                child: Text(
                  movie.name,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: isSelected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}
