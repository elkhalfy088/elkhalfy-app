import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.downloads)),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_done_outlined, size: 80, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(AppStrings.noDownloads, style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, fontSize: 16)),
            SizedBox(height: 8),
            Text(
              'يمكنك تحميل الأفلام والمسلسلات\nومشاهدتها بدون إنترنت',
              style: TextStyle(fontFamily: 'Cairo', color: AppColors.textHint, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
