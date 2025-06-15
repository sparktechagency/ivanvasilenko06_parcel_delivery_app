import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';
import 'package:parcel_delivery_app/services/deviceInfo/device_info.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

class LoginScreenController extends GetxController {
  RxBool isLoading = false.obs;
  final DeviceInfo _deviceInfo = DeviceInfo();
  TextEditingController emailController = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxString completePhoneNumber = ''.obs;
  TextEditingController phoneController = TextEditingController();

  void updatePhoneNumber(String phoneNumber) {
    completePhoneNumber.value = phoneNumber;
  }

  // Future<dynamic> clickLoginButton() async {
  //   try {
  //     if (loginFormKey.currentState!.validate()) {
  //       isLoading.value = true;
  //
  //       var fcmToken =
  //           await SharePrefsHelper.getString(SharedPreferenceValue.fcmToken);
  //
  //       // Get device info
  //       String deviceId = await _deviceInfo.getDeviceId();
  //       String deviceType = await _deviceInfo.getDeviceType();
  //
  //       // If device info is not initialized yet, get it asynchronously
  //       if (deviceId == 'unknown' || deviceType == 'unknown') {
  //         deviceId = await _deviceInfo.getDeviceId();
  //         deviceType = await _deviceInfo.getDeviceType();
  //       }
  //
  //       Map<String, String> body = {
  //         "email": emailController.text,
  //         "fcmToken": fcmToken.toString(),
  //         "deviceId": deviceId,
  //         "deviceType": deviceType,
  //       };
  //
  //       var data = await ApiPostServices().apiPostServices(
  //         url: AppApiUrl.login,
  //         body: body,
  //       );
  //
  //       if (data != null) {
  //         Get.toNamed(
  //           AppRoutes.verifyEmailScreen,
  //           arguments: {
  //             "email": emailController.text,
  //             "isFromLogin": true,
  //           },
  //         );
  //         debugPrint("✳️✳️✳️✳️✳️✳️✳️✳️✳️✳️ $fcmToken");
  //         debugPrint("📱📱📱 DeviceId: $deviceId, DeviceType: $deviceType");
  //       } else {
  //         // Get.snackbar("Error", "Failed to send OTP. Please try again.");
  //       }
  //     }
  //   } catch (e) {
  //     log("Error from login click button: $e");
  //     // Get.snackbar("Error", "An error occurred. Please try again.");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

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
        "fcmToken": fcmToken?.toString() ?? "",
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
            "fcmToken": fcmToken?.toString() ?? "",
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

  // Future<void> sendOTPFirebase() async {
  //   try {
  //     if (loginFormKey.currentState!.validate()) {
  //       isLoading.value = true; // This sets loading to true
  //
  //       var fcmToken =
  //           await SharePrefsHelper.getString(SharedPreferenceValue.fcmToken);
  //
  //       // Get device info
  //       String deviceId = await _deviceInfo.getDeviceId();
  //       String deviceType = await _deviceInfo.getDeviceType();
  //
  //       if (deviceId == 'unknown' || deviceType == 'unknown') {
  //         deviceId = await _deviceInfo.getDeviceId();
  //         deviceType = await _deviceInfo.getDeviceType();
  //       }
  //
  //       await _auth.verifyPhoneNumber(
  //         phoneNumber: completePhoneNumber.value,
  //         verificationCompleted: (PhoneAuthCredential credential) async {
  //           await _auth.signInWithCredential(credential);
  //           isLoading.value = false; // Stop loading
  //         },
  //         verificationFailed: (FirebaseAuthException e) {
  //           log("${e.message}");
  //           isLoading.value = false; // Stop loading on error
  //         },
  //         codeSent: (String verificationId, int? resendToken) {
  //           // Add a small delay to show the loading indicator
  //           Future.delayed(const Duration(milliseconds: 500), () {
  //             isLoading.value = false; // Stop loading before navigation
  //             Get.toNamed(
  //               AppRoutes.verifyEmailScreen,
  //               arguments: {
  //                 "firebaseID": verificationId,
  //                 "phoneNumber": completePhoneNumber.value,
  //                 "fcmToken": fcmToken.toString(),
  //                 "deviceId": deviceId,
  //                 "deviceType": deviceType,
  //                 "screen": "login",
  //               },
  //             );
  //           });
  //         },
  //         codeAutoRetrievalTimeout: (String verificationId) {
  //           isLoading.value = false; // Stop loading on timeout
  //         },
  //       );
  //
  //       debugPrint("✳️✳️✳️✳️✳️✳️✳️✳️✳️✳️ $fcmToken");
  //       debugPrint("📱📱📱 DeviceId: $deviceId, DeviceType: $deviceType");
  //     }
  //   } catch (e) {
  //     log("Error from login click button: $e");
  //     isLoading.value = false; // Stop loading on error
  //   }
  //   // Remove the finally block since we're handling loading state in callbacks
  // }

