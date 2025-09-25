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
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      var status = await Permission.location.request();

      if (!serviceEnabled) {
        debugPrint('🔴 Location services are disabled on iOS device');
        // You can show a dialog to user to enable location services
        return;
      }
      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('🔴 Location permissions are denied on iOS device');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        debugPrint('🔴 Location permissions are permanently denied on iOS device');
        // You can show a dialog to guide user to app settings
        return;
      }
      // Permission granted
      debugPrint('✅ Location permission granted on iOS device');

    } catch (e) {
      debugPrint('❌ Error requesting location permission on iOS: $e');
    }
  }

  @override
  void onClose() {
    super.onClose();

  }
}