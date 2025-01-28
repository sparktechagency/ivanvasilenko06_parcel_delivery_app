import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/bottom_nav_bar.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../utils/app_size.dart';
import '../../widgets/button_widget/button_widget.dart';
import '../../widgets/image_widget/image_widget.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';

class ParcelForDeliveryScreen extends StatelessWidget {
  const ParcelForDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 48),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextWidget(
              text: AppStrings.parcelForDelivery,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.black,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SpaceWidget(spaceHeight: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  ...List.generate(5, (index) {
                    return ParcelItem(
                      parcelName: 'Parcel ${index + 1}',
                      rating: 4.5,
                      price: 150,
                      address: 'Western Wall to 4 lebri street',
                      date: '24-04-2024',
                      isRequestSent:
                          index == 2, // Highlight request sent for item 3
                    );
                  }),
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
              onPressed: () {
                Get.offAll(() => const BottomNavScreen());
              },
              label: AppStrings.backToHome,
              textColor: AppColors.white,
              buttonWidth: 175,
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

class ParcelItem extends StatelessWidget {
  final String parcelName;
  final double rating;
  final int price;
  final String address;
  final String date;
  final bool isRequestSent;

  const ParcelItem({
    super.key,
    required this.parcelName,
    required this.rating,
    required this.price,
    required this.address,
    required this.date,
    this.isRequestSent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: const ImageWidget(
                        imagePath: AppImagePath.sendParcel,
                        width: 40,
                        height: 40,
                      ),
                    ),
                    const SpaceWidget(spaceWidth: 12),
                    TextWidget(
                      text: parcelName,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontColor: AppColors.black,
                    ),
                    const SpaceWidget(spaceWidth: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.yellow,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.white,
                            size: 10,
                          ),
                          TextWidget(
                            text: AppStrings.ratings,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontColor: AppColors.white,
                            fontStyle: FontStyle.italic,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const TextWidget(
                  text: "${AppStrings.currency} 150",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontColor: AppColors.black,
                ),
              ],
            ),
            const SpaceWidget(spaceHeight: 8),
            const Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: AppColors.black,
                  size: 12,
                ),
                SpaceWidget(spaceWidth: 8),
                TextWidget(
                  text: 'Western Wall to 4 lebri street',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.greyDark2,
                  fontStyle: FontStyle.italic,
                ),
              ],
            ),
            const SpaceWidget(spaceHeight: 8),
            const Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: AppColors.black,
                  size: 12,
                ),
                SpaceWidget(spaceWidth: 8),
                TextWidget(
                  text: '24-04-2024',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.greyDark2,
                  fontStyle: FontStyle.italic,
                ),
              ],
            ),
            const SpaceWidget(spaceHeight: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.whiteLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: isRequestSent ? null : () {},
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_2_outlined,
                          color: isRequestSent ? Colors.grey : Colors.black,
                          size: 14,
                        ),
                        const SpaceWidget(spaceWidth: 8),
                        TextWidget(
                          text: isRequestSent ? 'Request Sent' : 'Send Request',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontColor: AppColors.greyDark2,
                          fontStyle: FontStyle.italic,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: isRequestSent ? null : () {},
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: const Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          color: Colors.black,
                          size: 14,
                        ),
                        SpaceWidget(spaceWidth: 8),
                        TextWidget(
                          text: 'View Summary',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontColor: AppColors.greyDark2,
                          fontStyle: FontStyle.italic,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
