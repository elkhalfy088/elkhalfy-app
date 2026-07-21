import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/iptv_service.dart';
import '../../data/models/channel_model.dart';
import '../../app/routes.dart';

class LiveTvController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final IPTVService _iptvService = IPTVService();

  final RxList<ChannelModel> channels = <ChannelModel>[].obs;
  final RxList<ChannelModel> filteredChannels = <ChannelModel>[].obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxString selectedCategory = ''.obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadChannels();

    ever(searchQuery, (_) => _filterChannels());
    ever(selectedCategory, (_) => _filterChannels());
  }

  Future<void> loadChannels() async {
    isLoading.value = true;
    try {
      final sources = await _firebaseService.getIPTVSources();
      final List<ChannelModel> allChannels = [];
      final Set<String> catIds = {};
      final List<Map<String, dynamic>> allCats = [];

      for (final src in sources) {
        if (src['show_channels'] != false) {
          final source = IPTVSource.fromMap(src);
          final chs = await _iptvService.getLiveChannels(source);
          final cats = await _iptvService.getLiveCategories(source);
          allChannels.addAll(chs);
          for (final cat in cats) {
            if (!catIds.contains(cat['category_id'])) {
              catIds.add(cat['category_id']?.toString() ?? '');
              allCats.add(Map<String, dynamic>.from(cat));
            }
          }
        }
      }

      categories.value = allCats;
      channels.value = allChannels;
      filteredChannels.value = allChannels;
    } catch (_) {}
    isLoading.value = false;
  }

  void _filterChannels() {
    var result = channels.toList();

    if (selectedCategory.value.isNotEmpty) {
      result = result.where((c) => c.categoryId == selectedCategory.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((c) => c.name.toLowerCase().contains(q)).toList();
    }

    filteredChannels.value = result;
  }
}

class LiveTvScreen extends StatelessWidget {
  const LiveTvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LiveTvController());
    return const _LiveTvView();
  }
}

class _LiveTvView extends StatelessWidget {
  const _LiveTvView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LiveTvController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.liveTV),
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

        if (controller.channels.isEmpty) {
          return _buildEmpty();
        }

        return Column(
          children: [
            // Categories
            if (controller.categories.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _CategoryChip(
                        label: AppStrings.allChannels,
                        isSelected: controller.selectedCategory.value.isEmpty,
                        onTap: () => controller.selectedCategory.value = '',
                      );
                    }
                    final cat = controller.categories[index - 1];
                    return _CategoryChip(
                      label: cat['category_name'] ?? '',
                      isSelected: controller.selectedCategory.value == cat['category_id']?.toString(),
                      onTap: () => controller.selectedCategory.value = cat['category_id']?.toString() ?? '',
                    );
                  },
                ),
              ),

            // Channels grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: controller.filteredChannels.length,
                itemBuilder: (context, index) {
                  final channel = controller.filteredChannels[index];
                  return _ChannelCard(channel: channel);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showSearch(BuildContext context, LiveTvController controller) {
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
          decoration: const InputDecoration(
            hintText: 'اسم القناة...',
            hintStyle: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.searchQuery.value = '';
              Navigator.pop(context);
            },
            child: const Text(AppStrings.cancel, style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.live_tv, size: 60, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(AppStrings.noChannels, style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, fontSize: 16)),
          ],
        ),
      );

  Widget _buildShimmer() => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 12,
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

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
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final ChannelModel channel;

  const _ChannelCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.player, arguments: {
        'url': channel.streamUrl,
        'title': channel.name,
        'type': 'live',
      }),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [AppColors.cardDark, AppColors.cardLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: channel.logo,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.live_tv,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                channel.name,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: Colors.white,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.live,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
