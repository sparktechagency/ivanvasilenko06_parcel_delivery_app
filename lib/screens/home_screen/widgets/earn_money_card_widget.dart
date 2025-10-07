import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_image_path.dart';
import '../../../widgets/button_widget/button_widget.dart';
import '../../../widgets/image_widget/image_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class EarnMoneyCardWidget extends StatelessWidget {
  final VoidCallback onTap;

  const EarnMoneyCardWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.greyLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: ImageWidget(
              height: 160,
              width: double.infinity,
              imagePath: AppImagePath.earnMoney,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: "earnMoneyDesc".tr,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.black,
                  textAlignment: TextAlign.start,
                ),
                const SpaceWidget(spaceHeight: 12),
                ButtonWidget(
                  onPressed: onTap,
                  label: "earnMoneyInYourRadius".tr,
                  buttonWidth: 270,
                  buttonHeight: 50,
                  fontSize: 15.5,
                  icon: Platform.isIOS==true
                                      ? Icons.arrow_forward_ios
                                      : Icons.arrow_forward,
                  iconSize: 18,
                  iconColor: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
