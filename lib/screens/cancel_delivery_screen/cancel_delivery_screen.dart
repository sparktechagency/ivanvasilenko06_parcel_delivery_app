import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:parcel_delivery_app/screens/delivery_parcel_screens/summary_of_parcel_screen/widgets/summary_info_row_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_icons_path.dart';
import '../../../constants/app_strings.dart';
import '../../../utils/app_size.dart';
import '../../../widgets/button_widget/button_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class CancelDeliveryScreen extends StatefulWidget {
  const CancelDeliveryScreen({super.key});

  @override
  State<CancelDeliveryScreen> createState() => _CancelDeliveryScreenState();
}

class _CancelDeliveryScreenState extends State<CancelDeliveryScreen> {
  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: ResponsiveUtils.height(5),
                      width: ResponsiveUtils.width(50),
                      decoration: BoxDecoration(
                        color: AppColors.greyDark,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SpaceWidget(spaceHeight: 32),
                  const Center(
                    child: TextWidget(
                      text: AppStrings.experience,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.black,
                    ),
                  ),
                  const SpaceWidget(spaceHeight: 10),
                  Center(
                    child: RatingBar.builder(
                      initialRating: 1,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 14),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star_border,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        print('Rating: $rating');
                      },
                    ),
                  ),
                  const SpaceWidget(spaceHeight: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: AppStrings.veryBad,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontColor: AppColors.greyLight2,
                        ),
                        TextWidget(
                          text: AppStrings.veryGood,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontColor: AppColors.greyLight2,
                        ),
                      ],
                    ),
                  ),
                  const SpaceWidget(spaceHeight: 32),
                  ButtonWidget(
                    onPressed: () {
                      Get.offAll(const BottomNavScreen());
                    },
                    label: AppStrings.submit,
                    buttonWidth: double.infinity,
                    buttonHeight: 50,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
              text: AppStrings.summary,
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
                    icon: AppIconsPath.destinationIcon,
                    label: AppStrings.currentLocationText,
                    value: AppStrings.currentLocation,
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const SummaryInfoRowWidget(
                    icon: AppIconsPath.currentLocationIcon,
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
                  radius: ResponsiveUtils.width(25),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
            ButtonWidget(
              onPressed: () {
                _openBottomSheet(context);
              },
              label: AppStrings.cancelDelivery,
              textColor: AppColors.white,
              buttonWidth: 200,
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
