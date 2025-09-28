import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parcel_delivery_app/firebase_options.dart';
import 'constants/dep.dart' as dep;
import 'main_app_entry.dart';
import 'screens/notification_screen/push_notification/push_notificaiton.dart';
import 'services/location_permission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  if (Platform.isIOS) {
// Initialize Firebase for iOS
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAynUpzfxt4zu2CTffqqzzkjrmiBv_vKCo',
        appId: '1:1091523135632:ios:87eaf0fa4915a1c223f015',
        messagingSenderId: '1091523135632',
        projectId: 'deliverly-app-aadfd',
        storageBucket: 'deliverly-app-aadfd.firebasestorage.app',
        iosBundleId: 'com.ivan.delivery',
      ),
    );
  } else {
// Initialize Firebase for Android
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  //Position? position = await LocationPermissionService.instance.getCurrentPosition();
// Set up push notifications just added a commnet
  await NotificationService().setupFCM();
  
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  Map<String, Map<String, String>> languages = await dep.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MainApp(
      languages: languages,
    ),
  );
}