  var isGoogleLoading = false.obs;

  Future<void> googleSignIn() async {
    try {
      isGoogleLoading(true);

      // Configure GoogleSignIn with explicit scopes if needed
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Sign out first to ensure clean state
      await googleSignIn.signOut();
      // Add a small delay to ensure sign out is complete
      await Future.delayed(const Duration(milliseconds: 500));
      log("🔄 Starting Google Sign-In process...");
      // Start sign-in process
      final GoogleSignInAccount? acc = await googleSignIn.signIn();

      if (acc == null) {
        // User cancelled the sign-in
        log("Google Sign-In cancelled by user");
        AppSnackBar.error("Sign-in cancelled");
        return;
      }

      // Get FCM token and device info
      var fcmToken =
          await SharePrefsHelper.getString(SharedPreferenceValue.fcmToken);
      log("FCM Token: '$fcmToken'");

      String deviceId = await _deviceInfo.getDeviceId();
      String deviceType = await _deviceInfo.getDeviceType();

      if (deviceId == 'unknown' || deviceType == 'unknown') {
        deviceId = await _deviceInfo.getDeviceId();
        deviceType = await _deviceInfo.getDeviceType();
      }

      log("Device ID: '$deviceId'");
      log("Device Type: '$deviceType'");

      // Extract user data
      var email = acc.email;
      var uuid = acc.id;
      var displayName = acc.displayName ?? "";
      var profileImage = acc.photoUrl ?? "";

      log("🧿🧿🧿🧿 Email = $email");
      log("🧿🧿🧿🧿 Name = $displayName");
      log("🧿🧿🧿🧿 Image = $profileImage");
      log("🧿🧿🧿🧿 UUID = $uuid");

      // Prepare request body - Use Map instead of json.encode for consistency
      Map<String, dynamic> body = {
        "googleId": uuid,
        "fullName": displayName,
        // "email": email,
        // "profileImage": profileImage,
        "fcmToken": fcmToken?.toString() ?? "",
        "deviceId": deviceId,
        "deviceType": deviceType,
        "role": "sender",
      };
      log("Google Auth API Request Body: $body");
      log("Google Auth API URL: ${AppApiUrl.googleAuth}");
      // Make API call
      var data = await ApiPostServices().apiPostServices(
        url: AppApiUrl.googleAuth,
        body: body,
        statusCode: 201,
      );
      log("Google Auth API Response: $data");
      if (data != null) {
        if (data["data"] != null && data["data"]["token"] != null) {
          String token = data["data"]["token"].toString();
          if (token.isNotEmpty) {
            // Save token
            await SharePrefsHelper.setString(
                SharedPreferenceValue.token, token);

            // Verify token was saved
            String savedToken =
                await SharePrefsHelper.getString(SharedPreferenceValue.token);
            log("✅ Token saved successfully: $savedToken");

            // Navigate to bottom nav
            log("🚀 Navigating to BottomNavScreen");
            Get.offAll(() => const BottomNavScreen());
          } else {
            log("❌ Empty token received");
            AppSnackBar.error("Authentication failed: Invalid token");
          }
        } else {
          log("❌ Invalid response structure: $data");
          AppSnackBar.error("Authentication failed: Invalid response");
        }
      } else {
        log("❌ API returned null data");
        AppSnackBar.error("Authentication failed: Server error");
      }
    } catch (e) {
      log("❌ Error in Google Sign-In: $e");
      AppSnackBar.error("Sign-in failed: ${e.toString()}");
    } finally {
      isGoogleLoading(false);
      log("🔄 Google Sign-In process completed");
    }
  }
}
