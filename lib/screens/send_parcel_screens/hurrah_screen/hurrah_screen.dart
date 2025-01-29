import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class HurrahScreen extends StatelessWidget {
  const HurrahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        Get.offAll(() =>
            const BottomNavScreen()); // Replaces current screen with HomeScreen
      });
    });
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ImageWidget(
              height: 80,
              width: 80,
              imagePath: AppImagePath.hurrahImage,
            ),
          ),
          const SpaceWidget(spaceHeight: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextWidget(
              text: AppStrings.hurray,
              fontSize: 33,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.black,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SpaceWidget(spaceHeight: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextWidget(
              text: AppStrings.hurrayDesc,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.black,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
