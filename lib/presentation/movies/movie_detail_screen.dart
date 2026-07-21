import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/movie_model.dart';
import '../../app/routes.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MovieModel movie = Get.arguments as MovieModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: movie.coverUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(color: AppColors.cardDark),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0xFF050E1F)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.name,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (movie.releaseDate.isNotEmpty) ...[
                        const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(movie.releaseDate, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(width: 16),
                      ],
                      if (movie.duration.isNotEmpty) ...[
                        const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(movie.duration, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(width: 16),
                      ],
                      if (movie.rating.isNotEmpty) ...[
                        RatingBarIndicator(
                          rating: double.tryParse(movie.rating) ?? 0,
                          itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(movie.rating, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.amber)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Get.toNamed(AppRoutes.player, arguments: {
                            'url': movie.streamUrl,
                            'title': movie.name,
                            'type': 'movie',
                          }),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text(AppStrings.watch, style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.download_outlined, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),

                  if (movie.plot.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'القصة',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.plot,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary, height: 1.7),
                    ),
                  ],

                  if (movie.cast.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _InfoRow(label: 'الممثلون', value: movie.cast),
                  ],
                  if (movie.director.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _InfoRow(label: 'الإخراج', value: movie.director),
                  ],
                  if (movie.genre.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _InfoRow(label: 'النوع', value: movie.genre),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold)),
        Expanded(child: Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary))),
      ],
    );
  }
}
