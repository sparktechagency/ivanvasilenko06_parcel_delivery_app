import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/bottom_nav_bar.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
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
    final String email = Get.arguments;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SpaceWidget(spaceHeight: 48),
              const TextWidget(
                text: AppStrings.verifyEmail,
                fontSize: 30,
                fontWeight: FontWeight.w500,
                fontColor: AppColors.black,
                fontStyle: FontStyle.italic,
              ),
              const SpaceWidget(spaceHeight: 16),
              TextFieldWidget(
                controller: controller.otpController,
                hintText: '******',
                maxLines: 1,
              ),
              const SpaceWidget(spaceHeight: 16),
              TextWidget(
                text:
                    "${AppStrings.codeHasSendTo} $email. ${AppStrings.usually}",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontColor: AppColors.greyDarkLight,
                fontStyle: FontStyle.italic,
                textAlignment: TextAlign.left,
              ),
              Obx(() => TextButtonWidget(
                    onPressed: controller.isButtonDisabled.value
                        ? () {}
                        : controller.resendCode,
                    text: controller.isButtonDisabled.value
                        ? "Send a repeat SMS in ${controller.start.value} sec"
                        : "Resend Code",
                    textColor: controller.isButtonDisabled.value
                        ? AppColors.greyDarkLight
                        : AppColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: ButtonWidget(
          onPressed: () {
            Get.offAll(() => const BottomNavScreen());
          },
          label: AppStrings.verify,
          buttonWidth: double.infinity,
          buttonHeight: 50,
        ),
      ),
    );
  }
}
