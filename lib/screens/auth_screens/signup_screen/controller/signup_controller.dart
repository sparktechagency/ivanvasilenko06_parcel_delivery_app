import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';
import 'package:parcel_delivery_app/services/deviceInfo/device_info.dart';
import 'package:parcel_delivery_app/utils/appLog/app_log.dart';

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

  Future<void> phoneOtpSignup() async {
    try {
      if (signUpFormKey.currentState!.validate()) {
        isLoading.value = true;

        var fcmToken =
            await SharePrefsHelper.getString(SharedPreferenceValue.fcmToken);
        appLog(fcmToken);
        // Get device info
        String deviceId = await _deviceInfo.getDeviceId();
        String deviceType = await _deviceInfo.getDeviceType();
        // If device info is not initialized yet, get it asynchronously
        if (deviceId == 'unknown' || deviceType == 'unknown') {
          deviceId = await _deviceInfo.getDeviceId();
          deviceType = await _deviceInfo.getDeviceType();
        }
        // Ensure no null values are passed
        Map<String, String> body = {
          "fullName": fullNameController.text.trim().isEmpty
              ? ""
              : fullNameController.text.trim(),
          "country": countryController.text.trim().isEmpty
              ? ""
              : countryController.text.trim(),
          "email": emailController.text.trim().isEmpty
              ? ""
              : emailController.text.trim(),
          "mobileNumber": completePhoneNumber.value.isEmpty
              ? ""
              : completePhoneNumber.value,
          "fcmToken": fcmToken.toString(),
          "deviceId": deviceId,
          "deviceType": deviceType,
          "role": "sender"
        };

        var data = await ApiPostServices().apiPostServices(
          url: AppApiUrl.phoneOtpSignup,
          body: body,
          statusCode: 201,
        );

        if (data != null) {
          log('Data: $data');
          Get.toNamed(AppRoutes.verifyPhoneScreen, arguments: {
            "mobileNumber": completePhoneNumber.value,
            "email": emailController.text.trim(),
            "fullName": fullNameController.text.trim(),
            "country": countryController.text.trim(),
            "fcmToken": fcmToken.toString(),
            "deviceId": deviceId,
            "deviceType": deviceType,
            "screen": "signup",
          });
        } else {
          // Handle error case
          log("API returned null data");
        }
      }
    } catch (e) {
      log("Error in PhoneOtpVerification: $e");
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
