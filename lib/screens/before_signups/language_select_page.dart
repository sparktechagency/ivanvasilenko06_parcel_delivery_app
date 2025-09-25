import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_constant.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/controller/language_controller.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectPage extends StatefulWidget {
  const LanguageSelectPage({super.key});

  @override
  State<LanguageSelectPage> createState() => _LanguageSelectPageState();
}

class _LanguageSelectPageState extends State<LanguageSelectPage> {
  void _saveLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
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
                text: "selectLanguage".tr,
                fontSize: 30,
                fontWeight: FontWeight.w600,
                fontColor: AppColors.black,
              ),
              const SpaceWidget(spaceHeight: 10),
              TextWidget(
                text: "enterYourPreferredLanguage".tr,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontColor: AppColors.black,
                textAlignment: TextAlign.left,
              ),
              const SpaceWidget(spaceHeight: 24),
              Center(
                child: GetBuilder<LocalizationController>(
                    builder: (localizationController) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap:(){
                          localizationController.setLanguage(Locale(
                            AppConstants.languages[0].languageCode,
                            AppConstants.languages[0].countryCode,
                          ));
                          localizationController.setSelectedIndex(0);
                          _saveLanguage(
                              'en'); // Save 'en' as selected language

                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: const ImageWidget(
                                height: 40,
                                width: 45,
                                imagePath: AppImagePath.usaFlag,
                              ),
                            ),
                            const SizedBox(width:05),
                            const Text(
                              'English',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          localizationController.setLanguage(Locale(
                            AppConstants.languages[1].languageCode,
                            AppConstants.languages[1].countryCode,
                          ));
                          localizationController.setSelectedIndex(1);
                          _saveLanguage(
                              'he'); // Save 'ar' as selected language
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: const ImageWidget(
                                height: 40,
                                width: 45,
                                imagePath: AppImagePath.israeilFlag,
                              ),
                            ),
                            const SizedBox(width:05),
                            const Text(
                              // 'עברי',
                              'Hebrew',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
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
                Get.toNamed(AppRoutes.signupScreen);
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
