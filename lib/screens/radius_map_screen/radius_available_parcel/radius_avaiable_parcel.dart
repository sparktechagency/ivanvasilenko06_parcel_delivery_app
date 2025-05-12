import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:parcel_delivery_app/screens/delivery_parcel_screens/controller/delivery_screens_controller.dart';
import 'package:parcel_delivery_app/screens/home_screen/controller/earn_money_radius_controller.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

class RadiusAvailableParcel extends StatefulWidget {
  const RadiusAvailableParcel({super.key});

  @override
  _RadiusAvailableParcelState createState() => _RadiusAvailableParcelState();
}

class _RadiusAvailableParcelState extends State<RadiusAvailableParcel> {
  final EarnMoneyRadiusController _radiusController = Get.find();

  // Get the DeliveryScreenController instead of managing local state
  final DeliveryScreenController _deliveryController =
      Get.put(DeliveryScreenController());

  // Cache for addresses to avoid multiple API calls for the same coordinates
  Map<String, String> addressCache = {};

  // Maps to store addresses for each parcel
  Map<String, String> pickupAddresses = {};
  Map<String, String> deliveryAddresses = {};

  // Loading states for addresses
  Map<String, bool> pickupAddressLoading = {};
  Map<String, bool> deliveryAddressLoading = {};

  @override
  void initState() {
    super.initState();
    // Set initial loading states and load addresses
    _initializeAddressStates();
  }

  void _initializeAddressStates() {
    if (_radiusController.parcelsInRadius.isNotEmpty) {
      for (var parcel in _radiusController.parcelsInRadius) {
        final parcelId = parcel["_id"];

        // Initialize loading states
        setState(() {
          pickupAddressLoading[parcelId] = true;
          deliveryAddressLoading[parcelId] = true;
        });

        // Load addresses
        _loadParcelAddresses(parcel);
      }
    }
  }

  void _loadParcelAddresses(dynamic parcel) {
    final parcelId = parcel["_id"];

    // Safely extract coordinates with null checks
    final pickupCoordinates = parcel["pickupLocation"]?["coordinates"];
    final deliveryCoordinates = parcel["deliveryLocation"]?["coordinates"];

    if (pickupCoordinates != null && pickupCoordinates.length >= 2) {
      final pickupLat = double.tryParse(pickupCoordinates[1].toString()) ?? 0.0;
      final pickupLng = double.tryParse(pickupCoordinates[0].toString()) ?? 0.0;
      _getAddress(parcelId, pickupLat, pickupLng, true);
    } else {
      _handleAddressError(parcelId, true, "Invalid pickup coordinates");
    }

    if (deliveryCoordinates != null && deliveryCoordinates.length >= 2) {
      final deliveryLat =
          double.tryParse(deliveryCoordinates[1].toString()) ?? 0.0;
      final deliveryLng =
          double.tryParse(deliveryCoordinates[0].toString()) ?? 0.0;
      _getAddress(parcelId, deliveryLat, deliveryLng, false);
    } else {
      _handleAddressError(parcelId, false, "Invalid delivery coordinates");
    }
  }

