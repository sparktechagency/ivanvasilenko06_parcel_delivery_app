import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/screens/delivery_parcel_screens/summary_of_parcel_screen/widgets/summary_info_row_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_icons_path.dart';
import '../../../constants/app_strings.dart';
import '../../../utils/app_size.dart';
import '../../../widgets/button_widget/button_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class SummaryOfParcelScreen extends StatelessWidget {
  const SummaryOfParcelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 48),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextWidget(
              text: AppStrings.summaryOfParcel,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.black,
              fontStyle: FontStyle.italic,
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
                        text: AppStrings.parcel1,
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
                  const SummaryInfoRowWidget(
                    image: AppImagePath.profileImage,
                    label: AppStrings.sendersName,
                    value: AppStrings.joshua,
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const SummaryInfoRowWidget(
                    icon: AppIconsPath.ratingIcon,
                    label: AppStrings.ratingsText,
                    value: AppStrings.ratings,
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const SummaryInfoRowWidget(
                    icon: AppIconsPath.profileIcon,
                    label: AppStrings.receiversName,
                    value: AppStrings.arial,
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const SummaryInfoRowWidget(
                    icon: AppIconsPath.callIcon,
                    label: AppStrings.receiversNumber,
                    value: AppStrings.number,
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const SummaryInfoRowWidget(
                    icon: AppIconsPath.deliveryTimeIcon,
                    label: AppStrings.deliveryTimeText,
                    value: AppStrings.deliveryTime,
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const SummaryInfoRowWidget(
                    icon: AppIconsPath.currentLocationIcon,
                    label: AppStrings.currentLocationText,
                    value: AppStrings.currentLocation,
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const SummaryInfoRowWidget(
                    icon: AppIconsPath.destinationIcon,
                    label: AppStrings.destinationText,
                    value: AppStrings.destination,
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const SummaryInfoRowWidget(
                    icon: AppIconsPath.priceIcon,
                    label: AppStrings.price,
                    value: "${AppStrings.currency} 150",
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const SummaryInfoRowWidget(
                    icon: AppIconsPath.descriptionIcon,
                    label: AppStrings.descriptionText,
                    value: AppStrings.description,
                  ),
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
              onPressed: () {},
              label: AppStrings.sendRequest,
              textColor: AppColors.white,
              buttonWidth: 180,
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
