
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';
import 'package:parcel_delivery_app/services/deviceInfo/device_info.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';
import 'dart:io' show Platform;

class LoginScreenController extends GetxController {
  RxBool isLoading = false.obs;
  final DeviceInfo _deviceInfo = DeviceInfo();
  TextEditingController emailController = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final RxString completePhoneNumber = ''.obs;
  TextEditingController phoneController = TextEditingController();
  TextEditingController googleSignInPhoneController = TextEditingController();

  void updatePhoneNumber(String phoneNumber) {
    completePhoneNumber.value = phoneNumber;
  }

  Future<void> phoneOtpLogin() async {
    try {
      //! log("=== PHONE OTP LOGIN DEBUG ===");
      //! log("Complete Phone Number: '${completePhoneNumber.value}'");
      //! log("Phone Controller Text: '${phoneController.text}'");

      //! Check if phone number is empty
      if (completePhoneNumber.value.isEmpty) {
        AppSnackBar.error("Please enter a valid phone number");
        return;
      }

      //! Validate form if it exists
      if (loginFormKey.currentState != null &&
          !loginFormKey.currentState!.validate()) {
        //! log("Form validation failed");
        return;
      }

      isLoading.value = true;
      isPhoneLoading.value = true;

      var fcmToken =
          await SharePrefsHelper.getString(SharedPreferenceValue.fcmToken);
      //! log("FCM Token: '$fcmToken'");

      // Get device info
      String deviceId = await _deviceInfo.getDeviceId();
      String deviceType = await _deviceInfo.getDeviceType();

      if (deviceId == 'unknown' || deviceType == 'unknown') {
        deviceId = await _deviceInfo.getDeviceId();
        deviceType = await _deviceInfo.getDeviceType();
      }

      //! log("Device ID: '$deviceId'");
      //! log("Device Type: '$deviceType'");

      // Ensure no null values are passed
      Map<String, String> body = {
        "mobileNumber": completePhoneNumber.value,
        "fcmToken": fcmToken.toString(),
        "deviceId": deviceId,
        "deviceType": deviceType,
      };

      //! log("API Request Body: $body");
      //! log("API URL: ${AppApiUrl.phoneOtpLogin}");

      var data = await ApiPostServices().apiPostServices(
        url: AppApiUrl.phoneOtpLogin,
        body: body,
        statusCode: 200,
      );

      //! log("API Response Data: $data");

      if (data != null) {
       //!  log("API call successful, navigating to verify screen");
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
        //! log("API returned null data");
      }

      debugPrint("✳️✳️✳️✳️✳️✳️✳️✳️✳️✳️ $fcmToken");
      debugPrint("📱📱📱 DeviceId: $deviceId, DeviceType: $deviceType");
    } catch (e) {
     //!  log("Error from phone OTP login: $e");
      //AppSnackBar.error("An error occurred: ${e.toString()}");
      // AppSnackBar.success(
      //     "Please, Complete the sign-up process before Logging in.");
    } finally {
      isLoading.value = false;
      isPhoneLoading.value = false;
    }
  }

  var isPhoneLoading = false.obs;

