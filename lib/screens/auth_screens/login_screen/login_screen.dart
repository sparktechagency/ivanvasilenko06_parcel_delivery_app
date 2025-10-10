import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/auth_screens/login_screen/controller/login_controller.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/text_button_widget/text_button_widget.dart';
import '../../../widgets/phone_field_widget/phone_field_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class LoginScreen extends StatelessWidget {
  final LoginScreenController controller = Get.find<LoginScreenController>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: controller.loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 48),
                  TextWidget(
                    text: "welcome".tr,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    fontColor: AppColors.black,
                  ),
                  const SizedBox(height: 10),
                  TextWidget(
                    text: "enterNumber0".tr,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontColor: AppColors.black,
                    textAlignment: TextAlign.left,
                  ),
                  const SizedBox(height: 24),
                  IntlPhoneFieldWidget(
                    hintText: "enterNumber0".tr,
                    controller: controller.phoneController,
                    onChanged: (phone) {
                      controller.updatePhoneNumber(phone.completeNumber);
                    },
                    fillColor: AppColors.white,
                    borderColor: AppColors.black,
                    initialCountryCode: "IL",
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 16),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
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
              const SizedBox(width: 4),
              TextButtonWidget(
                onPressed: () {
                  Get.toNamed(AppRoutes.countrySelectScreen);
                },
                text: "signUp".tr,
                textColor: AppColors.greyDark,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
