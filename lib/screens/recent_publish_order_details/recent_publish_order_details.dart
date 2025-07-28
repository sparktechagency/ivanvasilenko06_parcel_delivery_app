import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/screens/booking_parcel_details_screen/widgets/summary_info_row_widget.dart';
import 'package:parcel_delivery_app/screens/services_screen/controller/services_controller.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

import '../../constants/app_strings.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  final dynamic parcelId;

  const DeliveryDetailsScreen({super.key, this.parcelId});

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  final ServiceController serviceController = Get.find<ServiceController>();
  var parcelDetails = Rx<dynamic>(null);
  RxBool isLoading = true.obs;
  String pickupAddress = '';
  String deliveryAddress = '';
  Map<String, String> addressCache = {};

  @override
  void initState() {
    super.initState();
    fetchParcelDetails();
  }

  Future<void> fetchParcelDetails() async {
    try {
      isLoading.value = true;

      // Check if parcelId is provided
      if (widget.parcelId == null) {
        // AppSnackBar.error('Parcel ID is missing.');
        isLoading.value = false;
        return;
      }

      // Find the specific parcel from the controller's recentParcelList
      for (var item in serviceController.recentParcelList) {
        if (item.data != null && item.data!.isNotEmpty) {
          for (var datum in item.data!) {
            if (datum.id == widget.parcelId) {
              parcelDetails.value = datum;
              break;
            }
          }
        }

        if (parcelDetails.value != null) break;
      }

      // If parcel not found in the list, show error
      if (parcelDetails.value == null) {
        // AppSnackBar.error('Parcel details not found.');
      } else {
        // Load addresses after parcel details are found
        await _loadAddresses();
      }
    } catch (e) {
      // AppSnackBar.error('Failed to load parcel details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAddresses() async {
    try {
      if (parcelDetails.value?.pickupLocation != null) {
        var coordinates =
            _getCoordinatesFromLocation(parcelDetails.value.pickupLocation);
        if (coordinates != null) {
          double latitude = coordinates[1];
          double longitude = coordinates[0];
          pickupAddress = await _getAddress(latitude, longitude);
        }
      }

      if (parcelDetails.value?.deliveryLocation != null) {
        var coordinates =
            _getCoordinatesFromLocation(parcelDetails.value.deliveryLocation);
        if (coordinates != null) {
          double latitude = coordinates[1];
          double longitude = coordinates[0];
          deliveryAddress = await _getAddress(latitude, longitude);
        }
      }
    } catch (e) {
      log("Error loading addresses: $e");
    }
  }

  List<double>? _getCoordinatesFromLocation(dynamic location) {
    if (location == null) return null;

    try {
      // Try to access as a Map
      if (location is Map && location.containsKey('coordinates')) {
        final coordinates = location['coordinates'];
        if (coordinates is List && coordinates.length >= 2) {
          return [
            double.tryParse(coordinates[0].toString()) ?? 0.0,
            double.tryParse(coordinates[1].toString()) ?? 0.0
          ];
        }
      }

      // Try to access as an object with property
      if (location.coordinates != null &&
          location.coordinates is List &&
          location.coordinates.length >= 2) {
        return [
          double.tryParse(location.coordinates[0].toString()) ?? 0.0,
          double.tryParse(location.coordinates[1].toString()) ?? 0.0
        ];
      }
    } catch (e) {
      log("Error extracting coordinates: $e");
    }

    return null;
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
        Placemark place = placemarks[0];
        String address = '';

        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }

        if (place.locality != null && place.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.locality!;
        }

        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }

        if (address.isEmpty) {
          address = 'Location Found';
        }

        addressCache[key] = address;
        return address;
      }
      return 'No address found';
    } catch (e) {
      log("Error fetching address: $e");
      return 'Error fetching address';
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
        if (isLoading.value) {
          return  Center(child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.black,
                size: 40,
              ),);
        }

        if (parcelDetails.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TextWidget(
                  text: "Parcel details not found",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.black,
                ),
                const SpaceWidget(spaceHeight: 16),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const TextWidget(
                    text: "Go Back",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontColor: AppColors.black,
                  ),
                ),
              ],
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
                text: "summaryOfYourParcel".tr,
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
                        TextWidget(
                          text:
                              parcelDetails.value.title ?? "Details of Parcel",
                          fontSize: 20,
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
                      icon: AppIconsPath.profileIcon,
                      label: "senderNameText".tr,
                      value: parcelDetails.value.senderId?.fullName ?? "N/A",
                    ),
                    const SpaceWidget(spaceHeight: 8),
                    SummaryInfoRowWidget(
                      icon: AppIconsPath.profileIcon,
                      label: "receiversName".tr,
                      value: parcelDetails.value.name ?? "N/A",
                    ),
                    SummaryInfoRowWidget(
                      icon: AppIconsPath.deliveryTimeIcon,
                      label: "deliveryTimeText".tr,
                      value: _getFormattedDeliveryTime(parcelDetails.value),
                    ),
                    const SpaceWidget(spaceHeight: 8),
                    SummaryInfoRowWidget(
                      icon: AppIconsPath.currentLocationIcon,
                      label: "currentLocationText".tr,
                      value: pickupAddress.isNotEmpty
                          ? pickupAddress
                          : _getLocationString(
                              parcelDetails.value.pickupLocation),
                    ),
                    const SpaceWidget(spaceHeight: 8),
                    SummaryInfoRowWidget(
                      icon: AppIconsPath.destinationIcon,
                      label: "destinationText".tr,
                      value: deliveryAddress.isNotEmpty
                          ? deliveryAddress
                          : _getLocationString(
                              parcelDetails.value.deliveryLocation),
                    ),
                    const SpaceWidget(spaceHeight: 8),
                    SummaryInfoRowWidget(
                      icon: AppIconsPath.priceIcon,
                      label: "priceText".tr,
                      value:
                          "${AppStrings.currency} ${parcelDetails.value.price ?? 'N/A'} ",
                    ),
                    const SpaceWidget(spaceHeight: 8),
                    SummaryInfoRowWidget(
                      icon: AppIconsPath.descriptionIcon,
                      label: "descriptionText".tr,
                      value: parcelDetails.value.status ?? "N/A",
                    ),
                    const SpaceWidget(spaceHeight: 8),
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
            const SizedBox()
          ],
        ),
      ),
    );
  }

  // Helper method to safely extract location coordinates as string
  String _getLocationString(dynamic location) {
    if (location == null) return "N/A";

    try {
      // Try to access as a Map
      if (location is Map && location.containsKey('coordinates')) {
        final coordinates = location['coordinates'];
        if (coordinates is List && coordinates.length >= 2) {
          return "${coordinates[1]}, ${coordinates[0]}";
        }
      }

      // Try to access as an object with property
      if (location.coordinates != null &&
          location.coordinates is List &&
          location.coordinates.length >= 2) {
        return "${location.coordinates[1]}, ${location.coordinates[0]}";
      }
    } catch (e) {
      log("Error getting location string: $e");
    }

    return "N/A";
  }
}
