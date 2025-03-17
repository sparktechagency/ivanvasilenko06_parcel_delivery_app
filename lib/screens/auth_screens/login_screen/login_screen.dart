import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/auth_screens/login_screen/controller/login_controller.dart';
import 'package:parcel_delivery_app/screens/auth_screens/login_screen/widgets/customInkWellWidget.dart';
import 'package:parcel_delivery_app/screens/auth_screens/login_screen/widgets/or_widget.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/text_button_widget/text_button_widget.dart';
import 'package:parcel_delivery_app/widgets/text_field_widget/text_field_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';
import '../../bottom_nav_bar/bottom_nav_bar.dart';

class LoginScreen extends StatelessWidget {
  final LoginScreenController controller = Get.put(LoginScreenController());

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    text: "enterEmail".tr,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontColor: AppColors.black,
                    textAlignment: TextAlign.left,
                  ),
                  const SpaceWidget(spaceHeight: 24),
                  TextFieldWidget(
                    controller: controller.emailController,
                    hintText: "enterEmail".tr,
                    maxLines: 1,
                  ),
                  // IntlPhoneFieldWidget(
                  //   controller: phoneController,
                  //   hintText: "enterYourPhoneNumber".tr,
                  // ),
                  const SpaceWidget(spaceHeight: 24),
                  Obx(() {
                    return controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : ButtonWidget(
                      onPressed: controller.clickLoginButton,
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
                      Get.snackbar(
                        "Sign with Email Comming Soon",
                        "This Feature will be implemented Now You can Sing up with your Email",
                        backgroundColor: AppColors.green,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 2),
                        margin: EdgeInsets.all(10),
                      );
                    },
                    icon: AppIconsPath.emailIcon,
                    text: "continueWithEmail".tr,
                  ),
                  const SpaceWidget(spaceHeight: 16),
                  CustomInkWellButton(
                    onTap: () {
                      Get.snackbar(
                        "Sign with Google Comming Soon",
                        "This Feature will be implemented",
                        backgroundColor: AppColors.green,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 2),
                        margin: EdgeInsets.all(10),
                      );
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
                        margin: EdgeInsets.all(10),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(
              text: "dontHaveAccount".tr,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.greyDark,
            ),
            const SpaceWidget(spaceWidth: 4),
            TextButtonWidget(
              onPressed: () {
                Get.offAllNamed(AppRoutes.signupScreen);
              },
              text: "signUp".tr,
              textColor: AppColors.greyDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}
