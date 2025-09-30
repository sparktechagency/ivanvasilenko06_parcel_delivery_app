import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/home_screen/widgets/reserve_bottom_sheet_widget.dart';
import 'package:parcel_delivery_app/screens/home_screen/widgets/suggestionCardWidget.dart';
import 'package:parcel_delivery_app/screens/services_screen/controller/services_controller.dart';
import 'package:parcel_delivery_app/screens/services_screen/model/service_screen_model.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_button_widget/text_button_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';
import '../../constants/api_url.dart';
import '../delivery_parcel_screens/controller/delivery_screens_controller.dart';
import '../notification_screen/controller/notification_controller.dart';
import '../profile_screen/controller/profile_controller.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  var controller = Get.put(ServiceController());
  final ProfileController profileController = Get.put(ProfileController());
  final DeliveryScreenController deliveryController =
      Get.put(DeliveryScreenController());
  final NotificationController notificationController =
      Get.put(NotificationController());

  //! Cache for addresses to avoid multiple API calls for the same coordinates
  Map<String, String> addressCache = {};

//! Maps to store addresses for each parcel
  Map<String, String> pickupAddresses = {};
  Map<String, String> deliveryAddresses = {};

//! Loading states for addresses
  Map<String, bool> pickupAddressLoading = {};
  Map<String, bool> deliveryAddressLoading = {};

//! Track pending requests to prevent duplicates
  Set<String> pendingRequests = {};

