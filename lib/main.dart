import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:media_kit/media_kit.dart';

import 'app/app.dart';
import 'core/services/storage_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize MediaKit for video playback
  MediaKit.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D1B3E),
    ),
  );

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCveqPkBHOTFQLg9MDF3RK1EIN66xqBWrM',
      authDomain: 'elkhalfy-324b9.firebaseapp.com',
      databaseURL: 'https://elkhalfy-324b9-default-rtdb.firebaseio.com',
      projectId: 'elkhalfy-324b9',
      storageBucket: 'elkhalfy-324b9.firebasestorage.app',
      messagingSenderId: '1040857118437',
      appId: '1:1040857118437:web:97c7108303b157f70d860c',
      measurementId: 'G-31HHZM3VJ5',
    ),
  );

  // Initialize Services
  await StorageService.init();
  await Get.putAsync(() => FirebaseService().init());
  await Get.putAsync(() => NotificationService().init());

  runApp(const ElkhalfyApp());
}
