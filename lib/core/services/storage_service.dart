import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // String operations
  static String? getString(String key) => _prefs.getString(key);
  static Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  // Bool operations
  static bool? getBool(String key) => _prefs.getBool(key);
  static Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  // Int operations
  static int? getInt(String key) => _prefs.getInt(key);
  static Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  // Remove key
  static Future<bool> remove(String key) => _prefs.remove(key);

  // Clear all
  static Future<bool> clear() => _prefs.clear();

  // Check if key exists
  static bool containsKey(String key) => _prefs.containsKey(key);

  // Activation status
  static bool get isActivated => getBool('is_activated') ?? false;
  static Future<void> setActivated(bool value) => setBool('is_activated', value);

  static String get activationCode => getString('activation_code') ?? '';
  static Future<void> setActivationCode(String code) => setString('activation_code', code);

  // Language
  static String get language => getString('language') ?? 'ar';
  static Future<void> setLanguage(String lang) => setString('language', lang);

  // Video quality
  static String get videoQuality => getString('video_quality') ?? 'auto';
  static Future<void> setVideoQuality(String quality) => setString('video_quality', quality);

  // Auto play
  static bool get autoPlay => getBool('auto_play') ?? true;
  static Future<void> setAutoPlay(bool value) => setBool('auto_play', value);

  // Notifications
  static bool get notificationsEnabled => getBool('notifications_enabled') ?? true;
  static Future<void> setNotifications(bool value) => setBool('notifications_enabled', value);

  // First launch
  static bool get isFirstLaunch => getBool('is_first_launch') ?? true;
  static Future<void> setFirstLaunch(bool value) => setBool('is_first_launch', value);

  // Welcome message shown
  static bool get welcomeShown => getBool('welcome_shown') ?? false;
  static Future<void> setWelcomeShown(bool value) => setBool('welcome_shown', value);
}
