import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_image_path.dart';
import '../../../constants/app_strings.dart';
import '../../../widgets/image_widget/image_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class NewBookingWidget extends StatefulWidget {
  const NewBookingWidget({super.key});

  @override
  State<NewBookingWidget> createState() => _NewBookingWidgetState();
}

class _NewBookingWidgetState extends State<NewBookingWidget> {
  final List<String> images = [
    AppImagePath.joshuaImage,
    AppImagePath.joshuaImage,
    AppImagePath.joshuaImage,
  ];

  final List<String> names = [
    AppStrings.joshua,
    AppStrings.joshua,
    AppStrings.joshua,
  ];

  final List<String> details = [
    AppStrings.parcelDetails,
    AppStrings.viewDetails,
    AppStrings.parcelDetails,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          const SpaceWidget(spaceHeight: 8),
          ...List.generate(images.length, (index) {
            return
                //Card(
                // color: AppColors.white,
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(12),
                // ),
                // margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                // elevation: 3,
                // child:
                Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(left: 8, right: 8, bottom: 0),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                fontSize: 15.5,
                                fontWeight: FontWeight.w500,
                                fontColor: AppColors.black,
                              ),
                              names[index] == AppStrings.joshua
                                  ? const SpaceWidget(spaceWidth: 8)
                                  : const SizedBox.shrink(),
                              names[index] == AppStrings.joshua
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.yellow,
                                        borderRadius:
                                            BorderRadius.circular(100),
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
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                          const SpaceWidget(spaceHeight: 16),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: const ImageWidget(
                                  imagePath: AppImagePath.sendParcel,
                                  height: 14,
                                  width: 14,
                                ),
                              ),
                              const SpaceWidget(spaceWidth: 8),
                              const TextWidget(
                                text: 'Parcel 1',
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
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextWidget(
                            text: "${AppStrings.currency} 150",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontColor: AppColors.black,
                          ),
                          SpaceWidget(spaceHeight: 60),
                          TextWidget(
                            text: 'Recently Published',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontColor: AppColors.greyDark2,
                          ),
                        ],
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                size: 18,
                              ),
                              SpaceWidget(spaceWidth: 4),
                              TextWidget(
                                text: AppStrings.reject,
                                fontSize: 16,
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
                          child: const Row(
                            children: [
                              Icon(
                                Icons.remove_red_eye_outlined,
                                color: AppColors.black,
                                size: 18,
                              ),
                              SpaceWidget(spaceWidth: 4),
                              TextWidget(
                                text: AppStrings.view,
                                fontSize: 16,
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
                          onTap: () {},
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: const Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: AppColors.green,
                                size: 18,
                              ),
                              SpaceWidget(spaceWidth: 4),
                              TextWidget(
                                text: AppStrings.accept,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontColor: AppColors.green,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
            // );
          }),
          const SpaceWidget(spaceHeight: 80),
        ],
      ),
    );
  }
}
