import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';
import 'package:parcel_delivery_app/services/deviceInfo/device_info.dart';

class SignUpScreenController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  TextEditingController countryController = TextEditingController();

  TextEditingController phoneController = TextEditingController();
  GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  final DeviceInfo _deviceInfo = DeviceInfo();
  String? countryCode;
  final RxString completePhoneNumber = ''.obs;

  void updatePhoneNumber(String phoneNumber) {
    completePhoneNumber.value = phoneNumber;
  }

  Future<void> clickSignUpButton() async {
    try {
      if (signUpFormKey.currentState!.validate()) {
        isLoading.value = true;

        var fcmToken =
            await SharePrefsHelper.getString(SharedPreferenceValue.fcmToken);
        String fullPhoneNumber = '$countryCode${phoneController.text}';
        // Get device info
        String deviceId = await _deviceInfo.getDeviceId();
        String deviceType = await _deviceInfo.getDeviceType();

        // If device info is not initialized yet, get it asynchronously
        if (deviceId == 'unknown' || deviceType == 'unknown') {
          deviceId = await _deviceInfo.getDeviceId();
          deviceType = await _deviceInfo.getDeviceType();
        }

        Map<String, String> body = {
          "fullName": fullNameController.text,
          "country": countryController.text,
          "email": emailController.text,
          "mobileNumber": completePhoneNumber.toString(),
          "fcmToken": fcmToken.toString(),
          "deviceId": deviceId,
          "deviceType": deviceType,
        };

        var data = await ApiPostServices().apiPostServices(
          url: AppApiUrl.signupemail,
          body: body,
          statusCode: 201,
        );

        if (data != null) {
          Get.toNamed(
            AppRoutes.verifyEmailScreen,
            arguments: {"email": emailController.text},
          );
        } else {
          Get.snackbar("Error", "Failed to sign up. Please try again.");
        }
      }
    } catch (e) {
      log("Error from sign-up click button: $e");
      Get.snackbar("Error", "An error occurred. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
