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
import '../services_screen/model/promote_delivery_parcel.dart';

class DeliveryDetailsScreen extends StatelessWidget {
  final DeliveryPromote item; 

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
                        text:
                            "Details of Parcel", 
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
                  SummaryInfoRowWidget(
                    icon: AppIconsPath.deliveryTimeIcon,
                    label: "deliveryTimeText".tr,
                    value: item.deliveryTime ??
                        "N/A", // Use item field for delivery time
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  SummaryInfoRowWidget(
                    icon: AppIconsPath.destinationIcon,
                    label: "currentLocationText".tr,
                    value: item.pickupLocation ??
                        "N/A", // Use item field for current location
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  SummaryInfoRowWidget(
                    icon: AppIconsPath.currentLocationIcon,
                    label: "destinationText".tr,
                    value: item.deliveryLocation ??
                        "N/A", // Use item field for destination
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  SummaryInfoRowWidget(
                    icon: AppIconsPath.profileIcon,
                    label: "receiversName".tr,
                    value: item.deliveryType ??
                        "N/A", // Use item field for receiver's name
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  SummaryInfoRowWidget(
                    icon: AppIconsPath.callIcon,
                    label: "receiversNumber".tr,
                    value: item.senderType ??
                        "N/A", // Use item field for receiver's number
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  SummaryInfoRowWidget(
                    icon: AppIconsPath.descriptionIcon,
                    label: "descriptionText".tr,
                    value: item.createdAt ??
                        "N/A", // Use item field for description
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
