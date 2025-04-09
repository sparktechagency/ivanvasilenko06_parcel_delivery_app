import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

class VerifyEmailController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController otpController = TextEditingController();
  String email = "";
  var isButtonDisabled = true.obs;
  var start = 180.obs;
  Timer? _timer;
  bool isFromLogin = false;

  @override
  void onInit() {
    super.onInit();
    startTimer();
    if (Get.arguments != null && Get.arguments is Map) {
      email = Get.arguments["email"] ?? "";
      isFromLogin = Get.arguments["isFromLogin"] ?? false;
    } else {
      AppSnackBar.error("Invalid email. Try again.");
      Get.back();
    }
  }

  void startTimer() {
    isButtonDisabled.value = true;
    start.value = 100;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (start.value == 0) {
        isButtonDisabled.value = false;
        timer.cancel();
      } else {
        start.value--;
      }
    });
  }

  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) {
      AppSnackBar.error("Please enter the OTP");
      return;
    }
    try {
      isLoading.value = true;

      Map<String, String> body = {
        'email': email,
        'otpCode': otpController.text
      };

      String url =
          isFromLogin ? AppApiUrl.loginemailveify : AppApiUrl.verifyEmail;
      var response = await ApiPostServices().apiPostServices(
        url: url,
        body: body,
      );

      if (response != null) {
        if (isFromLogin) {
          if (response["data"]["token"] != null) {
            log("😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒😒");
            log(" ✅✅✅✅ ${response["data"]["token"]} ☑️☑️☑️☑️☑️☑️ ");
            // AppAuthStorage().setToken(response["data"]["token"].toString());

            SharePrefsHelper.setString(SharedPreferenceValue.token,
                response["data"]["token"].toString());

            String token =
                await SharePrefsHelper.getString(SharedPreferenceValue.token);
            debugPrint("token=-=-==-=-=-=-=-=-=-=--=-= $token");
          }
          AppSnackBar.success("Successfully verified the email");
          Get.offAll(() => const BottomNavScreen());
          //  Login flow → BottomNav
        } else {
          Get.offAllNamed(AppRoutes.loginScreen); //  Signup flow → Login Screen
        }
      } else {
        AppSnackBar.error("Invalid OTP. Please try again.");
      }
    } catch (e) {
      log("Error in email verification: $e");
      AppSnackBar.error("An error occurred. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  void resendCode() {
    log("Resend code logic executed");
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
