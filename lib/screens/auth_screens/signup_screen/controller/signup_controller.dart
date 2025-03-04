import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';

class SignUpScreenController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController fullNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();

  RxBool isContinueWithEmail = false.obs;  // Track whether to use phone or email
  GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();

  // Function to toggle between email and phone signup
  void toggleEmailPhone() {
    isContinueWithEmail.value = !isContinueWithEmail.value;
  }

  Future<void> clickSignUpButton() async {
    try {
      if (signUpFormKey.currentState!.validate()) {
        isLoading.value = true;

        // Prepare the data based on whether the user is signing up with email or phone
        Map<String, String> body = {
          "name": fullNameTextEditingController.text,
        };

        // Check if the user is signing up with phone or email
        if (isContinueWithEmail.value) {
          body["email"] = emailTextEditingController.text;
        } else {
          body["mobileNumber"] = phoneTextEditingController.text;
        }

        // API call
        var data = await ApiPostServices().apiPostServices(
          url: AppApiUrl.signup,
          body: body,
        );

        if (data != null) {
          // On success, navigate to OTP verification screen
          Get.toNamed(AppRoutes.verifyEmailScreen,
              arguments: {"email": emailTextEditingController.text});
        } else {
          // Handle error if API response is invalid
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
    fullNameTextEditingController.dispose();
    emailTextEditingController.dispose();
    phoneTextEditingController.dispose();
    super.onClose();
  }
}
