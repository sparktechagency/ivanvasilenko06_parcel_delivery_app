import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

class AppSnackBar {
  // >>>>>>>>>>>>>>>>>>>>>> when show message bottom  <<<<<<<<<<<<<<<<<<<<<<

  // >>>>>>>>>>>>>>>>>>>>>> error message snackbar  <<<<<<<<<<<<<<<<<<<<<<
  static error(String parameterValue) {
    Get.showSnackbar(
      GetSnackBar(
        backgroundColor: AppColors.red,
        animationDuration: const Duration(seconds: 2),
        duration: const Duration(seconds: 3),
        messageText: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextWidget(
              text: "Error!",
              fontColor: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
            TextWidget(
              text: parameterValue,
              fontColor: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }

  // >>>>>>>>>>>>>>>>>>>>>> success message <<<<<<<<<<<<<<<<<<<<<<

  static success(String parameterValue) {
    Get.showSnackbar(
      GetSnackBar(
        backgroundColor: AppColors.green,
        animationDuration: const Duration(seconds: 3),
        duration: const Duration(seconds: 3),
        messageText: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextWidget(
              text: "Success!",
              fontColor: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
            TextWidget(
              text: parameterValue,
              fontColor: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }

  // >>>>>>>>>>>>>>>>>>>>>> message  <<<<<<<<<<<<<<<<<<<<<<
  // >>>>>>>>>>>>>>>>>>>>>> only show message <<<<<<<<<<<<<<<<<<<<<<

  static message(String parameterValue) {
    Get.showSnackbar(
      GetSnackBar(
        backgroundColor: AppColors.black,
        animationDuration: const Duration(seconds: 2),
        duration: const Duration(seconds: 3),
        messageText: TextWidget(
          text: parameterValue,
          fontColor: AppColors.white,
          fontSize: 16,
          textAlignment: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        borderRadius: AppSize.width(value: 20.0),
        padding: EdgeInsets.all(AppSize.width(value: 10.0)),
        margin: EdgeInsets.symmetric(
            horizontal: AppSize.width(value: 40.0),
            vertical: AppSize.width(value: 30)),
      ),
    );
  }
}
