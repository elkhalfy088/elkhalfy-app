import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';
  bool _notificationsEnabled = StorageService.notificationsEnabled;
  bool _autoPlay = StorageService.autoPlay;
  String _selectedQuality = StorageService.videoQuality;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _appVersion = info.version);
  }

  @override
  Widget build(BuildContext context) {
    final config = Get.find<FirebaseService>().appConfig.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App section
          _SectionHeader('التطبيق'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: AppStrings.notificationsSettings,
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (v) async {
                await StorageService.setNotifications(v);
                setState(() => _notificationsEnabled = v);
              },
              activeColor: AppColors.primary,
            ),
          ),
          _SettingsTile(
            icon: Icons.play_circle_outline,
            title: AppStrings.autoPlay,
            trailing: Switch(
              value: _autoPlay,
              onChanged: (v) async {
                await StorageService.setAutoPlay(v);
                setState(() => _autoPlay = v);
              },
              activeColor: AppColors.primary,
            ),
          ),
          _SettingsTile(
            icon: Icons.hd,
            title: AppStrings.videoQuality,
            subtitle: _selectedQuality,
            onTap: () => _showQualityPicker(),
          ),
          _SettingsTile(
            icon: Icons.cleaning_services_outlined,
            title: AppStrings.clearCache,
            onTap: () => _showClearCacheDialog(),
          ),

          const SizedBox(height: 16),
          _SectionHeader('الدعم'),

          // Contact support
          if (config.supportConfig.isNotEmpty) ...[
            if (config.supportConfig['whatsapp'] != null)
              _SettingsTile(
                icon: Icons.chat,
                title: 'واتساب',
                subtitle: 'تواصل معنا عبر واتساب',
                onTap: () => _launchUrl('https://wa.me/${config.supportConfig['whatsapp']}'),
              ),
            if (config.supportConfig['telegram'] != null)
              _SettingsTile(
                icon: Icons.telegram,
                title: 'تيليجرام',
                subtitle: 'تواصل معنا عبر تيليجرام',
                onTap: () => _launchUrl(config.supportConfig['telegram']),
              ),
            if (config.supportConfig['email'] != null)
              _SettingsTile(
                icon: Icons.email_outlined,
                title: 'البريد الإلكتروني',
                subtitle: config.supportConfig['email'],
                onTap: () => _launchUrl('mailto:${config.supportConfig['email']}'),
              ),
          ],

          const SizedBox(height: 16),
          _SectionHeader('معلومات'),

          if (config.privacyPolicy.isNotEmpty)
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: AppStrings.privacyPolicy,
              onTap: () => _showPrivacyPolicy(config.privacyPolicy),
            ),

          if (config.activationButtonVisible && config.activationButtonUrl.isNotEmpty)
            _SettingsTile(
              icon: Icons.vpn_key_outlined,
              title: AppStrings.getActivationCode,
              onTap: () => _launchUrl(config.activationButtonUrl),
            ),

          _SettingsTile(
            icon: Icons.info_outline,
            title: AppStrings.appInfo,
            subtitle: 'Elkhalfy v$_appVersion',
          ),
        ],
      ),
    );
  }

  void _showQualityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('جودة الفيديو', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          ...['auto', '1080p', '720p', '480p', '360p'].map((q) => ListTile(
            title: Text(q == 'auto' ? 'تلقائي' : q, style: const TextStyle(fontFamily: 'Cairo', color: Colors.white)),
            trailing: _selectedQuality == q ? const Icon(Icons.check, color: AppColors.primary) : null,
            onTap: () async {
              await StorageService.setVideoQuality(q);
              setState(() => _selectedQuality = q);
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('مسح ذاكرة التخزين', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
        content: const Text('هل تريد مسح ذاكرة التخزين المؤقت؟', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              // Clear cache logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم مسح ذاكرة التخزين', style: TextStyle(fontFamily: 'Cairo'))));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('تأكيد', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(String text) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppStrings.privacyPolicy, style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Expanded(child: SingleChildScrollView(child: Text(text, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, height: 1.8)))),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 14)),
        subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, fontSize: 12)) : null,
        trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 14) : null),
        onTap: onTap,
      ),
    );
  }
}
