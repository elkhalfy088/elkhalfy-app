import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class PlayerController extends GetxController {
  late final Player player;
  late final VideoController videoController;

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxBool isFullscreen = false.obs;
  final RxString errorMessage = ''.obs;

  late String streamUrl;
  late String title;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    streamUrl = args?['url'] ?? '';
    title = args?['title'] ?? '';

    player = Player();
    videoController = VideoController(player);

    player.stream.error.listen((error) {
      hasError.value = true;
      isLoading.value = false;
      errorMessage.value = AppStrings.playerError;
    });

    player.stream.buffering.listen((buffering) {
      isLoading.value = buffering;
    });

    _startPlayback();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _startPlayback() async {
    try {
      await player.open(Media(streamUrl));
    } catch (e) {
      hasError.value = true;
      errorMessage.value = AppStrings.playerError;
    }
  }

  Future<void> retry() async {
    hasError.value = false;
    isLoading.value = true;
    await _startPlayback();
  }

  @override
  void onClose() {
    player.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.onClose();
  }
}

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PlayerController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video player
          Center(
            child: Video(controller: controller.videoController),
          ),

          // Loading indicator
          Obx(() => controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : const SizedBox.shrink()),

          // Error state
          Obx(() => controller.hasError.value
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value,
                        style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: controller.retry,
                        icon: const Icon(Icons.refresh),
                        label: const Text(AppStrings.retry, style: TextStyle(fontFamily: 'Cairo')),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink()),

          // Top controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
