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
import 'package:parcel_delivery_app/services/appStroage/location_storage.dart';
import 'package:parcel_delivery_app/utils/appLog/app_log.dart';
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
  final ServiceController controller = Get.find<ServiceController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final DeliveryScreenController deliveryController =
      Get.find<DeliveryScreenController>();
  final NotificationController notificationController =
      Get.find<NotificationController>();

  //! LocationStorage instance for persistent address caching
  late final LocationStorage locationStorage;

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

  //! Track previous unread count to detect changes
  int _previousUnreadCount = 0;

  @override
  void initState() {
    super.initState();

    // Initialize LocationStorage
    locationStorage = LocationStorage.instance;

    // Store initial unread count
    _previousUnreadCount = notificationController.unreadCount.value.toInt();

    // Listen for unread count changes
    ever(notificationController.unreadCount, (int newCount) {
      if (!_isDisposed && mounted) {
        // Refresh screen only when unread count changes from 0 to non-zero
        if (_previousUnreadCount == 0 && newCount != 0) {
          _refreshScreen();
        }
        _previousUnreadCount = newCount;
      }
    });

    // Initialize LocationStorage after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await locationStorage.initialize();
    });

    // Use cached profile data instead of forcing reload
    profileController.getProfileInfoWithCache();

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

  // Method to refresh the screen when notifications change
  Future<void> _refreshScreen() async {
    if (_isDisposed || !mounted) return;

    try {
      // Clear all address caches to force fresh data
      addressCache.clear();
      pickupAddresses.clear();
      deliveryAddresses.clear();
      pickupAddressLoading.clear();
      deliveryAddressLoading.clear();
      pendingRequests.clear();

      // Refresh profile data
      await profileController.getProfileInfo();

      // Refresh recent parcel list using the correct method
      await controller.fetchParcelList();

      // Reload addresses for parcels
      if (controller.recentParcelList.isNotEmpty) {
        _loadAddressesForParcels();
      }

      // Trigger UI rebuild
      if (mounted && !_isDisposed) {
        setState(() {});
      }
    } catch (e) {
      // Handle refresh errors gracefully
      appLog('Error refreshing services screen: $e');
    }
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

  void _loadParcelAddresses(Datum parcel) async {
    final parcelId = parcel.id;
    if (parcelId == null || _isDisposed) return;

    // Check LocationStorage for existing addresses first
    final pickupLocationData =
        await locationStorage.getLocationData(parcelId, 'pickup');
    final deliveryLocationData =
        await locationStorage.getLocationData(parcelId, 'delivery');

    if (pickupLocationData != null) {
      _updateAddress(parcelId, pickupLocationData.address, true);
    }

    if (deliveryLocationData != null) {
      _updateAddress(parcelId, deliveryLocationData.address, false);
    }

    final pickupCoordinates = parcel.pickupLocation?.coordinates;
    final deliveryCoordinates = parcel.deliveryLocation?.coordinates;

    // Only fetch pickup address if not found in LocationStorage
    if (pickupLocationData == null &&
        pickupCoordinates != null &&
        pickupCoordinates.length >= 2) {
      final pickupLat = pickupCoordinates[1];
      final pickupLng = pickupCoordinates[0];
      _getAddress(parcelId, pickupLat, pickupLng, true);
    } else if (pickupLocationData == null) {
      _handleAddressError(parcelId, true, "Invalid");
    }

    // Only fetch delivery address if not found in LocationStorage
    if (deliveryLocationData == null &&
        deliveryCoordinates != null &&
        deliveryCoordinates.length >= 2) {
      final deliveryLat = deliveryCoordinates[1];
      final deliveryLng = deliveryCoordinates[0];
      _getAddress(parcelId, deliveryLat, deliveryLng, false);
    } else if (deliveryLocationData == null) {
      _handleAddressError(parcelId, false, "Invalid");
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
      _handleAddressError(parcelId, isPickup, "Invalid");
      return;
    }

    final String key =
        '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';

    //! Check LocationStorage coordinate cache first
    final cachedAddress =
        await locationStorage.getAddressFromCoordinates(latitude, longitude);
    if (cachedAddress != null) {
      addressCache[key] = cachedAddress;
      _updateAddress(parcelId, cachedAddress, isPickup);
      return;
    }

    //! Check in-memory cache
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

        // Store in LocationStorage for persistence
        final locationData = LocationData(
          parcelId: parcelId,
          addressType: isPickup ? 'pickup' : 'delivery',
          latitude: latitude,
          longitude: longitude,
          address: address,
          timestamp: DateTime.now(),
        );
        await locationStorage.storeLocationData(locationData);

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
          }  else {
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
                                          "${DateFormat(' dd.MM ').format(startDate)} ${'to'.tr} ${DateFormat(' dd.MM ').format(endDate)}";
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
                                                  "${'from'.tr} $pickupAddress ${'cityTo'.tr} $deliveryAddress",
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
