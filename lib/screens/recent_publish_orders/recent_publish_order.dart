import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/services_screen/controller/services_controller.dart';
import 'package:parcel_delivery_app/screens/services_screen/model/service_screen_model.dart';
import 'package:parcel_delivery_app/services/appStroage/location_storage.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_button_widget/text_button_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

import '../../constants/app_icons_path.dart';
import '../../widgets/icon_widget/icon_widget.dart';
import '../delivery_parcel_screens/controller/delivery_screens_controller.dart';

class RecentPublishOrder extends StatefulWidget {
  const RecentPublishOrder({super.key});

  @override
  State<RecentPublishOrder> createState() => _RecentPublishOrderState();
}

class _RecentPublishOrderState extends State<RecentPublishOrder> {
  final ServiceController serviceController = Get.find();
  final DeliveryScreenController deliveryController =
      Get.put(DeliveryScreenController());

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

  @override
  void initState() {
    super.initState();
    // Initialize LocationStorage
    locationStorage = LocationStorage.instance;
    
    // Initialize addresses after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await locationStorage.initialize();
      _initializeAddressStates();
    });
  }

  void _initializeAddressStates() {
    if (serviceController.recentParcelList.isNotEmpty) {
      for (var serviceModel in serviceController.recentParcelList) {
        // Access the Datum objects correctly
        if (serviceModel.data != null && serviceModel.data!.isNotEmpty) {
          for (var parcel in serviceModel.data!) {
            final parcelId = parcel.id;
            if (parcelId != null) {
              //! Initialize loading states
              setState(() {
                pickupAddressLoading[parcelId] = true;
                deliveryAddressLoading[parcelId] = true;
              });

              //! Load addresses
              _loadParcelAddresses(parcel);
            }
          }
        }
      }
    }
  }

  void _loadParcelAddresses(Datum parcel) async {
    final parcelId = parcel.id;
    if (parcelId == null) return;

    //! Check LocationStorage for existing addresses first
    final pickupLocationData = await locationStorage.getLocationData(parcelId, 'pickup');
    final deliveryLocationData = await locationStorage.getLocationData(parcelId, 'delivery');

    if (pickupLocationData != null) {
      setState(() {
        pickupAddresses[parcelId] = pickupLocationData.address;
        pickupAddressLoading[parcelId] = false;
      });
    }

    if (deliveryLocationData != null) {
      setState(() {
        deliveryAddresses[parcelId] = deliveryLocationData.address;
        deliveryAddressLoading[parcelId] = false;
      });
    }

    //! Safely extract coordinates from Datum object (not map)
    final pickupCoordinates = parcel.pickupLocation?.coordinates;
    final deliveryCoordinates = parcel.deliveryLocation?.coordinates;

    if (pickupLocationData == null && pickupCoordinates != null && pickupCoordinates.length >= 2) {
      final pickupLat = pickupCoordinates[1]; // latitude is at index 1
      final pickupLng = pickupCoordinates[0]; // longitude is at index 0
      _getAddress(parcelId, pickupLat, pickupLng, true);
    } else if (pickupLocationData == null) {
      _handleAddressError(parcelId, true, "Invalid pickup coordinates");
    }

    if (deliveryLocationData == null && deliveryCoordinates != null && deliveryCoordinates.length >= 2) {
      final deliveryLat = deliveryCoordinates[1];
      final deliveryLng = deliveryCoordinates[0];
      _getAddress(parcelId, deliveryLat, deliveryLng, false);
    } else if (deliveryLocationData == null) {
      _handleAddressError(parcelId, false, "Invalid delivery coordinates");
    }
  }

  Future<void> _getAddress(
      String parcelId, double latitude, double longitude, bool isPickup) async {
    // Validate coordinates
    if (latitude.isNaN ||
        longitude.isNaN ||
        latitude.abs() > 90 ||
        longitude.abs() > 180) {
      _handleAddressError(parcelId, isPickup, "Invalid coordinates");
      return;
    }

    final String key = '$latitude,$longitude';

    //! Check LocationStorage coordinate cache first
    final cachedAddress = await locationStorage.getAddressFromCoordinates(latitude, longitude);
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

    try {
      // Add timeout to prevent hanging
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Address lookup timeout');
        },
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];

        // Get single address property in priority order: locality > subLocality > street > subAdministrativeArea
        String address;

        if (placemark.locality != null &&
            placemark.locality!.trim().isNotEmpty) {
          address = placemark.locality!.trim();
        } else if (placemark.subLocality != null &&
            placemark.subLocality!.trim().isNotEmpty) {
          address = placemark.subLocality!.trim();
        } else if (placemark.street != null &&
            placemark.street!.trim().isNotEmpty) {
          address = placemark.street!.trim();
        } else if (placemark.subAdministrativeArea != null &&
            placemark.subAdministrativeArea!.trim().isNotEmpty) {
          address = placemark.subAdministrativeArea!.trim();
        } else if (placemark.administrativeArea != null &&
            placemark.administrativeArea!.trim().isNotEmpty) {
          address = placemark.administrativeArea!.trim();
        } else if (placemark.country != null &&
            placemark.country!.trim().isNotEmpty) {
          address = placemark.country!.trim();
        } else {
          address = 'Unknown Location';
        }
        addressCache[key] = address;
        
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
        _updateAddress(parcelId, genericAddress, isPickup);
      }
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('timeout')) {
        errorMessage = 'Address lookup timed out';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Location permission required';
      } else {
        // Always provide generic location message instead of coordinates
        const genericErrorMessage = 'Location Unavailable';
        addressCache[key] = genericErrorMessage;
        _updateAddress(parcelId, genericErrorMessage, isPickup);
        return;
      }

      _handleAddressError(parcelId, isPickup, errorMessage);
    }
  }

  void _updateAddress(String parcelId, String address, bool isPickup) {
    if (mounted) {
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
        String displayMessage;
        
        // Provide specific error messages based on error type
        if (errorMessage.contains('Invalid coordinates')) {
          displayMessage = 'Invalid Location';
        } else if (errorMessage.contains('timeout')) {
          displayMessage = 'Location Timeout';
        } else if (errorMessage.contains('Network error')) {
          displayMessage = 'Network Error';
        } else if (errorMessage.contains('permission')) {
          displayMessage = 'Permission Required';
        } else {
          displayMessage = 'Address Unavailable';
        }
        
        if (isPickup) {
          pickupAddresses[parcelId] = displayMessage;
          pickupAddressLoading[parcelId] = false;
        } else {
          deliveryAddresses[parcelId] = displayMessage;
          deliveryAddressLoading[parcelId] = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ServiceController());

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SpaceWidget(spaceHeight: 30),
              TextWidget(
                text: "recentPublishOrders".tr,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontColor: AppColors.black,
              ),
              const SpaceWidget(spaceHeight: 24),
              Obx(() {
                if (controller.loading.value) {
                  return Center(
                    child: LoadingAnimationWidget.hexagonDots(
                      color: AppColors.black,
                      size: 40,
                    ),
                  );
                }

                if (controller.recentParcelList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const ImageWidget(
                          imagePath: AppImagePath.sendParcel,
                          width: 80,
                          height: 80,
                        ),
                        const SpaceWidget(spaceHeight: 16),
                        const TextWidget(
                          text: "No recent orders available",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontColor: AppColors.greyDark2,
                        ),
                        const SpaceWidget(spaceHeight: 16),
                        TextButtonWidget(
                          onPressed: () {
                            controller.refreshParcelList();
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              _initializeAddressStates();
                            });
                          },
                          text: "Retry",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          textColor: AppColors.black,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: List.generate(controller.recentParcelList.length,
                      (index) {
                    ServiceScreenModel item =
                        controller.recentParcelList[index];

                    // Safely access data or provide default values
                    String title = "Title not available";
                    String itemId = "";
                    String price = "0";
                    String status = "Status not available";
                    String receiverName = "Receiver not available";

                    if (item.data != null && item.data!.isNotEmpty) {
                      title = item.data!.first.title ?? "Title not available";
                      itemId = item.data!.first.id ?? "";
                      price = item.data!.first.price?.toString() ?? "0";
                      receiverName =
                          item.data!.first.name ?? "Receiver not available";
                    }

                    if (item.status != null) {
                      status = item.status!;
                    }

                    //! Get address display values
                    final bool isPickupLoading =
                        pickupAddressLoading[itemId] ?? true;
                    final bool isDeliveryLoading =
                        deliveryAddressLoading[itemId] ?? true;
                    final String pickupAddress = isPickupLoading
                        ? "Loading pickup address..."
                        : pickupAddresses[itemId] ?? "Address unavailable";
                    final String deliveryAddress = isDeliveryLoading
                        ? "Loading delivery address..."
                        : deliveryAddresses[itemId] ?? "Address unavailable";

                    // Check if request has been sent (you'll need to implement this logic based on your controller)
                    final bool hasRequestSent =
                        deliveryController.isRequestSent(itemId);

                    // Format dates if available
                    String formattedDate = "N/A";
                    try {
                      final startDate = DateTime.parse(
                          item.data!.first.deliveryStartTime.toString());
                      final endDate = DateTime.parse(
                          item.data!.first.deliveryEndTime.toString());
                      formattedDate =
                          "${DateFormat(' dd.MM ').format(startDate)} to ${DateFormat(' dd.MM ').format(endDate)}";
                    } catch (e) {
                      //! log("Error parsing dates: $e");
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: const ImageWidget(
                                      imagePath: AppImagePath.sendParcel,
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                  const SpaceWidget(spaceWidth: 12),
                                  SizedBox(
                                    width: ResponsiveUtils.width(180),
                                    child: TextWidget(
                                      text: title,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                      fontColor: AppColors.black,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlignment: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                              TextWidget(
                                text: "${AppStrings.currency} $price",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontColor: AppColors.black,
                              ),
                            ],
                          ),
                          const SpaceWidget(spaceHeight: 12),
                          //! Status section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: AppColors.black,
                                size: 14,
                              ),
                              const SpaceWidget(spaceWidth: 8),
                              TextWidget(
                                text: "$pickupAddress To $deliveryAddress",
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
                              mainAxisAlignment: MainAxisAlignment.end,
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
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: hasRequestSent
                                      ? null
                                      : () {
                                          deliveryController
                                              .sendParcelRequest(itemId);
                                        },
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Row(
                                    children: [
                                      IconWidget(
                                        icon: AppIconsPath.personAddIcon,
                                        color: hasRequestSent
                                            ? Colors.grey
                                            : AppColors.black,
                                        width: 14,
                                        height: 14,
                                      ),
                                      const SpaceWidget(spaceWidth: 8),
                                      TextWidget(
                                        text: hasRequestSent
                                            ? "requestSent".tr
                                            : "sendRequest".tr,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
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
                                        dataList.first.id != null) {
                                      const String routeName = AppRoutes
                                          .serviceScreenDeliveryDetails;
                                      if (routeName.isNotEmpty) {
                                        try {
                                          Get.toNamed(routeName,
                                              arguments: dataList.first.id);
                                        } catch (e) {
                                          // AppSnackBar.error(
                                          //     "Navigation error: ${e.toString()}");
                                        }
                                      } else {
                                        // AppSnackBar.error(
                                        //     "Route name is not properly defined.");
                                      }
                                    } else {
                                      // AppSnackBar.error(
                                      //     "Parcel details not available or ID is missing.");
                                    }
                                  },
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.visibility_outlined,
                                        color: Colors.black,
                                        size: 14,
                                      ),
                                      const SpaceWidget(spaceWidth: 8),
                                      TextWidget(
                                        text: "seeDetails".tr,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: AppColors.black,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }),
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 08),
        child: Row(
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
          ],
        ),
      ),
    );
  }
}
