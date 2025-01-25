import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_image_path.dart';
import '../../constants/app_strings.dart';
import '../../utils/app_size.dart';
import '../../widgets/image_widget/image_widget.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';

class NotificationScreen extends StatelessWidget {
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

  NotificationScreen({super.key});

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
              text: AppStrings.notification,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.black,
              fontStyle: FontStyle.italic,
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
                        return Card(
                          color: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 16),
                          elevation: 3,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
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
                                            names[index] == AppStrings.joshua
                                                ? const SpaceWidget(
                                                    spaceWidth: 8)
                                                : const SizedBox.shrink(),
                                            names[index] == AppStrings.joshua
                                                ? Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.yellow,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                    ),
                                                    child: const Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star_rounded,
                                                          color:
                                                              AppColors.white,
                                                          size: 10,
                                                        ),
                                                        TextWidget(
                                                          text: AppStrings
                                                              .ratings,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontColor:
                                                              AppColors.white,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
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
                                              text:
                                                  'Western Wall to 4 lebri street',
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
                                Container(
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
                                        onTap: () {},
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.close,
                                              color: AppColors.red,
                                              size: 16,
                                            ),
                                            SpaceWidget(spaceWidth: 4),
                                            TextWidget(
                                              text: AppStrings.reject,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              fontColor: AppColors.red,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {},
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.remove_red_eye_outlined,
                                              color: AppColors.black,
                                              size: 14,
                                            ),
                                            SpaceWidget(spaceWidth: 4),
                                            TextWidget(
                                              text: AppStrings.view,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              fontColor: AppColors.greyDark2,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {},
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.check,
                                              color: AppColors.green,
                                              size: 14,
                                            ),
                                            SpaceWidget(spaceWidth: 4),
                                            TextWidget(
                                              text: AppStrings.accept,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              fontColor: AppColors.green,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                        radius: ResponsiveUtils.width(30),
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
