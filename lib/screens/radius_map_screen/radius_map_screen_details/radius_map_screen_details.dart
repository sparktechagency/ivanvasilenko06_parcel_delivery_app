import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

import '../../cancel_delivery_screen/widgets/summary_info_row_widget.dart';

class RadiusMapScreenDetails extends StatefulWidget {
  const RadiusMapScreenDetails({super.key});

  @override
  State<RadiusMapScreenDetails> createState() => _RadiusMapScreenDetailsState();
}

class _RadiusMapScreenDetailsState extends State<RadiusMapScreenDetails> {
  late Map<String, dynamic> parcel;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Safely retrieve the parcel details passed as arguments
    try {
      final args = Get.arguments;
      if (args == null || args is! Map<String, dynamic>) {
        setState(() {
          hasError = true;
          errorMessage = 'Invalid parcel data received';
          isLoading = false;
        });
        return;
      }

      parcel = args;
      log("Received parcel data: $parcel");

      // Validate required fields
      if (!_validateParcelData()) {
        setState(() {
          hasError = true;
          errorMessage = 'Parcel is missing required data';
          isLoading = false;
        });
        return;
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      log("Error initializing RadiusMapScreenDetails: $e");
      setState(() {
        hasError = true;
        errorMessage = 'Failed to load parcel details: $e';
        isLoading = false;
      });
    }
  }

  bool _validateParcelData() {
    // Check if essential data exists
    final hasPickupLocation = parcel["pickupLocation"] != null &&
        parcel["pickupLocation"]["coordinates"] != null &&
        parcel["pickupLocation"]["coordinates"].length >= 2;

    final hasDeliveryLocation = parcel["deliveryLocation"] != null &&
        parcel["deliveryLocation"]["coordinates"] != null &&
        parcel["deliveryLocation"]["coordinates"].length >= 2;

    return hasPickupLocation && hasDeliveryLocation;
  }

  Future<String> _getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        return '${placemarks[0].street ?? ''}, ${placemarks[0].locality ?? ''}, ${placemarks[0].country ?? ''}';
      }
      return 'No address found';
    } catch (e) {
      log("Error fetching address: $e");
      return 'Error fetching address';
    }
  }

  String formatDeliveryDate(String? deliveryEndTime) {
    if (deliveryEndTime == null) return "N/A";

    try {
      final parsedDate = DateTime.parse(deliveryEndTime);
      return DateFormat('yyyy-MM-dd , hh:mm').format(parsedDate);
    } catch (e) {
      log("Date parsing error: $e");
      return "Invalid Date Format";
    }
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
            ),
            child: const Text("Go Back"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? _buildErrorView()
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
                                  text: parcel["title"] ?? "Unknown Parcel",
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
                              value: parcel["senderName"] ?? "N/A",
                            ),
                            const SpaceWidget(spaceHeight: 8),
                            SummaryInfoRowWidget(
                              icon: AppIconsPath.profileIcon,
                              label: "receiversName".tr,
                              value: parcel["receiverName"] ?? "N/A",
                            ),
                            const SpaceWidget(spaceHeight: 8),
                            SummaryInfoRowWidget(
                              icon: AppIconsPath.callIcon,
                              label: "receiversNumber".tr,
                              value: parcel["phoneNumber"] ?? "N/A",
                            ),
                            const SpaceWidget(spaceHeight: 8),
                            SummaryInfoRowWidget(
                              icon: AppIconsPath.deliveryTimeIcon,
                              label: "deliveryTimeText".tr,
                              value:
                                  formatDeliveryDate(parcel["deliveryEndTime"]),
                            ),
                            const SpaceWidget(spaceHeight: 8),
                            FutureBuilder<String>(
                              future: _getAddress(
                                double.tryParse(parcel["pickupLocation"]
                                            ["coordinates"][1]
                                        .toString()) ??
                                    0.0,
                                double.tryParse(parcel["pickupLocation"]
                                            ["coordinates"][0]
                                        .toString()) ??
                                    0.0,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SummaryInfoRowWidget(
                                    icon: AppIconsPath.destinationIcon,
                                    label: "pickupLocationText".tr,
                                    value: "Loading address...",
                                  );
                                } else if (snapshot.hasError) {
                                  return SummaryInfoRowWidget(
                                    icon: AppIconsPath.destinationIcon,
                                    label: "pickupLocationText".tr,
                                    value: "Error fetching address",
                                  );
                                } else {
                                  return SummaryInfoRowWidget(
                                    icon: AppIconsPath.destinationIcon,
                                    label: "pickupLocationText".tr,
                                    value: snapshot.data ??
                                        "Address not available",
                                  );
                                }
                              },
                            ),
                            const SpaceWidget(spaceHeight: 8),
                            FutureBuilder<String>(
                              future: _getAddress(
                                double.tryParse(parcel["deliveryLocation"]
                                            ["coordinates"][1]
                                        .toString()) ??
                                    0.0,
                                double.tryParse(parcel["deliveryLocation"]
                                            ["coordinates"][0]
                                        .toString()) ??
                                    0.0,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SummaryInfoRowWidget(
                                    icon: AppIconsPath.currentLocationIcon,
                                    label: "deliveryLocationText".tr,
                                    value: "Loading address...",
                                  );
                                } else if (snapshot.hasError) {
                                  return SummaryInfoRowWidget(
                                    icon: AppIconsPath.currentLocationIcon,
                                    label: "deliveryLocationText".tr,
                                    value: "Error fetching address",
                                  );
                                } else {
                                  return SummaryInfoRowWidget(
                                    icon: AppIconsPath.currentLocationIcon,
                                    label: "deliveryLocationText".tr,
                                    value: snapshot.data ??
                                        "Address not available",
                                  );
                                }
                              },
                            ),
                            const SpaceWidget(spaceHeight: 8),
                            SummaryInfoRowWidget(
                              icon: AppIconsPath.priceIcon,
                              label: "Price",
                              value: parcel["price"] != null
                                  ? "${parcel["price"]}"
                                  : "Not set",
                            ),
                            const SpaceWidget(spaceHeight: 8),
                            SummaryInfoRowWidget(
                              icon: AppIconsPath.descriptionIcon,
                              label: "descriptionText".tr,
                              value: parcel["description"] ?? "N/A",
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
                child: const CircleAvatar(
                  backgroundColor: AppColors.white,
                  radius: 25,
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: TextWidget(
                text: "sendRequest".tr,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
