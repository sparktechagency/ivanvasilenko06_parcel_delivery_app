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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  bool isContinueWithEmail = false;  // Track whether to show email or phone field
  String fullPhoneNumber = '';

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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextWidget(
                    text: "Are you Continue with".tr,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontColor: AppColors.black,
                  ),
                  const SpaceWidget(spaceWidth: 08),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        // Toggle between email and phone input fields
                        isContinueWithEmail = !isContinueWithEmail;
                      });
                    },
                    child: TextWidget(
                      text: isContinueWithEmail ? "Phone?" : "Email?",
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontColor: AppColors.black,
                      underline: true,
                    ),
                  )
                ],
              ),
              const SpaceWidget(spaceHeight: 16),
              // Show phone input if not using email, else show email input
              isContinueWithEmail
                  ? TextFieldWidget(
                controller: emailController,
                hintText: "enterEmail".tr,
                maxLines: 1,
              )
                  : IntlPhoneFieldWidget(
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
