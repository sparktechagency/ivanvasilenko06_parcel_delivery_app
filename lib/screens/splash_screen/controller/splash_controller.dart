import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override

  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1)).then((_) async {
        // Request location permissions for both iOS and Android
        await _requestLocationPermission();
        
        // Get.offAllNamed(AppRoutes.homeScreen);
        var token =
        await SharePrefsHelper.getString(SharedPreferenceValue.token);
        debugPrint("✅✅✅✅✅ $token ❇️❇️❇️❇️❇️❇️");

        if (token.isNotEmpty) {
          Get.offAll(() => const BottomNavScreen());
        } else {
          Get.offAllNamed(AppRoutes.onboardingScreen);
        }
        // Get.offAll(() => const BottomNavScreen());
      });
    });
    super.onInit();
  }
  /// Request location permission for both iOS and Android devices
  Future<void> _requestLocationPermission() async {
    try {
      // Check current permission status using permission_handler
      PermissionStatus status = await Permission.location.status;
      debugPrint('📍 Current location permission status: $status');
      if (status.isDenied) {
        debugPrint('📍 Requesting location permission...');
        status = await Permission.location.request();
        if (status.isDenied) {
          debugPrint('🔴 Location permissions are denied');
          return;
        }
      }
      if (status.isPermanentlyDenied) {
        debugPrint('🔴 Location permissions are permanently denied');
        await _showPermissionDialog();
        return;
      }
      
      // If permission is granted, check if location services are enabled
      if (status.isGranted) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          debugPrint('🔴 Location services are disabled');
          // For iOS, we can try to open location settings
          if (Platform.isIOS) {
            await _showLocationServiceDialog();
          }
          return;
        }
        debugPrint('✅ Location permission granted and services enabled');
      }

    } catch (e) {
      debugPrint('❌ Error requesting location permission: $e');
    }
  }

  /// Show dialog for permanently denied permissions
  Future<void> _showPermissionDialog() async {
    if (Get.context != null) {
      await Get.dialog(
        CupertinoAlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs location access to provide delivery services. Please enable location permission in app settings.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Get.back(),
            ),
            CupertinoDialogAction(
              child: const Text('Settings'),
              onPressed: () async {
                Get.back();
                await openAppSettings();
              },
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  /// Show dialog for disabled location services (iOS)
  Future<void> _showLocationServiceDialog() async {
    if (Get.context != null) {
      await Get.dialog(
        CupertinoAlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'Please enable Location Services in your device settings to use this app.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Get.back(),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  @override
  void onClose() {
    super.onClose();

  }
}