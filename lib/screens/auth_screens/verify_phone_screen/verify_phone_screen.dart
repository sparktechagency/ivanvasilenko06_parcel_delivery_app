import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';

import '../../../routes/app_routes.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_button_widget/text_button_widget.dart';
import '../../../widgets/text_field_widget/text_field_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';
import 'controller/verify_phone_controller.dart';

class VerifyPhoneScreen extends StatelessWidget {
  final VerifyPhoneController controller = Get.put(VerifyPhoneController());

  VerifyPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String phoneNumber = Get.arguments;
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
                text: "verifyPhone".tr,
                fontSize: 30,
                fontWeight: FontWeight.w600,
                fontColor: AppColors.black,
              ),
              const SpaceWidget(spaceHeight: 16),
              TextFieldWidget(
                controller: controller.otpController,
                hintText: '******',
                maxLines: 1,
              ),
              const SpaceWidget(spaceHeight: 16),
              TextWidget(
                text: "${"codeHasSendTo".tr} $phoneNumber. ${"usually".tr}",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontColor: AppColors.greyDarkLight,
                textAlignment: TextAlign.left,
              ),
              Obx(
                () => TextButtonWidget(
                  onPressed: controller.isButtonDisabled.value
                      ? () {}
                      : controller.resendCode,
                  text: controller.isButtonDisabled.value
                      ? "${"sendRepeatSMS".tr} ${controller.start.value} ${"sec".tr}"
                      : "resendCode".tr,
                  textColor: controller.isButtonDisabled.value
                      ? AppColors.greyDarkLight
                      : AppColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: ButtonWidget(
          onPressed: () {
            Get.toNamed(AppRoutes.loginScreen);
          },
          label: "verify".tr,
          buttonWidth: double.infinity,
          buttonHeight: 50,
        ),
      ),
    );
  }
}
