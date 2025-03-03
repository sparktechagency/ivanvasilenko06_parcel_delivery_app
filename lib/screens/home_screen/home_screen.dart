import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/home_screen/widgets/earn_money_card_widget.dart';
import 'package:parcel_delivery_app/screens/home_screen/widgets/home_screen_appbar.dart';
import 'package:parcel_delivery_app/screens/home_screen/widgets/reserve_bottom_sheet_widget.dart';
import 'package:parcel_delivery_app/screens/home_screen/widgets/suggestionCardWidget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';

import '../../utils/app_size.dart';
import '../../widgets/button_widget/button_widget.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                  TextWidget(
                    text: "chooseRadius".tr,
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
                      SizedBox(
                        width: ResponsiveUtils.width(250),
                        child: TextWidget(
                          text: "orderName".tr,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontColor: AppColors.black,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlignment: TextAlign.start,
                        ),
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
                            '${_currentValue.round()} ${"km".tr}',
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
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("0${"km".tr}"),
                                Text("50${"km".tr}"),
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
                                label: "next".tr,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeScreenAppBar(
            logoImagePath: AppImagePath.appLogo,
            notificationIconPath: AppIconsPath.notificationIcon,
            onNotificationPressed: () {
              Get.toNamed(AppRoutes.notificationScreen);
            },
            badgeLabel: "1",
            profileImagePath: AppImagePath.profileImage,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: "suggestions".tr,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontColor: AppColors.black,
                    ),
                    const SpaceWidget(spaceHeight: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: SuggestionCardWidget(
                            onTap: () {
                              Get.toNamed(AppRoutes.deliveryTypeScreen);
                            },
                            text: "deliverParcel".tr,
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
                            text: "sendParcel".tr,
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
                                        vertical: 15, horizontal: 26),
                                    child: const ReserveBottomSheetWidget(),
                                  );
                                },
                              );
                            },
                            text: "reserve".tr,
                            imagePath: AppImagePath.reserve,
                          ),
                        ),
                      ],
                    ),
                    const SpaceWidget(spaceHeight: 24),
                    TextWidget(
                      text: "earnMoney".tr,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.black,
                    ),
                    const SpaceWidget(spaceHeight: 16),
                    EarnMoneyCardWidget(
                      onTap: () {
                        _openBottomSheet(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
