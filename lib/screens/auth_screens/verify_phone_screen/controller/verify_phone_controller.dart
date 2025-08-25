import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';
import 'package:parcel_delivery_app/services/deviceInfo/device_info.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

class VerifyPhoneController extends GetxController {
  RxBool isLoading = false.obs;
  var otpController = TextEditingController();
  var isButtonDisabled = true.obs;
  var start = 60.obs;
  Timer? _timer;
  bool isFromLogin = false;
  final DeviceInfo _deviceInfo = DeviceInfo();

  late String firebaseID;
  late String phoneNumber;
  late String email;
  late String fullName;
  late String country;
  late String fcmToken;
  late String deviceId;
  late String deviceType;
  late String screen;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};

    // Use null-aware operators and provide defaults
    phoneNumber = arguments["phoneNumber"]?.toString() ??
        arguments["mobileNumber"]?.toString() ??
        "";
    email = arguments["email"]?.toString() ?? "";
    fullName = arguments["fullName"]?.toString() ?? "";
    country = arguments["country"]?.toString() ?? "";
    fcmToken = arguments["fcmToken"]?.toString() ?? "";
    deviceId = arguments["deviceId"]?.toString() ?? "";
    deviceType = arguments["deviceType"]?.toString() ?? "";
    screen = arguments["screen"]?.toString() ?? "";

    isFromLogin = screen == "login";
    //! log("Screen type: $screen, isFromLogin: $isFromLogin");
    //! log("Phone number received: $phoneNumber");

    startTimer();

    // Validation check
    if (phoneNumber.isEmpty) {
      //! log("Missing phone number");
      AppSnackBar.error("Missing phone number");
      Get.back();
      return;
    }
  }

  Future<void> verifyOTP() async {
    if (otpController.text.isEmpty) {
      AppSnackBar.error("Please enter the OTP");
      return;
    }
    try {
      isLoading.value = true;
      if (isFromLogin) {
        await handleLoginFlow();
      } else {
        await handleSignupFlow();
      }
    } catch (e) {
      //! log("Error from verifyOTP: $e");
      AppSnackBar.error("An error occurred. Please try again.");
    }
  }

  Future<void> handleLoginFlow() async {
    try {
      // Get fresh device info
      String deviceId = await _deviceInfo.getDeviceId();
      String deviceType = await _deviceInfo.getDeviceType();

      Map<String, String> body = {
        "mobileNumber": phoneNumber,
        "otpCode": otpController.text.trim(),
        "fcmToken": fcmToken.isEmpty ? "" : fcmToken,
        "deviceId": deviceId,
        "deviceType": deviceType,
      };

      var data = await ApiPostServices().apiPostServices(
        url: AppApiUrl.phoneOtpLoginVerify,
        body: body,
        statusCode: 200,
      );

      if (data != null) {
        if (data["data"]["token"] != null &&
            data["data"]["token"].toString().isNotEmpty) {
          await SharePrefsHelper.setString(
              SharedPreferenceValue.token, data["data"]["token"].toString());
          String token =
              await SharePrefsHelper.getString(SharedPreferenceValue.token);
          //! log("Saved login token: $token");
        }
        //! log('Login Data: $data');
        Get.offAll(() => const BottomNavScreen());
      } else {
        AppSnackBar.error("Failed to log in. Please try again.");
      }
    } catch (e) {
      //! log("Error from handleLoginFlow: $e");
      AppSnackBar.error("Login failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleSignupFlow() async {
    try {
      // Get fresh device info
      String deviceId = await _deviceInfo.getDeviceId();
      String deviceType = await _deviceInfo.getDeviceType();

      Map<String, String> body = {
        "mobileNumber": phoneNumber,
        "otpCode": otpController.text.trim(),
        "fcmToken": fcmToken.isEmpty ? "" : fcmToken,
        "deviceId": deviceId,
        "deviceType": deviceType,
        "role": "sender"
      };

      var data = await ApiPostServices().apiPostServices(
        url: AppApiUrl.phoneOtpVerify,
        body: body,
        statusCode: 200,
      );

      if (data != null) {
        if (data["token"] != null && data["token"].toString().isNotEmpty) {
          await SharePrefsHelper.setString(
              SharedPreferenceValue.token, data["token"].toString());
          String token =
              await SharePrefsHelper.getString(SharedPreferenceValue.token);
          //! log("Saved registration token: $token");
        }
       //!  log('Signup Data: $data');
        Get.offAll(() => const BottomNavScreen());
      } else {
        AppSnackBar.error("Failed to sign up. Please try again.");
      }
    } catch (e) {
     //!  log("Error from handleSignupFlow: $e");
      AppSnackBar.error("Signup failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendCode() async {
    try {
      Map<String, String> body = {
        "mobileNumber": phoneNumber,
      };

      var data = await ApiPostServices().apiPostServices(
        url: AppApiUrl.phoneOtpResend,
        body: body,
        statusCode: 200,
      );

      if (data != null) {
       //!  log('Resend Data: $data');
        startTimer();
      }
    } catch (e) {
     //!  log("Error from resendCode: $e");
      AppSnackBar.error("Resend code failed: ${e.toString()}");
    }
  }

  void startTimer() {
    isButtonDisabled.value = true;
    start.value = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (start.value == 0) {
        isButtonDisabled.value = false;
        timer.cancel();
      } else {
        start.value--;
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
