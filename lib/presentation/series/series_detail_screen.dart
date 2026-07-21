import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/iptv_service.dart';
import '../../data/models/series_model.dart';
import '../../app/routes.dart';

class SeriesDetailScreen extends StatefulWidget {
  const SeriesDetailScreen({super.key});

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  final SeriesModel series = Get.arguments as SeriesModel;
  final IPTVService _iptvService = IPTVService();

  Map<String, dynamic>? seriesInfo;
  bool isLoading = true;
  String selectedSeason = '1';

  @override
  void initState() {
    super.initState();
    _loadSeriesInfo();
  }

  Future<void> _loadSeriesInfo() async {
    try {
      final source = IPTVSource(
        id: '',
        name: '',
        type: IPTVSourceType.xtream,
        serverUrl: series.serverUrl,
        username: series.username,
        password: series.password,
      );
      final info = await _iptvService.getSeriesInfo(source, series.id);
      setState(() {
        seriesInfo = info;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final episodes = _getEpisodesForSeason();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(imageUrl: series.coverUrl, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: AppColors.cardDark)),
                  const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Color(0xFF050E1F)], begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [0.5, 1.0]))),
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
                  Text(series.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  if (series.plot.isNotEmpty) Text(series.plot, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary, height: 1.7)),
                  const SizedBox(height: 20),

                  // Season selector
                  if (!isLoading && seriesInfo != null && seriesInfo!['seasons'] != null) ...[
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: (seriesInfo!['seasons'] as Map).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final seasons = (seriesInfo!['seasons'] as Map).keys.toList();
                          final s = seasons[i].toString();
                          return GestureDetector(
                            onTap: () => setState(() => selectedSeason = s),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: selectedSeason == s ? AppColors.primary : AppColors.cardDark,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: selectedSeason == s ? AppColors.primary : AppColors.divider),
                              ),
                              child: Text('الموسم $s', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: selectedSeason == s ? Colors.white : AppColors.textSecondary)),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Episodes
                  if (isLoading)
                    const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  else
                    ...episodes.map((ep) => _EpisodeTile(episode: ep, seriesTitle: series.name)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<EpisodeModel> _getEpisodesForSeason() {
    if (seriesInfo == null) return [];
    try {
      final episodes = seriesInfo!['episodes'] as Map?;
      if (episodes == null) return [];
      final seasonEps = episodes[selectedSeason] as List?;
      if (seasonEps == null) return [];
      return seasonEps
          .map((e) => EpisodeModel.fromMap(
                Map<String, dynamic>.from(e),
                series.serverUrl,
                series.username,
                series.password,
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

class _EpisodeTile extends StatelessWidget {
  final EpisodeModel episode;
  final String seriesTitle;
  const _EpisodeTile({required this.episode, required this.seriesTitle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.player, arguments: {
        'url': episode.streamUrl,
        'title': '${seriesTitle} - الحلقة ${episode.episodeNum}',
        'type': 'series',
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.cardDark,
          border: Border.all(color: AppColors.divider),
        ),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                episode.episodeNum,
                style: const TextStyle(fontFamily: 'Cairo', color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          title: Text(
            episode.title.isNotEmpty ? episode.title : 'الحلقة ${episode.episodeNum}',
            style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 14),
          ),
          subtitle: episode.duration.isNotEmpty
              ? Text(episode.duration, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, fontSize: 12))
              : null,
          trailing: const Icon(Icons.play_circle_outline, color: AppColors.primary),
        ),
      ),
    );
  }
}
