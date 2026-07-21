import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/news_model.dart';
import '../../app/routes.dart';

class NewsController extends GetxController {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final Dio _dio = Dio();

  final RxList<NewsModel> news = <NewsModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMsg = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNews();
  }

  Future<void> _loadNews() async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      final snapshot = await _db.ref('news_providers').get();
      if (!snapshot.exists) {
        isLoading.value = false;
        return;
      }

      final providers = Map<dynamic, dynamic>.from(snapshot.value as Map);
      final List<NewsModel> all = [];

      for (final provider in providers.values) {
        final p = Map<String, dynamic>.from(provider as Map);
        if (p['active'] == false) continue;

        try {
          final url = p['api_url'] ?? '';
          final apiKey = p['api_key'] ?? '';
          final headers = <String, dynamic>{};
          if (apiKey.isNotEmpty) headers['X-Api-Key'] = apiKey;

          final response = await _dio.get(url, options: Options(headers: headers));
          final fieldMapping = Map<String, dynamic>.from(p['field_mapping'] ?? {});
          final dataPath = (p['data_path'] ?? '') as String;

          dynamic rawList = response.data;
          if (dataPath.isNotEmpty) {
            for (final key in dataPath.split('.')) {
              rawList = rawList[key];
            }
          }

          if (rawList is List) {
            for (final item in rawList) {
              all.add(NewsModel.fromDynamic(Map<String, dynamic>.from(item), fieldMapping));
            }
          }
        } catch (_) {}
      }

      news.value = all;
    } catch (e) {
      errorMsg.value = AppStrings.serverError;
    }
    isLoading.value = false;
  }
}

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NewsController());
    final controller = Get.find<NewsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.news)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (controller.news.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article_outlined, size: 60, color: AppColors.textSecondary),
                SizedBox(height: 16),
                Text(AppStrings.noNews, style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller._loadNews,
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.news.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _NewsCard(news: controller.news[i]),
          ),
        );
      }),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsModel news;
  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.newsDetail, arguments: news),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppColors.cardDark, AppColors.cardLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: news.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    height: 180,
                    color: AppColors.cardDark,
                    child: const Icon(Icons.image_not_supported, color: AppColors.textSecondary, size: 40),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (news.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      news.description,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (news.publishedAt.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(news.publishedAt, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textHint)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
