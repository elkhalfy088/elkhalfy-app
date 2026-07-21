import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/match_model.dart';
import '../../app/routes.dart';

class MatchesController extends GetxController {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final Dio _dio = Dio();

  final RxList<MatchModel> matches = <MatchModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedDay = 'today'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMatches();
    ever(selectedDay, (_) => _loadMatches());
  }

  Future<void> _loadMatches() async {
    isLoading.value = true;
    try {
      final snapshot = await _db.ref('matches_providers').get();
      if (!snapshot.exists) {
        isLoading.value = false;
        return;
      }

      final providers = Map<dynamic, dynamic>.from(snapshot.value as Map);
      final List<MatchModel> all = [];

      for (final provider in providers.values) {
        final p = Map<String, dynamic>.from(provider as Map);
        if (p['active'] == false) continue;

        try {
          String url = p['api_url'] ?? '';
          final apiKey = p['api_key'] ?? '';
          final headers = <String, dynamic>{};
          if (apiKey.isNotEmpty) headers['X-Api-Key'] = apiKey;

          final now = DateTime.now();
          final date = selectedDay.value == 'yesterday'
              ? now.subtract(const Duration(days: 1))
              : selectedDay.value == 'tomorrow'
                  ? now.add(const Duration(days: 1))
                  : now;
          final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          url = url.replaceAll('{date}', dateStr);

          final response = await _dio.get(url, options: Options(headers: headers));
          final fieldMapping = Map<String, dynamic>.from(p['field_mapping'] ?? {});
          final dataPath = (p['data_path'] ?? 'response') as String;

          dynamic rawList = response.data;
          if (dataPath.isNotEmpty) {
            for (final key in dataPath.split('.')) {
              rawList = rawList[key];
            }
          }

          if (rawList is List) {
            for (final item in rawList) {
              all.add(MatchModel.fromDynamic(Map<String, dynamic>.from(item), fieldMapping));
            }
          }
        } catch (_) {}
      }

      matches.value = all;
    } catch (_) {}
    isLoading.value = false;
  }
}

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MatchesController());
    final controller = Get.find<MatchesController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.matches)),
      body: Column(
        children: [
          // Day selector
          Obx(() => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                _DayTab(label: AppStrings.yesterday, value: 'yesterday', controller: controller),
                _DayTab(label: AppStrings.today, value: 'today', controller: controller),
                _DayTab(label: AppStrings.tomorrow, value: 'tomorrow', controller: controller),
              ],
            ),
          )),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (controller.matches.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_soccer, size: 60, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text(AppStrings.noMatches, style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: controller._loadMatches,
                color: AppColors.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.matches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _MatchCard(match: controller.matches[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DayTab extends StatelessWidget {
  final String label;
  final String value;
  final MatchesController controller;
  const _DayTab({required this.label, required this.value, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedDay.value = value,
        child: Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: controller.selectedDay.value == value ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: controller.selectedDay.value == value ? Colors.white : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        )),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final MatchModel match;
  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.matchDetail, arguments: match),
      child: Container(
        padding: const EdgeInsets.all(16),
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
          children: [
            // League
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (match.leagueLogo.isNotEmpty)
                  CachedNetworkImage(imageUrl: match.leagueLogo, width: 20, height: 20, errorWidget: (_, __, ___) => const SizedBox.shrink()),
                const SizedBox(width: 6),
                Text(match.leagueName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                if (match.status == MatchStatus.live) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.live, borderRadius: BorderRadius.circular(4)),
                    child: const Text('مباشر', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // Teams and score
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      if (match.homeTeamLogo.isNotEmpty)
                        CachedNetworkImage(imageUrl: match.homeTeamLogo, width: 48, height: 48, errorWidget: (_, __, ___) => const Icon(Icons.sports_soccer, color: AppColors.textSecondary, size: 40))
                      else
                        const Icon(Icons.sports_soccer, color: AppColors.textSecondary, size: 48),
                      const SizedBox(height: 6),
                      Text(match.homeTeamName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
                  child: match.status == MatchStatus.upcoming
                      ? Column(children: [
                          Text(match.matchTime, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          const Text('قادمة', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary)),
                        ])
                      : Text(
                          '${match.homeScore} - ${match.awayScore}',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 24, fontWeight: FontWeight.bold, color: match.status == MatchStatus.live ? AppColors.live : Colors.white),
                        ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      if (match.awayTeamLogo.isNotEmpty)
                        CachedNetworkImage(imageUrl: match.awayTeamLogo, width: 48, height: 48, errorWidget: (_, __, ___) => const Icon(Icons.sports_soccer, color: AppColors.textSecondary, size: 40))
                      else
                        const Icon(Icons.sports_soccer, color: AppColors.textSecondary, size: 48),
                      const SizedBox(height: 6),
                      Text(match.awayTeamName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
