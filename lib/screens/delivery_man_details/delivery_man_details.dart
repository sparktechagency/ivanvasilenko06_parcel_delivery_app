import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/screens/booking_screen/current_order/controller/current_order_controller.dart';
import 'package:parcel_delivery_app/screens/booking_screen/new_booking/controller/new_bookings_controller.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
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
  String pickUpAddress = "Loading...";

  Map<String, String> pickUpAddressCache = {};
  Map<String, String> addressCache = {};
  // ignore: prefer_typing_uninitialized_variables
  var currentParcel;
  // ignore: prefer_typing_uninitialized_variables
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
      log('An error occurred: $e');
    }
  }

  void _findCurrentParcel() {
    if (controller.currentOrdersModel.value.data != null) {
      for (var parcel in controller.currentOrdersModel.value.data!) {
        if (parcel.id == parcelId) {
          currentParcel = parcel;
          deliveryMan = parcel.assignedDelivererId;

          // Make sure to call both functions to get addresses
          findAddressFromCoordinates();
          findPickUpAddressFromCoordinates();
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
            '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}';
        setState(() {
          address = newAddress;
        });
        addressCache[key] = newAddress;
      } else {
        setState(() {
          address = 'No address found';
        });
      }
    } catch (e) {
      setState(() {
        address = 'Error fetching address';
      });
      log("Error fetching delivery address: $e");
    }
  }

  Future<void> pickAddress(double latitude, double longitude) async {
    final String key = '$latitude,$longitude';
    if (pickUpAddressCache.containsKey(key)) {
      setState(() {
        pickUpAddress = pickUpAddressCache[key]!;
      });
      return;
    }
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        String newAddress =
            '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}';
        setState(() {
          pickUpAddress = newAddress;
        });
        pickUpAddressCache[key] = newAddress;
      } else {
        setState(() {
          pickUpAddress = 'No address found';
        });
      }
    } catch (e) {
      setState(() {
        pickUpAddress = 'Error fetching address';
      });
      log("Error fetching pickup address: $e");
    }
  }

  void findAddressFromCoordinates() {
    try {
      if (currentParcel != null &&
          currentParcel.deliveryLocation != null &&
          currentParcel.deliveryLocation.coordinates != null &&
          currentParcel.deliveryLocation.coordinates!.length == 2) {
        double longitude = currentParcel.deliveryLocation.coordinates![0];
        double latitude = currentParcel.deliveryLocation.coordinates![1];

        log("Delivery coordinates: Lat $latitude, Long $longitude");
        _getAddress(latitude, longitude);
      } else {
        setState(() {
          address = 'Delivery location not available';
        });
      }
    } catch (e) {
      setState(() {
        address = 'Error processing delivery location';
      });
      log("Error in delivery coordinates: $e");
    }
  }

  void findPickUpAddressFromCoordinates() {
    try {
      if (currentParcel != null &&
          currentParcel.pickupLocation != null &&
          currentParcel.pickupLocation.coordinates != null &&
          currentParcel.pickupLocation.coordinates!.length == 2) {
        double longitude = currentParcel.pickupLocation.coordinates![0];
        double latitude = currentParcel.pickupLocation.coordinates![1];

        log("Pickup coordinates: Lat $latitude, Long $longitude");
        pickAddress(latitude, longitude);
      } else {
        setState(() {
          pickUpAddress = 'Pickup location not available';
        });
      }
    } catch (e) {
      setState(() {
        pickUpAddress = 'Error processing pickup location';
      });
      log("Error in pickup coordinates: $e");
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

  //! Helper method to calculate average rating from reviews
  String _calculateAverageRating(dynamic deliveryMan) {
    if (deliveryMan?.reviews == null || deliveryMan.reviews.isEmpty) {
      return "0.0";
    }

    try {
      double totalRating = 0;
      int count = 0;

      for (var review in deliveryMan.reviews) {
        if (review.rating != null) {
          totalRating += review.rating;
          count++;
        }
      }

      if (count == 0) return "0.0";

      double avgRating = totalRating / count;
      return avgRating.toStringAsFixed(1); // Format to one decimal place
    } catch (e) {
      log("Error calculating average rating: $e");
      return "0.0";
    }
  }

//! Showing Image in App
  String _getProfileImagePath() {
    if (controller.isLoading.value) {
      log('⏳ Profile is still loading, returning default image URL');
      return 'https://i.ibb.co/z5YHLV9/profile.png';
    }

    final imageUrl = deliveryMan.image;
    log('Raw image URL from API: "$imageUrl"');
    log('Image URL type: ${imageUrl.runtimeType}');

    // Check for null, empty, or invalid URLs
    if (imageUrl == null ||
        imageUrl.isEmpty ||
        imageUrl.trim().isEmpty ||
        imageUrl.toLowerCase() == 'null' ||
        imageUrl.toLowerCase() == 'undefined') {
      log('❌ Image URL is null/empty/invalid, using default image URL');
      return 'https://i.ibb.co/z5YHLV9/profile.png';
    }

    String fullImageUrl;
    // Trim and clean the URL
    String cleanImageUrl = imageUrl.trim();
    if (cleanImageUrl.startsWith('https://') ||
        cleanImageUrl.startsWith('http://')) {
      fullImageUrl = cleanImageUrl;
    } else {
      // Remove leading slashes and ensure proper concatenation
      cleanImageUrl = cleanImageUrl.startsWith('/')
          ? cleanImageUrl.substring(1)
          : cleanImageUrl;
      fullImageUrl = "${AppApiUrl.liveDomain}/$cleanImageUrl";
    }

    // Validate the constructed URL
    final uri = Uri.tryParse(fullImageUrl);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      log('❌ Invalid URL format: $fullImageUrl, using default image URL');
      return 'https://i.ibb.co/z5YHLV9/profile.png';
    }

    log('✅ Constructed URL: $fullImageUrl');
    return fullImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: currentParcel == null
          ? Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.black,
                size: 40,
              ),
            )
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
                            //! Profile Image with null check
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                _getProfileImagePath(),
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey.withAlpha(78),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Center(
                                      child: LoadingAnimationWidget.hexagonDots(
                                        color: AppColors.black,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  log('❌ Error loading image: $error');
                                  return Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey.withAlpha(78),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: AppColors.greyDark2,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SpaceWidget(spaceWidth: 8),

                            // Name with null check
                            Flexible(
                              child: TextWidget(
                                text: deliveryMan?.fullName ?? "Not Assigned",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontColor: AppColors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SpaceWidget(spaceWidth: 8),
                            // Rating calculated from reviews array
                            if (deliveryMan?.reviews != null &&
                                deliveryMan!.reviews!.isNotEmpty)
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
                                      text:
                                          " ${_calculateAverageRating(deliveryMan)}",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      fontColor: AppColors.white,
                                    ),
                                  ],
                                ),
                              ),
                            const SpaceWidget(spaceWidth: 8),

                            // Message button with null check for the onTap function
                            InkWell(
                              onTap: deliveryMan?.mobileNumber != null
                                  ? _sendMessage
                                  : null,
                              borderRadius: BorderRadius.circular(100),
                              child: const CircleAvatar(
                                backgroundColor: AppColors.whiteDark,
                                radius: 15,
                                child: IconWidget(
                                  icon: AppIconsPath.whatsAppIcon,
                                  color: AppColors.black,
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                            ),
                            const SpaceWidget(spaceWidth: 8),

                            // Call button with null check for the onTap function
                            InkWell(
                              onTap: deliveryMan?.mobileNumber != null
                                  ? _makePhoneCall
                                  : null,
                              borderRadius: BorderRadius.circular(100),
                              child: const CircleAvatar(
                                backgroundColor: AppColors.whiteDark,
                                radius: 15,
                                child: Icon(
                                  Icons.call,
                                  color: AppColors.black,
                                  size: 18,
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
                          icon: AppIconsPath.ratingIcon,
                          label: "Ratings".tr,
                          value: deliveryMan?.reviews != null &&
                                  deliveryMan!.reviews!.isNotEmpty
                              ? _calculateAverageRating(deliveryMan)
                              : "N/A",
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.callIcon,
                          label: "Phone Number".tr,
                          value: deliveryMan?.mobileNumber ?? "N/A",
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        // SummaryInfoRowWidget(
                        //   icon: AppIconsPath.profileIcon,
                        //   label: "receiversName".tr,
                        //   value: currentParcel?.name ?? "N/A",
                        // ),
                        // const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.deliveryTimeIcon,
                          label: "deliveryTimeText".tr,
                          value: _getFormattedDeliveryTime(currentParcel),
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.destinationIcon,
                          label: "currentLocationText".tr,
                          value: pickUpAddress,
                        ),
                        const SpaceWidget(spaceHeight: 8),
                        SummaryInfoRowWidget(
                          icon: AppIconsPath.currentLocationIcon,
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
            Obx(() => newBookingsController.isCancellingDelivery.value
                ? Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: LoadingAnimationWidget.progressiveDots(
                        color: AppColors.white,
                        size: 40,
                      ),
                    ),
                  )
                : ButtonWidget(
                    onPressed: () async {
                      newBookingsController.isCancellingDelivery.value = true;
                      try {
                        await newBookingsController.cancelDelivery(
                            parcelId, deliveryMan?.id);
                        final controller = Get.find<CurrentOrderController>();
                        await controller.getCurrentOrder();
                        controller.update();
                        Get.back();

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Delivery cancelled successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (error) {
                        log('Error cancelling delivery: $error');

                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to cancel delivery: $error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        newBookingsController.isCancellingDelivery.value =
                            false;
                      }
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
                  )),
          ],
        ),
      ),
    );
  }
}
