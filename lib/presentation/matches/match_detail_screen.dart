import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/match_model.dart';

class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MatchModel match = Get.arguments as MatchModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('${match.homeTeamName} vs ${match.awayTeamName}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(colors: [AppColors.cardDark, AppColors.cardLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Text(match.leagueName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _TeamBlock(name: match.homeTeamName, logo: match.homeTeamLogo),
                      Column(
                        children: [
                          if (match.status != MatchStatus.upcoming)
                            Text('${match.homeScore} - ${match.awayScore}',
                                style: TextStyle(fontFamily: 'Cairo', fontSize: 32, fontWeight: FontWeight.bold, color: match.status == MatchStatus.live ? AppColors.live : Colors.white)),
                          if (match.status == MatchStatus.live)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: AppColors.live, borderRadius: BorderRadius.circular(4)),
                              child: const Text('مباشر', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          if (match.status == MatchStatus.upcoming)
                            Column(children: [
                              Text(match.matchTime, style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                              const Text('قادمة', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                            ]),
                        ],
                      ),
                      _TeamBlock(name: match.awayTeamName, logo: match.awayTeamLogo),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Goals
            if (match.goals.isNotEmpty) ...[
              _SectionTitle('الأهداف'),
              ...match.goals.map((g) => _EventTile(
                icon: Icons.sports_soccer,
                color: AppColors.success,
                title: g.playerName,
                subtitle: 'الدقيقة ${g.minute}',
                isHome: g.team == 'home',
              )),
              const SizedBox(height: 16),
            ],

            // Cards
            if (match.cards.isNotEmpty) ...[
              _SectionTitle('البطاقات'),
              ...match.cards.map((c) => _EventTile(
                icon: Icons.rectangle,
                color: c.type == 'red' ? AppColors.error : Colors.amber,
                title: c.playerName,
                subtitle: 'الدقيقة ${c.minute}',
                isHome: c.team == 'home',
              )),
              const SizedBox(height: 16),
            ],

            // Stats
            if (match.stats != null) ...[
              _SectionTitle('إحصائيات المباراة'),
              _StatBar('الاستحواذ', match.stats!.homePossession, match.stats!.awayPossession),
              _StatBar('التسديدات', match.stats!.homeShots, match.stats!.awayShots),
              _StatBar('على المرمى', match.stats!.homeShotsOnTarget, match.stats!.awayShotsOnTarget),
              _StatBar('الأركان', match.stats!.homeCorners, match.stats!.awayCorners),
              _StatBar('الأخطاء', match.stats!.homeFouls, match.stats!.awayFouls),
            ],
          ],
        ),
      ),
    );
  }
}

class _TeamBlock extends StatelessWidget {
  final String name;
  final String logo;
  const _TeamBlock({required this.name, required this.logo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (logo.isNotEmpty)
          CachedNetworkImage(imageUrl: logo, width: 60, height: 60, errorWidget: (_, __, ___) => const Icon(Icons.sports_soccer, size: 50, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        SizedBox(width: 100, child: Text(name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center, maxLines: 2)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isHome;
  const _EventTile({required this.icon, required this.color, required this.title, required this.subtitle, required this.isHome});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)),
      child: Row(
        children: isHome
            ? [Icon(icon, color: color, size: 18), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 13)), Text(subtitle, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, fontSize: 11))]), const Spacer()]
            : [const Spacer(), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(title, style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 13)), Text(subtitle, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, fontSize: 11))]), const SizedBox(width: 10), Icon(icon, color: color, size: 18)],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final String home;
  final String away;
  const _StatBar(this.label, this.home, this.away);

  @override
  Widget build(BuildContext context) {
    final hVal = double.tryParse(home.replaceAll('%', '')) ?? 0;
    final aVal = double.tryParse(away.replaceAll('%', '')) ?? 0;
    final total = hVal + aVal;
    final hRatio = total == 0 ? 0.5 : hVal / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(home, style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, fontSize: 12)),
            Text(away, style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Expanded(flex: (hRatio * 100).round(), child: Container(height: 6, color: AppColors.primary)),
                Expanded(flex: ((1 - hRatio) * 100).round(), child: Container(height: 6, color: AppColors.accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
