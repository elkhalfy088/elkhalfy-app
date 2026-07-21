import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import '../constants/app_strings.dart';
import 'storage_service.dart';
import '../../app/routes.dart';

class AppConfig {
  final bool maintenanceMode;
  final String maintenanceMessage;
  final bool activationEnabled;
  final String activationButtonUrl;
  final bool activationButtonVisible;
  final String welcomeMessage;
  final bool welcomeMessageEnabled;
  final String telegramLink;
  final bool telegramBannerVisible;
  final String requiredVersion;
  final String updateUrl;
  final String updateDescription;
  final List<String> blockedPackages;
  final List<String> blockedCountries;
  final Map<String, dynamic> adsConfig;
  final Map<String, dynamic> supportConfig;
  final String privacyPolicy;

  AppConfig({
    this.maintenanceMode = false,
    this.maintenanceMessage = AppStrings.maintenanceDefault,
    this.activationEnabled = false,
    this.activationButtonUrl = '',
    this.activationButtonVisible = true,
    this.welcomeMessage = '',
    this.welcomeMessageEnabled = false,
    this.telegramLink = '',
    this.telegramBannerVisible = false,
    this.requiredVersion = '1.0.0',
    this.updateUrl = '',
    this.updateDescription = '',
    this.blockedPackages = const [],
    this.blockedCountries = const [],
    this.adsConfig = const {},
    this.supportConfig = const {},
    this.privacyPolicy = '',
  });

  factory AppConfig.fromMap(Map<dynamic, dynamic> map) {
    return AppConfig(
      maintenanceMode: map['maintenance_mode'] ?? false,
      maintenanceMessage: map['maintenance_message'] ?? AppStrings.maintenanceDefault,
      activationEnabled: map['activation_enabled'] ?? false,
      activationButtonUrl: map['activation_button_url'] ?? '',
      activationButtonVisible: map['activation_button_visible'] ?? true,
      welcomeMessage: map['welcome_message'] ?? '',
      welcomeMessageEnabled: map['welcome_message_enabled'] ?? false,
      telegramLink: map['telegram_link'] ?? '',
      telegramBannerVisible: map['telegram_banner_visible'] ?? false,
      requiredVersion: map['required_version'] ?? '1.0.0',
      updateUrl: map['update_url'] ?? '',
      updateDescription: map['update_description'] ?? '',
      blockedPackages: List<String>.from(map['blocked_packages'] ?? []),
      blockedCountries: List<String>.from(map['blocked_countries'] ?? []),
      adsConfig: Map<String, dynamic>.from(map['ads_config'] ?? {}),
      supportConfig: Map<String, dynamic>.from(map['support_config'] ?? {}),
      privacyPolicy: map['privacy_policy'] ?? '',
    );
  }
}

class FirebaseService extends GetxService {
  final FirebaseDatabase db = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rx<AppConfig> appConfig = AppConfig().obs;
  final RxBool isLoading = true.obs;
  final RxString deviceId = ''.obs;
  final RxBool isDeviceBlocked = false.obs;

  Future<FirebaseService> init() async {
    await _initDeviceId();
    await _loadAppConfig();
    _listenToConfig();
    _registerDevice();
    return this;
  }

  Future<void> _initDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String id = StorageService.getString('device_id') ?? '';

    if (id.isEmpty) {
      try {
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          id = androidInfo.id;
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          id = iosInfo.identifierForVendor ?? '';
        } else {
          id = DateTime.now().millisecondsSinceEpoch.toString();
        }
      } catch (_) {
        id = DateTime.now().millisecondsSinceEpoch.toString();
      }
      await StorageService.setString('device_id', id);
    }

    deviceId.value = id;
  }

  Future<void> _loadAppConfig() async {
    try {
      final snapshot = await db.ref('app_config').get();
      if (snapshot.exists && snapshot.value != null) {
        appConfig.value = AppConfig.fromMap(
          Map<dynamic, dynamic>.from(snapshot.value as Map),
        );
      }
    } catch (e) {
      // Use defaults
    } finally {
      isLoading.value = false;
    }
  }

  void _listenToConfig() {
    db.ref('app_config').onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        appConfig.value = AppConfig.fromMap(
          Map<dynamic, dynamic>.from(event.snapshot.value as Map),
        );
        _checkMaintenanceAndBlocks();
      }
    });
  }

  void _checkMaintenanceAndBlocks() {
    if (appConfig.value.maintenanceMode) {
      Get.offAllNamed(AppRoutes.maintenance);
    }
  }

  Future<void> _registerDevice() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      Map<String, dynamic> deviceData = {
        'device_id': deviceId.value,
        'app_version': packageInfo.version,
        'last_seen': ServerValue.timestamp,
        'platform': Platform.operatingSystem,
      };

      try {
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceData['device_model'] = '${androidInfo.manufacturer} ${androidInfo.model}';
          deviceData['os_version'] = 'Android ${androidInfo.version.release}';
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceData['device_model'] = iosInfo.model;
          deviceData['os_version'] = 'iOS ${iosInfo.systemVersion}';
        }
      } catch (_) {}

      await db.ref('devices/${deviceId.value}').update(deviceData);

      // Check device block status
      db.ref('devices/${deviceId.value}/blocked').onValue.listen((event) {
        final blocked = event.snapshot.value as bool? ?? false;
        isDeviceBlocked.value = blocked;
        if (blocked) {
          exit(0);
        }
      });
    } catch (e) {
      // Continue silently
    }
  }

  /// Verify an activation code against Firebase
  Future<Map<String, dynamic>?> verifyActivationCode(String code) async {
    try {
      final snapshot = await db.ref('activation_codes/$code').get();
      if (!snapshot.exists) return null;

      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

      // Check expiry
      if (data['expiry'] != null) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(data['expiry'] as int);
        if (expiry.isBefore(DateTime.now())) {
          return {'error': 'expired'};
        }
      }

      // Check device limit
      final int deviceLimit = data['device_limit'] ?? 1;
      final List devices = data['devices'] ?? [];

      if (!devices.contains(deviceId.value) && devices.length >= deviceLimit) {
        return {'error': 'device_limit'};
      }

      // Register device with code
      if (!devices.contains(deviceId.value)) {
        await db.ref('activation_codes/$code/devices').set([...devices, deviceId.value]);
      }

      return Map<String, dynamic>.from(data);
    } catch (e) {
      return null;
    }
  }

  /// Check if an app update is required
  Future<bool> checkRequiredUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final requiredVersion = appConfig.value.requiredVersion;
      return _compareVersions(currentVersion, requiredVersion) < 0;
    } catch (e) {
      return false;
    }
  }

  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();
    for (int i = 0; i < 3; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 < p2) return -1;
      if (p1 > p2) return 1;
    }
    return 0;
  }

  /// Get IPTV sources from Firebase
  Future<List<Map<String, dynamic>>> getIPTVSources() async {
    try {
      final snapshot = await db.ref('iptv_sources').get();
      if (!snapshot.exists) return [];

      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
      final list = data.values
          .map((v) => Map<String, dynamic>.from(v as Map))
          .where((s) => s['visible'] != false)
          .toList()
        ..sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));
      return list;
    } catch (e) {
      return [];
    }
  }

  /// Get promotional banners
  Future<List<Map<String, dynamic>>> getBanners() async {
    try {
      final snapshot = await db.ref('banners').get();
      if (!snapshot.exists) return [];

      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
      return data.values
          .map((v) => Map<String, dynamic>.from(v as Map))
          .where((b) => b['active'] != false)
          .toList();
    } catch (e) {
      return [];
    }
  }
}
