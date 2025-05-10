import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/home_screen/controller/earn_money_radius_controller.dart';
import 'package:parcel_delivery_app/screens/home_screen/widgets/earn_money_card_widget.dart';
import 'package:parcel_delivery_app/screens/home_screen/widgets/home_screen_appbar.dart';
import 'package:parcel_delivery_app/screens/home_screen/widgets/reserve_bottom_sheet_widget.dart';
import 'package:parcel_delivery_app/screens/home_screen/widgets/suggestionCardWidget.dart';
import 'package:parcel_delivery_app/screens/notification_screen/controller/notification_controller.dart';
import 'package:parcel_delivery_app/screens/profile_screen/controller/profile_controller.dart';
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
  final EarnMoneyRadiusController _radiusController =
      Get.put(EarnMoneyRadiusController());
  final NotificationController notificationController =
      Get.put(NotificationController());
  final ProfileController profileController = Get.put(ProfileController());

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log('Location permissions denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        log('Location permissions permanently denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _radiusController
          .setCurrentLocation(LatLng(position.latitude, position.longitude));
      log('Current Location: Latitude: ${position.latitude}');
      log('Current Location: Longitude: ${position.longitude}');
    } catch (e) {
      log('Error getting location: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not get current location. Please try again.')));
    }
  }

  void _openBottomSheet(BuildContext context) {
    _getCurrentLocation();
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
                    fontFamily: "AeonikTRIAL",
                    fontWeight: FontWeight.w600,
                    fontColor: AppColors.black,
                  ),
                  const SpaceWidget(spaceHeight: 12),
                  const Row(
                    children: [
                      ImageWidget(
                        height: 40,
                        width: 40,
                        imagePath: AppImagePath.sendParcel,
                      ),
                      SpaceWidget(spaceWidth: 12),
                      Flexible(
                        child: TextWidget(
                          text:
                              "Pick the distance you want to work within. We'll only show you jobs nearby!",
                          fontSize: 14,
                          fontFamily: "AeonikTRIAL",
                          fontWeight: FontWeight.w600,
                          fontColor: AppColors.black,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlignment: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                  const SpaceWidget(spaceHeight: 32),
                  // Slider for radius selection
                  Column(
                    children: [
                      const SpaceWidget(spaceWidth: 0),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.black,
                          inactiveTrackColor: Colors.grey.shade200,
                          thumbColor: Colors.black,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 12),
                          overlayColor: Colors.black.withAlpha(51),
                          trackHeight: 6.0,
                        ),
                        child: Slider(
                          label:
                              '${_radiusController.radius.value.toStringAsFixed(0)} ${"km".tr}',
                          value: _radiusController.radius.value,
                          min: 0,
                          max: 50,
                          divisions: 50,
                          onChanged: (value) {
                            setState(() {
                              _radiusController.radius.value = value;
                            });
                            _radiusController.radius.value = value;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                              _radiusController.fetchParcelsInRadius();
                              Get.offNamed(AppRoutes.radiusMapScreen);
                              log("😉😉😉😉😉😉😉😉 ${_radiusController.currentLocation.value?.latitude} ${_radiusController.currentLocation.value?.longitude}");
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
                    ],
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeScreenAppBar(
              logoImagePath: AppImagePath.appLogo,
              notificationIconPath: AppIconsPath.notificationIcon,
              onNotificationPressed: () {
                notificationController.fetchNotifications();
                Get.toNamed(AppRoutes.notificationScreen);
              },
              badgeLabel: "1",
              profileImagePath: profileController
                          .profileData.value.data?.user?.image?.isNotEmpty ??
                      false
                  ? profileController.profileData.value.data!.user!.image!
                  : AppImagePath.dummyProfileImage,
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
                      const SpaceWidget(spaceHeight: 12),
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
                          const SpaceWidget(spaceWidth: 12),
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
                          const SpaceWidget(spaceWidth: 12),
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
                      const SpaceWidget(spaceHeight: 12),
                      TextWidget(
                        text: "earnMoney".tr,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontColor: AppColors.black,
                      ),
                      const SpaceWidget(spaceHeight: 12),
                      EarnMoneyCardWidget(
                        onTap: () {
                          _openBottomSheet(context);
                        },
                      ),
                      const SpaceWidget(spaceHeight: 12),
                      Container(
                        height: ResponsiveUtils.height(50),
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.greyLightest,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        child: Row(
                          children: [
                            const TextWidget(
                              text: "Interested in Receiving Deliveries?",
                              fontSize: 14,
                              fontColor: AppColors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            const Spacer(),
                            Obx(() {
                              return GestureDetector(
                                onTap: () {
                                  bool newStatus = !notificationController
                                      .receivingDeliveries.value;
                                  notificationController
                                      .receivingDeliveryNotification(newStatus);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 54,
                                  height: 27,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: notificationController
                                            .receivingDeliveries.value
                                        ? AppColors.green
                                        : AppColors.red,
                                  ),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: notificationController
                                                .receivingDeliveries.value
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 05),
                                          child: Text(
                                            notificationController
                                                    .receivingDeliveries.value
                                                ? 'ON'
                                                : 'OFF',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      AnimatedAlign(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        alignment: notificationController
                                                .receivingDeliveries.value
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Container(
                                          width: 18,
                                          height: 18,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SpaceWidget(spaceHeight: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
