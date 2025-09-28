import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/screens/booking_screen/current_order/controller/current_order_controller.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

import '../../booking_parcel_details_screen/widgets/summary_info_row_widget.dart';

class ViewDetailsScreen extends StatefulWidget {
  const ViewDetailsScreen({super.key});

  @override
  State<ViewDetailsScreen> createState() => _ViewDetailsScreenState();
}

class _ViewDetailsScreenState extends State<ViewDetailsScreen> {
  late final CurrentOrderController controller;

  // Regular String variables for address and pickupAddress
  String address = "";
  String pickupAddress = "";
  String exactPickupLocation = "";
  String exactDeliveryLocation = "";

  Map<String, String> addressCache = {};
  var currentParcel;

  var parcelId = Get.arguments;

  // Function to get address based on latitude and longitude
  Future<void> _getAddress(
      double latitude, double longitude, bool isPickup) async {
    final String key = '$latitude,$longitude';

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

        String exactLocation =
            '${placemarks[0].street}, ${placemarks[0].subLocality}, '
            '${placemarks[0].locality}, ${placemarks[0].administrativeArea}, '
            '${placemarks[0].postalCode}, ${placemarks[0].country}';
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

  // Function to find both pickup and delivery addresses from coordinates
  void findAddressesFromCoordinates() {
    if (currentParcel != null) {
      if (currentParcel.deliveryLocation != null &&
          currentParcel.deliveryLocation.coordinates != null &&
          currentParcel.deliveryLocation.coordinates!.length == 2) {
        double longitude = currentParcel.deliveryLocation.coordinates![0];
        double latitude = currentParcel.deliveryLocation.coordinates![1];
        _getAddress(latitude, longitude, false);
      }

      // Checking pickupLocation coordinates
      if (currentParcel.pickupLocation != null &&
          currentParcel.pickupLocation.coordinates != null &&
          currentParcel.pickupLocation.coordinates!.length == 2) {
        double longitude = currentParcel.pickupLocation.coordinates![0];
        double latitude = currentParcel.pickupLocation.coordinates![1];

        _getAddress(latitude, longitude, true);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Get the existing controller instance from booking_screen
    try {
      controller = Get.find<CurrentOrderController>(tag: 'booking_screen');
    } catch (e) {
      // Fallback to default controller if tagged one doesn't exist
      controller = Get.find<CurrentOrderController>();
    }

    _findCurrentParcel();
  }

  // Function to find the current parcel based on the parcelId passed from the arguments
  void _findCurrentParcel() {
    if (controller.currentOrdersModel.value.data != null &&
        controller.currentOrdersModel.value.data!.isNotEmpty) {
      for (var parcel in controller.currentOrdersModel.value.data!) {
        if (parcel.id == parcelId) {
          setState(() {
            currentParcel = parcel;
          });
          findAddressesFromCoordinates();
          break;
        }
      }
    } else {
      // If no data is available, try to refresh the orders
      controller.getCurrentOrder().then((_) {
        if (mounted) {
          _findCurrentParcel();
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
        final formatter = DateFormat('dd.MM • hh:mm a');
        return "${formatter.format(startDate)} to ${formatter.format(endDate)}";
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
      body: Obx(() {
        // Show loading if controller is loading or currentParcel is null
        if (controller.isLoading.value || currentParcel == null) {
          return Center(
            child: LoadingAnimationWidget.hexagonDots(
              color: AppColors.black,
              size: 40,
            ),
          );
        }

        return Column(
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
                            text: currentParcel?.title ?? "Parcel",
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
                      value: currentParcel?.senderId?.fullName ?? "Sender Name",
                    ),
                    const SpaceWidget(spaceHeight: 8),
                    SummaryInfoRowWidget(
                      icon: AppIconsPath.profileIcon,
                      label: "receiversName".tr,
                      value: currentParcel?.name ?? "Receiver Name",
                    ),
                    const SpaceWidget(spaceHeight: 8),
                    if (currentParcel?.status == "IN_TRANSIT") ...[
                      SummaryInfoRowWidget(
                        icon: AppIconsPath.callIcon,
                        label: "receiversNumber".tr,
                        value: currentParcel?.phoneNumber ??
                            "Receiver Phone Number",
                      ),
                      const SpaceWidget(spaceHeight: 8),
                    ],
                    SummaryInfoRowWidget(
                      icon: AppIconsPath.deliveryTimeIcon,
                      label: "deliveryTimeText".tr,
                      value: _getFormattedDeliveryTime(currentParcel),
                    ),
                    const SpaceWidget(spaceHeight: 8),
                    SummaryInfoRowWidget(
                      icon: AppIconsPath.destinationIcon,
                      label: "currentLocationText".tr,
                      value: exactPickupLocation.isNotEmpty
                          ? exactPickupLocation
                          : pickupAddress,
                    ),
                    const SpaceWidget(spaceHeight: 8),
                    SummaryInfoRowWidget(
                      icon: AppIconsPath.currentLocationIcon,
                      label: "destinationText".tr,
                      value: exactDeliveryLocation.isNotEmpty
                          ? exactDeliveryLocation
                          : address,
                    ),
                    const SpaceWidget(spaceHeight: 8),
                    SummaryInfoRowWidget(
                      icon: AppIconsPath.priceIcon,
                      label: "price".tr,
                      value: "${AppStrings.currency} ${currentParcel.price}",
                    ),
                    const SpaceWidget(spaceHeight: 8),
                    SummaryInfoRowWidget(
                      icon: AppIconsPath.descriptionIcon,
                      label: "descriptionText".tr,
                      value: currentParcel.description ?? "No Description",
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
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