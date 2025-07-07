import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';
import 'package:parcel_delivery_app/services/deviceInfo/device_info.dart';
import 'package:parcel_delivery_app/utils/appLog/app_log.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

class LoginScreenController extends GetxController {
  RxBool isLoading = false.obs;
  final DeviceInfo _deviceInfo = DeviceInfo();
  TextEditingController emailController = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final RxString completePhoneNumber = ''.obs;
  TextEditingController phoneController = TextEditingController();

  void updatePhoneNumber(String phoneNumber) {
    completePhoneNumber.value = phoneNumber;
  }

  Future<void> phoneOtpLogin() async {
    try {
      log("=== PHONE OTP LOGIN DEBUG ===");
      log("Complete Phone Number: '${completePhoneNumber.value}'");
      log("Phone Controller Text: '${phoneController.text}'");

      // Check if phone number is empty
      if (completePhoneNumber.value.isEmpty) {
        AppSnackBar.error("Please enter a valid phone number");
        return;
      }

      // Validate form if it exists
      if (loginFormKey.currentState != null &&
          !loginFormKey.currentState!.validate()) {
        log("Form validation failed");
        return;
      }

      isLoading.value = true;
      isPhoneLoading.value = true;

      var fcmToken =
          await SharePrefsHelper.getString(SharedPreferenceValue.fcmToken);
      log("FCM Token: '$fcmToken'");

      // Get device info
      String deviceId = await _deviceInfo.getDeviceId();
      String deviceType = await _deviceInfo.getDeviceType();

      if (deviceId == 'unknown' || deviceType == 'unknown') {
        deviceId = await _deviceInfo.getDeviceId();
        deviceType = await _deviceInfo.getDeviceType();
      }

      log("Device ID: '$deviceId'");
      log("Device Type: '$deviceType'");

      // Ensure no null values are passed
      Map<String, String> body = {
        "mobileNumber": completePhoneNumber.value,
        "fcmToken": fcmToken.toString(),
        "deviceId": deviceId,
        "deviceType": deviceType,
      };

      log("API Request Body: $body");
      log("API URL: ${AppApiUrl.phoneOtpLogin}");

      var data = await ApiPostServices().apiPostServices(
        url: AppApiUrl.phoneOtpLogin,
        body: body,
        statusCode: 200,
      );

      log("API Response Data: $data");

      if (data != null) {
        log("API call successful, navigating to verify screen");
        Get.toNamed(
          AppRoutes.verifyPhoneScreen,
          arguments: {
            "phoneNumber": completePhoneNumber.value,
            "mobileNumber": completePhoneNumber.value,
            "fcmToken": fcmToken.toString(),
            "deviceId": deviceId,
            "deviceType": deviceType,
            "screen": "login",
          },
        );
      } else {
        log("API returned null data");
        AppSnackBar.error("Failed to send OTP. Please try again.");
      }

      debugPrint("✳️✳️✳️✳️✳️✳️✳️✳️✳️✳️ $fcmToken");
      debugPrint("📱📱📱 DeviceId: $deviceId, DeviceType: $deviceType");
    } catch (e) {
      log("Error from phone OTP login: $e");
      AppSnackBar.error("An error occurred: ${e.toString()}");
    } finally {
      isLoading.value = false;
      isPhoneLoading.value = false;
    }
  }

  var isPhoneLoading = false.obs;

  var isGoogleLoading = false.obs;

  Future<void> googleSignIn() async {
    try {
      isGoogleLoading(true);
      final GoogleSignIn googleSignIn = GoogleSignIn();

      await googleSignIn.signOut();
      await Future.delayed(const Duration(milliseconds: 500));

      appLog("🔄 Starting Google Sign-In process...");

      final GoogleSignInAccount? acc = await googleSignIn.signIn();

      if (acc == null) {
        appLog("Google Sign-In cancelled by user");
        AppSnackBar.error("Sign-in cancelled");
        return;
      }

      final GoogleSignInAuthentication auth = await acc.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        appLog("❌ Failed to get ID token");
        AppSnackBar.error("Failed to get authentication token");
        return;
      }

      var fcmToken =
          await SharePrefsHelper.getString(SharedPreferenceValue.fcmToken);

      Map<String, dynamic> body = {
        "idToken": idToken,
        "fcmToken": fcmToken.toString(),
      };

      appLog("Google Auth API Request Body: $body");

      // TEMPORARY FIX: Try both status codes
      var data = await ApiPostServices().apiPostServices(
        url: AppApiUrl.googleAuth,
        body: body,
        statusCode: 200, // ← Try 200 first
      );


      appLog("Google Auth API Response: $data");

      if (data != null) {
        if (data["status"] == "success" && data["data"] != null) {
          String? token = data["data"]["token"]?.toString();

          if (token != null && token.isNotEmpty) {
            await SharePrefsHelper.setString(
                SharedPreferenceValue.token, token);

            String savedToken =
                await SharePrefsHelper.getString(SharedPreferenceValue.token);
            appLog(
                "✅ Token saved successfully: ${savedToken.substring(0, 50)}...");

            AppSnackBar.success(data["message"] ?? "Login successful");
            Get.offAll(() => const BottomNavScreen());
          } else {
            appLog("❌ Empty or null token received");
            AppSnackBar.error("Authentication failed: Invalid token");
          }
        } else {
          appLog("❌ Invalid response structure: $data");
          AppSnackBar.error(data["message"] ?? "Authentication failed");
        }
      } else {
        appLog(
            "❌ API returned null data - Check your ApiPostServices implementation");
        AppSnackBar.error("Authentication failed: Server error");
      }
    } catch (e) {
      appLog("❌ Error in Google Sign-In: $e");
      AppSnackBar.error("Sign-in failed: ${e.toString()}");
    } finally {
      isGoogleLoading(false);
    }
  }
}
