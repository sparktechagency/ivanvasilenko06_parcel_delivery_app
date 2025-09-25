// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:parcel_delivery_app/utils/appLog/app_log.dart';
// import 'package:parcel_delivery_app/utils/appLog/error_app_log.dart';
//
// @pragma("vm:entry-point")
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   try {
//     await AppPushNotificationService.instance.setupFlutterNotifications();
//     await AppPushNotificationService.instance.showNotification(message);
//     appLog("Background message received: ${message.messageId}");
//   } catch (e) {
//     errorLog("_firebaseMessagingBackgroundHandler", e);
//   }
// }
//
// @pragma('vm:entry-point')
// void onDidReceiveBackgroundNotificationResponse(NotificationResponse details) {
//   appLog("Background Notification Clicked: ${details.payload}");
//   AppPushNotificationService.instance.handleNotificationClick(details.payload);
// }
//
// class AppPushNotificationService {
//   AppPushNotificationService._privateConstructor();
//
//   static final AppPushNotificationService _instance =
//       AppPushNotificationService._privateConstructor();
//
//   static AppPushNotificationService get instance => _instance;
//
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotifications =
//       FlutterLocalNotificationsPlugin();
//
//   bool _isInitialized = false;
//   bool _isNotificationSetup = false;
//   String? _lastMessageId;
//
//   Future<void> initialize() async {
//     if (_isInitialized) return;
//
//     try {
//       // Setup background handler
//       FirebaseMessaging.onBackgroundMessage(
//           _firebaseMessagingBackgroundHandler);
//
//       // Request permissions
//       await _requestPermission();
//
//       // Setup notification channels
//       await _setupNotificationChannels();
//
//       // Setup message handlers
//       await _setupMessageHandlers();
//
//       // Get FCM token
//       _getFcmToken();
//
//       _isInitialized = true;
//       appLog("Push Notification Service Initialized");
//     } catch (e) {
//       errorLog("initialize", e);
//     }
//   }
//
//   Future<void> _requestPermission() async {
//     try {
//       final settings = await _messaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//         provisional: false,
//       );
//
//       if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//         appLog("Notification permission granted");
//       } else {
//         appLog(
//             "Notification permission denied: ${settings.authorizationStatus}");
//       }
//     } catch (e) {
//       errorLog("_requestPermission", e);
//     }
//   }
//
//   Future<void> _setupNotificationChannels() async {
//     try {
//       // Android channel
//       const androidChannel = AndroidNotificationChannel(
//         'high_importance_channel',
//         'High Importance Channel',
//         description: 'Rent Me Notifications',
//         importance: Importance.high,
//       );
//
//       await _localNotifications
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>()
//           ?.createNotificationChannel(androidChannel);
//
//       // iOS permissions
//       await _localNotifications
//           .resolvePlatformSpecificImplementation<
//               IOSFlutterLocalNotificationsPlugin>()
//           ?.requestPermissions(alert: true, badge: true, sound: true);
//     } catch (e) {
//       errorLog("_setupNotificationChannels", e);
//     }
//   }
//
//   Future<void> setupFlutterNotifications() async {
//     if (_isNotificationSetup) return;
//
//     try {
//       const androidSettings =
//           AndroidInitializationSettings('@mipmap/ic_launcher');
//       const darwinSettings = DarwinInitializationSettings();
//
//       const settings = InitializationSettings(
//         android: androidSettings,
//         iOS: darwinSettings,
//       );
//
//       await _localNotifications.initialize(
//         settings,
//         onDidReceiveNotificationResponse: (details) {
//           appLog("Notification Clicked: ${details.payload}");
//           handleNotificationClick(details.payload);
//         },
//         onDidReceiveBackgroundNotificationResponse:
//             onDidReceiveBackgroundNotificationResponse,
//       );
//
//       _isNotificationSetup = true;
//       appLog("Flutter notifications setup complete");
//     } catch (e) {
//       errorLog("setupFlutterNotifications", e);
//     }
//   }
//
//   Future<void> _setupMessageHandlers() async {
//     try {
//       // Foreground messages
//       FirebaseMessaging.onMessage.listen((message) {
//         appLog("Foreground message received: ${message.messageId}");
//         showNotification(message);
//       });
//
//       // When app is opened from terminated state
//       final initialMessage = await _messaging.getInitialMessage();
//       if (initialMessage != null) {
//         appLog("Initial message received: ${initialMessage.messageId}");
//         _handleMessage(initialMessage);
//       }
//
//       // When app is opened from background
//       FirebaseMessaging.onMessageOpenedApp.listen((message) {
//         appLog("App opened from background with message: ${message.messageId}");
//         _handleMessage(message);
//       });
//     } catch (e) {
//       errorLog("_setupMessageHandlers", e);
//     }
//   }
//
//   Future<void> showNotification(RemoteMessage message) async {
//     try {
//       // Prevent showing duplicate notifications
//       if (_lastMessageId == message.messageId) return;
//       _lastMessageId = message.messageId;
//
//       final notification = message.notification;
//       final android = message.notification?.android;
//       final apple = message.notification?.apple;
//
//       if (notification == null || (android == null && apple == null)) return;
//
//       await _localNotifications.show(
//         message.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: android != null
//               ? AndroidNotificationDetails(
//                   'high_importance_channel',
//                   'High Importance Channel',
//                   channelDescription: 'Rent Me',
//                   importance: Importance.high,
//                   priority: Priority.high,
//                   icon: android.smallIcon,
//                 )
//               : null,
//           iOS: apple != null
//               ? DarwinNotificationDetails(
//                   presentAlert: true,
//                   presentBadge: true,
//                   presentSound: true,
//                 )
//               : null,
//         ),
//         payload: message.data.toString(),
//       );
//
//       appLog("Notification shown: ${message.messageId}");
//     } catch (e) {
//       errorLog("showNotification", e);
//     }
//   }
//
//   void _handleMessage(RemoteMessage message) {
//     try {
//       // Handle message when app is opened from notification
//       final data = message.data;
//       if (data.isNotEmpty) {
//         appLog("Message data: $data");
//         // Add your navigation logic here based on message data
//       }
//     } catch (e) {
//       errorLog("_handleMessage", e);
//     }
//   }
//
//   void handleNotificationClick(String? payload) {
//     try {
//       if (payload != null) {
//         appLog("Handling notification click with payload: $payload");
//         // Add your navigation logic here based on payload
//       }
//     } catch (e) {
//       errorLog("handleNotificationClick", e);
//     }
//   }
//
//   Future<void> _getFcmToken() async {
//     try {
//       final token = await _messaging.getToken();
//       appLog("FCM Token: $token");
//
//       // Save this token to your server if needed
//     } catch (e) {
//       errorLog("_getFcmToken", e);
//     }
//   }
// }

/////////////Testing Perpourse
library;


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
      //! log('User granted permission: ${settings.authorizationStatus}');
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
       //!  log("An error occurred during FCM setup: $e");
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
