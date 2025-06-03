import 'dart:convert';
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

  Future<dynamic> clickLoginButton() async {
    try {
      if (loginFormKey.currentState!.validate()) {
        isLoading.value = true;

        var fcmToken =
            await SharePrefsHelper.getString(SharedPreferenceValue.fcmToken);

        // Get device info
        String deviceId = await _deviceInfo.getDeviceId();
        String deviceType = await _deviceInfo.getDeviceType();

        // If device info is not initialized yet, get it asynchronously
        if (deviceId == 'unknown' || deviceType == 'unknown') {
          deviceId = await _deviceInfo.getDeviceId();
          deviceType = await _deviceInfo.getDeviceType();
        }

        Map<String, String> body = {
          "email": emailController.text,
          "fcmToken": fcmToken.toString(),
          "deviceId": deviceId,
          "deviceType": deviceType,
        };

        var data = await ApiPostServices().apiPostServices(
          url: AppApiUrl.login,
          body: body,
        );

        if (data != null) {
          Get.toNamed(
            AppRoutes.verifyEmailScreen,
            arguments: {
              "email": emailController.text,
              "isFromLogin": true,
            },
          );
          debugPrint("✳️✳️✳️✳️✳️✳️✳️✳️✳️✳️ $fcmToken");
          debugPrint("📱📱📱 DeviceId: $deviceId, DeviceType: $deviceType");
        } else {
          // Get.snackbar("Error", "Failed to send OTP. Please try again.");
        }
      }
    } catch (e) {
      log("Error from login click button: $e");
      // Get.snackbar("Error", "An error occurred. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  var isPhoneLoading = false.obs;

  Future<void> sendOTPFirebase() async {
    try {
      if (loginFormKey.currentState!.validate()) {
        isPhoneLoading.value = true;
        var fcmToken =
            await SharePrefsHelper.getString(SharedPreferenceValue.fcmToken);
        // Get device info
        String deviceId = await _deviceInfo.getDeviceId();
        String deviceType = await _deviceInfo.getDeviceType();
        if (deviceId == 'unknown' || deviceType == 'unknown') {
          deviceId = await _deviceInfo.getDeviceId();
          deviceType = await _deviceInfo.getDeviceType();
        }

        if (true) {
          await _auth.verifyPhoneNumber(
            phoneNumber: completePhoneNumber.value,
            verificationCompleted: (PhoneAuthCredential credential) async {
              await _auth.signInWithCredential(credential);
            },
            verificationFailed: (FirebaseAuthException e) {
              log("${e.message}");
            },
            codeSent: (String verificationId, int? resendToken) {
              Get.toNamed(
                AppRoutes.verifyEmailScreen,
                arguments: {
                  "firebaseID": verificationId,
                  "phoneNumber": completePhoneNumber.value,
                  "fcmToken": fcmToken.toString(),
                  "deviceId": deviceId,
                  "deviceType": deviceType,
                  "screen": "login",
                },
              );
            },
            codeAutoRetrievalTimeout: (String verificationId) {},
          );
          debugPrint("✳️✳️✳️✳️✳️✳️✳️✳️✳️✳️ $fcmToken");
          debugPrint("📱📱📱 DeviceId: $deviceId, DeviceType: $deviceType");
        } else {
          // Get.snackbar("Error", "Failed to send OTP. Please try again.");
        }
      }
    } catch (e) {
      log("Error from login click button: $e");
    } finally {
      isLoading.value = false;
    }
  }

  var isGoogleLoading = false.obs;

  Future<void> googleSignIn() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.signOut();
    final acc = await googleSignIn.signIn();
    if (acc != null) {
      var email = acc.email;
      var uuid = acc.id;
      var displayName = acc.displayName;
      var profileImage = acc.photoUrl;
      log("🧿🧿🧿🧿 Email = $email");
      log("🧿🧿🧿🧿 Name = $displayName");
      log("🧿🧿🧿🧿 Image = $profileImage");
      log("🧿🧿🧿🧿 UUID = $uuid");
      try {
        isGoogleLoading(true);

        var data = await ApiPostServices().apiPostServices(
          url: AppApiUrl.googleAuth,
          body: json.encode({
            "googleId": uuid,
            "fullName": displayName,
            "email": email,
            "profileImage": profileImage,
          }),
          statusCode: 200,
        );

        if (data != null) {
          Get.offAll(() => const BottomNavScreen());
        }
      } catch (e) {
        log("Error from sign-up click button: $e");
        // Get.snackbar("Error", "An error occurred. Please try again.");
      } finally {
        isGoogleLoading(false);
      }
    }
  }
}
