import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/iptv_service.dart';
import '../../data/models/channel_model.dart';
import '../../app/routes.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'widgets/section_header.dart';

class HomeController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final IPTVService _iptvService = IPTVService();

  final RxList<Map<String, dynamic>> banners = <Map<String, dynamic>>[].obs;
  final RxList<ChannelModel> liveChannels = <ChannelModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt currentBannerIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final b = await _firebaseService.getBanners();
      banners.value = b;

      final sources = await _firebaseService.getIPTVSources();
      if (sources.isNotEmpty) {
        final source = IPTVSource.fromMap(sources.first);
        if (source.showChannels) {
          final channels = await _iptvService.getLiveChannels(source);
          liveChannels.value = channels.take(20).toList();
        }
      }
    } catch (_) {}
    isLoading.value = false;
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return const _HomeView();
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final HomeController controller = Get.find();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          Container(color: AppColors.background), // Content placeholder
          Container(color: AppColors.background), // Live TV placeholder
          Container(color: AppColors.background), // Matches placeholder
          Container(color: AppColors.background), // News placeholder
        ],
      ),
      bottomNavigationBar: ElkhalfyBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              setState(() => _selectedIndex = 0);
              break;
            case 1:
              Get.toNamed(AppRoutes.movies);
              break;
            case 2:
              Get.toNamed(AppRoutes.liveTV);
              break;
            case 3:
              Get.toNamed(AppRoutes.matches);
              break;
            case 4:
              Get.toNamed(AppRoutes.news);
              break;
          }
        },
      ),
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF3A1B8C), Color(0xFF1565C0)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset('assets/images/logo.png'),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Elkhalfy',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Obx(() {
            if (controller.isLoading.value) {
              return _buildShimmerLoading();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Slider
                if (controller.banners.isNotEmpty) _buildBannerSlider(),

                const SizedBox(height: 24),

                // Live Now
                if (controller.liveChannels.isNotEmpty) ...[
                  const SectionHeader(
                    title: AppStrings.liveNow,
                    icon: Icons.live_tv,
                    showMore: true,
                    onMoreTap: _goToLiveTV,
                  ),
                  _buildLiveChannels(),
                  const SizedBox(height: 24),
                ],

                // Promo banners for sections
                _buildPromoCard(
                  title: AppStrings.movies,
                  subtitle: 'آلاف الأفلام في مكان واحد',
                  icon: Icons.movie_outlined,
                  color: const Color(0xFF1565C0),
                  onTap: () => Get.toNamed(AppRoutes.movies),
                ),
                const SizedBox(height: 12),
                _buildPromoCard(
                  title: AppStrings.series,
                  subtitle: 'مسلسلات من جميع أنحاء العالم',
                  icon: Icons.tv,
                  color: const Color(0xFF7B1FA2),
                  onTap: () => Get.toNamed(AppRoutes.series),
                ),
                const SizedBox(height: 12),
                _buildPromoCard(
                  title: AppStrings.matches,
                  subtitle: 'جدول المباريات والنتائج المباشرة',
                  icon: Icons.sports_soccer,
                  color: const Color(0xFF2E7D32),
                  onTap: () => Get.toNamed(AppRoutes.matches),
                ),
                const SizedBox(height: 12),
                _buildPromoCard(
                  title: AppStrings.news,
                  subtitle: 'آخر الأخبار والمستجدات',
                  icon: Icons.article_outlined,
                  color: const Color(0xFFE65100),
                  onTap: () => Get.toNamed(AppRoutes.news),
                ),

                const SizedBox(height: 100),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBannerSlider() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            viewportFraction: 0.92,
            onPageChanged: (index, _) {
              controller.currentBannerIndex.value = index;
            },
          ),
          items: controller.banners.map((banner) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: banner['image'] ?? '',
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.cardGradient,
                        ),
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.imageOverlay,
                      ),
                    ),
                    if (banner['title'] != null)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        left: 16,
                        child: Text(
                          banner['title'],
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Obx(() => AnimatedSmoothIndicator(
          activeIndex: controller.currentBannerIndex.value,
          count: controller.banners.length,
          effect: WormEffect(
            dotWidth: 8,
            dotHeight: 8,
            activeDotColor: AppColors.primary,
            dotColor: Colors.white.withOpacity(0.3),
          ),
        )),
      ],
    );
  }

  Widget _buildLiveChannels() {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.liveChannels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final channel = controller.liveChannels[index];
          return GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.player, arguments: {
              'url': channel.streamUrl,
              'title': channel.name,
              'type': 'live',
            }),
            child: Container(
              width: 90,
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
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: channel.logo,
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.live_tv,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.live,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      channel.name,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color.withOpacity(0.3)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _goToLiveTV() => Get.toNamed(AppRoutes.liveTV);
}
