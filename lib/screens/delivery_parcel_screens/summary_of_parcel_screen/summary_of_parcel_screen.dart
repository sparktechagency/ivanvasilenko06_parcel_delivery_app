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
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
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
  late DeliverParcelList parcel;
  bool isLoading = true;

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
      parcel = deliveryScreenController.parcels.firstWhere((p) => p.sId == id);
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

  // Function to get the address from coordinates
  Future<String> _getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        return '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}';
      }
      return 'No address found';
    } catch (e) {
      return 'Error fetching address';
    }
  }

  String formatDeliveryDate(dynamic deliveryEndTime) {
    if (deliveryEndTime is String) {
      try {
        final parsedDate = DateTime.parse(deliveryEndTime);
        return DateFormat('yyyy-MM-dd , hh:mm').format(parsedDate);
      } catch (e) {
        return "Invalid Date Format";
      }
    } else if (deliveryEndTime is DateTime) {
      return DateFormat('yyyy-MM-dd , hh:mm').format(deliveryEndTime);
    } else {
      return "Unknown Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryScreenController>();

    // Fetching coordinates for starting and ending locations
    final startingLocation = controller.startingCoordinates.value;
    final endingLocation = controller.endingCoordinates.value;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading spinner while fetching data
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
                              text: parcel.title ?? "Unknown Parcel",
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
                          value: parcel.senderId?.fullName ??
                              "N/A", // Sender's name
                        ),
                        // const SpaceWidget(spaceHeight: 8),
                        // SummaryInfoRowWidget(
                        //   icon: AppIconsPath.ratingIcon,
                        //   label: "ratingsText".tr,
                        //   value: AppStrings.ratings, // Rating text
                        // ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.profileIcon,
                          label: "receiversName".tr,
                          value: parcel.name ?? "N/A",
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.callIcon,
                          label: "receiversNumber".tr,
                          value: parcel.phoneNumber ?? "N/A",
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.deliveryTimeIcon,
                          label: "deliveryTimeText".tr,
                          value: formatDeliveryDate(parcel.deliveryEndTime),
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        // Display starting location using FutureBuilder
                        FutureBuilder<String>(
                          future: _getAddress(startingLocation!.latitude,
                              startingLocation.longitude),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SummaryInfoRowWidget(
                                icon: AppIconsPath.destinationIcon,
                                label: "currentLocationText".tr,
                                value: "Loading address...",
                              );
                            } else if (snapshot.hasError) {
                              return SummaryInfoRowWidget(
                                icon: AppIconsPath.destinationIcon,
                                label: "currentLocationText".tr,
                                value: "Error fetching address",
                              );
                            } else if (snapshot.hasData) {
                              return SummaryInfoRowWidget(
                                icon: AppIconsPath.destinationIcon,
                                label: "currentLocationText".tr,
                                value: snapshot.data ?? "Address not available",
                              );
                            } else {
                              return SummaryInfoRowWidget(
                                icon: AppIconsPath.destinationIcon,
                                label: "currentLocationText".tr,
                                value: "No data",
                              );
                            }
                          },
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        // Display destination location using FutureBuilder
                        FutureBuilder<String>(
                          future: _getAddress(endingLocation!.latitude,
                              endingLocation.longitude),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SummaryInfoRowWidget(
                                icon: AppIconsPath.currentLocationIcon,
                                label: "destinationText".tr,
                                value: "Loading address...",
                              );
                            } else if (snapshot.hasError) {
                              return SummaryInfoRowWidget(
                                icon: AppIconsPath.currentLocationIcon,
                                label: "destinationText".tr,
                                value: "Error fetching address",
                              );
                            } else if (snapshot.hasData) {
                              return SummaryInfoRowWidget(
                                icon: AppIconsPath.currentLocationIcon,
                                label: "destinationText".tr,
                                value: snapshot.data ?? "Address not available",
                              );
                            } else {
                              return SummaryInfoRowWidget(
                                icon: AppIconsPath.currentLocationIcon,
                                label: "destinationText".tr,
                                value: "No data",
                              );
                            }
                          },
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        // Display price
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.priceIcon,
                          label: "Price",
                          value: parcel.price != null
                              ? "${parcel.price}"
                              : "Not set",
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.descriptionIcon,
                          label: "descriptionText".tr,
                          value: controller.parcels.isNotEmpty
                              ? "${controller.parcels.first.description}"
                              : "N/A}", // Description
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
            ButtonWidget(
              onPressed: () {
                Get.back();
              },
              label: "sendRequest".tr,
              textColor: AppColors.white,
              buttonWidth: 180,
              buttonHeight: 50,
              icon: Icons.arrow_forward,
              iconColor: AppColors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
