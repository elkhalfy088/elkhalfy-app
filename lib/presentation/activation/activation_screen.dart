import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/storage_service.dart';
import '../../app/routes.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _errorMessage.value = 'يرجى إدخال كود التفعيل';
      return;
    }

    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final firebaseService = Get.find<FirebaseService>();
      final result = await firebaseService.verifyActivationCode(code);

      if (result == null) {
        _errorMessage.value = AppStrings.invalidCode;
      } else if (result['error'] == 'expired') {
        _errorMessage.value = AppStrings.codeExpired;
      } else if (result['error'] == 'device_limit') {
        _errorMessage.value = AppStrings.deviceLimitReached;
      } else {
        await StorageService.setActivated(true);
        await StorageService.setActivationCode(code);
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      _errorMessage.value = AppStrings.unknownError;
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = Get.find<FirebaseService>().appConfig.value;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050E1F), Color(0xFF0D1B3E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF3A1B8C), Color(0xFF1565C0)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Elkhalfy',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.activationCode,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 48),

                // Code input
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppColors.cardDark, AppColors.cardLight],
                    ),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: TextField(
                    controller: _codeController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                    decoration: InputDecoration(
                      hintText: AppStrings.activationCodeHint,
                      hintStyle: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white.withOpacity(0.3),
                        letterSpacing: 3,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                    onSubmitted: (_) => _activate(),
                  ),
                ),
                const SizedBox(height: 16),

                // Error message
                Obx(() => _errorMessage.value.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.error.withOpacity(0.4)),
                        ),
                        child: Text(
                          _errorMessage.value,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.error,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink()),

                const SizedBox(height: 24),

                // Activate button
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading.value ? null : _activate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            AppStrings.activate,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                )),

                if (config.activationButtonVisible && config.activationButtonUrl.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // Launch URL
                    },
                    child: Text(
                      AppStrings.getActivationCode,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.accentLight,
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.accentLight,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
