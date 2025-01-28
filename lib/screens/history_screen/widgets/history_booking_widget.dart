import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_image_path.dart';
import '../../../constants/app_strings.dart';
import '../../../widgets/image_widget/image_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class HistoryBookingWidget extends StatefulWidget {
  const HistoryBookingWidget({super.key});

  @override
  State<HistoryBookingWidget> createState() => _HistoryBookingWidgetState();
}

class _HistoryBookingWidgetState extends State<HistoryBookingWidget> {
  final List<String> images = [
    AppImagePath.sendParcel,
    AppImagePath.sendParcel,
    AppImagePath.sendParcel,
    AppImagePath.sendParcel,
    AppImagePath.sendParcel,
    AppImagePath.sendParcel,
  ];

  final List<String> names = [
    AppStrings.parcel,
    AppStrings.parcel,
    AppStrings.parcel,
    AppStrings.parcel,
    AppStrings.parcel,
    AppStrings.parcel,
  ];

  final List<String> details = [
    AppStrings.parcelDetails,
    AppStrings.viewDetails,
    AppStrings.parcelDetails,
    AppStrings.parcelDetails,
    AppStrings.viewDetails,
    AppStrings.parcelDetails,
  ];

  final List<String> status = [
    AppStrings.cancelled,
    AppStrings.received,
    AppStrings.republish,
    AppStrings.cancelled,
    AppStrings.received,
    AppStrings.republish,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              elevation: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
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
                              fontStyle: FontStyle.italic,
                            ),
                          ],
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        const Row(
                          children: [
                            Icon(
                              Icons.call,
                              color: AppColors.black,
                              size: 12,
                            ),
                            SpaceWidget(spaceWidth: 8),
                            TextWidget(
                              text: '+375 292316347',
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
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const TextWidget(
                          text: "${AppStrings.currency} 150",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontColor: AppColors.black,
                        ),
                        const SpaceWidget(spaceHeight: 30),
                        TextWidget(
                          text: status[index],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontColor: status[index] == AppStrings.cancelled
                              ? AppColors.red
                              : status[index] == AppStrings.received
                                  ? AppColors.green
                                  : status[index] == AppStrings.republish
                                      ? AppColors.greyDark2
                                      : AppColors.black,
                          // Default color if none of the conditions match

                          fontStyle: FontStyle.italic,
                        ),
                        const SpaceWidget(spaceHeight: 8),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
