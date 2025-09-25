import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/routes/route_manager.dart';

import 'constants/app_colors.dart';
import 'constants/app_constant.dart';
import 'constants/app_strings.dart';
import 'constants/messages.dart';
import 'controller/language_controller.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.languages});

  final Map<String, Map<String, String>> languages;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return GetBuilder<LocalizationController>(
          builder: (localizationController) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.white),
            useMaterial3: true,
            fontFamily: AppStrings.fontFamilyName,
          ),
          initialRoute: RouteManager.initial,
          getPages: RouteManager.getPages(),
          locale: localizationController.locale,
          translations: Messages(languages: languages),
          fallbackLocale: Locale(
            AppConstants.languages[0].languageCode,
            AppConstants.languages[0].countryCode,
          ),
        );
      });
    });
  }
}
