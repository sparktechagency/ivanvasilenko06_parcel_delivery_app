import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/button_widget/button_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_button_widget/text_button_widget.dart';
import '../../../widgets/text_field_widget/text_field_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';
import 'controller/verify_email_controller.dart';

class VerifyEmailScreen extends StatelessWidget {
  final VerifyEmailController controller = Get.put(VerifyEmailController());

  VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    final firebaseID = arguments["firebaseID"];
    final phoneNumber = arguments["phoneNumber"];
    final email = arguments["email"];
    final fullName = arguments["fullName"];
    final country = arguments["country"];
    final fcmToken = arguments["fcmToken"];
    final deviceId = arguments["deviceId"];
    final deviceType = arguments["deviceType"];
    final screen = arguments["screen"];
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

              // OTP Input Field
              TextFieldWidget(
                controller: controller.otpController,
                hintText: '******',
                maxLines: 1,
                keyboardType: TextInputType.number,
              ),
              const SpaceWidget(spaceHeight: 16),

              // Display Email Information
              TextWidget(
                text:
                    "${"codeHasSendTo".tr} ${controller.phoneNumber}. ${"usually".tr}",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontColor: AppColors.greyDarkLight,
                textAlignment: TextAlign.left,
              ),

              // Resend Code Button with Timer
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
        child: Obx(() => ButtonWidget(
              onPressed: controller.isLoading.value
                  ? null // Disable button while loading
                  : () => controller.verifyOTP(),
              label: controller.isLoading.value ? "Verifying..." : "verify".tr,
              buttonWidth: double.infinity,
              buttonHeight: 50,
            )),
      ),
    );
  }
}
