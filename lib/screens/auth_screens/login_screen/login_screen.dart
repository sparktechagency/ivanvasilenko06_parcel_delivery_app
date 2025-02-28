import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/auth_screens/login_screen/widgets/customInkWellWidget.dart';
import 'package:parcel_delivery_app/screens/auth_screens/login_screen/widgets/or_widget.dart';
import 'package:parcel_delivery_app/screens/auth_screens/otp_login_screen/otp_login_screen.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/text_button_widget/text_button_widget.dart';
import '../../../constants/app_icons_path.dart';
import '../../../widgets/phone_field_widget/phone_field_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';
import '../../bottom_nav_bar/bottom_nav_bar.dart';

class LoginScreen extends StatelessWidget {
  final phoneController = TextEditingController();
  final isLoading = false.obs;

  LoginScreen({super.key});

  void loginUser() {
    if (phoneController.text.isNotEmpty) {
      Get.to(() => OtpLoginScreen());
    } else {
      Get.offAll(() => const BottomNavScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                text: "enterNumber".tr,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontColor: AppColors.black,
                textAlignment: TextAlign.left,
              ),
              const SpaceWidget(spaceHeight: 24),
              IntlPhoneFieldWidget(
                controller: phoneController,
                hintText: "enterYourPhoneNumber".tr,
              ),
              const SpaceWidget(spaceHeight: 24),
              Obx(() {
                return isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ButtonWidget(
                        onPressed: loginUser,
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
                  Get.toNamed(AppRoutes.emailLoginScreen);
                },
                icon: AppIconsPath.emailIcon,
                text: "continueWithEmail".tr,
              ),
              const SpaceWidget(spaceHeight: 16),
              CustomInkWellButton(
                onTap: () {
                  Get.offAll(() => const BottomNavScreen());
                },
                icon: AppIconsPath.googleIcon,
                text: "continueWithGoogle".tr,
              ),
              const SpaceWidget(spaceHeight: 16),
              CustomInkWellButton(
                onTap: () {
                  Get.offAll(() => const BottomNavScreen());
                },
                icon: AppIconsPath.appleIcon,
                text: "continueWithApple".tr,
              ),
            ],
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
                Get.offAllNamed(AppRoutes.loginScreen);
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
