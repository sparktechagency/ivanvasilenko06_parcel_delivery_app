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
        // Check if device is iOS and request location services
        if (Platform.isIOS) {
          await _requestLocationPermissionForIOS();
        }
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
  /// Request location permission specifically for iOS devices
  Future<void> _requestLocationPermissionForIOS() async {
    try {
      // Check current permission status using permission_handler
      PermissionStatus status = await Permission.location.status;
      
      // If permission is denied, request it
      if (status.isDenied) {
        status = await Permission.location.request();
        if (status.isDenied) {
          debugPrint('🔴 Location permissions are denied on iOS device');
          return;
        }
      }
      
      // If permission is permanently denied, guide user to settings
      if (status.isPermanentlyDenied) {
        debugPrint('🔴 Location permissions are permanently denied on iOS device');
        // You can show a dialog to guide user to app settings
        await openAppSettings();
        return;
      }
      
      // If permission is granted, check if location services are enabled
      if (status.isGranted) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          debugPrint('🔴 Location services are disabled on iOS device');
          // You can show a dialog to user to enable location services
          return;
        }
        
        debugPrint('✅ Location permission granted and services enabled on iOS device');
      }

    } catch (e) {
      debugPrint('❌ Error requesting location permission on iOS: $e');
    }
  }

  @override
  void onClose() {
    super.onClose();

  }
}