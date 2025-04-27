import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/screens/booking_screen/current_order/controller/current_order_controller.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

import '../booking_parcel_details_screen/widgets/summary_info_row_widget.dart';

class DeliveryManDetails extends StatefulWidget {
  const DeliveryManDetails({super.key});

  @override
  State<DeliveryManDetails> createState() => _DeliveryManDetailsState();
}

class _DeliveryManDetailsState extends State<DeliveryManDetails> {
  final CurrentOrderController controller = Get.find<CurrentOrderController>();
  String parcelId = '';
  var currentParcel;
  var deliveryMan;

  @override
  void initState() {
    super.initState();
    // Get the parcel ID from arguments
    parcelId = Get.arguments as String;
    // Find the current parcel from the controller data
    _findCurrentParcel();
  }

  void _findCurrentParcel() {
    if (controller.currentOrdersModel.value.data != null) {
      for (var parcel in controller.currentOrdersModel.value.data!) {
        if (parcel.id == parcelId) {
          currentParcel = parcel;
          deliveryMan = parcel.assignedDelivererId;
          break;
        }
      }
    }
  }

  String _formatDeliveryDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextWidget(
              text: "deliveryManDetails".tr,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
            ),
          ),
          const SpaceWidget(spaceHeight: 40),
          Expanded(
            child: currentParcel == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Parcel Info Section
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
                            Expanded(
                              child: TextWidget(
                                fontSize: 20,
                                text: currentParcel?.title ?? "Parcel",
                                fontWeight: FontWeight.w500,
                                fontColor: AppColors.black,
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

                        // Delivery Man Details Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.whiteLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TextWidget(
                                text: "Delivery Man Details",
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontColor: AppColors.black,
                              ),
                              const SpaceWidget(spaceHeight: 16),

                              // Delivery Man Profile
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteDark,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: deliveryMan?.image != null &&
                                            deliveryMan.image.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: Image.network(
                                              deliveryMan.image,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(
                                                Icons.person,
                                                size: 40,
                                                color: AppColors.greyDark,
                                              ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.person,
                                            size: 40,
                                            color: AppColors.greyDark,
                                          ),
                                  ),
                                  const SpaceWidget(spaceWidth: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: deliveryMan?.fullName ??
                                              "Not Assigned",
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          fontColor: AppColors.black,
                                        ),
                                        const SpaceWidget(spaceHeight: 4),
                                        TextWidget(
                                          text: deliveryMan?.role ?? "",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontColor: AppColors.greyDark2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SpaceWidget(spaceHeight: 16),

                        // Contact Information
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.whiteLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TextWidget(
                                text: "Contact Information",
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontColor: AppColors.black,
                              ),
                              const SpaceWidget(spaceHeight: 16),
                              SummaryInfoRowWidget(
                                icon: AppIconsPath.appleIcon,
                                label: "Phone Number",
                                value: deliveryMan?.mobileNumber ??
                                    "Not Available",
                              ),
                            ],
                          ),
                        ),

                        const SpaceWidget(spaceHeight: 16),

                        // Parcel Details Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.whiteLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TextWidget(
                                text: "Parcel Details",
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontColor: AppColors.black,
                              ),
                              const SpaceWidget(spaceHeight: 16),
                              SummaryInfoRowWidget(
                                icon: AppIconsPath.profileIcon,
                                label: "sendersName".tr,
                                value: currentParcel?.senderId?.fullName ??
                                    "Not Available",
                              ),
                              const SpaceWidget(spaceHeight: 8),
                              SummaryInfoRowWidget(
                                icon: AppIconsPath.profileIcon,
                                label: "receiversName".tr,
                                value: currentParcel?.name ?? "Not Available",
                              ),
                              const SpaceWidget(spaceHeight: 8),
                              SummaryInfoRowWidget(
                                icon: AppIconsPath.callIcon,
                                label: "receiversNumber".tr,
                                value: currentParcel?.phoneNumber ??
                                    "Not Available",
                              ),
                              const SpaceWidget(spaceHeight: 8),
                              SummaryInfoRowWidget(
                                icon: AppIconsPath.deliveryTimeIcon,
                                label: "deliveryTimeText".tr,
                                value: _formatDeliveryDate(
                                    currentParcel?.deliveryEndTime ?? ""),
                              ),
                              const SpaceWidget(spaceHeight: 8),
                              SummaryInfoRowWidget(
                                icon: AppIconsPath.priceIcon,
                                label: "price".tr,
                                value:
                                    "${AppStrings.currency} ${currentParcel?.price ?? 0}",
                              ),
                              const SpaceWidget(spaceHeight: 8),
                              SummaryInfoRowWidget(
                                icon: AppIconsPath.descriptionIcon,
                                label: "descriptionText".tr,
                                value: currentParcel?.description ??
                                    "No description available",
                              ),
                            ],
                          ),
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
            Row(
              children: [
                ButtonWidget(
                  onPressed: () {
                    // Make a call to delivery man
                    if (deliveryMan?.mobileNumber != null) {
                      // Implement call functionality
                    }
                  },
                  label: "Call",
                  textColor: AppColors.white,
                  buttonWidth: 100,
                  buttonHeight: 50,
                  icon: Icons.call,
                  iconColor: AppColors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  iconSize: 20,
                ),
                const SpaceWidget(spaceWidth: 8),
                ButtonWidget(
                  onPressed: () {
                    // Implement cancel delivery functionality
                  },
                  label: "cancelDelivery".tr,
                  textColor: AppColors.white,
                  buttonWidth: 130,
                  buttonHeight: 50,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
