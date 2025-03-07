import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_image_path.dart';
import '../../constants/app_strings.dart';
import '../../utils/app_size.dart';
import '../../widgets/image_widget/image_widget.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';

class NotificationScreen extends StatefulWidget {
  NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<String> images = [
    AppImagePath.profileImage,
    AppImagePath.profileImage,
    AppImagePath.profileImage,
    AppImagePath.profileImage,
    AppImagePath.profileImage,
    AppImagePath.profileImage,
  ];

  final List<String> names = [
    AppStrings.joshua,
    AppStrings.joshua,
    AppStrings.joshua,
    AppStrings.joshua,
    AppStrings.joshua,
    AppStrings.joshua,
  ];

  final List<String> details = [
    AppStrings.parcelDetails,
    AppStrings.viewDetails,
    AppStrings.parcelDetails,
    AppStrings.parcelDetails,
    AppStrings.viewDetails,
    AppStrings.parcelDetails,
  ];

  // List to track the status (accepted, rejected, or pending)
  List<String> status = List.generate(6, (index) => 'pending'); // Initial status is 'pending'

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
              text: "notification".tr,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
            ),
          ),
          const SpaceWidget(spaceHeight: 24),
          Expanded(
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      const SpaceWidget(spaceHeight: 8),
                      ...List.generate(images.length, (index) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(100),
                                            child: ImageWidget(
                                              height: 40,
                                              width: 40,
                                              imagePath: images[index],
                                            ),
                                          ),
                                          const SpaceWidget(spaceWidth: 8),
                                          TextWidget(
                                            text: names[index],
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
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
                                          ),
                                        ],
                                      ),
                                      const SpaceWidget(spaceHeight: 16),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: TextWidget(
                                      text: "${AppStrings.currency} 150",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontColor: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SpaceWidget(spaceHeight: 16),
                              // Conditionally render the status in the container
                              status[index] == 'pending'
                                  ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.whiteLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          status[index] = 'rejected'; // Change to 'rejected'
                                        });
                                      },
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.close,
                                            color: AppColors.red,
                                            size: 16,
                                          ),
                                          const SpaceWidget(spaceWidth: 4),
                                          TextWidget(
                                            text: "reject".tr,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontColor: AppColors.red,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: AppColors.blackLighter,
                                    ),
                                    InkWell(
                                      onTap: () {},
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.remove_red_eye_outlined,
                                            color: AppColors.black,
                                            size: 14,
                                          ),
                                          const SpaceWidget(spaceWidth: 4),
                                          TextWidget(
                                            text: "view".tr,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontColor: AppColors.greyDark2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: AppColors.blackLighter,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          status[index] = 'accepted'; // Change to 'accepted'
                                        });
                                      },
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.check,
                                            color: AppColors.green,
                                            size: 14,
                                          ),
                                          const SpaceWidget(spaceWidth: 4),
                                          TextWidget(
                                            text: "accept".tr,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontColor: AppColors.green,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  : Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.whiteLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    TextWidget(
                                      text: status[index] == 'accepted'
                                          ? "Accepted"
                                          : "Rejected",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontColor: status[index] == 'accepted'
                                          ? AppColors.green
                                          : AppColors.red,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SpaceWidget(spaceHeight: 16),
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: InkWell(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
