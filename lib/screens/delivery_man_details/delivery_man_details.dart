import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/screens/booking_screen/current_order/controller/current_order_controller.dart';
import 'package:parcel_delivery_app/screens/booking_screen/new_booking/controller/new_bookings_controller.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/app_images.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/icon_widget/icon_widget.dart';
import '../booking_parcel_details_screen/widgets/summary_info_row_widget.dart';

class DeliveryManDetails extends StatefulWidget {
  const DeliveryManDetails({super.key});

  @override
  State<DeliveryManDetails> createState() => _DeliveryManDetailsState();
}

class _DeliveryManDetailsState extends State<DeliveryManDetails> {
  final CurrentOrderController controller = Get.find<CurrentOrderController>();

  final NewBookingsController newBookingsController =
      Get.find<NewBookingsController>();
  String parcelId = '';
  String address = "Loading...";
  Map<String, String> addressCache = {};
  var currentParcel;
  var deliveryMan;

  @override
  void initState() {
    super.initState();
    parcelId = Get.arguments;
    _findCurrentParcel();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: deliveryMan.mobileNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        _showErrorSnackBar('Could not launch phone call');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    }
  }

  // Function to send a message
  Future<void> _sendMessage() async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: deliveryMan.mobileNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        _showErrorSnackBar('Could not launch messaging app');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
      print('An error occurred: $e');
    }
  }

  void _findCurrentParcel() {
    if (controller.currentOrdersModel.value.data != null) {
      for (var parcel in controller.currentOrdersModel.value.data!) {
        if (parcel.id == parcelId) {
          currentParcel = parcel;
          deliveryMan = parcel.assignedDelivererId;
          findAddressFromCoordinates();
          break;
        }
      }
    }
  }

  Future<void> _getAddress(double latitude, double longitude) async {
    final String key = '$latitude,$longitude';
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
            '${placemarks[0].locality}, ${placemarks[0].subAdministrativeArea}, ${placemarks[0].country}';
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

  void findAddressFromCoordinates() {
    if (currentParcel != null &&
        currentParcel.deliveryLocation != null &&
        currentParcel.deliveryLocation.coordinates != null &&
        currentParcel.deliveryLocation.coordinates!.length == 2) {
      double longitude = currentParcel.deliveryLocation.coordinates![0];
      double latitude = currentParcel.deliveryLocation.coordinates![1];

      _getAddress(latitude, longitude);
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
                    text: "Delivery Man Details".tr,
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
                              child: AppImage(
                                url: deliveryMan.image ??
                                    AppImagePath.dummyProfileImage,
                                height: 40,
                                width: 40,
                              ),
                            ),
                            const SpaceWidget(spaceWidth: 8),
                            Flexible(
                              child: TextWidget(
                                text: deliveryMan?.fullName ?? "Not Assigned",
                                // text: currentParcel?.title ?? "Parcel",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontColor: AppColors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SpaceWidget(spaceWidth: 8),
                            Container(
                              width: ResponsiveUtils.width(45),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.yellow,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.white,
                                    size: 12,
                                  ),
                                  TextWidget(
                                    text: "${deliveryMan?.avgRating}" ?? "N/A",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontColor: AppColors.white,
                                  ),
                                ],
                              ),
                            ),
                            const SpaceWidget(spaceWidth: 8),
                            InkWell(
                              onTap: _sendMessage,
                              borderRadius: BorderRadius.circular(100),
                              child: const CircleAvatar(
                                backgroundColor: AppColors.whiteDark,
                                radius: 15,
                                child: IconWidget(
                                  icon: AppIconsPath.whatsAppIcon,
                                  color: AppColors.black,
                                  width: 15,
                                  height: 15,
                                ),
                              ),
                            ),
                            const SpaceWidget(spaceWidth: 8),
                            InkWell(
                              onTap: _makePhoneCall,
                              borderRadius: BorderRadius.circular(100),
                              child: const CircleAvatar(
                                backgroundColor: AppColors.whiteDark,
                                radius: 15,
                                child: Icon(
                                  Icons.call,
                                  color: AppColors.black,
                                  size: 15,
                                ),
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
                          image: AppImagePath.sendParcel,
                          label: "Parcel Name".tr,
                          value: currentParcel?.title ?? "Parcel",
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.profileIcon,
                          label: "receiversName".tr,
                          value: currentParcel?.name ?? "N/A",
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.callIcon,
                          label: "receiversNumber".tr,
                          value: currentParcel?.phoneNumber ?? "N/A",
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.deliveryTimeIcon,
                          label: "deliveryTimeText".tr,
                          value: _formatDeliveryDate(
                              currentParcel?.deliveryEndTime),
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.destinationIcon,
                          label: "destinationText".tr,
                          value: address,
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
                          value: currentParcel?.description ?? "No Description",
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
              onPressed: () async {
                newBookingsController.cancelDelivery(parcelId, deliveryMan?.id);
                final controller = Get.find<CurrentOrderController>();
                await controller.getCurrentOrder();
                controller.update();
                Get.back();
              },
              label: "cancelDelivery".tr,
              textColor: AppColors.white,
              buttonWidth: 200,
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
