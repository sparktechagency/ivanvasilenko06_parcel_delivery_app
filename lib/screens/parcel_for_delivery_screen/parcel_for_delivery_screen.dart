import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; // Import geocoding package
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:parcel_delivery_app/screens/delivery_parcel_screens/controller/delivery_screens_controller.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_size.dart';
import '../../widgets/button_widget/button_widget.dart';
import '../../widgets/icon_widget/icon_widget.dart';
import '../../widgets/image_widget/image_widget.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';

class ParcelForDeliveryScreen extends StatelessWidget {
  const ParcelForDeliveryScreen({super.key});

  Future<String> _getLocationFromCoordinates(
      double latitude, double longitude) async {
    try {
      // Use reverse geocoding to get a human-readable address from coordinates
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark placemark =
          placemarks.first; // Get the first available placemark

      // Return a formatted address
      return '${placemark.street}, ${placemark.locality}, ${placemark.country}';
    } catch (e) {
      return 'Location not available';
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveryScreenController = Get.find<DeliveryScreenController>();

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
                final date = (parcel.deliveryEndTime is String)
                    ? (() {
                        try {
                          DateTime parsedDate =
                              DateTime.parse(parcel.deliveryEndTime as String);
                          return DateFormat('yyyy-MM-dd , hh:mm')
                              .format(parsedDate);
                        } catch (e) {
                          return "Invalid Date Format";
                        }
                      })()
                    : parcel.deliveryEndTime != null
                        ? DateFormat('yyyy-MM-dd , hh:mm')
                            .format(parcel.deliveryEndTime as DateTime)
                        : "Unknown Date";

                // Extract the coordinates for the delivery location
                final deliveryCoordinates =
                    parcel.deliveryLocation?.coordinates;
                String locationText = "Location not available";

                if (deliveryCoordinates != null &&
                    deliveryCoordinates.length == 2) {
                  final latitude = deliveryCoordinates[1]; // Latitude
                  final longitude = deliveryCoordinates[0]; // Longitude

                  // Fetch the human-readable address using reverse geocoding
                  _getLocationFromCoordinates(latitude, longitude)
                      .then((address) {
                    // Update the state of the widget with the location
                    locationText = address;
                  });
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: const ImageWidget(
                                  imagePath: AppImagePath.sendParcel,
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                              const SpaceWidget(spaceWidth: 12),
                              TextWidget(
                                text: title,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                fontColor: AppColors.black,
                              ),
                              const SpaceWidget(spaceWidth: 12),
                            ],
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
                      // Display the location as text
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.black,
                            size: 12,
                          ),
                          const SpaceWidget(spaceWidth: 8),
                          // Show the location text here
                          TextWidget(
                            text: locationText,
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
                              onTap: index == 2 ? null : () {},
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
                                    text: index == 2
                                        ? "requestSent".tr
                                        : "sendRequest".tr,
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
                              onTap: index == 2
                                  ? null
                                  : () {
                                      Get.toNamed(
                                          AppRoutes.summaryOfParcelScreen);
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
