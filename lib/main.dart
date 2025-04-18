import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parcel_delivery_app/firebase_options.dart';

import 'constants/dep.dart' as dep;
import 'main_app_entry.dart';
import 'screens/notification_screen/push_notification/push_notificaiton.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  if (Platform.isIOS) {
// Initialize Firebase for iOS
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAwMjGDNC1PezbO-NsSUzEEKCLCvF4PSB8",
        appId: "1:251712478840:ios:4c8b58009cee0ed26d578d",
        messagingSenderId: "251712478840",
        projectId: "push-notification-21d77",
      ),
    );
  } else {
// Initialize Firebase for Android
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
// Set up push notifications
  await NotificationService().setupFCM();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  Map<String, Map<String, String>> languages = await dep.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    // DevicePreview(
    //   enabled: !kReleaseMode,
    //   builder: (context) => MainApp(
    //     languages: languages,
    //   ), // Wrap your app
    // ),
    MainApp(
      languages: languages,
    ),
  );
}
