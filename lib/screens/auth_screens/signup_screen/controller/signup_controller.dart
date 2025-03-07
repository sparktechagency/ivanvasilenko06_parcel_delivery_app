import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

class SignUpScreenController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController(); // Only phoneController

  GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();

  Future<void> clickSignUpButton() async {
    try {
      // Validate form
      if (!signUpFormKey.currentState!.validate()) return;

      // You can show a loading indicator if needed
      isLoading.value = true;

      // Ensure phone number is provided
      if (phoneController.text.isEmpty) {
        AppSnackBar.error("Please enter a valid phone number.");
        return;
      }

      // Bypass the API call and directly navigate to the VerifyPhoneScreen
      Get.toNamed(AppRoutes.verifyPhoneScreen, arguments: phoneController.text); // Navigate to verify phone screen
    } catch (e) {
      log("Signup error: $e");
      AppSnackBar.error("An error occurred. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose(); // Dispose only phoneController
    super.onClose();
  }
}
