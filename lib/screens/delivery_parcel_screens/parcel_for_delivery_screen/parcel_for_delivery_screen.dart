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
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

class ParcelForDeliveryScreen extends StatefulWidget {
  const ParcelForDeliveryScreen({super.key});

  @override
  State<ParcelForDeliveryScreen> createState() =>
      _ParcelForDeliveryScreenState();
}

class _ParcelForDeliveryScreenState extends State<ParcelForDeliveryScreen> {
  // Cache to store the fetched address based on coordinates
  Map<String, String> addressCache = {};

  // Store the current address to update it only when coordinates change
  String address = "Loading...";

  // Function to get the address from coordinates with caching
  Future<void> _getAddress(double latitude, double longitude) async {
    final String key = '$latitude,$longitude';

    // Check if the address for these coordinates is cached
    if (addressCache.containsKey(key)) {
      setState(() {
        address = addressCache[key]!;
      });
      return;
    }

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        String newAddress =
            '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}';
        setState(() {
          address = newAddress;
        });
        addressCache[key] = newAddress; // Cache the address
      } else {
        setState(() {
          address = 'No address found';
        });
      }
    } catch (e) {
      setState(() {
        address = 'Error fetching address';
      });
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
    final deliveryScreenController = Get.find<DeliveryScreenController>();

    log("▶️▶️▶️▶️▶️ The parcels are: ${deliveryScreenController.parcels}◀️◀️◀️◀️◀️");

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextWidget(
              text: "parcelForDelivery".tr,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
            ),
          ),
          const SpaceWidget(spaceHeight: 16),
          Expanded(
            child: ListView.separated(
              itemCount: deliveryScreenController.parcels.length,
              itemBuilder: (context, index) {
                final parcel = deliveryScreenController.parcels[index];
                final title = parcel.title ?? "Unknown Parcel";
                final price = parcel.price ?? 0;
                final date = formatDeliveryDate(parcel.deliveryEndTime);
                // Extract the coordinates for the delivery location
                final deliveryCoordinates =
                    parcel.deliveryLocation?.coordinates;

                // Only fetch the address if coordinates are available and not already cached
                if (deliveryCoordinates != null &&
                    deliveryCoordinates.length == 2) {
                  final latitude = deliveryCoordinates[1];
                  final longitude = deliveryCoordinates[0];
                  // Call _getAddress only if the address for these coordinates is not cached
                  _getAddress(latitude, longitude);
                }

                return Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: const ImageWidget(
                                    imagePath: AppImagePath.sendParcel,
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                                const SpaceWidget(spaceWidth: 10),
                                Flexible(
                                  child: TextWidget(
                                    text: title,
                                    fontSize: 15,
                                    fontFamily: "AeonikTRIAL",
                                    fontWeight: FontWeight.w600,
                                    fontColor: AppColors.black,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SpaceWidget(spaceWidth: 10),
                              ],
                            ),
                          ),
                          TextWidget(
                            text: "${AppStrings.currency} $price",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontColor: AppColors.black,
                          ),
                        ],
                      ),
                      const SpaceWidget(spaceHeight: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.black,
                            size: 12,
                          ),
                          const SpaceWidget(spaceWidth: 8),
                          TextWidget(
                            text: address,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontColor: AppColors.greyDark2,
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
                            text: date,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontColor: AppColors.greyDark2,
                          ),
                        ],
                      ),
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
                              onTap: index == 2
                                  ? null
                                  : () {
                                      final parcelId = parcel.sId;
                                      if (parcelId != null &&
                                          parcelId.isNotEmpty) {
                                        deliveryScreenController
                                            .sendParcelRequest(parcelId);
                                        Get.toNamed(
                                            AppRoutes.sentRequestSuccessfully);
                                      } else {
                                        AppSnackBar.error(
                                            "Parcel ID is missing");
                                      }
                                    },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Row(
                                children: [
                                  IconWidget(
                                    icon: AppIconsPath.personAddIcon,
                                    color: index == 2
                                        ? Colors.grey
                                        : AppColors.black,
                                    width: 14,
                                    height: 14,
                                  ),
                                  const SpaceWidget(spaceWidth: 8),
                                  TextWidget(
                                    text: "sendRequest".tr,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontColor: AppColors.black,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 18,
                              color: AppColors.blackLighter,
                            ),
                            InkWell(
                              onTap: index == 2 || parcel.sId == null
                                  ? null
                                  : () {
                                      if (parcel.sId != null) {
                                        Get.toNamed(
                                          AppRoutes.summaryOfParcelScreen,
                                          arguments: parcel.sId,
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
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) {
                return const SizedBox(height: 10);
              },
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
