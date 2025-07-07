import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

import '../../booking_parcel_details_screen/widgets/summary_info_row_widget.dart';

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
  String pickupAddress = '';
  String deliveryAddress = '';
  Map<String, String> addressCache = {};

  @override
  void initState() {
    super.initState();
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

      if (!_validateParcelData()) {
        setState(() {
          hasError = true;
          errorMessage = 'Parcel is missing required data';
          isLoading = false;
        });
        return;
      }

      _loadAddresses();
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
    final hasPickupLocation = parcel["pickupLocation"] != null &&
        parcel["pickupLocation"]["coordinates"] != null &&
        parcel["pickupLocation"]["coordinates"].length >= 2;

    final hasDeliveryLocation = parcel["deliveryLocation"] != null &&
        parcel["deliveryLocation"]["coordinates"] != null &&
        parcel["deliveryLocation"]["coordinates"].length >= 2;

    return hasPickupLocation && hasDeliveryLocation;
  }

  Future<void> _loadAddresses() async {
    if (parcel["pickupLocation"] != null &&
        parcel["pickupLocation"]["coordinates"] != null) {
      double latitude = double.tryParse(
              parcel["pickupLocation"]["coordinates"][1].toString()) ??
          0.0;
      double longitude = double.tryParse(
              parcel["pickupLocation"]["coordinates"][0].toString()) ??
          0.0;
      pickupAddress = await _getAddress(latitude, longitude);
    }

    if (parcel["deliveryLocation"] != null &&
        parcel["deliveryLocation"]["coordinates"] != null) {
      double latitude = double.tryParse(
              parcel["deliveryLocation"]["coordinates"][1].toString()) ??
          0.0;
      double longitude = double.tryParse(
              parcel["deliveryLocation"]["coordinates"][0].toString()) ??
          0.0;
      deliveryAddress = await _getAddress(latitude, longitude);
    }

    setState(() {});
  }

  Future<String> _getAddress(double latitude, double longitude) async {
    final String key = '$latitude,$longitude';

    if (addressCache.containsKey(key)) {
      return addressCache[key]!;
    }

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        String address =
            '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}';
        addressCache[key] = address;
        return address;
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
      return '${parsedDate.day}.${parsedDate.month}-${parsedDate.year}';
    } catch (e) {
      log("Date parsing error: $e");
      return "Invalid Date Format";
    }
  }

  String _getFormattedDeliveryTime(Map<String, dynamic> parcel) {
    try {
      if (parcel["deliveryStartTime"] != null &&
          parcel["deliveryEndTime"] != null) {
        final startDate = DateTime.parse(parcel["deliveryStartTime"]);
        final endDate = DateTime.parse(parcel["deliveryEndTime"]);
        return "${DateFormat(' dd.MM ').format(startDate)} to ${DateFormat(' dd.MM ').format(endDate)}";
      } else {
        return "N/A";
      }
    } catch (e) {
      return "N/A";
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
                        text: "summary".tr,
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
                                Flexible(
                                  child: TextWidget(
                                    text: parcel["title"] ?? "Parcel",
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    fontColor: AppColors.black,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
                              icon: AppIconsPath.profileIcon,
                              label: "sendersName".tr,
                              value:
                                  parcel["senderId"]["fullName"].toString(),
                            ),
                            const SpaceWidget(spaceHeight: 8),
                            SummaryInfoRowWidget(
                              icon: AppIconsPath.profileIcon,
                              label: "receiversName".tr,
                              value: parcel["name"] ?? "N/A",
                            ),
                            const SpaceWidget(spaceHeight: 8),
                            // SummaryInfoRowWidget(
                            //   icon: AppIconsPath.callIcon,
                            //   label: "receiversNumber".tr,
                            //   value: parcel["phoneNumber"] ?? "N/A",
                            // ),
                            // const SpaceWidget(spaceHeight: 8),
                            SummaryInfoRowWidget(
                              icon: AppIconsPath.deliveryTimeIcon,
                              label: "deliveryTimeText".tr,
                              value: _getFormattedDeliveryTime(parcel),
                            ),
                            const SpaceWidget(spaceHeight: 8),
                            // Use the regular String variables now
                            SummaryInfoRowWidget(
                              icon: AppIconsPath.destinationIcon,
                              label: "currentLocationText".tr,
                              value: pickupAddress,
                            ),
                            const SpaceWidget(spaceHeight: 8),
                            SummaryInfoRowWidget(
                              icon: AppIconsPath.currentLocationIcon,
                              label: "destinationText".tr,
                              value: deliveryAddress,
                            ),
                            const SpaceWidget(spaceHeight: 8),
                            SummaryInfoRowWidget(
                              icon: AppIconsPath.priceIcon,
                              label: "price".tr,
                              value:
                                  "${AppStrings.currency} ${parcel["price"] ?? "N/A"}",
                            ),
                            const SpaceWidget(spaceHeight: 8),
                            SummaryInfoRowWidget(
                              icon: AppIconsPath.descriptionIcon,
                              label: "descriptionText".tr,
                              value: parcel["description"] ?? "No Description",
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
          ],
        ),
      ),
    );
  }
}
