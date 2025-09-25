import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/screens/booking_screen/current_order/controller/current_order_controller.dart';

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
  final CurrentOrderController newBookingController =
      Get.put(CurrentOrderController());
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
          if (newBookingController.currentOrdersModel.value.data!.first
              .deliveryRequests!.isNotEmpty)
            ...List.generate(images.length, (index) {
              return Container(
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
                        // Left Column with user details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row(
                              //   children: [
                              //     ClipRRect(
                              //       borderRadius: BorderRadius.circular(100),
                              //       child: AppImage(
                              //         url: newBookingController
                              //             .currentOrdersModel
                              //             .value
                              //             .data!
                              //             .first
                              //             .deliveryRequests
                              //             !.first
                              //             .image,
                              //         height: 40,
                              //         width: 40,
                              //       ),
                              //     ),
                              //     const SpaceWidget(spaceWidth: 8),
                              //     TextWidget(
                              //       text: newBookingController
                              //               .currentOrdersModel
                              //               .value
                              //               .data
                              //               ?.first
                              //               .deliveryRequests
                              //               ?.first
                              //               .fullName ??
                              //           '',
                              //       fontSize: 15.5,
                              //       fontWeight: FontWeight.w500,
                              //       fontColor: AppColors.black,
                              //     ),
                              //   ],
                              // ),
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
                                  TextWidget(
                                    text: newBookingController
                                            .currentOrdersModel
                                            .value
                                            .data!
                                            .first
                                            .title ??
                                        '',
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
                                  SpaceWidget(spaceWidth: 4),
                                  TextWidget(
                                    text: 'Western Wall to 4 lebri street',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontColor: AppColors.greyDark2,
                                    overflow: TextOverflow.ellipsis,
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
                        ),
                        // Right Column with price and publication date
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const TextWidget(
                              text: "${AppStrings.currency} 150",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontColor: AppColors.black,
                            ),
                            const SpaceWidget(spaceHeight: 60),
                            TextWidget(
                              text: "recentlyPublished".tr,
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
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.close,
                                  color: AppColors.red,
                                  size: 18,
                                ),
                                const SpaceWidget(spaceWidth: 4),
                                TextWidget(
                                  text: "reject".tr,
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
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.remove_red_eye_outlined,
                                  color: AppColors.black,
                                  size: 18,
                                ),
                                const SpaceWidget(spaceWidth: 4),
                                TextWidget(
                                  text: "view".tr,
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
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check,
                                  color: AppColors.green,
                                  size: 18,
                                ),
                                const SpaceWidget(spaceWidth: 4),
                                TextWidget(
                                  text: "accept".tr,
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