  var isGoogleLoading = false.obs;
//! Login with Google
  Future<void> googleSignIn() async {
    try {
      isGoogleLoading(true);
      GoogleSignIn googleSignIn;
      if (Platform.isIOS) {
        googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
          // Add iOS-specific configuration
          clientId: '10243427761-cp6rebbhe0a0ugomqabd4n1jtv4qo0ro.apps.googleusercontent.com',
        );
      } else {
        googleSignIn = GoogleSignIn();
      }
      // Ensure clean state before starting
      try {
        await googleSignIn.signOut();
      } catch (e) {
        debugPrint("Sign out error (ignored): $e");
      }
      
      await Future.delayed(const Duration(milliseconds: 500));

      //! appLog("🔄 Starting Google Sign-In process...");

      final GoogleSignInAccount? acc = await googleSignIn.signIn();

      if (acc == null) {
        //! appLog("Google Sign-In cancelled by user");
        AppSnackBar.error("Sign-in cancelled");
        return;
      }
      if (acc.email.isEmpty) {
        AppSnackBar.error("Failed to get user email");
        return;
      }

      final GoogleSignInAuthentication auth = await acc.authentication;
      final String? idToken = auth.idToken;
      
      if (idToken == null || idToken.isEmpty) {
        //! appLog("❌ Failed to get ID token");
        AppSnackBar.error("Failed to get authentication token");
        return;
      }

      var fcmToken =
          await SharePrefsHelper.getString(SharedPreferenceValue.fcmToken);

      Map<String, dynamic> body = {
        "idToken": idToken,
        "fcmToken": fcmToken.toString(),
        "mobileNumber": completePhoneNumber.value,
        // "email": acc.email, 
        // "displayName": acc.displayName ?? "", // Add display name with null safety
      };

      //! appLog("Google Auth API Request Body: $body");

      // Retry logic with support for both 200 and 201 status codes
      var data = await _retryApiCall(body, maxRetries: 3);

      //! appLog("Google Auth API Response: $data");

      if (data != null) {
        if (data["status"] == "success" && data["data"] != null) {
          String? token = data["data"]["token"]?.toString();

          if (token != null && token.isNotEmpty) {
            await SharePrefsHelper.setString(
                SharedPreferenceValue.token, token);

            //! appLog("✅ Token saved successfully: ${savedToken.substring(0, 50)}...");

            AppSnackBar.success(data["message"] ?? "Login successful");
            Get.offAll(() => const BottomNavScreen());
          } else {
            //! appLog("❌ Empty or null token received");
            AppSnackBar.error("Authentication failed: Invalid token");
          }
        } else {
          //! appLog("❌ Invalid response structure: $data");
          AppSnackBar.error(data["message"] ?? "Authentication failed");
        }
      } else {
        //! appLog("❌ All retry attempts failed");
        AppSnackBar.error(
            "Server is temporarily unavailable. Please try again later.");
      }
    } on PlatformException catch (e) {
      // Handle iOS-specific platform exceptions
      debugPrint("Platform Exception: ${e.code} - ${e.message}");
      if (e.code == 'sign_in_canceled') {
        AppSnackBar.error("Sign-in was cancelled");
      } else if (e.code == 'network_error') {
        AppSnackBar.error("Network error. Please check your connection.");
      } else if (e.code == 'sign_in_failed') {
        AppSnackBar.error("Sign-in failed. Please try again.");
      } else {
        AppSnackBar.error("Authentication error: ${e.message ?? 'Unknown error'}");
      }
    } catch (e) {
      //! appLog("❌ Error in Google Sign-In: $e");
      debugPrint("Google Sign-In Error: $e");
      
      // Provide more specific error messages for iOS
      if (Platform.isIOS) {
        if (e.toString().contains('network')) {
          AppSnackBar.error("Network error. Please check your internet connection.");
        } else if (e.toString().contains('configuration')) {
          AppSnackBar.error("Configuration error. Please contact support.");
        } else {
          AppSnackBar.error("Sign-in failed. Please try again.");
        }
      } else {
        AppSnackBar.error("Sign-in failed. Please try again.");
      }
    } finally {
      isGoogleLoading(false);
    }
  }

// Helper method for retry logic with support for both 200 and 201 status codes
  Future<dynamic> _retryApiCall(Map<String, dynamic> body,
      {int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        //! appLog("🔄 Attempt $attempt of $maxRetries");

        // Try with 200 status code first (existing user)
        var data = await _tryApiCall(body, 200);
        if (data != null) {
          //! appLog("✅ API call successful with status 200 (existing user)");
          return data;
        }

        // If 200 fails, try with 201 status code (new user)
        data = await _tryApiCall(body, 201);
        if (data != null) {
          //! appLog("✅ API call successful with status 201 (new user)");
          return data;
        }

        // If both fail, this attempt failed
        throw Exception("Both 200 and 201 status codes failed");
      } catch (e) {
        //! appLog("❌ Attempt $attempt failed: $e");

        if (attempt == maxRetries) {
          // This was the last attempt, don't retry
          rethrow;
        }

        // Wait before retrying (exponential backoff)
        int delaySeconds = attempt * 2; // 2, 4, 6 seconds
        //! appLog("⏳ Waiting $delaySeconds seconds before retry...");
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }

    return null;
  }

  // Helper method to try API call with specific status code
  Future<dynamic> _tryApiCall(Map<String, dynamic> body, int statusCode) async {
    try {
      return await ApiPostServices().apiPostServices(
        url: AppApiUrl.googleAuth,
        body: body,
        statusCode: statusCode,
      );
    } catch (e) {
      // If this specific status code fails, return null
      return null;
    }
  }
}
