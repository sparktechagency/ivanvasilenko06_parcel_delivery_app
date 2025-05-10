import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/screens/auth_screens/signup_screen/controller/signup_controller.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/phone_field_widget/phone_field_widget.dart';

import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_field_widget/text_field_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class SignupScreen extends StatelessWidget {
  final SignUpScreenController controller = Get.put(SignUpScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: controller.signUpFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SpaceWidget(spaceHeight: 48),
                TextWidget(
                  text: "getStarted".tr,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  fontColor: AppColors.black,
                ),
                const SpaceWidget(spaceHeight: 10),
                TextWidget(
                  text: "signupDesc".tr,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontColor: AppColors.black,
                  textAlignment: TextAlign.left,
                ),
                const SpaceWidget(spaceHeight: 24),

                // Name Field
                TextFieldWidget(
                  controller: controller.fullNameController,
                  hintText: "enterYourName".tr,
                  maxLines: 1,
                ),
                const SpaceWidget(spaceHeight: 16),

                // Email Field
                TextFieldWidget(
                  controller: controller.emailController,
                  hintText: "enterEmail".tr,
                  maxLines: 1,
                ),
                const SpaceWidget(spaceHeight: 16),

                IntlPhoneFieldWidget(
                  hintText: "Enter Your Number".tr,
                  controller: controller.phoneController,
                  onChanged: (phone) {
                    controller.updatePhoneNumber(phone.completeNumber);
                    log(phone.completeNumber);
                  },
                  fillColor: AppColors.white,
                  borderColor: AppColors.black,
                  initialCountryCode: "IL",
                ),
                const SpaceWidget(spaceHeight: 20),
                // Loading Indicator
                Obx(() => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(100),
              child: const CircleAvatar(
                backgroundColor: AppColors.grey,
                radius: 25,
                child: Icon(Icons.arrow_back, color: AppColors.black),
              ),
            ),
            ButtonWidget(
              onPressed: () => controller.clickSignUpButton(),
              label: "next".tr,
              icon: Icons.arrow_forward,
              buttonWidth: 120,
              buttonHeight: 50,
            ),
          ],
        ),
      ),
    );
  }
}
