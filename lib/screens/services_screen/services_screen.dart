import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/text_button_widget/text_button_widget.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_image_path.dart';
import '../../constants/app_strings.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_size.dart';
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
                  const SpaceWidget(spaceHeight: 20),
                  const TextWidget(
                    text: AppStrings.chooseRadius,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    fontColor: AppColors.black,
                    fontStyle: FontStyle.italic,
                  ),
                  const SpaceWidget(spaceHeight: 12),
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
                        text: AppStrings.orderName,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontColor: AppColors.black,
                        fontStyle: FontStyle.italic,
                      ),
                    ],
                  ),
                  // Local state for slider value
                  StatefulBuilder(
                    builder: (context, sliderSetState) {
                      return Column(
                        children: [
                          Stack(
                            alignment: AlignmentDirectional.topCenter,
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.black,
                                  inactiveTrackColor: Colors.grey.shade300,
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
                                  label: '${_currentValue.round()} Km',
                                  onChanged: (value) {
                                    sliderSetState(() {
                                      _currentValue = value;
                                    });
                                  },
                                ),
                              ),
                              Positioned(
                                top: 0,
                                child: Text(
                                  '${_currentValue.round()} Km',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('0km'),
                              Text('50km'),
                            ],
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
                                  Get.toNamed(AppRoutes.radiusMapScreen);
                                },
                                label: AppStrings.next,
                                textColor: AppColors.white,
                                buttonWidth: 100,
                                buttonHeight: 50,
                                icon: Icons.arrow_forward,
                                iconColor: AppColors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                iconSize: 20,
                              ),
                            ],
                          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SpaceWidget(spaceHeight: 48),
            const TextWidget(
              text: AppStrings.services,
              fontSize: 30,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.black,
              fontStyle: FontStyle.italic,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SpaceWidget(spaceHeight: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SuggestionCardWidget(
                          onTap: () {
                            Get.toNamed(AppRoutes.deliveryTypeScreen);
                          },
                          text: AppStrings.deliverParcel,
                          imagePath: AppImagePath.deliverParcel,
                        ),
                        SuggestionCardWidget(
                          onTap: () {
                            Get.toNamed(AppRoutes.senderDeliveryTypeScreen);
                          },
                          text: AppStrings.sendParcel,
                          imagePath: AppImagePath.sendParcel,
                        ),
                        SuggestionCardWidget(
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
                      ],
                    ),
                    const SpaceWidget(spaceHeight: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TextWidget(
                          text: AppStrings.recentPublishedOrders,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontColor: AppColors.black,
                          fontStyle: FontStyle.italic,
                        ),
                        TextButtonWidget(
                          onPressed: () {},
                          text: AppStrings.viewAll,
                          textColor: AppColors.black,
                          fontSize: 14,
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
                                  width: 77,
                                  imagePath: images[index],
                                ),
                                const SpaceWidget(spaceWidth: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: title[index],
                                      fontSize: 16,
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
                                  fontWeight: FontWeight.w500,
                                  textColor: AppColors.black,
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
                      buttonWidth: double.infinity,
                      buttonHeight: 50,
                      icon: Icons.currency_exchange_rounded,
                      iconColor: AppColors.white,
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
