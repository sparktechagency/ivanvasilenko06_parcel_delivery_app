import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
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
import 'package:parcel_delivery_app/utils/appLog/app_log.dart';
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
      Get.find<EarnMoneyRadiusController>();
  final NotificationController notificationController =
      Get.find<NotificationController>();
  final ProfileController profileController = Get.find<ProfileController>();

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          //! log('Location permissions denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        //! log('Location permissions permanently denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _radiusController
          .setCurrentLocation(LatLng(position.latitude, position.longitude));
      //! log('Current Location: Latitude: ${position.latitude}');
      //! log('Current Location: Longitude: ${position.longitude}');
    } catch (e) {
      //! log('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not get current location. Please try again.')));
    }
  }

  String _getProfileImagePath() {
    if (profileController.isLoading.value) {
      //!  log('⏳ Profile is still loading, returning default image URL');
      return 'https://i.ibb.co/z5YHLV9/profile.png';
    }

    final imageUrl = profileController.profileData.value.data?.user?.image;
    //! log('Raw image URL from API: "$imageUrl"');
    //! log('Image URL type: ${imageUrl.runtimeType}');

    // Check for null, empty, or invalid URLs
    if (imageUrl == null ||
        imageUrl.isEmpty ||
        imageUrl.trim().isEmpty ||
        imageUrl.toLowerCase() == 'null' ||
        imageUrl.toLowerCase() == 'undefined') {
      //! '❌ Image URL is null/empty/invalid, using default image URL');
      return 'https://i.ibb.co/z5YHLV9/profile.png';
    }

    String fullImageUrl;
    // Trim and clean the URL
    String cleanImageUrl = imageUrl.trim();
    if (cleanImageUrl.startsWith('https://') ||
        cleanImageUrl.startsWith('http://')) {
      fullImageUrl = cleanImageUrl;
    } else {
      // Remove leading slashes and ensure proper concatenation
      cleanImageUrl = cleanImageUrl.startsWith('/')
          ? cleanImageUrl.substring(1)
          : cleanImageUrl;
      fullImageUrl = "${AppApiUrl.liveDomain}/$cleanImageUrl";
    }

    // Validate the constructed URL
    final uri = Uri.tryParse(fullImageUrl);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      //! log('❌ Invalid URL format: $fullImageUrl, using default image URL');
      return 'https://i.ibb.co/z5YHLV9/profile.png';
    }

    //! log('✅ Constructed URL: $fullImageUrl');
    return fullImageUrl;
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
                  Row(
                    children: [
                      const ImageWidget(
                        height: 40,
                        width: 40,
                        imagePath: AppImagePath.sendParcel,
                      ),
                      const SpaceWidget(spaceWidth: 12),
                      Flexible(
                        child: TextWidget(
                          text: "pickthedistanceYouwantoWork".tr,
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
                              '${_radiusController.radius.value.toStringAsFixed(0)} ${" km".tr}',
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
                          activeColor: AppColors.black,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("0${" km".tr}"),
                            Text("50${" km".tr}"),
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
                                child: Platform.isIOS==true
                                    ? const Icon(
                                      Icons.arrow_back_ios,
                                      
                                        color: AppColors.black,
                                      )
                                    : const Icon(
                                         Icons.arrow_back,
                                        color: AppColors.black,
                                      ),
                              ),
                            ),
                          ),
                          ButtonWidget(
                            onPressed: () async {
                              // Check if location is available before proceeding
                              if (_radiusController.currentLocation.value ==
                                  null) {
                                // Try to get location again
                                await _getCurrentLocation();
                                // If still null, show error and return
                                if (_radiusController.currentLocation.value ==
                                    null) {
                                  appLog("Error");
                                  return;
                                }
                              }
                              try {
                                Get.back();
                                _radiusController.fetchParcelsInRadius();
                                Get.toNamed(AppRoutes.radiusMapScreen);
                              } catch (e) {
                                appLog("Error: $e");
                              }
                            },
                            label: "next".tr,
                            textColor: AppColors.white,
                            buttonWidth: 105,
                            buttonHeight: 50,
                            icon: Platform.isIOS==true
                                    ? Icons.arrow_forward_ios
                                    : Icons.arrow_forward,
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // Load profile data first using cached data
      await profileController.getProfileInfoWithCache();
      notificationController.isReadNotification();

      // Log profile data after it's loaded
      //! appLog('🔍 Profile loaded in initState');
      //! appLog('Profile Status: ${profileController.profileData.value.status}');
      //! appLog('Profile Image: ${profileController.profileData.value.data?.user?.image ?? "No image"}');
      //! appLog('Full Name: ${profileController.profileData.value.data?.user?.fullName ?? "No name"}');
    });
  }

  @override
  Widget build(BuildContext context) {
    log("🛑 Unread Notification: ${notificationController.unreadCount.value.toString()}");

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wrap AppBar with Obx to make it reactive
          Obx(() => HomeScreenAppBar(
                isLabelVisible:
                    notificationController.unreadCount.value.toInt() == 0
                        ? false
                        : true,
                logoImagePath: AppImagePath.appLogo,
                notificationIconPath: AppIconsPath.notificationIcon,
                onNotificationPressed: () {
                  notificationController.fetchNotifications();
                  notificationController.isReadAllNotificaton();
                  Get.toNamed(AppRoutes.notificationScreen);
                },
                badgeLabel:
                    notificationController.unreadCount.value.toInt().toString(),
                profileImagePath: _getProfileImagePath(),
              )),
          // Main content area
          Obx(() {
            // Show loading only if profile is still loading
            if (profileController.isLoading.value) {
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingAnimationWidget.hexagonDots(
                        color: AppColors.black,
                        size: 40,
                      ),
                      const SizedBox(height: 16),
                      const Text('Loading Info...'),
                    ],
                  ),
                ),
              );
            }

            return Expanded(
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontColor: AppColors.black,
                      ),
                      const SpaceWidget(spaceHeight: 12),
                      EarnMoneyCardWidget(
                        onTap: () {
                          _openBottomSheet(context);
                        },
                      ),
                      const SpaceWidget(spaceHeight: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
