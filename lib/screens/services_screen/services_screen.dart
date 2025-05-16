import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/home_screen/widgets/reserve_bottom_sheet_widget.dart';
import 'package:parcel_delivery_app/screens/home_screen/widgets/suggestionCardWidget.dart';
import 'package:parcel_delivery_app/screens/services_screen/controller/services_controller.dart';
import 'package:parcel_delivery_app/screens/services_screen/model/service_screen_model.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/app_images.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_button_widget/text_button_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

import '../profile_screen/controller/profile_controller.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  double _currentValue = 5.0;
  var controller = Get.put(ServiceController());
  final ProfileController profileController = Get.put(ProfileController());

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
                              onChanged: (value) {
                                sliderSetState(() {
                                  _currentValue = value;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('0${"km".tr}'),
                                Text('50${"km".tr}'),
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
                                  child: const CircleAvatar(
                                    backgroundColor: AppColors.white,
                                    child: Icon(
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
  void initState() {
    super.initState();
    profileController.getProfileInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SpaceWidget(spaceHeight: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    text: "services".tr,
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
                          isLabelVisible: false,
                          label: Text(''),
                          backgroundColor: AppColors.red,
                          child: IconWidget(
                            icon: AppIconsPath.notificationIcon,
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                      const SpaceWidget(spaceWidth: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: AppImage(
                          url: profileController.profileData.value.data?.user
                                      ?.image?.isNotEmpty ??
                                  false
                              ? profileController
                                  .profileData.value.data!.user!.image!
                              : AppImagePath.dummyProfileImage,
                          height: 40,
                          width: 40,
                        ),
                      )
                    ],
                  )
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Obx(
                    () => controller.loading.value
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          )
                        : Column(
                            children: [
                              const SpaceWidget(spaceHeight: 25),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: SuggestionCardWidget(
                                      onTap: () {
                                        Get.toNamed(
                                            AppRoutes.deliveryTypeScreen);
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
                                        Get.toNamed(
                                            AppRoutes.senderDeliveryTypeScreen);
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 24,
                                                      horizontal: 32),
                                              child:
                                                  const ReserveBottomSheetWidget(),
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
                              const SpaceWidget(spaceHeight: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextWidget(
                                    text: "recentPublishedOrders".tr,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontColor: AppColors.black,
                                  ),
                                  TextButtonWidget(
                                    onPressed: () {
                                      Get.toNamed(AppRoutes.recentpublishorder);
                                    },
                                    text: "viewAll".tr,
                                    textColor: AppColors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                              const SpaceWidget(spaceHeight: 14),
                              if (controller.recentParcelList.isEmpty)
                                const Center(
                                  child: TextWidget(
                                    text: "No recent orders available",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontColor: AppColors.greyDark2,
                                  ),
                                )
                              else
                                ...List.generate(
                                  controller.recentParcelList.length > 4
                                      ? 4
                                      : controller.recentParcelList.length,
                                  (index) {
                                    ServiceScreenModel item =
                                        controller.recentParcelList[index];
                                    // Safely access data or provide default values
                                    String title = "Title not available";
                                    if (item.data != null &&
                                        item.data!.isNotEmpty &&
                                        item.data!.first.title != null) {
                                      title = item.data!.first.title!;
                                    }

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const ImageWidget(
                                                height: 51,
                                                width: 65,
                                                imagePath:
                                                    AppImagePath.sendParcel,
                                              ),
                                              const SpaceWidget(spaceWidth: 12),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  TextWidget(
                                                    text: item.data?.first
                                                            .title ??
                                                        "Title not available",
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    fontColor: AppColors.black,
                                                  ),
                                                  const SpaceWidget(
                                                      spaceHeight: 4),
                                                  TextWidget(
                                                    text: item
                                                            .data?.first.name ??
                                                        "Status not available",
                                                    // Display status
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    fontColor: AppColors.black,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              TextWidget(
                                                text:
                                                    "${AppStrings.currency} ${item.data?.first.price.toString()}",
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                fontColor: AppColors.black,
                                              ),
                                              TextButtonWidget(
                                                onPressed: () {
                                                  final dataList = item.data;
                                                  if (dataList != null &&
                                                      dataList.isNotEmpty &&
                                                      dataList.first.id !=
                                                          null) {
                                                    const String routeName =
                                                        AppRoutes
                                                            .serviceScreenDeliveryDetails;

                                                    if (routeName.isNotEmpty) {
                                                      try {
                                                        Get.toNamed(routeName,
                                                            arguments: dataList
                                                                .first.id);
                                                      } catch (e) {
                                                        AppSnackBar.error(
                                                            "Navigation error: ${e.toString()}");
                                                      }
                                                    } else {
                                                      AppSnackBar.error(
                                                          "Route name is not properly defined.");
                                                    }
                                                  } else {
                                                    AppSnackBar.error(
                                                        "Parcel details not available or ID is missing.");
                                                  }
                                                },
                                                text: "seeDetails".tr,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                textColor: AppColors.greyDark2,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              const SpaceWidget(spaceHeight: 14),
                              const ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
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
                                label: "earnMoneyInYourRadius".tr,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                buttonWidth: double.infinity,
                                buttonHeight: 50,
                                prefixIcon: AppIconsPath.earnMoneyRadiusIcon,
                              ),
                              const SpaceWidget(spaceHeight: 100),
                            ],
                          ),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
