import 'dart:developer';
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
import 'package:parcel_delivery_app/services/location_permission_service.dart';
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
  final EarnMoneyRadiusController _radiusController = Get.put(EarnMoneyRadiusController());
  final NotificationController notificationController = Get.put(NotificationController());
  final ProfileController profileController = Get.put(ProfileController());
  final LocationPermissionService _locationService = LocationPermissionService.instance;

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled first (iOS requirement)
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('locationServicesDisabled'.tr),
            backgroundColor: AppColors.red,
          ));
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          //! log('Location permissions denied.');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('locationPermissionDenied'.tr),
              backgroundColor: AppColors.red,
            ));
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        //! log('Location permissions permanently denied.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('locationPermissionPermanentlyDenied'.tr),
            backgroundColor: AppColors.red,
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => Geolocator.openAppSettings(),
            ),
          ));
        }
        return;
      }

      // Add timeout for iOS stability
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      if (mounted) {
        _radiusController.setCurrentLocation(LatLng(position.latitude, position.longitude));
        //! log('Current Location: Latitude: ${position.latitude}');
        //! log('Current Location: Longitude: ${position.longitude}');
      }
    } catch (e) {
      //! log('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('couldNotGetLocation'.tr),
          backgroundColor: AppColors.red,
        ));
      }
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
    if (cleanImageUrl.startsWith('https://') || cleanImageUrl.startsWith('http://')) {
      fullImageUrl = cleanImageUrl;
    } else {
      // Remove leading slashes and ensure proper concatenation
      cleanImageUrl = cleanImageUrl.startsWith('/') ? cleanImageUrl.substring(1) : cleanImageUrl;
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
    // Don't call _getCurrentLocation here - it will be called when needed
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
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                          overlayColor: Colors.black.withAlpha(51),
                          trackHeight: 6.0,
                        ),
                        child: Slider(
                          label: '${_radiusController.radius.value.toStringAsFixed(0)} ${" km".tr}',
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
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                          ),
                          ButtonWidget(
                            onPressed: () async {
                              // Get location first with proper error handling
                              await _getCurrentLocation();
                              
                              // Check if location is available after getting it
                              if (_radiusController.currentLocation.value == null) {
                                // Location request failed or was denied
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('locationRequiredToContinue'.tr),
                                      backgroundColor: AppColors.red,
                                    ),
                                  );
                                }
                                return;
                              }
                              
                              // Proceed with fetching parcels and navigation
                              try {
                                _radiusController.fetchParcelsInRadius();
                                Get.offNamed(AppRoutes.radiusMapScreen);
                                //! log("😉😉😉😉😉😉😉😉 ${_radiusController.currentLocation.value?.latitude} ${_radiusController.currentLocation.value?.longitude}");
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('errorLoadingParcels'.tr),
                                      backgroundColor: AppColors.red,
                                    ),
                                  );
                                }
                              }
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // Load profile data first
      await profileController.getProfileInfo();
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
            isLabelVisible: notificationController.unreadCount.value.toInt() == 0 ? false : true,
            logoImagePath: AppImagePath.appLogo,
            notificationIconPath: AppIconsPath.notificationIcon,
            onNotificationPressed: () {
              notificationController.fetchNotifications();
              notificationController.isReadAllNotificaton();
              Get.toNamed(AppRoutes.notificationScreen);
            },
            badgeLabel: notificationController.unreadCount.value.toInt().toString(),
            profileImagePath: _getProfileImagePath(),
          )),
          // Main content area
          Obx(() {
            // Show loading only if profile is still loading
            if (profileController.isLoading.value) {
              return  Expanded(
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
                                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 26),
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
                        onTap: () async {
                          // Check location permission first using the LocationPermissionService
                          bool hasPermission = await _locationService.ensureLocationPermission(
                            showDialog: true,
                            customMessage: 'earnMoneyDesc'.tr,
                          );
                          
                          if (hasPermission) {
                            // Permission granted, proceed to open bottom sheet
                            _openBottomSheet(context);
                          }
                          // If permission is denied, the service will handle showing appropriate dialogs
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