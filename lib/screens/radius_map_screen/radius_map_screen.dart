import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';

import '../../constants/app_strings.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_size.dart';
import '../../widgets/button_widget/button_widget.dart';

class RadiusMapScreen extends StatelessWidget {
  const RadiusMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImagePath.radiusMapBg),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    borderRadius: BorderRadius.circular(100),
                    child: Card(
                      color: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 3,
                      child: CircleAvatar(
                        backgroundColor: AppColors.white,
                        radius: ResponsiveUtils.width(30),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                  ButtonWidget(
                    onPressed: () {
                      Get.toNamed(AppRoutes.parcelForDeliveryScreen);
                    },
                    label: AppStrings.next,
                    textColor: AppColors.white,
                    buttonWidth: 105,
                    buttonHeight: 50,
                    icon: Icons.arrow_forward,
                    iconColor: AppColors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    iconSize: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