//! Track if widget is disposed
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    profileController.getProfileInfo();

    // Only listen for future changes
    ever(controller.recentParcelList, (List<ServiceScreenModel> parcels) {
      if (parcels.isNotEmpty && !_isDisposed) {
        _loadAddressesForParcels();
      }
    });

    // Load initial data after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.recentParcelList.isNotEmpty && !_isDisposed) {
        _loadAddressesForParcels();
      }
    });
  }

  void _loadAddressesForParcels() {
    if (_isDisposed) return;

    for (var serviceModel in controller.recentParcelList) {
      if (serviceModel.data != null && serviceModel.data!.isNotEmpty) {
        for (var parcel in serviceModel.data!) {
          final parcelId = parcel.id;
          if (parcelId != null && !_isDisposed) {
            // Skip if already successfully loaded
            if (pickupAddresses[parcelId] != null &&
                pickupAddresses[parcelId] != "Loading..." &&
                !pickupAddresses[parcelId]!.contains('Unavailable')) {
              continue; // Already have a good address
            }

            if (mounted) {
              setState(() {
                pickupAddressLoading[parcelId] = true;
                deliveryAddressLoading[parcelId] = true;
                pickupAddresses[parcelId] = "Loading...";
                deliveryAddresses[parcelId] = "Loading...";
              });
            }

            _loadParcelAddresses(parcel);
          }
        }
      }
    }
  }

  void _loadParcelAddresses(Datum parcel) {
    final parcelId = parcel.id;
    if (parcelId == null || _isDisposed) return;

    final pickupCoordinates = parcel.pickupLocation?.coordinates;
    final deliveryCoordinates = parcel.deliveryLocation?.coordinates;

    if (pickupCoordinates != null && pickupCoordinates.length >= 2) {
      final pickupLat = pickupCoordinates[1];
      final pickupLng = pickupCoordinates[0];
      _getAddress(parcelId, pickupLat, pickupLng, true);
    } else {
      _handleAddressError(parcelId, true, "Invalid pickup coordinates");
    }

    if (deliveryCoordinates != null && deliveryCoordinates.length >= 2) {
      final deliveryLat = deliveryCoordinates[1];
      final deliveryLng = deliveryCoordinates[0];
      _getAddress(parcelId, deliveryLat, deliveryLng, false);
    } else {
      _handleAddressError(parcelId, false, "Invalid delivery coordinates");
    }
  }

  Future<void> _getAddress(
      String parcelId, double latitude, double longitude, bool isPickup) async {
    if (_isDisposed) return;

    // Validate coordinates
    if (latitude.isNaN ||
        longitude.isNaN ||
        latitude.abs() > 90 ||
        longitude.abs() > 180) {
      _handleAddressError(parcelId, isPickup, "Invalid coordinates");
      return;
    }

    final String key =
        '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';

    //! Check cache first
    if (addressCache.containsKey(key)) {
      _updateAddress(parcelId, addressCache[key]!, isPickup);
      return;
    }

    //! Prevent duplicate requests
    if (pendingRequests.contains(key)) {
      // Wait for the pending request to complete
      int attempts = 0;
      while (pendingRequests.contains(key) && attempts < 50 && !_isDisposed) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
        if (addressCache.containsKey(key)) {
          _updateAddress(parcelId, addressCache[key]!, isPickup);
          return;
        }
      }
      return;
    }

    pendingRequests.add(key);

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout'),
      );

      if (_isDisposed) {
        pendingRequests.remove(key);
        return;
      }

      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        String address = _extractBestAddress(placemark);

        addressCache[key] = address;
        pendingRequests.remove(key);
        _updateAddress(parcelId, address, isPickup);
      } else {
        const genericAddress = 'Location Not Found';
        addressCache[key] = genericAddress;
        pendingRequests.remove(key);
        _updateAddress(parcelId, genericAddress, isPickup);
      }
    } catch (e) {
      pendingRequests.remove(key);

      if (_isDisposed) return;

      String errorMessage;
      if (e.toString().contains('Timeout') ||
          e.toString().contains('timeout')) {
        errorMessage = 'Loading...';
      } else if (e.toString().contains('network') ||
          e.toString().contains('internet')) {
        errorMessage = 'No Network';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission Required';
      } else {
        errorMessage = 'Location Unavailable';
      }

      // Don't cache temporary errors
      if (errorMessage != 'Loading...') {
        addressCache[key] = errorMessage;
      }

      _updateAddress(parcelId, errorMessage, isPickup);
    }
  }

  String _extractBestAddress(Placemark placemark) {
    final List<String?> addressParts = [
      placemark.locality,
      placemark.subLocality,
      placemark.street,
      placemark.subAdministrativeArea,
      placemark.administrativeArea,
      placemark.country,
    ];

    for (var part in addressParts) {
      if (part != null &&
          part.trim().isNotEmpty &&
          part.toLowerCase() != 'null') {
        return part.trim();
      }
    }

    return 'Unknown Location';
  }

  void _updateAddress(String parcelId, String address, bool isPickup) {
    if (mounted && !_isDisposed) {
      setState(() {
        if (isPickup) {
          pickupAddresses[parcelId] = address;
          pickupAddressLoading[parcelId] = false;
        } else {
          deliveryAddresses[parcelId] = address;
          deliveryAddressLoading[parcelId] = false;
        }
      });
    }
  }

  void _initializeAddressStates() {
    // Check if controller has data, if not, listen for changes
    if (controller.recentParcelList.isEmpty) {
      // Listen for changes in the controller
      ever(controller.recentParcelList, (List<ServiceScreenModel> parcels) {
        if (parcels.isNotEmpty) {
          _loadAddressesForParcels();
        }
      });
    } else {
      _loadAddressesForParcels();
    }
  }

  // void _loadAddressesForParcels() {
  //   if (controller.recentParcelList.isNotEmpty) {
  //     for (var serviceModel in controller.recentParcelList) {
  //       // Access the Datum objects correctly
  //       if (serviceModel.data != null && serviceModel.data!.isNotEmpty) {
  //         for (var parcel in serviceModel.data!) {
  //           final parcelId = parcel.id;
  //           if (parcelId != null) {
  //             //! Initialize loading states
  //             setState(() {
  //               pickupAddressLoading[parcelId] = true;
  //               deliveryAddressLoading[parcelId] = true;
  //             });

  //             //! Load addresses
  //             _loadParcelAddresses(parcel);
  //           }
  //         }
  //       }
  //     }
  //   }
  // }

  // void _loadParcelAddresses(Datum parcel) {
  //   final parcelId = parcel.id;
  //   if (parcelId == null) return;

  //   //! Safely extract coordinates from Datum object (not map)
  //   final pickupCoordinates = parcel.pickupLocation?.coordinates;
  //   final deliveryCoordinates = parcel.deliveryLocation?.coordinates;

  //   if (pickupCoordinates != null && pickupCoordinates.length >= 2) {
  //     final pickupLat = pickupCoordinates[1]; // latitude is at index 1
  //     final pickupLng = pickupCoordinates[0]; // longitude is at index 0
  //     _getAddress(parcelId, pickupLat, pickupLng, true);
  //   } else {
  //     _handleAddressError(parcelId, true, "Invalid pickup coordinates");
  //   }

  //   if (deliveryCoordinates != null && deliveryCoordinates.length >= 2) {
  //     final deliveryLat = deliveryCoordinates[1];
  //     final deliveryLng = deliveryCoordinates[0];
  //     _getAddress(parcelId, deliveryLat, deliveryLng, false);
  //   } else {
  //     _handleAddressError(parcelId, false, "Invalid delivery coordinates");
  //   }
  // }

  // Future<void> _getAddress(
  //     String parcelId, double latitude, double longitude, bool isPickup) async {
  //   // Validate coordinates
  //   if (latitude.isNaN ||
  //       longitude.isNaN ||
  //       latitude.abs() > 90 ||
  //       longitude.abs() > 180) {
  //     _handleAddressError(parcelId, isPickup, "Invalid coordinates");
  //     return;
  //   }

  //   final String key = '$latitude,$longitude';

  //   //! Check cache first
  //   if (addressCache.containsKey(key)) {
  //     _updateAddress(parcelId, addressCache[key]!, isPickup);
  //     return;
  //   }

  //   try {
  //     // Add timeout to prevent hanging
  //     List<Placemark> placemarks =
  //         await placemarkFromCoordinates(latitude, longitude).timeout(
  //       const Duration(seconds: 10),
  //       onTimeout: () {
  //         throw Exception('Address lookup timeout');
  //       },
  //     );

  //     if (placemarks.isNotEmpty) {
  //       final placemark = placemarks[0];

  //       // Get single address property in priority order: locality > subLocality > street > subAdministrativeArea
  //       String address;

  //       if (placemark.locality != null &&
  //           placemark.locality!.trim().isNotEmpty) {
  //         address = placemark.locality!.trim();
  //       } else if (placemark.subLocality != null &&
  //           placemark.subLocality!.trim().isNotEmpty) {
  //         address = placemark.subLocality!.trim();
  //       } else if (placemark.street != null &&
  //           placemark.street!.trim().isNotEmpty) {
  //         address = placemark.street!.trim();
  //       } else if (placemark.subAdministrativeArea != null &&
  //           placemark.subAdministrativeArea!.trim().isNotEmpty) {
  //         address = placemark.subAdministrativeArea!.trim();
  //       } else if (placemark.administrativeArea != null &&
  //           placemark.administrativeArea!.trim().isNotEmpty) {
  //         address = placemark.administrativeArea!.trim();
  //       } else if (placemark.country != null &&
  //           placemark.country!.trim().isNotEmpty) {
  //         address = placemark.country!.trim();
  //       } else {
  //         // Final fallback to generic location text instead of coordinates
  //         address = 'Unknown Location';
  //       }

  //       addressCache[key] = address;
  //       _updateAddress(parcelId, address, isPickup);
  //     } else {
  //       // Fallback to generic location text instead of coordinates
  //       const genericAddress = 'Location Not Found';
  //       addressCache[key] = genericAddress;
  //       _updateAddress(parcelId, genericAddress, isPickup);
  //     }
  //   } catch (e) {
  //     // Enhanced error handling with specific error types
  //     String errorMessage;

  //     if (e.toString().contains('timeout')) {
  //       errorMessage = 'Address lookup timed out';
  //     } else if (e.toString().contains('network') ||
  //         e.toString().contains('internet')) {
  //       errorMessage = 'Network error - please check your connection';
  //     } else if (e.toString().contains('permission')) {
  //       errorMessage = 'Location permission required';
  //     } else {
  //       // Always provide generic fallback instead of coordinates
  //       const genericAddress = 'Location Unavailable';
  //       addressCache[key] = genericAddress;
  //       _updateAddress(parcelId, genericAddress, isPickup);
  //       return;
  //     }

  //     _handleAddressError(parcelId, isPickup, errorMessage);
  //   }
  // }

  // void _updateAddress(String parcelId, String address, bool isPickup) {
  //   if (mounted) {
  //     setState(() {
  //       if (isPickup) {
  //         pickupAddresses[parcelId] = address;
  //         pickupAddressLoading[parcelId] = false;
  //       } else {
  //         deliveryAddresses[parcelId] = address;
  //         deliveryAddressLoading[parcelId] = false;
  //       }
  //     });
  //   }
  // }

  void _handleAddressError(
      String parcelId, bool isPickup, String errorMessage) {
    if (mounted) {
      setState(() {
        if (isPickup) {
          // Provide generic error messages instead of coordinates
          if (errorMessage.contains('Invalid coordinates')) {
            pickupAddresses[parcelId] = 'Invalid Location';
          } else if (errorMessage.contains('timeout')) {
            pickupAddresses[parcelId] = 'Location Timeout';
          } else if (errorMessage.contains('Network error')) {
            pickupAddresses[parcelId] = 'Network Error';
          } else if (errorMessage.contains('permission')) {
            pickupAddresses[parcelId] = 'Permission Required';
          } else {
            pickupAddresses[parcelId] = 'Address Unavailable';
          }
          pickupAddressLoading[parcelId] = false;
        } else {
          // Provide generic error messages instead of coordinates
          if (errorMessage.contains('Invalid coordinates')) {
            deliveryAddresses[parcelId] = 'Invalid Location';
          } else if (errorMessage.contains('timeout')) {
            deliveryAddresses[parcelId] = 'Location Timeout';
          } else if (errorMessage.contains('Network error')) {
            deliveryAddresses[parcelId] = 'Network Error';
          } else if (errorMessage.contains('permission')) {
            deliveryAddresses[parcelId] = 'Permission Required';
          } else {
            deliveryAddresses[parcelId] = 'Address Unavailable';
          }
          deliveryAddressLoading[parcelId] = false;
        }
      });
    }
  }

  String _getProfileImagePath() {
    if (profileController.isLoading.value) {
      //! log('⏳ Profile is still loading, returning default image URL');
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
      //! log('❌ Image URL is null/empty/invalid, using default image URL');
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

    //!  log('✅ Constructed URL: $fullImageUrl');
    return fullImageUrl;
  }

  @override
  void dispose() {
    _isDisposed = true;
    pendingRequests.clear();
    addressCache.clear();
    pickupAddresses.clear();
    deliveryAddresses.clear();
    pickupAddressLoading.clear();
    deliveryAddressLoading.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(() {
        if (profileController.isLoading.value) {
          return Center(
            child: LoadingAnimationWidget.hexagonDots(
              color: AppColors.black,
              size: 40,
            ),
          );
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
                        icon: Badge(
                          isLabelVisible: notificationController
                                      .unreadCount.value
                                      .toInt() ==
                                  0
                              ? false
                              : true,
                          label: Text(notificationController.unreadCount.value
                              .toInt()
                              .toString()),
                          backgroundColor: AppColors.red,
                          child: const IconWidget(
                            icon: AppIconsPath.notificationIcon,
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                      const SpaceWidget(spaceWidth: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          _getProfileImagePath(),
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'https://i.ibb.co/z5YHLV9/profile.png',
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              height: 40,
                              width: 40,
                              child: Center(
                                child: LoadingAnimationWidget.hexagonDots(
                                  color: AppColors.black,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),
                        // AppImage(
                        //   url: profileController.isLoading.value
                        //       ? AppImagePath.dummyProfileImage
                        //       : (profileController.profileData.value.data?.user
                        //       ?.image?.isNotEmpty ??
                        //       false)
                        //       ? profileController
                        //       .profileData.value.data!.user!.image!
                        //       : AppImagePath.dummyProfileImage,
                        //   height: 40,
                        //   width: 40,
                        // ),
                      )
                    ],
                  )
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Obx(
                    () => controller.loading.value
                        ? Center(
                            child: LoadingAnimationWidget.hexagonDots(
                              color: AppColors.black,
                              size: 40,
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
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const ImageWidget(
                                        imagePath: AppImagePath.sendParcel,
                                        width: 50,
                                        height: 50,
                                      ),
                                      const SpaceWidget(spaceHeight: 16),
                                      TextWidget(
                                        text: "noRecentPublishParcelFound".tr,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        fontColor: AppColors.greyDark2,
                                      ),
                                    ],
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
                                    String itemId = "";
                                    String price = "0";
                                    if (item.data != null &&
                                        item.data!.isNotEmpty) {
                                      title = item.data!.first.title ??
                                          "Title not available";
                                      itemId = item.data!.first.id ?? "";
                                      price =
                                          item.data!.first.price?.toString() ??
                                              "0";
                                    }

                                    //! Get address display values
                                    final bool isPickupLoading =
                                        pickupAddressLoading[itemId] ?? true;
                                    final bool isDeliveryLoading =
                                        deliveryAddressLoading[itemId] ?? true;
                                    final String pickupAddress = isPickupLoading
                                        ? "Loading pickup address..."
                                        : pickupAddresses[itemId] ??
                                            "Address unavailable";
                                    final String deliveryAddress =
                                        isDeliveryLoading
                                            ? "Loading delivery address..."
                                            : deliveryAddresses[itemId] ??
                                                "Address unavailable";
                                    final bool hasRequestSent =
                                        deliveryController
                                            .isRequestSent(itemId);
                                    String formattedDate = "N/A";
                                    try {
                                      final startDate = DateTime.parse(item
                                          .data!.first.deliveryStartTime
                                          .toString());
                                      final endDate = DateTime.parse(item
                                          .data!.first.deliveryEndTime
                                          .toString());
                                      formattedDate =
                                          "${DateFormat(' dd.MM ').format(startDate)} to ${DateFormat(' dd.MM ').format(endDate)}";
                                    } catch (e) {
                                      //! log("Error parsing dates: $e");
                                    }

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: const ImageWidget(
                                                    imagePath:
                                                        AppImagePath.sendParcel,
                                                    width: 40,
                                                    height: 40,
                                                  ),
                                                ),
                                                const SpaceWidget(
                                                    spaceWidth: 12),
                                                TextWidget(
                                                  text: title,
                                                  fontSize: 15.5,
                                                  fontWeight: FontWeight.w600,
                                                  fontColor: AppColors.black,
                                                ),
                                              ],
                                            ),
                                            TextWidget(
                                              text:
                                                  "${AppStrings.currency} $price",
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              fontColor: AppColors.black,
                                            ),
                                          ],
                                        ),
                                        const SpaceWidget(spaceHeight: 12),
                                        //! Status section
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.location_on_rounded,
                                              color: AppColors.black,
                                              size: 14,
                                            ),
                                            const SpaceWidget(spaceWidth: 8),
                                            TextWidget(
                                              text:
                                                  "$pickupAddress To $deliveryAddress",
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              fontColor: AppColors.greyDark2,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        const SpaceWidget(spaceHeight: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_month,
                                              color: AppColors.black,
                                              size: 12,
                                            ),
                                            const SpaceWidget(spaceWidth: 8),
                                            TextWidget(
                                              text: formattedDate,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              fontColor: AppColors.greyDark2,
                                            ),
                                          ],
                                        ),
                                        if (hasRequestSent) ...[
                                          const SpaceWidget(spaceHeight: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 12,
                                              ),
                                              const SpaceWidget(spaceWidth: 8),
                                              TextWidget(
                                                text: "requestSent".tr,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                fontColor: Colors.green,
                                              ),
                                            ],
                                          ),
                                        ],
                                        const SpaceWidget(spaceHeight: 12),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: AppColors.whiteLight,
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                onTap: hasRequestSent
                                                    ? null
                                                    : () {
                                                        deliveryController
                                                            .sendParcelRequest(
                                                                itemId);
                                                      },
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                child: Row(
                                                  children: [
                                                    IconWidget(
                                                      icon: AppIconsPath
                                                          .personAddIcon,
                                                      color: hasRequestSent
                                                          ? Colors.grey
                                                          : AppColors.black,
                                                      width: 14,
                                                      height: 14,
                                                    ),
                                                    const SpaceWidget(
                                                        spaceWidth: 8),
                                                    TextWidget(
                                                      text: hasRequestSent
                                                          ? "requestSent".tr
                                                          : "sendRequest".tr,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontColor: hasRequestSent
                                                          ? Colors.grey
                                                          : AppColors.black,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: 1,
                                                height: 18,
                                                color: AppColors.blackLighter,
                                              ),
                                              //! Keep original "See Details" functionality
                                              InkWell(
                                                onTap: () {
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
                                                        // AppSnackBar.error(
                                                        //     "Navigation error: ${e.toString()}");
                                                      }
                                                    } else {
                                                      // AppSnackBar.error(
                                                      //     "Route name is not properly defined.");
                                                    }
                                                  } else {}
                                                },
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.visibility_outlined,
                                                      color: Colors.black,
                                                      size: 14,
                                                    ),
                                                    const SpaceWidget(
                                                        spaceWidth: 8),
                                                    TextWidget(
                                                      text: "seeDetails".tr,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontColor:
                                                          AppColors.black,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    );
                                  },
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
