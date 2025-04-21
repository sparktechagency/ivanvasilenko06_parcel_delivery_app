// radius_avaiable_parcel.dart - modifications
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:parcel_delivery_app/screens/home_screen/controller/earn_money_radius_controller.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

class RadiusAvailableParcel extends StatefulWidget {
  const RadiusAvailableParcel({super.key});

  @override
  _RadiusAvailableParcelState createState() => _RadiusAvailableParcelState();
}

class _RadiusAvailableParcelState extends State<RadiusAvailableParcel> {
  final EarnMoneyRadiusController _radiusController = Get.find();
  List<String> requestedParcelIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: "parcelForDelivery".tr,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontColor: AppColors.black,
                ),
                Obx(() => TextWidget(
                      text:
                          "${_radiusController.parcelsInRadius.length} ${"found".tr}",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontColor: AppColors.greyDark2,
                    )),
              ],
            ),
          ),
          const SpaceWidget(spaceHeight: 16),
          Expanded(
            child: Obx(() {
              if (_radiusController.parcelsInRadius.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 64,
                        color: AppColors.greyDark,
                      ),
                      const SpaceWidget(spaceHeight: 16),
                      TextWidget(
                        text: "noParcelFound".tr,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontColor: AppColors.greyDark2,
                      ),
                      const SpaceWidget(spaceHeight: 8),
                      TextWidget(
                        text: "tryDifferentRadius".tr,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontColor: AppColors.greyDark,
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    ..._radiusController.parcelsInRadius.map((parcel) {
                      // Convert date strings to formatted dates
                      final startDate =
                          DateTime.parse(parcel["deliveryStartTime"]);
                      final endDate = DateTime.parse(parcel["deliveryEndTime"]);
                      final formattedDate =
                          "${DateFormat('dd-MM-yyyy').format(startDate)} to ${DateFormat('dd-MM-yyyy').format(endDate)}";

                      // Get pickup and delivery locations
                      final pickupLat =
                          parcel["pickupLocation"]["coordinates"][1];
                      final pickupLng =
                          parcel["pickupLocation"]["coordinates"][0];
                      final deliveryLat =
                          parcel["deliveryLocation"]["coordinates"][1];
                      final deliveryLng =
                          parcel["deliveryLocation"]["coordinates"][0];
                      final locationText =
                          "From (${pickupLat.toStringAsFixed(3)}, ${pickupLng.toStringAsFixed(3)}) to (${deliveryLat.toStringAsFixed(3)}, ${deliveryLng.toStringAsFixed(3)})";

                      // Check if parcel request has been sent
                      final hasRequestSent = parcel["status"] == "REQUESTED" ||
                          requestedParcelIds.contains(parcel["_id"]);

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
                                      text: parcel["title"],
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                      fontColor: AppColors.black,
                                    ),
                                    const SpaceWidget(spaceWidth: 12),
                                  ],
                                ),
                                TextWidget(
                                  text:
                                      "${AppStrings.currency} ${parcel["price"]}",
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
                                Expanded(
                                  child: TextWidget(
                                    text: locationText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontColor: AppColors.greyDark2,
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
                                  InkWell(
                                    onTap: hasRequestSent
                                        ? null
                                        : () {
                                            // Logic to send request
                                            setState(() {
                                              requestedParcelIds
                                                  .add(parcel["_id"]);
                                            });
                                            // Here you would call an API to send the request
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "requestSent".tr)));
                                          },
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: Row(
                                      children: [
                                        IconWidget(
                                          icon: AppIconsPath.personAddIcon,
                                          color: hasRequestSent
                                              ? Colors.grey
                                              : AppColors.black,
                                          width: 14,
                                          height: 14,
                                        ),
                                        const SpaceWidget(spaceWidth: 8),
                                        TextWidget(
                                          text: hasRequestSent
                                              ? "requestSent".tr
                                              : "sendRequest".tr,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontColor: hasRequestSent
                                              ? Colors.grey
                                              : AppColors.black,
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
                                    onTap: () {
                                      // Store the selected parcel in controller or pass as parameter
                                      Get.toNamed(
                                          AppRoutes.summaryOfParcelScreen,
                                          arguments: parcel);
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
                    }).toList(),
                  ],
                ),
              );
            }),
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
