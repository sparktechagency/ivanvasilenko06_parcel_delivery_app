import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';

class LoginScreenController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController emailController = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  Future<dynamic> clickLoginButton() async {
    try {
      if (loginFormKey.currentState!.validate()) {
        isLoading.value = true;

        Map<String, String> body = {
          "email": emailController.text,
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
        } else {
          Get.snackbar("Error", "Failed to send OTP. Please try again.");
        }
      }
    } catch (e) {
      log("Error from login click button: $e");
      Get.snackbar("Error", "An error occurred. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
