import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';

import '../../../routes/app_routes.dart';
import '../../../widgets/phone_field_widget/phone_field_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_field_widget/text_field_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class SignupScreen extends StatelessWidget {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String fullPhoneNumber = '';

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRTL = Get.locale?.languageCode == 'he';
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
              TextFieldWidget(
                controller: nameController,
                hintText: "enterYourName".tr,
                maxLines: 1,
              ),
              const SpaceWidget(spaceHeight: 16),
              IntlPhoneFieldWidget(
                controller: phoneController,
                hintText: "enterYourPhoneNumber".tr,
                onChanged: (phone) {
                  fullPhoneNumber = phone.completeNumber;
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                Get.back();
              },
              borderRadius: BorderRadius.circular(100),
              child: CircleAvatar(
                backgroundColor: AppColors.grey,
                radius: ResponsiveUtils.width(25),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.black,
                ),
              ),
            ),
            ButtonWidget(
              onPressed: () {
                final phoneNumber = phoneController.text;
                Get.toNamed(AppRoutes.verifyPhoneScreen,
                    arguments: phoneNumber);
              },
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
