import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; // Import geocoding package
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/screens/delivery_parcel_screens/controller/delivery_screens_controller.dart';
import 'package:parcel_delivery_app/screens/delivery_parcel_screens/summary_of_parcel_screen/widgets/summary_info_row_widget.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';
import '../models/delivery_screen_models.dart';

class SummaryOfParcelScreen extends StatefulWidget {
  const SummaryOfParcelScreen({super.key});

  @override
  State<SummaryOfParcelScreen> createState() => _SummaryOfParcelScreenState();
}

class _SummaryOfParcelScreenState extends State<SummaryOfParcelScreen> {
  late final String parcelId;
  DeliverParcelList? parcel;
  bool isLoading = true;
  String address = "";
  String pickupAddress = "";
  String exactPickupLocation = "";
  String exactDeliveryLocation = "";
  Map<String, String> addressCache = {};

  @override
  void initState() {
    super.initState();
    parcelId = Get.arguments;
    fetchParcelDetails(parcelId);
  }

  // Fetch the parcel details from controller using _id
  Future<void> fetchParcelDetails(String id) async {
    final deliveryScreenController = Get.find<DeliveryScreenController>();
    try {
      // Find specific parcel by ID
      parcel = deliveryScreenController.parcels.firstWhere((p) => p.sId == id);

      // Fetch addresses after finding the parcel
      if (parcel != null) {
        // Check for delivery location coordinates
        if (parcel!.deliveryLocation != null &&
            parcel!.deliveryLocation!.coordinates != null &&
            parcel!.deliveryLocation!.coordinates!.length == 2) {
          double longitude = parcel!.deliveryLocation!.coordinates![0];
          double latitude = parcel!.deliveryLocation!.coordinates![1];
          await _getAddress(latitude, longitude, false);
        }

        // Check for pickup location coordinates
        if (parcel!.pickupLocation != null &&
            parcel!.pickupLocation!.coordinates != null &&
            parcel!.pickupLocation!.coordinates!.length == 2) {
          double longitude = parcel!.pickupLocation!.coordinates![0];
          double latitude = parcel!.pickupLocation!.coordinates![1];
          await _getAddress(latitude, longitude, true);
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      log("Error fetching parcel details: $e");
    }
  }

  // Function to get address based on latitude and longitude
  Future<void> _getAddress(
      double latitude, double longitude, bool isPickup) async {
    final String key = '$latitude,$longitude';
    String addressType = isPickup ? "Pickup" : "Delivery";

    if (addressCache.containsKey(key)) {
      // Use cached address if available
      setState(() {
        if (isPickup) {
          pickupAddress = addressCache[key]!;
        } else {
          address = addressCache[key]!;
        }
      });
      return;
    }

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        String newAddress =
            '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}';

        String exactLocation = '${placemarks[0].street}, '
            '${placemarks[0].locality}, ${placemarks[0].administrativeArea},';
        addressCache[key] = newAddress;
        setState(() {
          if (isPickup) {
            pickupAddress = newAddress;
            exactPickupLocation = exactLocation;
          } else {
            address = newAddress;
            exactDeliveryLocation = exactLocation;
          }
        });
      } else {
        // If no address is found
        setState(() {
          if (isPickup) {
            pickupAddress = 'No pickup address found';
            exactPickupLocation = 'No exact pickup location found';
          } else {
            address = 'No delivery address found';
            exactDeliveryLocation = 'No exact delivery location found';
          }
        });
      }
    } catch (e) {
      // If an error occurs while fetching the address
      setState(() {
        if (isPickup) {
          pickupAddress = 'Error fetching pickup address';
          exactPickupLocation = 'Error fetching exact pickup location';
        } else {
          address = 'Error fetching delivery address';
          exactDeliveryLocation = 'Error fetching exact delivery location';
        }
      });
    }
  }

  String _getFormattedDeliveryTime(currentParcel) {
    log("deliveryStartTime: ${currentParcel?.deliveryStartTime}");
    log("deliveryEndTime: ${currentParcel?.deliveryEndTime}");
    try {
      if (currentParcel?.deliveryStartTime != null &&
          currentParcel?.deliveryEndTime != null) {
        final startDate =
            DateTime.parse(currentParcel.deliveryStartTime.toString());
        final endDate =
            DateTime.parse(currentParcel.deliveryEndTime.toString());
        return "${DateFormat('dd.MM').format(startDate)} to ${DateFormat('dd.MM').format(endDate)}";
      } else {
        return "N/A";
      }
    } catch (e) {
      log("Error in _getFormattedDeliveryTime: $e");
      return "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SpaceWidget(spaceHeight: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextWidget(
                    text: "summaryOfParcel".tr,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontColor: AppColors.black,
                  ),
                ),
                const SpaceWidget(spaceHeight: 40),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: const ImageWidget(
                                height: 40,
                                width: 40,
                                imagePath: AppImagePath.sendParcel,
                              ),
                            ),
                            const SpaceWidget(spaceWidth: 8),
                            TextWidget(
                              text: parcel?.title ?? "Unknown Parcel",
                              // Display parcel title
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontColor: AppColors.black,
                            ),
                          ],
                        ),
                        const SpaceWidget(spaceHeight: 16),
                        const Divider(
                          color: AppColors.grey,
                          thickness: 1,
                        ),
                        const SpaceWidget(spaceHeight: 16),
                        SummaryInfoRowWidget(
                          image: AppImagePath.profileImage,
                          label: "sendersName".tr,
                          value: parcel?.senderId?.fullName ??
                              "N/A", // Sender's name
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.profileIcon,
                          label: "receiversName".tr,
                          value: parcel?.name ?? "N/A",
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        // SummaryInfoRowWidget(
                        //   icon: AppIconsPath.callIcon,
                        //   label: "receiversNumber".tr,
                        //   value: parcel?.phoneNumber ?? "N/A",
                        // ),
                        //const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.deliveryTimeIcon,
                          label: "deliveryTimeText".tr,
                          value: _getFormattedDeliveryTime(parcel),
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        // Display starting location using FutureBuilder
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.destinationIcon,
                          label: "currentLocationText".tr,
                          value: exactPickupLocation.isNotEmpty
                              ? exactPickupLocation
                              : pickupAddress, // Exact pickup location
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.currentLocationIcon,
                          label: "destinationText".tr,
                          value: exactDeliveryLocation.isNotEmpty
                              ? exactDeliveryLocation
                              : address, // Exact delivery location
                        ),
                        // Display price
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.priceIcon,
                          label: "Price",
                          value: parcel?.price != null
                              ? "${parcel!.price}"
                              : "Not set",
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                            icon: AppIconsPath.descriptionIcon,
                            label: "descriptionText".tr,
                            value: parcel?.description ??
                                "No description" // Get this specific parcel's description
                            ),
                      ],
                    ),
                  ),
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
            // ButtonWidget(
            //   onPressed: () {
            //     Get.back();
            //   },
            //   label: "sendRequest".tr,
            //   textColor: AppColors.white,
            //   buttonWidth: 180,
            //   buttonHeight: 50,
            //   icon: Icons.arrow_forward,
            //   iconColor: AppColors.white,
            //   fontWeight: FontWeight.w500,
            //   fontSize: 16,
            //   iconSize: 20,
            // ),
          ],
        ),
      ),
    );
  }
}
