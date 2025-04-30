import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

import '../../constants/app_icons_path.dart';
import '../booking_parcel_details_screen/widgets/summary_info_row_widget.dart';

class DeliveryDetailsScreen extends StatelessWidget {
  final dynamic item; // Correctly define the item parameter as Data

  const DeliveryDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextWidget(
              text: "summaryOfYourParcel".tr,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
            ),
          ),
          const SpaceWidget(spaceHeight: 40),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: const ImageWidget(
                          height: 40,
                          width: 40,
                          imagePath: AppImagePath.sendParcel,
                        ),
                      ),
                      const SpaceWidget(spaceWidth: 8),
                      const TextWidget(
                        text: "Details of Parcel",
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontColor: AppColors.black,
                      ),
                    ],
                  ),
                  const SpaceWidget(spaceHeight: 16),
                  const Divider(
                    color: AppColors.grey,
                    thickness: 1,
                  ),
                  const SpaceWidget(spaceHeight: 16),
                  // Updated to handle nested properties properly
                  SummaryInfoRowWidget(
                    icon: AppIconsPath.deliveryTimeIcon,
                    label: "deliveryTimeText".tr,
                    value: item.deliveryType ?? "N/A", // Fixed field usage
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  // Correctly access nested coordinates
                  SummaryInfoRowWidget(
                    icon: AppIconsPath.destinationIcon,
                    label: "currentLocationText".tr,
                    value: item.pickupLocation?.coordinates?.join(", ") ??
                        "N/A", // Access coordinates properly
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  // Correctly access delivery location coordinates
                  SummaryInfoRowWidget(
                    icon: AppIconsPath.currentLocationIcon,
                    label: "destinationText".tr,
                    value: item.deliveryLocation?.coordinates?.join(", ") ??
                        "N/A", // Access coordinates properly
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  SummaryInfoRowWidget(
                    icon: AppIconsPath.profileIcon,
                    label: "receiversName".tr,
                    value: item.name ??
                        "N/A", // Use item.name for the receiver's name
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  SummaryInfoRowWidget(
                    icon: AppIconsPath.callIcon,
                    label: "receiversNumber".tr,
                    value: item.phoneNumber ?? "N/A", // Correct field usage
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  SummaryInfoRowWidget(
                    icon: AppIconsPath.descriptionIcon,
                    label: "descriptionText".tr,
                    value: item.status ?? "N/A", // Correct field usage
                  ),
                  const SpaceWidget(spaceHeight: 8),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                child: const CircleAvatar(
                  backgroundColor: AppColors.white,
                  radius: 25, // Adjust the size if needed
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
            ButtonWidget(
              onPressed: () async {
                // Add any additional action on finish button if needed
              },
              label: "finish".tr,
              textColor: AppColors.white,
              buttonWidth: 112,
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
    );
  }
}
