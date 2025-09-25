
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';

@pragma('vm:entry-point')
class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> setupFCM() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      // Request permission for notifications (iOS specific)
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        carPlay: false,
        provisional: false,
        criticalAlert: false,
      );
      //! 'User granted permission: ${settings.authorizationStatus}');
      // Get the token for the device
      String? token = await _firebaseMessaging.getToken();
      //! log('🛑🛑🛑🛑🛑🛑🛑🛑🛑🛑🛑🛑🛑 Device Token: $token');
      await SharePrefsHelper.setString(SharedPreferenceValue.fcmToken, token);
      String savedToken =
          await SharePrefsHelper.getString(SharedPreferenceValue.fcmToken);
      //! log("Saved FCM Token: $savedToken");
          // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleForegroundMessage(message);
      });
      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      // Handle notification when app is opened from a terminated state
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationNavigation(initialMessage);
      }
      // Handle when the app is resumed from the background via notification tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationNavigation(message);
      });
    } catch (e) {
      //! log("An error occurred during FCM setup: $e");
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    //! log('Received message in foreground: ${message.notification?.title}, ${message.notification?.body}');
    Get.snackbar(message.notification?.title ?? 'Notification',
        message.notification?.body ?? 'You have a new message.',
        backgroundColor: AppColors.black, colorText: Colors.white, onTap: (x) {
      Get.toNamed(
        AppRoutes.notificationScreen,
        arguments: {'tabIndex': 1},
      );
    });

    // Add navigation logic here if needed
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // Initialize Firebase in the background
    await Firebase.initializeApp();

    Get.toNamed(AppRoutes.notificationScreen);

    //! log('Handling a background message: ${message.messageId}');
    // Additional background handling logic can be added here
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    Get.toNamed(
      AppRoutes.notificationScreen,
      arguments: {'tabIndex': 0},
    );

    //! log('Navigating to notification screen due to message: ${message.notification?.title}');
    // Implement your navigation logic here
    // Example: Get.toNamed(AppRoute.notification);
  }
}
