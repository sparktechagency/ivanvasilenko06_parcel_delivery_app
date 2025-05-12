import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
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

class ParcelDetailsScreen extends StatefulWidget {
  const ParcelDetailsScreen({super.key});

  @override
  State<ParcelDetailsScreen> createState() => _ParcelDetailsScreenState();
}

class _ParcelDetailsScreenState extends State<ParcelDetailsScreen> {
  final CurrentOrderController controller = Get.find<CurrentOrderController>();

  // Regular String variables for address and pickupAddress
  String address = "";
  String pickupAddress = "";

  Map<String, String> addressCache = {};
  var currentParcel;

  var parcelId = Get.arguments;

  // Function to get address based on latitude and longitude
  Future<void> _getAddress(
      double latitude, double longitude, bool isPickup) async {
    final String key = '$latitude,$longitude';
    String addressType = isPickup
        ? "Pickup"
        : "Delivery"; // Use this to differentiate pickup and delivery address

    if (addressCache.containsKey(key)) {
      // Use cached address if available
      setState(() {
        if (isPickup) {
          pickupAddress = addressCache[key]!; // Set pickup address
        } else {
          address = addressCache[key]!; // Set delivery address
        }
      });
      return;
    }

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        String newAddress =
            '${placemarks[0].locality}, ${placemarks[0].subAdministrativeArea}, ${placemarks[0].country}';

        // Cache the address
        addressCache[key] = newAddress;

        // Set the address based on whether it's pickup or delivery
        setState(() {
          if (isPickup) {
            pickupAddress = newAddress; // Set pickup address
          } else {
            address = newAddress; // Set delivery address
          }
        });
      } else {
        // If no address is found
        setState(() {
          if (isPickup) {
            pickupAddress = 'No pickup address found';
          } else {
            address = 'No delivery address found';
          }
        });
      }
    } catch (e) {
      // If an error occurs while fetching the address
      setState(() {
        if (isPickup) {
          pickupAddress = 'Error fetching pickup address';
        } else {
          address = 'Error fetching delivery address';
        }
      });
    }
  }

  // Function to find both pickup and delivery addresses from coordinates
  void findAddressesFromCoordinates() {
    if (currentParcel != null) {
      // Checking deliveryLocation coordinates
      if (currentParcel.deliveryLocation != null &&
          currentParcel.deliveryLocation.coordinates != null &&
          currentParcel.deliveryLocation.coordinates!.length == 2) {
        double longitude = currentParcel.deliveryLocation.coordinates![0];
        double latitude = currentParcel.deliveryLocation.coordinates![1];

        _getAddress(latitude, longitude, false); // false for delivery
      }

      // Checking pickupLocation coordinates
      if (currentParcel.pickupLocation != null &&
          currentParcel.pickupLocation.coordinates != null &&
          currentParcel.pickupLocation.coordinates!.length == 2) {
        double longitude = currentParcel.pickupLocation.coordinates![0];
        double latitude = currentParcel.pickupLocation.coordinates![1];

        _getAddress(latitude, longitude, true); // true for pickup
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _findCurrentParcel();
  }

  // Function to find the current parcel based on the parcelId passed from the arguments
  void _findCurrentParcel() {
    if (controller.currentOrdersModel.value.data != null) {
      for (var parcel in controller.currentOrdersModel.value.data!) {
        if (parcel.id == parcelId) {
          // Ensure to compare the parcelId correctly
          currentParcel = parcel;
          findAddressesFromCoordinates();
          break;
        }
      }
    }
  }

  String _formatDeliveryDate(dynamic dateInput) {
    if (dateInput == null) return '';
    try {
      DateTime date;
      if (dateInput is DateTime) {
        date = dateInput;
      } else if (dateInput is String) {
        date = DateTime.parse(dateInput);
      } else {
        return '';
      }
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: currentParcel == null
          ? const Center(child: CircularProgressIndicator())
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
                          value: currentParcel?.senderId?.fullName ??
                              "Sender Name",
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.profileIcon,
                          label: "receiversName".tr,
                          value: currentParcel?.name ?? "Receiver Name",
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.callIcon,
                          label: "receiversNumber".tr,
                          value: currentParcel?.phoneNumber ??
                              "Receiver Phone Number",
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.deliveryTimeIcon,
                          label: "deliveryTimeText".tr,
                          value: _formatDeliveryDate(
                              currentParcel?.deliveryStartTime),
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        // Use the regular String variables now
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.destinationIcon,
                          label: "currentLocationText".tr,
                          value: address, // Use the regular address String
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.currentLocationIcon,
                          label: "destinationText".tr,
                          value:
                              pickupAddress, // Use the regular pickupAddress String
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.priceIcon,
                          label: "price".tr,
                          value:
                              "${AppStrings.currency} ${currentParcel.price}",
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
