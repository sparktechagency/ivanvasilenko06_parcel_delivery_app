import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/text_button_widget/text_button_widget.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_icons_path.dart';
import '../../constants/app_image_path.dart';
import '../../constants/app_strings.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_size.dart';
import '../../widgets/icon_widget/icon_widget.dart';
import '../../widgets/image_widget/image_widget.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';
import '../home_screen/widgets/reserve_bottom_sheet_widget.dart';
import '../home_screen/widgets/suggestionCardWidget.dart';

class ServicesScreen extends StatefulWidget {
  ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final List<String> images = [
    AppImagePath.sendParcel,
    AppImagePath.sendParcel,
    AppImagePath.sendParcel,
  ];

  final List<String> title = [
    'Parcel 1',
    'Parcel 2',
    'Parcel 3',
  ];

  final List<String> address = [
    'Western Wall',
    'Western Wall',
    'Western Wall',
  ];
  double _currentValue = 5.0;

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
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 26),
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
                  const SpaceWidget(spaceHeight: 23),
                  const TextWidget(
                    text: AppStrings.chooseRadius,
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                    fontColor: AppColors.black,
                  ),
                  const SpaceWidget(spaceHeight: 12),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: const ImageWidget(
                          height: 50,
                          width: 50,
                          imagePath: AppImagePath.sendParcel,
                        ),
                      ),
                      const SpaceWidget(spaceWidth: 8),
                      const TextWidget(
                        text: AppStrings.orderName,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontColor: AppColors.black,
                      ),
                    ],
                  ),
                  const SpaceWidget(spaceWidth: 16),
                  // Local state for slider value
                  StatefulBuilder(
                    builder: (context, sliderSetState) {
                      return Column(
                        children: [
                          Text(
                            '${_currentValue.round()} Km',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SpaceWidget(spaceWidth: 0),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.black,
                              inactiveTrackColor: Colors.grey.shade200,
                              thumbColor: Colors.black,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 12),
                              overlayColor: Colors.black.withOpacity(0.2),
                              trackHeight: 6.0,
                            ),
                            child: Slider(
                              value: _currentValue,
                              min: 0,
                              max: 50,
                              divisions: 50,
                              // label: '${_currentValue.round()} Km',
                              onChanged: (value) {
                                sliderSetState(() {
                                  _currentValue = value;
                                });
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('0km'),
                                Text('50km'),
                              ],
                            ),
                          ),
                          const SpaceWidget(spaceHeight: 32),
                          Row(
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
                                  Get.toNamed(AppRoutes.radiusMapScreen);
                                },
                                label: AppStrings.next,
                                textColor: AppColors.white,
                                buttonWidth: 105,
                                buttonHeight: 50,
                                icon: Icons.arrow_forward,
                                iconColor: AppColors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                iconSize: 20,
                              ),
                            ],
                          ),
                          const SpaceWidget(spaceHeight: 32),
                        ],
                      );
                    },
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SpaceWidget(spaceHeight: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TextWidget(
                  text: AppStrings.services,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontColor: AppColors.black,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: "Notifications",
                      onPressed: () {
                        Get.toNamed(AppRoutes.notificationScreen);
                      },
                      icon: const Badge(
                        isLabelVisible: true,
                        label: Text('1'),
                        backgroundColor: AppColors.red,
                        child: IconWidget(
                          icon: AppIconsPath.notificationIcon,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                    const SpaceWidget(spaceWidth: 12),
                    const ImageWidget(
                      height: 40,
                      width: 40,
                      imagePath: AppImagePath.profileImage,
                    )
                  ],
                )
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SpaceWidget(spaceHeight: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: SuggestionCardWidget(
                            onTap: () {
                              Get.toNamed(AppRoutes.deliveryTypeScreen);
                            },
                            text: AppStrings.deliverParcel,
                            imagePath: AppImagePath.deliverParcel,
                          ),
                        ),
                        const SpaceWidget(spaceWidth: 16),
                        Expanded(
                          flex: 1,
                          child: SuggestionCardWidget(
                            onTap: () {
                              Get.toNamed(AppRoutes.senderDeliveryTypeScreen);
                            },
                            text: AppStrings.sendParcel,
                            imagePath: AppImagePath.sendParcel,
                          ),
                        ),
                        const SpaceWidget(spaceWidth: 16),
                        Expanded(
                          flex: 1,
                          child: SuggestionCardWidget(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (BuildContext context) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(24),
                                        topRight: Radius.circular(24),
                                      ),
                                    ),
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 24, horizontal: 32),
                                    child: const ReserveBottomSheetWidget(),
                                  );
                                },
                              );
                            },
                            text: AppStrings.reserve,
                            imagePath: AppImagePath.reserve,
                          ),
                        ),
                      ],
                    ),
                    const SpaceWidget(spaceHeight: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TextWidget(
                          text: AppStrings.recentPublishedOrders,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontColor: AppColors.black,
                        ),
                        TextButtonWidget(
                          onPressed: () {},
                          text: AppStrings.viewAll,
                          textColor: AppColors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                    const SpaceWidget(spaceHeight: 14),
                    ...List.generate(images.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                ImageWidget(
                                  height: 51,
                                  width: 65,
                                  imagePath: images[index],
                                ),
                                const SpaceWidget(spaceWidth: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: title[index],
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w500,
                                      fontColor: AppColors.black,
                                    ),
                                    const SpaceWidget(spaceHeight: 4),
                                    TextWidget(
                                      text: address[index],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      fontColor: AppColors.black,
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
                                TextButtonWidget(
                                  onPressed: () {},
                                  text: AppStrings.seeDetails,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  textColor: AppColors.greyDark2,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    const SpaceWidget(spaceHeight: 14),
                    const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      child: ImageWidget(
                        height: 180,
                        width: double.infinity,
                        imagePath: AppImagePath.servicesImage,
                      ),
                    ),
                    const SpaceWidget(spaceHeight: 14),
                    ButtonWidget(
                      onPressed: () {
                        _openBottomSheet(context);
                      },
                      label: AppStrings.earnMoneyInYourRadius,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      buttonWidth: double.infinity,
                      buttonHeight: 50,
                      prefixIcon: AppIconsPath.earnMoneyRadiusIcon,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
