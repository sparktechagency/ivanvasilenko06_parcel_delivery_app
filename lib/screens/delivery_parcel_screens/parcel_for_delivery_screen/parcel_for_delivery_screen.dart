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
  //! Cache to store the fetched address based on coordinates
  Map<String, String> addressCache = {};
  Map<String, String> locationToAddressCache = {};

  @override
  void initState() {
    super.initState();
    final deliveryScreenController = Get.find<DeliveryScreenController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  //! Function to fetch and return address from coordinates
  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    final String key = '$latitude,$longitude';
    if (locationToAddressCache.containsKey(key)) {
      return locationToAddressCache[key]!;
    }

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        String newAddress = '${placemarks[0].locality}';
        locationToAddressCache[key] = newAddress;
        return newAddress;
      } else {
        return 'No address found';
      }
    } catch (e) {
      log('Error fetching address: $e');
      return 'Error fetching address';
    }
  }

  // Store address by parcel ID
  void cacheAddressForParcel(String parcelId, String addressType,
      double latitude, double longitude) async {
    final cacheKey = '${parcelId}_${addressType}';
    if (!addressCache.containsKey(cacheKey)) {
      String fetchedAddress =
          await getAddressFromCoordinates(latitude, longitude);
      setState(() {
        addressCache[cacheKey] = fetchedAddress;
      });
    }
  }

  // Get address for a specific parcel
  String getParcelAddress(String parcelId, String addressType) {
    final cacheKey = '${parcelId}_${addressType}';
    return addressCache[cacheKey] ?? 'Loading...';
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
            //! Using GetBuilder for more reliable UI updates
            child: GetBuilder<DeliveryScreenController>(
              builder: (controller) {
                //! Check if there are any parcels available
                if (controller.parcels.isEmpty) {
                  //! Return empty state widget when no parcels are available
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
                        TextWidget(
                          text: "No Parcels Available".tr,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontColor: AppColors.black,
                          textAlignment: TextAlign.center,
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: TextWidget(
                            text: "Check it Later".tr,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontColor: AppColors.greyDark2,
                            textAlignment: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                //! Return the list of parcels if available
                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchParcels();
                  },
                  child: ListView.separated(
                    itemCount: controller.parcels.length,
                    itemBuilder: (context, index) {
                      final parcel = controller.parcels[index];
                      final title = parcel.title ?? "Unknown Parcel";
                      final price = parcel.price ?? 0;
                      final parcelId = parcel.sId;

                      //! Show the exact location
                      final pickupLocation = parcel.pickupLocation?.coordinates;
                      final deliveryLocation =
                          parcel.deliveryLocation?.coordinates;

                      //! Request address fetching for this parcel
                      if (deliveryLocation != null &&
                          deliveryLocation.length == 2) {
                        final latitude = deliveryLocation[1];
                        final longitude = deliveryLocation[0];
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          cacheAddressForParcel(
                              parcelId!, 'delivery', latitude, longitude);
                        });
                      }
                      if (pickupLocation != null &&
                          pickupLocation.length == 2) {
                        final latitude = pickupLocation[1];
                        final longitude = pickupLocation[0];
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          cacheAddressForParcel(
                              parcelId!, 'pickup', latitude, longitude);
                        });
                      }

                      //! Get the delivery and pickup addresses for this specific parcel
                      final deliveryAddress =
                          getParcelAddress(parcelId!, 'delivery');
                      final pickupAddress =
                          getParcelAddress(parcelId, 'pickup');

                      //! Show the Date with appropriate format
                      String formattedDate = "N/A";
                      try {
                        final startDate =
                            DateTime.parse(parcel.deliveryStartTime.toString());
                        final endDate =
                            DateTime.parse(parcel.deliveryEndTime.toString());
                        formattedDate =
                            "${DateFormat(' dd.MM ').format(startDate)} to ${DateFormat(' dd.MM ').format(endDate)}";
                      } catch (e) {
                        log("Error parsing dates: $e");
                      }

                      //! Check if request is already sent for this parcel
                      final isRequestSent = controller.isRequestSent(parcelId);

                      //! Debug log to verify status
                      if (parcelId != null) {
                        log("Parcel ID: $parcelId, Request Sent: $isRequestSent");
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
                                        borderRadius:
                                            BorderRadius.circular(100),
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
                                Flexible(
                                  child: TextWidget(
                                    text: "$pickupAddress to $deliveryAddress",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontColor: AppColors.greyDark2,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
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
                            if (isRequestSent == true) ...[
                              const SpaceWidget(spaceHeight: 8),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
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
                                  Opacity(
                                    opacity: (index == 2 ||
                                            isRequestSent ||
                                            parcelId == null)
                                        ? 0.5
                                        : 1.0,
                                    child: InkWell(
                                      onTap: (index == 2 ||
                                              isRequestSent ||
                                              parcelId == null)
                                          ? null
                                          : () async {
                                              if (parcelId != null &&
                                                  parcelId.isNotEmpty) {
                                                //! Use mounted check to update UI after request
                                                await controller
                                                    .sendParcelRequest(
                                                        parcelId);
                                                if (mounted) {
                                                  setState(() {
                                                    //! Force rebuild of this widget
                                                  });
                                                }
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
                                            color: (index == 2 || isRequestSent)
                                                ? Colors.grey
                                                : AppColors.black,
                                            width: 14,
                                            height: 14,
                                          ),
                                          const SpaceWidget(spaceWidth: 8),
                                          TextWidget(
                                            text: isRequestSent
                                                ? "Request Sent"
                                                : "sendRequest".tr,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontColor: isRequestSent
                                                ? Colors.grey
                                                : AppColors.black,
                                          ),
                                        ],
                                      ),
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
                );
                ;
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
