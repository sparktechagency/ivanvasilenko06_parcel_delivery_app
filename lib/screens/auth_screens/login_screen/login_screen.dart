import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/auth_screens/login_screen/controller/login_controller.dart';
import 'package:parcel_delivery_app/screens/auth_screens/login_screen/widgets/customInkWellWidget.dart';
import 'package:parcel_delivery_app/screens/auth_screens/login_screen/widgets/or_widget.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/text_button_widget/text_button_widget.dart';

import '../../../widgets/phone_field_widget/phone_field_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class LoginScreen extends StatelessWidget {
  final LoginScreenController controller = Get.put(LoginScreenController());

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void showDialogBoxPhone() {
      Get.dialog(
          barrierDismissible: false,
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Dialog(
              backgroundColor: AppColors.white,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextWidget(
                      text: "beforeGoogleSignInEnterYourNumber".tr,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.black,
                      textAlignment: TextAlign.center,
                    ),
                    const SpaceWidget(
                      spaceHeight: 20,
                    ),
                    IntlPhoneFieldWidget(
                      hintText: "enterNumber0".tr,
                      controller: controller.googleSignInPhoneController,
                      onChanged: (phone) {
                        controller.updatePhoneNumber(phone.completeNumber);
                        //! log(phone.completeNumber);
                      },
                      fillColor: AppColors.white,
                      borderColor: AppColors.black,
                      initialCountryCode: "IL",
                    ),
                    const SpaceWidget(
                      spaceHeight: 20,
                    ),
                    Obx(
                      () => controller.isLoading.value
                          ? Center(
                              child: LoadingAnimationWidget.progressiveDots(
                                color: Colors.white,
                                size: 40,
                              ),
                            )
                          : ButtonWidget(
                              label: "continueWithGoogle".tr,
                              buttonHeight: 50,
                              buttonWidth: double.infinity,
                              onPressed: () {
                                controller.googleSignIn();
                              },
                            ),
                    ),
                    const SpaceWidget(
                      spaceHeight: 20,
                    ),
                  ],
                ),
              ),
            ),
          ));
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: controller.loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SpaceWidget(spaceHeight: 48),
                  TextWidget(
                    text: "welcome".tr,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    fontColor: AppColors.black,
                  ),
                  const SpaceWidget(spaceHeight: 10),
                  TextWidget(
                    text: "enterNumber0".tr,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontColor: AppColors.black,
                    textAlignment: TextAlign.left,
                  ),
                  const SpaceWidget(spaceHeight: 24),
                  IntlPhoneFieldWidget(
                    hintText: "enterNumber0".tr,
                    controller: controller.phoneController,
                    onChanged: (phone) {
                      controller.updatePhoneNumber(phone.completeNumber);
                      //! log(phone.completeNumber);
                    },
                    fillColor: AppColors.white,
                    borderColor: AppColors.black,
                    initialCountryCode: "IL",
                  ),
                  const SpaceWidget(spaceHeight: 24),
                  Obx(() {
                    return controller.isLoading.value
                        ? Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.black,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: LoadingAnimationWidget.progressiveDots(
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          )
                        : ButtonWidget(
                            onPressed: controller.phoneOtpLogin,
                            label: "login".tr,
                            buttonHeight: 50,
                            buttonWidth: double.infinity,
                          );
                  }),
                  const SpaceWidget(spaceHeight: 16),
                  const OrWidget(),
                  const SpaceWidget(spaceHeight: 16),
                  CustomInkWellButton(
                    onTap: () {
                      //controller.googleSignIn();
                      showDialogBoxPhone();
                    },
                    icon: AppIconsPath.googleIcon,
                    text: "continueWithGoogle".tr,
                  ),
                  const SpaceWidget(spaceHeight: 16),
                  CustomInkWellButton(
                    onTap: () {
                      Get.snackbar(
                        "Sign with Apple Comming Soon",
                        "This Feature will be implemented",
                        backgroundColor: AppColors.green,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 2),
                        margin: const EdgeInsets.all(10),
                      );
                    },
                    icon: AppIconsPath.appleIcon,
                    text: "continueWithApple".tr,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(
              text: "dontHaveAccount".tr,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.greyDark,
            ),
            const SpaceWidget(spaceWidth: 4),
            TextButtonWidget(
              onPressed: () {
                Get.offAllNamed(AppRoutes.countrySelectScreen);
              },
              text: "signUp".tr,
              textColor: AppColors.greyDark,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}
