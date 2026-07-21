import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/iptv_service.dart';
import '../../data/models/series_model.dart';
import '../../app/routes.dart';

class SeriesController extends GetxController {
  final FirebaseService _fs = Get.find<FirebaseService>();
  final IPTVService _iptv = IPTVService();
  final RxList<SeriesModel> series = <SeriesModel>[].obs;
  final RxList<SeriesModel> filtered = <SeriesModel>[].obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxString selectedCategory = ''.obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
    ever(searchQuery, (_) => _filter());
    ever(selectedCategory, (_) => _filter());
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final sources = await _fs.getIPTVSources();
      final List<SeriesModel> all = [];
      final Set<String> catIds = {};
      final List<Map<String, dynamic>> allCats = [];
      for (final src in sources) {
        if (src['show_series'] != false) {
          final source = IPTVSource.fromMap(src);
          final s = await _iptv.getSeries(source);
          all.addAll(s);
        }
      }
      series.value = all;
      filtered.value = all;
    } catch (_) {}
    isLoading.value = false;
  }

  void _filter() {
    var result = series.toList();
    if (selectedCategory.value.isNotEmpty) result = result.where((s) => s.categoryId == selectedCategory.value).toList();
    if (searchQuery.value.isNotEmpty) { final q = searchQuery.value.toLowerCase(); result = result.where((s) => s.name.toLowerCase().contains(q)).toList(); }
    filtered.value = result;
  }
}

class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SeriesController());
    final controller = Get.find<SeriesController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.series)),
      body: Obx(() {
        if (controller.isLoading.value) return _shimmer();
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: controller.filtered.length,
          itemBuilder: (_, i) {
            final s = controller.filtered[i];
            return GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.seriesDetail, arguments: s),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(imageUrl: s.coverUrl, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: AppColors.cardDark, child: const Icon(Icons.tv, color: AppColors.textSecondary, size: 40))),
                    const Positioned(bottom: 0, left: 0, right: 0, child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.black87], begin: Alignment.topCenter, end: Alignment.bottomCenter)), child: SizedBox(height: 60))),
                    Positioned(bottom: 6, left: 6, right: 6, child: Text(s.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _shimmer() => Shimmer.fromColors(
    baseColor: AppColors.shimmerBase, highlightColor: AppColors.shimmerHighlight,
    child: GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: 12, itemBuilder: (_, __) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)))),
  );
}
