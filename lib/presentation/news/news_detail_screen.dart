import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/news_model.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NewsModel news = Get.arguments as NewsModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: news.imageUrl.isNotEmpty ? 260 : 0,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: news.imageUrl.isNotEmpty
                ? FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(imageUrl: news.imageUrl, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: AppColors.cardDark)),
                        const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Color(0xFF050E1F)], begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [0.5, 1.0]))),
                      ],
                    ),
                  )
                : null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(news.title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  if (news.publishedAt.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(news.publishedAt, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textHint)),
                  ],
                  const SizedBox(height: 20),
                  if (news.description.isNotEmpty)
                    Text(news.description, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, color: AppColors.textSecondary, height: 1.8)),
                  if (news.fullUrl.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(news.fullUrl);
                          if (await canLaunchUrl(uri)) await launchUrl(uri);
                        },
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('قراءة الخبر كاملاً', style: TextStyle(fontFamily: 'Cairo')),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
