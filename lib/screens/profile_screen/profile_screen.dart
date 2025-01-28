import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/profile_screen/widgets/profile_card_widget.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_image_path.dart';
import '../../constants/app_strings.dart';
import '../../widgets/image_widget/image_widget.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 48),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TextWidget(
                  text: AppStrings.profile,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.black,
                  fontStyle: FontStyle.italic,
                ),
                PopupMenuButton<int>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.black,
                    size: 24,
                  ),
                  color: AppColors.white,
                  onSelected: (value) {
                    if (value == 1) {
                      Get.toNamed(AppRoutes.contactUsScreen);
                    } else if (value == 2) {
                      // Handle "About" action
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 1,
                      child: Text(AppStrings.contactUs),
                    ),
                    // const PopupMenuItem(
                    //   value: 2,
                    //   child: Text("About"),
                    // ),
                  ],
                ),
              ],
            ),
          ),
          const SpaceWidget(spaceHeight: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: ResponsiveUtils.width(120),
                    height: ResponsiveUtils.width(120),
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: SizedBox(
                            width: ResponsiveUtils.width(120),
                            height: ResponsiveUtils.width(120),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: const ImageWidget(
                                imagePath: AppImagePath.profileImage,
                                height: 116,
                                width: 116,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Positioned(
                            child: Container(
                              width: ResponsiveUtils.width(45),
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
                                    size: 12,
                                  ),
                                  TextWidget(
                                    text: AppStrings.ratings,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontColor: AppColors.white,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SpaceWidget(spaceHeight: 16),
                  const TextWidget(
                    text: AppStrings.basicInfo,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontColor: AppColors.greyDark2,
                    fontStyle: FontStyle.italic,
                  ),
                  const SpaceWidget(spaceHeight: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: AppColors.greyLight,
                        width: 1.5,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconWidget(
                              height: 14,
                              width: 14,
                              icon: AppIconsPath.basicInfoIcon1,
                            ),
                            SpaceWidget(spaceWidth: 6),
                            TextWidget(
                              text: AppStrings.orderCompleted,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontColor: AppColors.greyDark2,
                              fontStyle: FontStyle.italic,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconWidget(
                              height: 14,
                              width: 14,
                              icon: AppIconsPath.basicInfoIcon2,
                            ),
                            SpaceWidget(spaceWidth: 6),
                            TextWidget(
                              text: AppStrings.orderDelivered,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontColor: AppColors.greyDark2,
                              fontStyle: FontStyle.italic,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconWidget(
                              height: 14,
                              width: 14,
                              icon: AppIconsPath.basicInfoIcon3,
                            ),
                            SpaceWidget(spaceWidth: 6),
                            TextWidget(
                              text: AppStrings.orderReceived,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontColor: AppColors.greyDark2,
                              fontStyle: FontStyle.italic,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const Divider(
                    color: AppColors.grey,
                    thickness: 1,
                  ),
                  const ProfileCardWidget(
                    titleText: AppStrings.credits,
                    subtitleText: AppStrings.yourEarning,
                    additionalText: AppStrings.yourEarningAmount,
                  ),
                  const Divider(
                    color: AppColors.grey,
                    thickness: 1,
                  ),
                  const ProfileCardWidget(
                    titleText: AppStrings.name,
                    subtitleText: AppStrings.ivan,
                  ),
                  const Divider(
                    color: AppColors.grey,
                    thickness: 1,
                  ),
                  const ProfileCardWidget(
                    titleText: AppStrings.phoneNumber,
                    subtitleText: AppStrings.number,
                  ),
                  const Divider(
                    color: AppColors.grey,
                    thickness: 1,
                  ),
                  const ProfileCardWidget(
                    titleText: AppStrings.verifiedEmail,
                    subtitleText: AppStrings.emailId,
                    badgeIcon: AppIconsPath.badgeIcon,
                  ),
                  const Divider(
                    color: AppColors.grey,
                    thickness: 1,
                  ),
                  const SpaceWidget(spaceHeight: 16),
                  const TextWidget(
                    text: AppStrings.addTrustOverYou,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontColor: AppColors.greyDark2,
                    fontStyle: FontStyle.italic,
                  ),
                  const ProfileCardWidget(
                    titleText: AppStrings.facebook,
                    subtitleText: AppStrings.emailId,
                  ),
                  const Divider(
                    color: AppColors.grey,
                    thickness: 1,
                  ),
                  const ProfileCardWidget(
                    titleText: AppStrings.instagram,
                    subtitleText: AppStrings.instagramId,
                  ),
                  const Divider(
                    color: AppColors.grey,
                    thickness: 1,
                  ),
                  const ProfileCardWidget(
                    titleText: AppStrings.whatsapp,
                    subtitleText: AppStrings.number,
                  ),
                  const SpaceWidget(spaceHeight: 80),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