  Future<void> _getAddress(
      String parcelId, double latitude, double longitude, bool isPickup) async {
    if (latitude == 0.0 && longitude == 0.0) {
      _handleAddressError(parcelId, isPickup, "Invalid coordinates");
      return;
    }

    final String key = '$latitude,$longitude';

    // Check cache first
    if (addressCache.containsKey(key)) {
      _updateAddress(parcelId, addressCache[key]!, isPickup);
      return;
    }

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        // Build a more complete address string
        final placemark = placemarks[0];
        final List<String> addressParts = [
          placemark.locality ?? '',
          // placemark.administrativeArea ?? '',
          // placemark.country ?? ''
        ].where((part) => part.isNotEmpty).toList();

        String address = addressParts.join(', ');

        // Cache the address
        addressCache[key] = address;

        // Update UI
        _updateAddress(parcelId, address, isPickup);
      } else {
        _handleAddressError(parcelId, isPickup, "No address found");
      }
    } catch (e) {
      log("Error getting address for parcel $parcelId (${isPickup ? 'pickup' : 'delivery'}): $e");
      _handleAddressError(parcelId, isPickup, "Error fetching address");
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
        if (isPickup) {
          pickupAddresses[parcelId] = errorMessage;
          pickupAddressLoading[parcelId] = false;
        } else {
          deliveryAddresses[parcelId] = errorMessage;
          deliveryAddressLoading[parcelId] = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: "parcelForDelivery".tr,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontColor: AppColors.black,
                ),
                Obx(() => TextWidget(
                      text:
                          "${_radiusController.parcelsInRadius.length} ${"found".tr}",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontColor: AppColors.greyDark2,
                    )),
              ],
            ),
          ),
          const SpaceWidget(spaceHeight: 16),
          Expanded(
            child: Obx(() {
              if (_radiusController.parcelsInRadius.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 64,
                        color: AppColors.greyDark,
                      ),
                      const SpaceWidget(spaceHeight: 16),
                      TextWidget(
                        text: "No Parcel Found".tr,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontColor: AppColors.greyDark2,
                      ),
                      const SpaceWidget(spaceHeight: 8),
                      TextWidget(
                        text: "Try Different Radius".tr,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontColor: AppColors.greyDark,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _initializeAddressStates();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: List.generate(
                      _radiusController.parcelsInRadius.length,
                      (index) {
                        final parcel = _radiusController.parcelsInRadius[index];
                        final parcelId = parcel["_id"] ?? "unknown";

                        // Format dates
                        String formattedDate = "N/A";
                        try {
                          final startDate =
                              DateTime.parse(parcel["deliveryStartTime"]);
                          final endDate =
                              DateTime.parse(parcel["deliveryEndTime"]);
                          formattedDate =
                              "${DateFormat(' dd.MM ').format(startDate)} to ${DateFormat(' dd.MM ').format(endDate)}";
                        } catch (e) {
                          log("Error parsing dates: $e");
                        }

                        // Get address display values
                        final bool isPickupLoading =
                            pickupAddressLoading[parcelId] ?? true;
                        final bool isDeliveryLoading =
                            deliveryAddressLoading[parcelId] ?? true;

                        final String pickupAddress = isPickupLoading
                            ? "Loading pickup address..."
                            : pickupAddresses[parcelId] ??
                                "Address unavailable";

                        final String deliveryAddress = isDeliveryLoading
                            ? "Loading delivery address..."
                            : deliveryAddresses[parcelId] ??
                                "Address unavailable";

                        // Check if parcel request has been sent using DeliveryScreenController
                        final bool hasRequestSent =
                            _deliveryController.isRequestSent(parcelId);

                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: const ImageWidget(
                                          imagePath: AppImagePath.sendParcel,
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                      const SpaceWidget(spaceWidth: 12),
                                      TextWidget(
                                        text: parcel["title"] ??
                                            "Untitled Parcel",
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w600,
                                        fontColor: AppColors.black,
                                      ),
                                    ],
                                  ),
                                  TextWidget(
                                    text:
                                        "${AppStrings.currency} ${parcel["price"] ?? 0}",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontColor: AppColors.black,
                                  ),
                                ],
                              ),
                              const SpaceWidget(spaceHeight: 12),
                              // Address section - From
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
                              // Add "Request Sent" text indicator like in ParcelForDeliveryScreen
                              if (hasRequestSent) ...[
                                const SpaceWidget(spaceHeight: 8),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 12,
                                    ),
                                    SpaceWidget(spaceWidth: 8),
                                    TextWidget(
                                      text: "Request Sent",
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: hasRequestSent
                                          ? null
                                          : () {
                                              // Use DeliveryScreenController to send the request
                                              _deliveryController
                                                  .sendParcelRequest(parcelId);
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
                                    // In radius_avaiable_parcel.dart file
// Locate this code block in your onTap handler for "View Summary" button

                                    InkWell(
                                      onTap: () {
                                        if (parcel != null) {
                                          // Debug the parcel object to ensure it's not null
                                          log("Navigating with parcel: $parcel");

                                          // Check if parcel has required coordinates
                                          final pickupCoords =
                                              parcel["pickupLocation"]
                                                  ?["coordinates"];
                                          final deliveryCoords =
                                              parcel["deliveryLocation"]
                                                  ?["coordinates"];

                                          if (pickupCoords == null ||
                                              deliveryCoords == null) {
                                            Get.snackbar(
                                              "Error",
                                              "Parcel location coordinates are missing.",
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                            );
                                            return;
                                          }

                                          // Make a copy of the parcel to avoid reference issues
                                          final parcelCopy =
                                              Map<String, dynamic>.from(parcel);

                                          // Navigate with the parcel data
                                          Get.toNamed(
                                            AppRoutes.radiusMapScreenDetails,
                                            arguments: parcelCopy,
                                          );
                                        } else {
                                          log("Parcel is null or missing required fields");
                                          Get.snackbar(
                                            "Error",
                                            "Parcel details are missing.",
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
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
                                            text: "viewSummary".tr,
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
                      },
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            ButtonWidget(
              onPressed: () {
                Get.offAll(() => const BottomNavScreen());
              },
              label: "backToHome".tr,
              textColor: AppColors.white,
              buttonWidth: 180,
              buttonHeight: 50,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              prefixIcon: AppIconsPath.homeOutlinedIcon,
            ),
          ],
        ),
      ),
    );
  }
}
