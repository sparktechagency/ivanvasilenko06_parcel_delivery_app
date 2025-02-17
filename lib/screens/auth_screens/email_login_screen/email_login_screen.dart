import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/button_widget/button_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_field_widget/text_field_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class EmailLoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  EmailLoginScreen({super.key});

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
                text: "loginWithEmail".tr,
                fontSize: 30,
                fontWeight: FontWeight.w600,
                fontColor: AppColors.black,
              ),
              const SpaceWidget(spaceHeight: 10),
              TextWidget(
                text: "emailLoginDesc".tr,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontColor: AppColors.black,
                textAlignment: TextAlign.left,
              ),
              const SpaceWidget(spaceHeight: 24),
              TextFieldWidget(
                controller: emailController,
                hintText: "enterEmail".tr,
                maxLines: 1,
              ),
              const SpaceWidget(spaceHeight: 16),
              TextFieldWidget(
                controller: passwordController,
                hintText: "enterPassword".tr,
                maxLines: 1,
              ),
              const SpaceWidget(spaceHeight: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: ButtonWidget(
          onPressed: () {
            final email = emailController.text;
            Get.toNamed(
              AppRoutes.verifyEmailScreen,
              arguments: email,
            );
          },
          label: "login".tr,
          buttonWidth: double.infinity,
          buttonHeight: 50,
        ),
      ),
    );
  }
}
