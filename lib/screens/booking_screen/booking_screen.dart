import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/screens/booking_screen/current_order/controller/current_order_controller.dart';
import 'package:parcel_delivery_app/screens/booking_screen/new_booking/controller/new_bookings_controller.dart';
import 'package:parcel_delivery_app/screens/notification_screen/controller/notification_controller.dart';
import 'package:parcel_delivery_app/services/appStroage/location_storage.dart';
import 'package:parcel_delivery_app/utils/appLog/app_log.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/api_url.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_icons_path.dart';
import '../../routes/app_routes.dart';
import '../../widgets/icon_widget/icon_widget.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  Map<String, String> addressCache = {};
  Map<String, String> locationToAddressCache = {};
  Set<String> pendingRequests = {}; // Track ongoing requests
  bool _isDisposed = false; // Track widget disposal

  late final CurrentOrderController currentOrderController;
  late final NewBookingsController newBookingsController;
  late final LocationStorage locationStorage;
  late final NotificationController notificationController;

  //! Track previous unread count to detect changes
  int _previousUnreadCount = 0;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    try {
      currentOrderController = Get.find<CurrentOrderController>();
    } catch (e) {
      currentOrderController =
          Get.put(CurrentOrderController(), permanent: true);
    }
    try {
      newBookingsController = Get.find<NewBookingsController>();
    } catch (e) {
      newBookingsController = Get.put(NewBookingsController(), permanent: true);
    }
    try {
      notificationController = Get.find<NotificationController>();
    } catch (e) {
      notificationController =
          Get.put(NotificationController(), permanent: true);
    }

    locationStorage = LocationStorage.instance;

    // Store initial unread count
    _previousUnreadCount = notificationController.unreadCount.value.toInt();

    // Listen for unread count changes to refresh booking screen
    ever(notificationController.unreadCount, (int newCount) {
      if (!_isDisposed && mounted) {
        // Refresh booking screen when unread count increases
        if (_previousUnreadCount < newCount) {
          log('📱 Unread notifications increased from $_previousUnreadCount to $newCount - refreshing booking screen');
          _refreshBookingScreen();
        }
        _previousUnreadCount = newCount;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Initialize location storage
      await locationStorage.initialize();
      // Use cached data instead of forcing reload
      await currentOrderController.getCurrentOrderWithCache();
      // Prefetch all addresses at once
      final parcels = currentOrderController.currentOrdersModel.value.data;
      if (parcels != null) {
        await prefetchAllAddresses(parcels);
      }
    });
    // Listen to controller changes to refresh UI
    ever(currentOrderController.currentOrdersModel, (_) async {
      if (mounted && !_isDisposed) {
        // Refresh addresses for new parcels
        final parcels = currentOrderController.currentOrdersModel.value.data;
        if (parcels != null && parcels.isNotEmpty) {
          await prefetchAllAddresses(parcels);
        }
        setState(() {
          // Trigger UI rebuild when data changes
        });
      }
    });
  }

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    // Validate coordinates
    if (latitude.isNaN ||
        longitude.isNaN ||
        latitude.abs() > 90 ||
        longitude.abs() > 180) {
      return 'Invalid coordinates';
    }

    // First check LocationStorage for cached address
    final cachedAddress =
        await locationStorage.getAddressFromCoordinates(latitude, longitude);
    if (cachedAddress != null) {
      return cachedAddress;
    }

    final String key =
        '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';

    // Return in-memory cached result if available (fallback)
    if (locationToAddressCache.containsKey(key)) {
      return locationToAddressCache[key]!;
    }

    // Prevent duplicate requests for the same location
    if (pendingRequests.contains(key)) {
      // Wait for the pending request to complete
      int attempts = 0;
      while (pendingRequests.contains(key) && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
        if (locationToAddressCache.containsKey(key)) {
          return locationToAddressCache[key]!;
        }
      }
    }

    pendingRequests.add(key);

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout'),
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        String newAddress = _extractBestAddress(placemark, latitude, longitude);

        // Cache the result in both in-memory and persistent storage
        locationToAddressCache[key] = newAddress;

        // Store in LocationStorage for persistence (no need to await)
        locationStorage.storeLocationData(LocationData(
          parcelId: 'coordinate_cache',
          addressType: 'coordinate',
          latitude: latitude,
          longitude: longitude,
          address: newAddress,
          timestamp: DateTime.now(),
        ));

        pendingRequests.remove(key);

        return newAddress;
      } else {
        final coordinateAddress =
            '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
        locationToAddressCache[key] = coordinateAddress;
        pendingRequests.remove(key);
        return coordinateAddress;
      }
    } catch (e) {
      pendingRequests.remove(key);

      // Provide specific error messages
      String errorMessage;
      if (e.toString().contains('Timeout') ||
          e.toString().contains('timeout')) {
        errorMessage = 'Location loading...';
      } else if (e.toString().contains('network') ||
          e.toString().contains('internet')) {
        errorMessage = 'No network';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission needed';
      } else {
        // Fallback to coordinates on any error
        errorMessage =
            '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
      }

      // Don't cache errors (except coordinate fallback)
      if (errorMessage.contains(',')) {
        locationToAddressCache[key] = errorMessage;
      }

      return errorMessage;
    }
  }

  String _extractBestAddress(Placemark placemark, double lat, double lng) {
    // Priority order: locality > subLocality > street > subAdministrativeArea > administrativeArea
    final List<String?> addressParts = [
      placemark.locality,
      placemark.subLocality,
      placemark.subAdministrativeArea,
      placemark.administrativeArea,
      placemark.street,
      placemark.country,
    ];
    for (var part in addressParts) {
      if (part != null &&
          part.trim().isNotEmpty &&
          part.toLowerCase() != 'null') {
        return part.trim();
      }
    }

    // Final fallback to coordinates
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  //! Store address by parcel ID using LocationStorage
  void cacheAddressForParcel(String parcelId, String addressType,
      double latitude, double longitude) async {
    if (_isDisposed) return;

    final cacheKey = '${parcelId}_$addressType';

    // First check LocationStorage for existing data
    final existingLocationData =
        await locationStorage.getLocationData(parcelId, addressType);
    if (existingLocationData != null) {
      if (mounted && !_isDisposed) {
        setState(() {
          addressCache[cacheKey] = existingLocationData.address;
        });
      }
      return;
    }

    // Skip if already cached in memory
    if (addressCache.containsKey(cacheKey)) {
      return;
    }

    // Set loading state immediately
    if (mounted) {
      setState(() {
        addressCache[cacheKey] = 'Loading...';
      });
    }

    try {
      String fetchedAddress =
          await getAddressFromCoordinates(latitude, longitude);

      // Store in LocationStorage for persistence
      final locationData = LocationData(
        parcelId: parcelId,
        addressType: addressType,
        latitude: latitude,
        longitude: longitude,
        address: fetchedAddress,
        timestamp: DateTime.now(),
      );

      await locationStorage.storeLocationData(locationData);

      // Only update if widget is still mounted and not disposed
      if (mounted && !_isDisposed) {
        setState(() {
          addressCache[cacheKey] = fetchedAddress;
        });
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          addressCache[cacheKey] =
              '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
        });
      }
    }
  }

  //! Get address for a specific parcel with LocationStorage fallback
  String getParcelAddress(String parcelId, String addressType) {
    final cacheKey = '${parcelId}_$addressType';

    // Return from memory cache if available
    if (addressCache.containsKey(cacheKey)) {
      return addressCache[cacheKey]!;
    }

    // Try to load from LocationStorage asynchronously
    _loadAddressFromStorage(parcelId, addressType);

    return 'Loading...';
  }

  //! Helper method to load address from LocationStorage
  void _loadAddressFromStorage(String parcelId, String addressType) async {
    if (_isDisposed) return;

    final locationData =
        await locationStorage.getLocationData(parcelId, addressType);
    if (locationData != null && mounted && !_isDisposed) {
      setState(() {
        addressCache['${parcelId}_$addressType'] = locationData.address;
      });
    }
  }

  Future<void> prefetchAllAddresses(List<dynamic> parcels) async {
    final List<Future<void>> futures = [];
    final List<LocationData> locationDataToStore = [];

    for (var parcel in parcels) {
      final parcelId = parcel.id ?? "";
      final deliveryLocation = parcel.deliveryLocation?.coordinates;
      final pickupLocation = parcel.pickupLocation?.coordinates;

      // Check delivery location
      if (deliveryLocation != null && deliveryLocation.length == 2) {
        final lat = deliveryLocation[1];
        final lng = deliveryLocation[0];

        // First check if we have this data in LocationStorage
        final existingData =
            await locationStorage.getLocationData(parcelId, 'delivery');
        if (existingData != null) {
          if (mounted && !_isDisposed) {
            setState(() {
              addressCache['${parcelId}_delivery'] = existingData.address;
            });
          }
        } else {
          // Fetch address and prepare for storage
          futures.add(getAddressFromCoordinates(lat, lng).then((address) {
            if (mounted && !_isDisposed) {
              setState(() {
                addressCache['${parcelId}_delivery'] = address;
              });

              // Prepare location data for batch storage
              locationDataToStore.add(LocationData(
                parcelId: parcelId,
                addressType: 'delivery',
                latitude: lat,
                longitude: lng,
                address: address,
                timestamp: DateTime.now(),
              ));
            }
          }));
        }
      }

      // Check pickup location
      if (pickupLocation != null && pickupLocation.length == 2) {
        final lat = pickupLocation[1];
        final lng = pickupLocation[0];

        // First check if we have this data in LocationStorage
        final existingData =
            await locationStorage.getLocationData(parcelId, 'pickup');
        if (existingData != null) {
          if (mounted && !_isDisposed) {
            setState(() {
              addressCache['${parcelId}_pickup'] = existingData.address;
            });
          }
        } else {
          // Fetch address and prepare for storage
          futures.add(getAddressFromCoordinates(lat, lng).then((address) {
            if (mounted && !_isDisposed) {
              setState(() {
                addressCache['${parcelId}_pickup'] = address;
              });

              // Prepare location data for batch storage
              locationDataToStore.add(LocationData(
                parcelId: parcelId,
                addressType: 'pickup',
                latitude: lat,
                longitude: lng,
                address: address,
                timestamp: DateTime.now(),
              ));
            }
          }));
        }
      }
    }

    // Wait for all requests to complete (with timeout)
    await Future.wait(futures).timeout(
      const Duration(seconds: 05),
      onTimeout: () => [],
    );

    // Store all new location data in batch
    if (locationDataToStore.isNotEmpty) {
      await locationStorage.storeMultipleLocationData(locationDataToStore);
    }
  }

  // Method to refresh the booking screen when notifications change
  Future<void> _refreshBookingScreen() async {
    if (_isDisposed) return;

    try {
      log('🔄 Booking Screen: Refreshing booking screen data...');

      // Clear address caches to ensure fresh data
      addressCache.clear();
      locationToAddressCache.clear();

      // Force refresh current orders
      await currentOrderController.getCurrentOrderWithCache(forceRefresh: true);

      // Refresh addresses for parcels
      final parcels = currentOrderController.currentOrdersModel.value.data;
      if (parcels != null && parcels.isNotEmpty) {
        await prefetchAllAddresses(parcels);
      }

      // Trigger UI rebuild
      if (mounted && !_isDisposed) {
        setState(() {
          // Force UI refresh
        });
      }

      log('✅ Booking Screen: Booking screen refresh completed');
    } catch (error) {
      log('❌ Booking Screen: Error during booking screen refresh: $error');
    }
  }

  void _openBottomSheet(String parcelId, dynamic parcel) {
    // Check if review already exists BEFORE opening the sheet
    if (hasAlreadyReviewed(parcelId, parcel)) {
      AppSnackBar.reviewError("You have already reviewed this delivery");
      return;
    }
    double selectedRating = 1.0;
    // Safely get the controller - use the instance variable directly
    // This avoids any GetX lookup issues
    final controller = currentOrderController;
    // Set parcel ID and user ID before opening the sheet
    controller.parcelID.value = parcelId;
    controller.userID.value = parcel.assignedDelivererId?.id ?? "";
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                      height: 5,
                      width: 50,
                      decoration: BoxDecoration(
                        color: AppColors.greyDark,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SpaceWidget(spaceHeight: 32),
                  Center(
                    child: TextWidget(
                      text: "experience".tr,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.black,
                    ),
                  ),
                  const SpaceWidget(spaceHeight: 10),
                  Center(
                    child: RatingBar.builder(
                      initialRating: selectedRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 06),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setModalState(() {
                          selectedRating = rating;
                        });
                        appLog('Rating: $rating');
                      },
                    ),
                  ),
                  const SpaceWidget(spaceHeight: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: AppStrings.veryBad,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontColor: AppColors.black,
                        ),
                        TextWidget(
                          text: AppStrings.veryGood,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontColor: AppColors.black,
                        ),
                      ],
                    ),
                  ),
                  const SpaceWidget(spaceHeight: 32),
                  ButtonWidget(
                    onPressed: () async {
                      // Set the rating value
                      controller.rating.value = selectedRating;
                      Navigator.pop(context);
                      try {
                        await controller.givingReview();
                      } finally {
                        if (Get.isDialogOpen == true) {
                          Get.back();
                        }
                      }
                      try {
                        // Submit the review
                        await controller.givingReview();
                        // Close loading dialog
                        Get.back();
                        // Refresh the current orders to update UI
                        await controller.getCurrentOrderWithCache(
                            forceRefresh: true);
                        // Update the UI
                        if (mounted) {
                          setState(() {});
                        }
                      } catch (e) {
                        // Close loading dialog if still open
                        if (Get.isDialogOpen == true) {
                          Get.back();
                        }
                        AppSnackBar.error(
                            "Failed to submit review: ${e.toString()}");
                      }
                    },
                    label: "submit".tr,
                    buttonWidth: double.infinity,
                    buttonHeight: 50,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      AppSnackBar.error('No phone number available');
      return;
    }

    final String formattedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    try {
      //! Use different approaches based on platform
      if (Platform.isAndroid) {
        //! For Android, use Intent.ACTION_DIAL (doesn't require permission)
        final Uri phoneUri = Uri.parse('tel:$formattedNumber');
        await launchUrl(phoneUri,
            mode: LaunchMode.externalNonBrowserApplication);
      } else if (Platform.isIOS) {
        //! For iOS
        final Uri phoneUri = Uri.parse('tel://$formattedNumber');
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          throw 'Could not launch $phoneUri';
        }
      } else {
        //! For other platforms
        final Uri phoneUri = Uri.parse('tel:$formattedNumber');
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          throw 'Could not launch $phoneUri';
        }
      }
    } catch (e) {
      log('Error launching phone call: $e');
      AppSnackBar.error('Error launching phone call: ${e.toString()}');
    }
  }

  //! Function to send a message

  Future<void> _openWhatsApp(String phoneNumber, String message) async {
    if (phoneNumber.isEmpty) {
      AppSnackBar.error('No phone number available');
      return;
    }

    // Format the phone number (remove any non-digit characters)
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Ensure the number has country code (add + if not present)
    if (!formattedNumber.startsWith('+')) {
      formattedNumber = '+$formattedNumber';
    }

    try {
      // Try different WhatsApp URL schemes in order of reliability
      List<String> whatsappUrls = [
        "whatsapp://send?phone=$formattedNumber&text=${Uri.encodeComponent(message)}",
        "https://wa.me/$formattedNumber?text=${Uri.encodeComponent(message)}",
        "https://api.whatsapp.com/send?phone=$formattedNumber&text=${Uri.encodeComponent(message)}"
      ];

      for (String urlString in whatsappUrls) {
        try {
          final Uri uri = Uri.parse(urlString);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return;
          }
        } catch (e) {
          log('Failed to launch $urlString: $e');
          continue;
        }
      }

      // If all methods fail, show error
      log('Could not find any working WhatsApp method');
      AppSnackBar.error('Could not find any working WhatsApp method');
    } catch (e) {
      log('Error opening WhatsApp: $e');
      AppSnackBar.error('Error opening WhatsApp: ${e.toString()}');
    }
  }

  // Helper method to check if review already exists for a parcel
  bool hasAlreadyReviewed(String parcelId, dynamic parcel) {
    // Add null safety checks for the parcel object
    if (parcel == null) return false;
    if (parcel is String) return false; // Add this check to prevent String type
    if (parcel.assignedDelivererId == null) return false;
    if (parcel.assignedDelivererId?.reviews == null) return false;

    return parcel.assignedDelivererId!.reviews!
        .any((review) => review.parcelId == parcelId);
  }

  void deliveryFinished(String parcelId, String status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)), // Flat corners
          ),
          backgroundColor: AppColors.grey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextWidget(
                  text: 'haveYouCompletedTheDelivery'.tr,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontColor: AppColors.black,
                  textAlignment: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonWidget(
                      buttonWidth: 100,
                      buttonHeight: 40,
                      label: 'no'.tr,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      buttonRadius: BorderRadius.circular(10),
                      backgroundColor: AppColors.white,
                      textColor: AppColors.black,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    ButtonWidget(
                      buttonWidth: 100,
                      buttonHeight: 40,
                      label: 'yes'.tr,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      buttonRadius: BorderRadius.circular(10),
                      backgroundColor: AppColors.green,
                      textColor: AppColors.white,
                      onPressed: () async {
                        try {
                          final currentOrderController =
                              Get.find<CurrentOrderController>();
                          // Set the parcel ID to finish
                          currentOrderController.finishedParcelId.value =
                              parcelId;
                          currentOrderController.parcelStatus.value = status;

                          // Close dialog first
                          Navigator.pop(context);

                          // Call the finishedDelivery method
                          await currentOrderController.finishedDelivery();
                          // Clear address caches to ensure fresh data
                          addressCache.clear();
                          locationToAddressCache.clear();
                          await locationStorage.clearAllLocationData();
                          // Refresh addresses for remaining parcels
                          final parcels = currentOrderController
                              .currentOrdersModel.value.data;
                          if (parcels != null && parcels.isNotEmpty) {
                            await prefetchAllAddresses(parcels);
                          }
                          // Update UI state and navigate to first tab
                          if (mounted) {
                            setState(() {
                              _currentIndex = 0;
                            });
                          }
                          _pageController.jumpToPage(0);
                          // Close loading dialog
                          if (Get.isDialogOpen == true) {
                            Get.back();
                          }
                        } catch (e) {
                          // Close loading dialog if still open
                          if (Get.isDialogOpen == true) {
                            Get.back();
                          }
                          AppSnackBar.error(
                              "Failed to complete delivery: ${e.toString()}");
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void removeParcelConfirmation(String parcelId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Dialog(
            shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(10)), // Flat corners
            ),
            backgroundColor: AppColors.grey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextWidget(
                    text: 'areYouSureYouwantToRemovethisParcel'.tr,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontColor: AppColors.black,
                    textAlignment: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ButtonWidget(
                        buttonWidth: 100,
                        buttonHeight: 40,
                        label: 'no'.tr,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        buttonRadius: BorderRadius.circular(10),
                        backgroundColor: AppColors.white,
                        textColor: AppColors.black,
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                      ),
                      ButtonWidget(
                        buttonWidth: 100,
                        buttonHeight: 40,
                        label: 'yes'.tr,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        buttonRadius: BorderRadius.circular(10),
                        backgroundColor: AppColors.green,
                        textColor: AppColors.white,
                        onPressed: () async {
                          Navigator.pop(context);
                          try {
                            //! Get the correct controller instance
                            final controller =
                                Get.find<NewBookingsController>();
                            await controller.removeParcelFromMap(parcelId);

                            // Clear all caches and refresh data
                            currentOrderController.clearCacheAndRefresh();

                            // Clear address caches
                            addressCache.clear();
                            locationToAddressCache.clear();
                            await locationStorage.clearAllLocationData();

                            // Force refresh with new data
                            await currentOrderController
                                .getCurrentOrderWithCache(forceRefresh: true);

                            // Refresh addresses for remaining parcels
                            final parcels = currentOrderController
                                .currentOrdersModel.value.data;
                            if (parcels != null && parcels.isNotEmpty) {
                              await prefetchAllAddresses(parcels);
                            }

                            // Update UI state
                            if (mounted) {
                              setState(() {
                                _currentIndex = 0;
                              });
                            }

                            controller.update();
                            _pageController.jumpToPage(0);
                            Get.back();
                          } catch (e) {
                            // Close loading dialog
                            Get.back();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void cancelParcelFromDelivery(String parcelId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Dialog(
            shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(10)), // Flat corners
            ),
            backgroundColor: AppColors.grey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextWidget(
                    text: 'areYourSureYouwantToCancelThisRequest'.tr,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontColor: AppColors.black,
                    textAlignment: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ButtonWidget(
                        buttonWidth: 100,
                        buttonHeight: 40,
                        label: 'no'.tr,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        buttonRadius: BorderRadius.circular(10),
                        backgroundColor: AppColors.white,
                        textColor: AppColors.black,
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                      ),
                      ButtonWidget(
                        buttonWidth: 100,
                        buttonHeight: 40,
                        label: 'yes'.tr,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        buttonRadius: BorderRadius.circular(10),
                        backgroundColor: AppColors.green,
                        textColor: AppColors.white,
                        onPressed: () async {
                          Navigator.pop(context);
                          try {
                            //! Get the correct controller instance
                            final controller =
                                Get.find<NewBookingsController>();
                            await controller
                                .parcelCancelFromDeliveryMan(parcelId);

                            // Clear all caches and refresh data
                            currentOrderController.clearCacheAndRefresh();

                            // Clear address caches
                            addressCache.clear();
                            locationToAddressCache.clear();
                            await locationStorage.clearAllLocationData();

                            // Force refresh with new data
                            await currentOrderController
                                .getCurrentOrderWithCache(forceRefresh: true);

                            // Refresh addresses for remaining parcels
                            final parcels = currentOrderController
                                .currentOrdersModel.value.data;
                            if (parcels != null && parcels.isNotEmpty) {
                              await prefetchAllAddresses(parcels);
                            }

                            // Update UI state
                            if (mounted) {
                              setState(() {
                                _currentIndex = 0;
                              });
                            }

                            controller.update();
                            _pageController.jumpToPage(0);
                            Get.back();
                          } catch (e) {
                            Get.back();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextWidget(
              text: "bookings".tr,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
            ),
          ),
          const SpaceWidget(spaceHeight: 24),

          //! <This one is tab bar  ===================>
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    _buildTabItem("currentOrders".tr, 0),
                    const SpaceWidget(spaceHeight: 4),
                    Container(
                      height: ResponsiveUtils.height(3),
                      width: ResponsiveUtils.width(12),
                      decoration: BoxDecoration(
                        color: _currentIndex == 0
                            ? AppColors.black
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.greyDarkLight,
                ),
                Column(
                  children: [
                    Stack(
                      children: [
                        _buildTabItem("deliveryRequests".tr, 1),
                        // Badge for new bookings
                        Obx(() {
                          final newBookingsController =
                              Get.find<NewBookingsController>();
                          final allParcels = currentOrderController
                              .currentOrdersModel.value.data;
                          final parcelsWithRequests = allParcels
                                  ?.where((parcel) =>
                                      parcel.typeParcel == "sendParcel" &&
                                      parcel.deliveryRequests != null &&
                                      parcel.deliveryRequests!.isNotEmpty)
                                  .toList() ??
                              [];
                          // Show badge if there are new bookings and user hasn't visited the tab
                          if (parcelsWithRequests.isNotEmpty &&
                              !newBookingsController
                                  .hasVisitedNewBookings.value) {
                            return Positioned(
                              right: -0.01,
                              top: -0.01,
                              child: Container(
                                width: 08,
                                height: 08,
                                decoration: const BoxDecoration(
                                  color: AppColors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                    const SpaceWidget(spaceHeight: 4),
                    Container(
                      height: ResponsiveUtils.height(3),
                      width: ResponsiveUtils.width(12),
                      decoration: BoxDecoration(
                        color: _currentIndex == 1
                            ? AppColors.black
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                // Mark new bookings as visited when user swipes to tab 1
                if (index == 1) {
                  newBookingsController.markNewBookingsAsVisited();
                }
              },
              children: [
                SingleChildScrollView(child: _currentOrderWidget()),
                SingleChildScrollView(child: _newBookingWidget()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.jumpToPage(index);

        // Mark new bookings as visited when user switches to tab 1
        if (index == 1) {
          newBookingsController.markNewBookingsAsVisited();
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: TextWidget(
          text: label,
          fontColor: _currentIndex == index
              ? AppColors.black
              : AppColors.greyDarkLight,
          fontSize: 14,
          fontWeight:
              _currentIndex == index ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _currentOrderWidget() {
    return Obx(() {
      final data = currentOrderController.currentOrdersModel.value.data;
      if (data == null || data.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Center(
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
                  text: "noCurrentOrdersAvailable".tr,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.greyDark2,
                ),
              ],
            ),
          ),
        );
      }
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: List.generate(data.length, (index) {
                final parcelId = data[index].id ?? "";
                final deliverLocation =
                    data[index].deliveryLocation?.coordinates;
                final pickupLocation = data[index].pickupLocation?.coordinates;
                // Request address fetching for this parcel
                if (deliverLocation != null && deliverLocation.length == 2) {
                  final latitude = deliverLocation[1];
                  final longitude = deliverLocation[0];
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    cacheAddressForParcel(
                        parcelId, 'delivery', latitude, longitude);
                  });
                }

                if (pickupLocation != null && pickupLocation.length == 2) {
                  final latitude = pickupLocation[1];
                  final longitude = pickupLocation[0];
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    cacheAddressForParcel(
                        parcelId, 'pickup', latitude, longitude);
                  });
                }

                //! Get the delivery and pickup addresses for this specific parcel
                final deliveryAddress = getParcelAddress(parcelId, 'delivery');
                final pickupAddress = getParcelAddress(parcelId, 'pickup');

                //! Date Formateed
                String formattedDate = "N/A";
                try {
                  final startDate =
                      DateTime.parse(data[index].deliveryStartTime.toString());
                  final endDate =
                      DateTime.parse(data[index].deliveryEndTime.toString());
                  formattedDate =
                      "${DateFormat(' dd.MM ').format(startDate)} ${'to'.tr} ${DateFormat(' dd.MM ').format(endDate)}";
                } catch (e) {
                  log("Error parsing dates: $e");
                }
                //!
                return Column(
                  children: [
                    if (index > 0) const SpaceWidget(spaceHeight: 8),
                    // Separator
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: const ImageWidget(
                                          height: 40,
                                          width: 40,
                                          imagePath: AppImagePath.sendParcel,
                                        ),
                                      ),
                                      const SpaceWidget(spaceWidth: 8),
                                      SizedBox(
                                        width: ResponsiveUtils.width(160),
                                        child: TextWidget(
                                          text: data[index].title ?? "",
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w500,
                                          fontColor: AppColors.black,
                                          overflow: TextOverflow.ellipsis,
                                          textAlignment: TextAlign.start,
                                        ),
                                      ),
                                      const SpaceWidget(spaceWidth: 8),
                                    ],
                                  ),
                                  const SpaceWidget(spaceHeight: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        color: AppColors.black,
                                        size: 12,
                                      ),
                                      const SpaceWidget(spaceWidth: 8),
                                      TextWidget(
                                        text:
                                            "${'from'.tr} $pickupAddress ${'cityTo'.tr} $deliveryAddress",
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        fontColor: AppColors.greyDark2,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlignment: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                  const SpaceWidget(spaceHeight: 8),
                                  if (data[index].status != "REQUESTED" &&
                                      data[index].status != "PENDING" &&
                                      data[index].status != "WAITING")
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.call,
                                              color: AppColors.black,
                                              size: 12,
                                            ),
                                            const SpaceWidget(spaceWidth: 8),
                                            TextWidget(
                                              text:
                                                  data[index].phoneNumber ?? "",
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              fontColor: AppColors.greyDark2,
                                            ),
                                          ],
                                        ),
                                        const SpaceWidget(spaceHeight: 8),
                                      ],
                                    ),
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
                                  const SpaceWidget(spaceHeight: 10),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextWidget(
                                    text:
                                        "${AppStrings.currency} ${data[index].price}",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontColor: AppColors.black,
                                  ),
                                  const SpaceWidget(spaceHeight: 20),

                                  // Only show status for sendParcel type
                                  if (data[index].typeParcel.toString() ==
                                      "sendParcel") ...[
                                    TextWidget(
                                      text: data[index].status == "PENDING" ||
                                              data[index].status ==
                                                  "REQUESTED" ||
                                              data[index].status == "WAITING"
                                          ? "waiting".tr
                                          : data[index].status == "IN_TRANSIT"
                                              ? "inTransit".tr
                                              : data[index].status ==
                                                      "DELIVERED"
                                                  ? "delivered".tr
                                                  : "",
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      fontColor: data[index].status ==
                                                  "PENDING" ||
                                              data[index].status ==
                                                  "REQUESTED" ||
                                              data[index].status == "WAITING"
                                          ? AppColors.red
                                          : data[index].status == "IN_TRANSIT"
                                              ? AppColors.green
                                              : data[index].status ==
                                                      "DELIVERED"
                                                  ? AppColors.green
                                                  : AppColors.black,
                                    ),
                                  ],
                                  const SpaceWidget(spaceHeight: 12),
                                  // Show contact buttons for both sendParcel and deliveryRequest if in transit
                                  if ((data[index].typeParcel.toString() ==
                                              "sendParcel" &&
                                          data[index].status == "IN_TRANSIT") ||
                                      (data[index].typeParcel.toString() ==
                                              "deliveryRequest" &&
                                          data[index].status == "IN_TRANSIT") ||
                                      (data[index].typeParcel.toString() ==
                                              "assignedParcel" &&
                                          data[index].status ==
                                              "IN_TRANSIT")) ...[
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            String phoneNumber = "";
                                            if (data[index]
                                                    .typeParcel
                                                    .toString() ==
                                                "deliveryRequest") {
                                              // For deliveryRequest type
                                              if (data[index].status ==
                                                  "IN_TRANSIT") {
                                                phoneNumber = data[index]
                                                        .senderId
                                                        ?.mobileNumber
                                                        .toString() ??
                                                    "";
                                              }
                                            } else if (data[index]
                                                    .typeParcel
                                                    .toString() ==
                                                "assignedParcel") {
                                              // For finished Delivery
                                              if (data[index].status ==
                                                  "IN_TRANSIT") {
                                                phoneNumber = data[index]
                                                        .senderId
                                                        ?.mobileNumber
                                                        .toString() ??
                                                    "";
                                              }
                                            } else {
                                              // For sendParcel type
                                              if (data[index].status ==
                                                  "IN_TRANSIT") {
                                                phoneNumber = data[index]
                                                        .assignedDelivererId
                                                        ?.mobileNumber
                                                        .toString() ??
                                                    "";
                                              }
                                            }
                                            _openWhatsApp(phoneNumber,
                                                "Hello, regarding your parcel delivery.");
                                          },
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: const CircleAvatar(
                                            backgroundColor:
                                                AppColors.whiteDark,
                                            radius: 18,
                                            child: IconWidget(
                                              icon: AppIconsPath.whatsAppIcon,
                                              color: AppColors.black,
                                              width: 18,
                                              height: 18,
                                            ),
                                          ),
                                        ),
                                        const SpaceWidget(spaceWidth: 8),
                                        InkWell(
                                          onTap: () {
                                            String phoneNumber = "";
                                            if (data[index]
                                                    .typeParcel
                                                    .toString() ==
                                                "deliveryRequest") {
                                              // For deliveryRequest type
                                              if (data[index].status ==
                                                  "IN_TRANSIT") {
                                                phoneNumber = data[index]
                                                        .senderId
                                                        ?.mobileNumber
                                                        .toString() ??
                                                    "";
                                              }
                                            } else if (data[index]
                                                    .typeParcel
                                                    .toString() ==
                                                "assignedParcel") {
                                              // For finished Delivery
                                              if (data[index].status ==
                                                  "IN_TRANSIT") {
                                                phoneNumber = data[index]
                                                        .senderId
                                                        ?.mobileNumber
                                                        .toString() ??
                                                    "";
                                              }
                                            } else {
                                              // For sendParcel type
                                              if (data[index].status ==
                                                  "IN_TRANSIT") {
                                                phoneNumber = data[index]
                                                        .assignedDelivererId
                                                        ?.mobileNumber
                                                        .toString() ??
                                                    "";
                                              }
                                            }
                                            _makePhoneCall(phoneNumber);
                                          },
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: const CircleAvatar(
                                            backgroundColor:
                                                AppColors.whiteDark,
                                            radius: 18,
                                            child: Icon(
                                              Icons.call,
                                              color: AppColors.black,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SpaceWidget(spaceHeight: 8),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.whiteLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    // Navigate to appropriate screen based on type
                                    if (data[index].typeParcel.toString() ==
                                        "deliveryRequest") {
                                      Get.toNamed(AppRoutes.viewDetailsScreen,
                                          arguments: data[index].id);
                                    } else {
                                      Get.toNamed(AppRoutes.parcelDetailsScreen,
                                          arguments: data[index].id);
                                    }
                                  },
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.remove_red_eye_outlined,
                                        color: AppColors.black,
                                        size: 16,
                                      ),
                                      const SpaceWidget(spaceWidth: 8),
                                      TextWidget(
                                        text:
                                            data[index].typeParcel.toString() ==
                                                    "deliveryRequest"
                                                ? "viewDetails".tr
                                                : "parcelDetails".tr,
                                        fontSize: 14,
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
                                  onTap: () {
                                    // Handle actions based on parcel type and status
                                    if (data[index].typeParcel.toString() ==
                                        "deliveryRequest") {
                                      if (data[index].status == "IN_TRANSIT") {
                                        String parcelId = data[index].id ?? "";
                                        // Always set status to DELIVERED when finishing
                                        deliveryFinished(parcelId, "DELIVERED");
                                      } else if (data[index].status ==
                                              "REQUESTED" ||
                                          data[index].status == "PENDING" ||
                                          data[index].status == "WAITING") {
                                        String parcelId = data[index].id ?? "";
                                        //cancelParcelFromDelivery(parcelId);
                                        // Cancel Delivery
                                      }
                                    } else if (data[index]
                                            .typeParcel
                                            .toString() ==
                                        "assignedParcel") {
                                      if (data[index].status == "IN_TRANSIT") {
                                        String parcelId = data[index].id ?? "";
                                        deliveryFinished(parcelId, "DELIVERED");
                                      }
                                    } else {
                                      // For sendParcel type
                                      if (data[index].status == "IN_TRANSIT") {
                                        Get.toNamed(
                                            AppRoutes.deliveryManDetails,
                                            arguments: data[index].id);
                                      } else if (data[index].status ==
                                          "DELIVERED") {
                                        // Check if review already exists
                                        if (hasAlreadyReviewed(
                                            data[index].id ?? "",
                                            data[index])) {
                                          // Pass the full parcel object, not just the ID
                                          AppSnackBar.reviewError(
                                              "reviewError".tr);
                                        } else {
                                          // Set parcel ID and user ID for review
                                          currentOrderController.parcelID
                                              .value = data[index].id ?? "";
                                          currentOrderController.userID.value =
                                              data[index]
                                                      .assignedDelivererId
                                                      ?.id ??
                                                  "";
                                          _openBottomSheet(
                                            data[index].id ?? "",
                                            data[index],
                                          );
                                        }
                                      } else {
                                        // Remove from map option
                                        String parcelId = data[index].id ?? "";
                                        removeParcelConfirmation(parcelId);
                                      }
                                    }
                                  },
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Row(
                                    children: [
                                      if (data[index].typeParcel.toString() ==
                                              "sendParcel" &&
                                          data[index].status == "IN_TRANSIT")
                                        const IconWidget(
                                          icon: AppIconsPath.deliverymanIcon,
                                          color: AppColors.greyDark2,
                                          width: 14,
                                          height: 14,
                                        ),
                                      if (data[index].typeParcel.toString() ==
                                              "sendParcel" &&
                                          data[index].status == "IN_TRANSIT")
                                        const SpaceWidget(spaceWidth: 8)
                                      else
                                        const SpaceWidget(spaceWidth: 0),
                                      SizedBox(
                                        width: ResponsiveUtils.width(120),
                                        child: TextWidget(
                                          text:
                                              data[index].status == "DELIVERED"
                                                  ? "rateDriver".tr
                                                  : _getActionButtonText(
                                                      data[index]),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontColor:
                                              data[index].status == "DELIVERED"
                                                  ? AppColors.greyDark2
                                                  : _getActionButtonColor(
                                                      data[index]),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SpaceWidget(spaceHeight: 80),
        ],
      );
    });
  }

  // Helper method to determine the action button text based on parcel type and status
  String _getActionButtonText(dynamic parcel) {
    if (parcel.typeParcel.toString() == "deliveryRequest") {
      // For deliveryRequest type
      if (parcel.status == "IN_TRANSIT") {
        return "Finish Delivery".tr;
      } else if (parcel.status == "REQUESTED" ||
          parcel.status == "PENDING" ||
          parcel.status == "WAITING") {
        return "waitingForApproval".tr;
      }
    } else if (parcel.typeParcel.toString() == "assignedParcel") {
      // For finished Delivery
      if (parcel.status == "IN_TRANSIT") {
        return "finishDelivery".tr;
      }
    } else {
      // For sendParcel type
      if (parcel.status == "IN_TRANSIT") {
        return "deliveryManDetails".tr;
      } else if (parcel.status == "DELIVERED") {
        // Check if review already exists
        if (hasAlreadyReviewed(parcel.id ?? "", parcel)) {
          return "reviewGiven".tr;
        } else {
          return "givingReview".tr;
        }
      } else {
        return "removeFromMap".tr;
      }
    }
    return "waitingForApproval".tr; // Default fallback
  }

  // Helper method to determine the action button color based on parcel type and status
  Color _getActionButtonColor(dynamic parcel) {
    if (parcel.typeParcel.toString() == "deliveryRequest") {
      // For deliveryRequest type
      if (parcel.status == "IN_TRANSIT") {
        return AppColors.green; // Green for finish delivery
      } else if (parcel.status == "REQUESTED" ||
          parcel.status == "PENDING" ||
          parcel.status == "WAITING") {
        return AppColors.green; // Green for waiting for approval
      }
    } else if (parcel.typeParcel.toString() == "assignedParcel") {
      // For finished Delivery
      if (parcel.status == "IN_TRANSIT") {
        return AppColors.green;
      }
    } else {
      // For sendParcel type
      if (parcel.status == "IN_TRANSIT") {
        return AppColors.greyDark2;
      } else if (parcel.status == "DELIVERED") {
        // Check if review already exists
        if (hasAlreadyReviewed(parcel.id ?? "", parcel)) {
          return AppColors.greyDark2; // Grey for already reviewed
        } else {
          return AppColors.green; // Green for giving review
        }
      } else {
        return AppColors.red;
      }
    }
    return AppColors.green; // Default fallback
  }

  Widget _newBookingWidget() {
    return SingleChildScrollView(
      child: Obx(() {
        final newBookingsController = Get.find<NewBookingsController>();
        if (currentOrderController.currentOrdersModel.value.data == null) {
          // Only call getCurrentOrder if not already loading
          if (!currentOrderController.isLoading.value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              currentOrderController.getCurrentOrderWithCache();
            });
          }
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.black,
                size: 40,
              ),
            ),
          );
        }
        final allParcels = currentOrderController.currentOrdersModel.value.data;
        // Filter only parcels that have deliveryRequests
        final parcelsWithRequests = allParcels
                ?.where((parcel) =>
                    parcel.typeParcel == "sendParcel" &&
                    parcel.deliveryRequests != null &&
                    parcel.deliveryRequests!.isNotEmpty)
                .toList() ??
            [];

        if (parcelsWithRequests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Icon(
                    Icons.inbox_outlined,
                    size: 60,
                    color: AppColors.greyDarkLight,
                  ),
                  const SizedBox(height: 16),
                  TextWidget(
                    text: "noNewRequests".tr,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontColor: AppColors.greyDark2,
                    textAlignment: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          children: [
            const SpaceWidget(spaceHeight: 15),
            ...List.generate(parcelsWithRequests.length, (index) {
              final parcel = parcelsWithRequests[index];
              final parcelId = parcel.id ?? "";
              final deliveryRequest = parcel.deliveryRequests!.first;
              String formattedDate = "N/A";
              try {
                final startDate =
                    DateTime.parse(parcel.deliveryStartTime.toString());
                final endDate =
                    DateTime.parse(parcel.deliveryEndTime.toString());
                formattedDate =
                    "${DateFormat(' dd.MM ').format(startDate)} to ${DateFormat(' dd.MM ').format(endDate)}";
              } catch (e) {
                log("Error parsing dates: $e");
              }
              final deliveryLocation = parcel.deliveryLocation?.coordinates;
              final pickupLocation = parcel.pickupLocation?.coordinates;
              // Track the request state locally using a unique key for the request
              final String requestKey =
                  '${parcel.id}-${deliveryRequest.id ?? ""}';
              final requestState =
                  newBookingsController.requestStates[requestKey] ?? 'pending';

              // Request address fetching for this parcel
              if (deliveryLocation != null && deliveryLocation.length == 2) {
                final latitude = deliveryLocation[1];
                final longitude = deliveryLocation[0];
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  cacheAddressForParcel(
                      parcelId, 'delivery', latitude, longitude);
                });
              }

              if (pickupLocation != null && pickupLocation.length == 2) {
                final latitude = pickupLocation[1];
                final longitude = pickupLocation[0];
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  cacheAddressForParcel(
                      parcelId, 'pickup', latitude, longitude);
                });
              }

              // Get addresses for this specific parcel
              final deliveryAddress = getParcelAddress(parcelId, 'delivery');
              final pickupAddress = getParcelAddress(parcelId, 'pickup');

              String getProfileImagePath() {
                // Check if deliveryRequest.image is null first
                if (deliveryRequest.image == null) {
                  log('❌ Image URL is null, using default image URL');
                  return 'https://i.ibb.co/z5YHLV9/profile.png';
                }

                final imageUrl = deliveryRequest.image!;
                log('Raw image URL from API: "$imageUrl"');
                log('Image URL type: ${imageUrl.runtimeType}');

                // Check for null, empty, or invalid URLs
                if (imageUrl.isEmpty ||
                    imageUrl.trim().isEmpty ||
                    imageUrl.toLowerCase() == 'null' ||
                    imageUrl.toLowerCase() == 'undefined') {
                  log('❌ Image URL is null/empty/invalid, using default image URL');
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
                  log('❌ Invalid URL format: $fullImageUrl, using default image URL');
                  return 'https://i.ibb.co/z5YHLV9/profile.png';
                }

                log('✅ Constructed URL: $fullImageUrl');
                return fullImageUrl;
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.greyDarkLight.withAlpha(25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                getProfileImagePath(),
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // First try the network fallback URL
                                  return Image.network(
                                    'https://i.ibb.co/z5YHLV9/profile.png',
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // If network fallback also fails, use local asset
                                      return Image.asset(
                                        'assets/images/profileImages.png',
                                        height: 40,
                                        width: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          // Final fallback: a simple container with icon
                                          return Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              color: AppColors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            child: const Icon(
                                              Icons.person,
                                              color: AppColors.white,
                                              size: 24,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Center(
                                      child: LoadingAnimationWidget.hexagonDots(
                                        color: AppColors.black,
                                        size: 20,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SpaceWidget(spaceWidth: 8),
                            SizedBox(
                              width:
                                  (deliveryRequest.fullName?.length ?? 0) <= 12
                                      ? ResponsiveUtils.width(60)
                                      : ResponsiveUtils.width(180),
                              child: TextWidget(
                                text: deliveryRequest.fullName ?? '',
                                fontSize: 15.5,
                                fontWeight: FontWeight.w500,
                                fontColor: AppColors.black,
                                overflow: TextOverflow.ellipsis,
                                textAlignment: TextAlign.start,
                                maxLines: 1,
                              ),
                            ),
                            const SpaceWidget(spaceWidth: 5),
                            if ((deliveryRequest.reviews?.isNotEmpty == true &&
                                deliveryRequest.reviews!
                                            .map((r) => r.rating ?? 0)
                                            .reduce((a, b) => a + b) /
                                        deliveryRequest.reviews!.length >
                                    0.0))
                              Container(
                                width: ResponsiveUtils.width(58),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.yellow,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: AppColors.white,
                                      size: 12,
                                    ),
                                    const SpaceWidget(spaceWidth: 4),
                                    TextWidget(
                                      text: (deliveryRequest.reviews!
                                                  .map((r) => r.rating ?? 0)
                                                  .reduce((a, b) => a + b) /
                                              deliveryRequest.reviews!.length)
                                          .toStringAsFixed(1),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      fontColor: AppColors.white,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SpaceWidget(spaceHeight: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                  text: parcel.title ?? '',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontColor: AppColors.greyDark2,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            TextWidget(
                              text: "${AppStrings.currency} ${parcel.price}",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontColor: AppColors.black,
                            ),
                          ],
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.black,
                              size: 12,
                            ),
                            const SpaceWidget(spaceWidth: 8),
                            Flexible(
                              child: TextWidget(
                                text:
                                    "${'from'.tr} $pickupAddress ${'cityTo'.tr} $deliveryAddress",
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontColor: AppColors.greyDark2,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                        const SpaceWidget(spaceHeight: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.delivery_dining_outlined,
                              color: AppColors.black,
                              size: 15,
                            ),
                            const SpaceWidget(spaceWidth: 8),
                            TextWidget(
                              text: allParcels?.first.deliveryType == 'bike'
                                  ? 'Bike'
                                  : allParcels?.first.deliveryType == 'bicycle'
                                      ? 'Bicycle'
                                      : allParcels?.first.deliveryType == 'car'
                                          ? 'Car'
                                          : allParcels?.first.deliveryType ==
                                                  'taxi'
                                              ? 'Taxi'
                                              : allParcels?.first
                                                          .deliveryType ==
                                                      'truck'
                                                  ? 'Truck'
                                                  : allParcels?.first
                                                              .deliveryType ==
                                                          'person'
                                                      ? 'Person'
                                                      : allParcels?.first
                                                                  .deliveryType ==
                                                              'plane'
                                                          ? 'Plane'
                                                          : allParcels?.first
                                                                  .deliveryType ??
                                                              '',
                              // Default empty string if null
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontColor: AppColors.greyDark2,
                            )
                          ],
                        ),
                        const SpaceWidget(spaceHeight: 8),
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
                            onTap: requestState == 'accepted' ||
                                    requestState == 'rejected'
                                ? null // Disable if already acted upon
                                : () async {
                                    // Implement reject functionality
                                    await newBookingsController
                                        .rejectParcelRequest(
                                      parcel.id ?? '',
                                      deliveryRequest.id ?? '',
                                    );
                                  },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Row(
                              children: [
                                Icon(
                                  requestState == 'rejected'
                                      ? Icons.close
                                      : Icons.close,
                                  color: requestState == 'accepted'
                                      ? AppColors.greyDark2
                                      : (requestState == 'rejected'
                                          ? AppColors.red
                                          : AppColors.red),
                                  size: 18,
                                ),
                                const SpaceWidget(spaceWidth: 4),
                                TextWidget(
                                  text: requestState == 'rejected'
                                      ? "rejected".tr
                                      : "reject".tr,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontColor: requestState == 'accepted'
                                      ? AppColors.greyDark2
                                      : (requestState == 'rejected'
                                          ? AppColors.red
                                          : AppColors.red),
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
                            onTap: requestState == 'accepted' ||
                                    requestState == 'rejected'
                                ? null // Disable if already acted upon
                                : () async {
                                    // Implement accept functionality
                                    await newBookingsController
                                        .acceptParcelRequest(
                                      parcel.id ?? '',
                                      deliveryRequest.id ?? '',
                                    );
                                  },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Row(
                              children: [
                                Icon(
                                  requestState == 'accepted'
                                      ? Icons.check
                                      : Icons.check,
                                  color: requestState == 'rejected'
                                      ? AppColors.greyDark2
                                      : (requestState == 'accepted'
                                          ? AppColors.green
                                          : AppColors.green),
                                  size: 18,
                                ),
                                const SpaceWidget(spaceWidth: 4),
                                TextWidget(
                                  text: requestState == 'accepted'
                                      ? "accepted".tr
                                      : "accept".tr,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontColor: requestState == 'rejected'
                                      ? AppColors.greyDark2
                                      : (requestState == 'accepted'
                                          ? AppColors.green
                                          : AppColors.green),
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
            }),
            const SpaceWidget(spaceHeight: 80),
          ],
        );
      }),
    );
  }
}
