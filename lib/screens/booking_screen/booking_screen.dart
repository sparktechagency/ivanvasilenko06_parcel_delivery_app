import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/screens/booking_screen/current_order/controller/current_order_controller.dart';
import 'package:parcel_delivery_app/screens/booking_screen/new_booking/controller/new_bookings_controller.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/app_images.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_icons_path.dart';
import '../../routes/app_routes.dart';
import '../../widgets/icon_widget/icon_widget.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentIndex = 0;
  Map<String, String> addressCache = {};
  Map<String, String> locationToAddressCache = {};
  final PageController _pageController = PageController();

  final CurrentOrderController currentOrderController =
      Get.put(CurrentOrderController());
  final CurrentOrderController newBookingController =
      Get.put(CurrentOrderController());
  final NewBookingsController newBookingsController =
      Get.put(NewBookingsController());

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentOrderController.getCurrentOrder();
    });
    super.initState();
  }

  // Function to make a phone call
  final String phoneNumber = '+1234567890';

  // Replace with actual phone number
  final String message = 'Hello, this is a test message';

  // Function to fetch and return address from coordinates
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

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 5,
                      width: 50,
                      decoration: BoxDecoration(
                        color: AppColors.greyDark,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SpaceWidget(spaceHeight: 32),
                  Center(
                    child: TextWidget(
                      text: "experience".tr,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.black,
                    ),
                  ),
                  const SpaceWidget(spaceHeight: 10),
                  Center(
                    child: RatingBar.builder(
                      initialRating: 1,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 06),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star_border,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        print('Rating: $rating');
                      },
                    ),
                  ),
                  const SpaceWidget(spaceHeight: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: AppStrings.veryBad,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontColor: AppColors.black,
                        ),
                        TextWidget(
                          text: AppStrings.veryGood,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontColor: AppColors.black,
                        ),
                      ],
                    ),
                  ),
                  const SpaceWidget(spaceHeight: 32),
                  ButtonWidget(
                    onPressed: () {
                      Get.back();
                    },
                    label: "submit".tr,
                    buttonWidth: double.infinity,
                    buttonHeight: 50,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      _showErrorSnackBar('No phone number available');
      return;
    }

    // Clean the phone number
    final String formattedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    try {
      // Use different approaches based on platform
      if (Platform.isAndroid) {
        // For Android, use Intent.ACTION_DIAL (doesn't require permission)
        final Uri phoneUri = Uri.parse('tel:$formattedNumber');
        await launchUrl(phoneUri,
            mode: LaunchMode.externalNonBrowserApplication);
      } else if (Platform.isIOS) {
        // For iOS
        final Uri phoneUri = Uri.parse('tel://$formattedNumber');
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          throw 'Could not launch $phoneUri';
        }
      } else {
        // For other platforms
        final Uri phoneUri = Uri.parse('tel:$formattedNumber');
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          throw 'Could not launch $phoneUri';
        }
      }
    } catch (e) {
      log('Error launching phone call: $e');
      _showErrorSnackBar('Error opening dialer: $e');
    }
  }

  // Function to send a message

  Future<void> _openWhatsApp(String phoneNumber, String message) async {
    if (phoneNumber.isEmpty) {
      _showErrorSnackBar('No phone number available');
      return;
    }

    // Format the phone number (remove any non-digit characters)
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    try {
      // Direct WhatsApp intent
      if (Platform.isAndroid) {
        // Try Android-specific direct intent first (most reliable)
        final Uri androidUri = Uri.parse(
            "intent://send?phone=$formattedNumber&text=${Uri.encodeComponent(message)}#Intent;scheme=whatsapp;package=com.whatsapp;end");

        if (await canLaunchUrl(androidUri)) {
          await launchUrl(androidUri);
          return;
        }
      }

      // Try the standard WhatsApp URL scheme
      final Uri whatsappUri = Uri.parse(
          "whatsapp://send?phone=$formattedNumber&text=${Uri.encodeComponent(message)}");

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri,
            mode: LaunchMode.externalNonBrowserApplication);
        return;
      }

      // Fallback to website (this should work on most devices)
      final Uri webUri = Uri.parse(
          "https://api.whatsapp.com/send?phone=$formattedNumber&text=${Uri.encodeComponent(message)}");

      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return;
      }

      log('Could not find any WhatsApp method that works');
      _showErrorSnackBar('WhatsApp not installed or accessible');
    } catch (e) {
      log('Error opening WhatsApp: $e');
      _showErrorSnackBar('Error opening WhatsApp');
    }
  }

  // Helper method to show error messages
  void _showErrorSnackBar(String message) {
    final scaffoldMessenger = ScaffoldMessenger.of(Get.context!);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void deliveryFinished() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)), // Flat corners
          ),
          backgroundColor: AppColors.grey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const TextWidget(
                  text: 'Have you completed the delivery?',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontColor: AppColors.black,
                  textAlignment: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonWidget(
                      buttonWidth: 100,
                      buttonHeight: 40,
                      label: 'No',
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      buttonRadius: BorderRadius.circular(10),
                      backgroundColor: AppColors.white,
                      textColor: AppColors.black,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    ButtonWidget(
                      buttonWidth: 100,
                      buttonHeight: 40,
                      label: 'Yes',
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      buttonRadius: BorderRadius.circular(10),
                      backgroundColor: AppColors.green,
                      textColor: AppColors.white,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void removeParcelConfirmation(String parcelId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)), // Flat corners
          ),
          backgroundColor: AppColors.grey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const TextWidget(
                  text: 'Are you sure you want to remove this parcel?',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontColor: AppColors.black,
                  textAlignment: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonWidget(
                      buttonWidth: 100,
                      buttonHeight: 40,
                      label: 'No',
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      buttonRadius: BorderRadius.circular(10),
                      backgroundColor: AppColors.white,
                      textColor: AppColors.black,
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                    ),
                    ButtonWidget(
                      buttonWidth: 100,
                      buttonHeight: 40,
                      label: 'Yes',
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      buttonRadius: BorderRadius.circular(10),
                      backgroundColor: AppColors.green,
                      textColor: AppColors.white,
                      onPressed: () async {
                        Navigator.pop(context); // Close the dialog first
                        try {
                          // Get the correct controller instance
                          final controller = Get.find<NewBookingsController>();
                          await controller.removeParcelFromMap(parcelId);
                          await currentOrderController.getCurrentOrder();
                          _currentIndex = 0;
                          controller.update();
                          _pageController.jumpToPage(0);

                          Get.back();
                        } catch (e) {
                          // Close loading dialog
                          Get.back();
                          Get.snackbar(
                            'Error',
                            'Failed to remove parcel: ${e.toString()}',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
              text: "bookings".tr,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
            ),
          ),
          const SpaceWidget(spaceHeight: 24),

          ///<This one is tab bar  ===================>

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    _buildTabItem("currentOrders".tr, 0),
                    const SpaceWidget(spaceHeight: 4),
                    Container(
                      height: ResponsiveUtils.height(3),
                      width: ResponsiveUtils.width(12),
                      decoration: BoxDecoration(
                        color: _currentIndex == 0
                            ? AppColors.black
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.greyDarkLight,
                ),
                Column(
                  children: [
                    _buildTabItem("newBookings".tr, 1),
                    const SpaceWidget(spaceHeight: 4),
                    Container(
                      height: ResponsiveUtils.height(3),
                      width: ResponsiveUtils.width(12),
                      decoration: BoxDecoration(
                        color: _currentIndex == 1
                            ? AppColors.black
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                SingleChildScrollView(child: _currentOrderWidget()),
                SingleChildScrollView(child: _newBookingWidget()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.jumpToPage(index); // Change PageView page
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: TextWidget(
        text: label,
        fontColor:
            _currentIndex == index ? AppColors.black : AppColors.greyDarkLight,
        fontSize: 14,
        fontWeight: _currentIndex == index ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _currentOrderWidget() {
    return Obx(() {
      final data = currentOrderController.currentOrdersModel.value.data;
      if (data == null || data.isEmpty) {
        return const Center(child: Text('No current orders available'));
      }
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: List.generate(data.length, (index) {
                final parcelId = data[index].id ?? "";
                final deliverLocation =
                    data[index].deliveryLocation?.coordinates;
                final pickupLocation = data[index].pickupLocation?.coordinates;

                // Request address fetching for this parcel
                if (deliverLocation != null && deliverLocation.length == 2) {
                  final latitude = deliverLocation[1];
                  final longitude = deliverLocation[0];
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    cacheAddressForParcel(
                        parcelId, 'delivery', latitude, longitude);
                  });
                }

                if (pickupLocation != null && pickupLocation.length == 2) {
                  final latitude = pickupLocation[1];
                  final longitude = pickupLocation[0];
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    cacheAddressForParcel(
                        parcelId, 'pickup', latitude, longitude);
                  });
                }

                // Get the delivery and pickup addresses for this specific parcel
                final deliveryAddress = getParcelAddress(parcelId, 'delivery');
                final pickupAddress = getParcelAddress(parcelId, 'pickup');

                //////////////// Date Formateed
                String formattedDate = "N/A";
                try {
                  final startDate =
                      DateTime.parse(data[index].deliveryStartTime.toString());
                  final endDate =
                      DateTime.parse(data[index].deliveryEndTime.toString());
                  formattedDate =
                      "${DateFormat(' dd.MM ').format(startDate)} to ${DateFormat(' dd.MM ').format(endDate)}";
                } catch (e) {
                  log("Error parsing dates: $e");
                }
                /////////////

                final isUserSender =
                    data[index].senderId == data[index].senderId;

                return Column(
                  children: [
                    if (index > 0) const SpaceWidget(spaceHeight: 8),
                    // Separator
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: const ImageWidget(
                                          height: 40,
                                          width: 40,
                                          imagePath: AppImagePath.sendParcel,
                                        ),
                                      ),
                                      const SpaceWidget(spaceWidth: 8),
                                      SizedBox(
                                        width: ResponsiveUtils.width(160),
                                        child: TextWidget(
                                          text: data[index].title ?? "",
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w500,
                                          fontColor: AppColors.black,
                                          overflow: TextOverflow.ellipsis,
                                          textAlignment: TextAlign.start,
                                        ),
                                      ),
                                      const SpaceWidget(spaceWidth: 8),
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
                                        text:
                                            "$pickupAddress to $deliveryAddress",
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        fontColor: AppColors.greyDark2,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlignment: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                  const SpaceWidget(spaceHeight: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.call,
                                        color: AppColors.black,
                                        size: 12,
                                      ),
                                      const SpaceWidget(spaceWidth: 8),
                                      TextWidget(
                                        text: data[index].phoneNumber ?? "",
                                        fontSize: 12,
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
                                        text: formattedDate,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        fontColor: AppColors.greyDark2,
                                      ),
                                    ],
                                  ),
                                  const SpaceWidget(spaceHeight: 10),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextWidget(
                                    text:
                                        "${AppStrings.currency} ${data[index].price}",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontColor: AppColors.black,
                                  ),
                                  const SpaceWidget(spaceHeight: 20),
                                  // Updated status text display logic
                                  TextWidget(
                                    text: data[index].status == "PENDING" ||
                                            data[index].status == "REQUESTED" ||
                                            data[index].status == "WAITING"
                                        ? "Waiting"
                                        : data[index].status == "IN_TRANSIT"
                                            ? "In Transit"
                                            : data[index].status == "DELIVERED"
                                                ? "Delivered"
                                                : "",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    fontColor: data[index].status ==
                                                "PENDING" ||
                                            data[index].status == "REQUESTED" ||
                                            data[index].status == "WAITING"
                                        ? AppColors.red
                                        : data[index].status == "IN_TRANSIT"
                                            ? AppColors.green
                                            : data[index].status == "DELIVERED"
                                                ? AppColors.green
                                                : AppColors.black,
                                  ),
                                  const SpaceWidget(spaceHeight: 12),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () => _openWhatsApp(
                                            data[index].phoneNumber ?? "",
                                            "Hello, regarding your parcel delivery."),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: const CircleAvatar(
                                          backgroundColor: AppColors.whiteDark,
                                          radius: 18,
                                          child: IconWidget(
                                            icon: AppIconsPath.whatsAppIcon,
                                            color: AppColors.black,
                                            width: 18,
                                            height: 18,
                                          ),
                                        ),
                                      ),
                                      const SpaceWidget(spaceWidth: 8),
                                      InkWell(
                                        onTap: () => _makePhoneCall(
                                            data[index].phoneNumber ?? ""),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: const CircleAvatar(
                                          backgroundColor: AppColors.whiteDark,
                                          radius: 18,
                                          child: Icon(
                                            Icons.call,
                                            color: AppColors.black,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SpaceWidget(spaceHeight: 8),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.whiteLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    // Navigate to appropriate screen based on sender ID
                                    if (isUserSender) {
                                      Get.toNamed(AppRoutes.parcelDetailsScreen,
                                          arguments: data[index].id);
                                    } else {
                                      Get.toNamed(
                                          AppRoutes.bookingViewDetailsScreen,
                                          arguments: data[index].id);
                                    }
                                  },
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.remove_red_eye_outlined,
                                        color: AppColors.black,
                                        size: 16,
                                      ),
                                      const SpaceWidget(spaceWidth: 8),
                                      TextWidget(
                                        text: isUserSender
                                            ? "parcelDetails".tr
                                            : "viewDetails".tr,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: AppColors.greyDark2,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 24,
                                  color: AppColors.blackLighter,
                                ),
                                InkWell(
                                  onTap: () {
                                    // Handle appropriate action based on status and sender ID
                                    if (data[index].status == "IN_TRANSIT") {
                                      Get.toNamed(AppRoutes.deliveryManDetails,
                                          arguments: data[index].id);
                                    } else if (!isUserSender) {
                                      deliveryFinished();
                                    } else if (data[index].status ==
                                        "DELIVERED") {
                                      _openBottomSheet();
                                    } else {
                                      String parcelId = data[index].id ?? "";
                                      removeParcelConfirmation(parcelId);
                                    }
                                  },
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Row(
                                    children: [
                                      data[index].status == "IN_TRANSIT"
                                          ? const IconWidget(
                                              icon:
                                                  AppIconsPath.deliverymanIcon,
                                              color: AppColors.greyDark2,
                                              width: 14,
                                              height: 14,
                                            )
                                          : const SizedBox.shrink(),
                                      data[index].status == "IN_TRANSIT"
                                          ? const SpaceWidget(spaceWidth: 8)
                                          : const SpaceWidget(spaceWidth: 0),
                                      SizedBox(
                                        width: ResponsiveUtils.width(120),
                                        child: TextWidget(
                                          text:
                                              data[index].status == "IN_TRANSIT"
                                                  ? "deliveryManDetails".tr
                                                  : !isUserSender
                                                      ? "Finish Delivery".tr
                                                      : data[index].status ==
                                                              "DELIVERED"
                                                          ? "Giving Review".tr
                                                          : "removeFromMap".tr,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontColor:
                                              data[index].status == "IN_TRANSIT"
                                                  ? AppColors.greyDark2
                                                  : !isUserSender ||
                                                          data[index].status ==
                                                              "DELIVERED"
                                                      ? AppColors.green
                                                      : AppColors.red,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SpaceWidget(spaceHeight: 80),
        ],
      );
    });
  }

  Widget _newBookingWidget() {
    return SingleChildScrollView(
      child: Obx(() {
        final newBookingsController = Get.find<NewBookingsController>();
        if (newBookingController.currentOrdersModel.value.data == null) {
          newBookingController.getCurrentOrder();
          return const Center(child: CircularProgressIndicator());
        }

        final allParcels = newBookingController.currentOrdersModel.value.data;
        // Filter only parcels that have deliveryRequests
        final parcelsWithRequests = allParcels
                ?.where((parcel) =>
                    parcel.deliveryRequests != null &&
                    parcel.deliveryRequests!.isNotEmpty)
                .toList() ??
            [];

        if (parcelsWithRequests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Icon(
                    Icons.inbox_outlined,
                    size: 60,
                    color: AppColors.greyDarkLight,
                  ),
                  const SizedBox(height: 16),
                  TextWidget(
                    text: "No New Bookings".tr,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontColor: AppColors.greyDark2,
                    textAlignment: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            const SpaceWidget(spaceHeight: 15),
            ...List.generate(parcelsWithRequests.length, (index) {
              final parcel = parcelsWithRequests[index];
              final parcelId = parcel.id ?? "";
              // Parse the deliveryRequest as a Map instead of accessing properties directly
              final deliveryRequest =
                  parcel.deliveryRequests!.first as Map<String, dynamic>;

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

              final deliveryLocation = parcel.deliveryLocation?.coordinates;
              final pickupLocation = parcel.pickupLocation?.coordinates;

              // Track the request state locally using a unique key for the request
              final String requestKey =
                  '${parcel.id}-${deliveryRequest["_id"] ?? ""}';
              final requestState =
                  newBookingsController.requestStates[requestKey] ?? 'pending';

              // Request address fetching for this parcel
              if (deliveryLocation != null && deliveryLocation.length == 2) {
                final latitude = deliveryLocation[1];
                final longitude = deliveryLocation[0];
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  cacheAddressForParcel(
                      parcelId, 'delivery', latitude, longitude);
                });
              }

              if (pickupLocation != null && pickupLocation.length == 2) {
                final latitude = pickupLocation[1];
                final longitude = pickupLocation[0];
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  cacheAddressForParcel(
                      parcelId, 'pickup', latitude, longitude);
                });
              }

              // Get addresses for this specific parcel
              final deliveryAddress = getParcelAddress(parcelId, 'delivery');
              final pickupAddress = getParcelAddress(parcelId, 'pickup');

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.greyDarkLight.withAlpha(25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Column with user details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: AppImage(
                                      url: deliveryRequest["image"] ??
                                          AppImagePath.dummyProfileImage,
                                      height: 40,
                                      width: 40,
                                    ),
                                  ),
                                  const SpaceWidget(spaceWidth: 8),
                                  TextWidget(
                                    text: deliveryRequest["fullName"] ?? '',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w500,
                                    fontColor: AppColors.black,
                                  ),
                                ],
                              ),
                              const SpaceWidget(spaceHeight: 16),
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: const ImageWidget(
                                      imagePath: AppImagePath.sendParcel,
                                      height: 14,
                                      width: 14,
                                    ),
                                  ),
                                  const SpaceWidget(spaceWidth: 8),
                                  TextWidget(
                                    text: parcel.title ?? '',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontColor: AppColors.greyDark2,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                                      text:
                                          "$pickupAddress to $deliveryAddress",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      fontColor: AppColors.greyDark2,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SpaceWidget(spaceHeight: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    color: AppColors.black,
                                    size: 12,
                                  ),
                                  const SpaceWidget(spaceWidth: 8),
                                  TextWidget(
                                    text: deliveryRequest["mobileNumber"] ??
                                        parcel.phoneNumber ??
                                        '',
                                    fontSize: 12,
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
                                    text: formattedDate,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontColor: AppColors.greyDark2,
                                  ),
                                ],
                              ),
                              const SpaceWidget(spaceHeight: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.delivery_dining_outlined,
                                    color: AppColors.black,
                                    size: 15,
                                  ),
                                  const SpaceWidget(spaceWidth: 8),
                                  TextWidget(
                                    text: allParcels?.first.deliveryType ==
                                            'bike'
                                        ? 'Bike'
                                        : allParcels?.first.deliveryType ==
                                                'bicycle'
                                            ? 'Bicycle'
                                            : allParcels?.first.deliveryType ==
                                                    'car'
                                                ? 'Car'
                                                : allParcels?.first
                                                            .deliveryType ==
                                                        'taxi'
                                                    ? 'Taxi'
                                                    : allParcels?.first
                                                                .deliveryType ==
                                                            'truck'
                                                        ? 'Truck'
                                                        : allParcels?.first
                                                                    .deliveryType ==
                                                                'person'
                                                            ? 'Person'
                                                            : allParcels?.first
                                                                        .deliveryType ==
                                                                    'plane'
                                                                ? 'Plane'
                                                                : allParcels
                                                                        ?.first
                                                                        .deliveryType ??
                                                                    '',
                                    // Default empty string if null
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontColor: AppColors.greyDark2,
                                  )
                                ],
                              ),
                              const SpaceWidget(spaceHeight: 8),
                            ],
                          ),
                        ),
                        // Right Column with price and publication date
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: "${AppStrings.currency} ${parcel.price}",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontColor: AppColors.black,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.whiteLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: requestState == 'accepted' ||
                                    requestState == 'rejected'
                                ? null // Disable if already acted upon
                                : () async {
                                    // Implement reject functionality
                                    await newBookingsController
                                        .rejectParcelRequest(
                                      parcel.id ?? '',
                                      deliveryRequest["_id"] ?? '',
                                    );
                                    await currentOrderController
                                        .getCurrentOrder();
                                    final controller =
                                        Get.find<NewBookingsController>();
                                    _currentIndex = 0;
                                    controller.update();
                                    _pageController.jumpToPage(1);
                                  },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Row(
                              children: [
                                Icon(
                                  requestState == 'rejected'
                                      ? Icons.close
                                      : Icons.close,
                                  color: requestState == 'accepted'
                                      ? AppColors.greyDark2
                                      : (requestState == 'rejected'
                                          ? AppColors.red
                                          : AppColors.red),
                                  size: 18,
                                ),
                                const SpaceWidget(spaceWidth: 4),
                                TextWidget(
                                  text: requestState == 'rejected'
                                      ? "rejected".tr
                                      : "reject".tr,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontColor: requestState == 'accepted'
                                      ? AppColors.greyDark2
                                      : (requestState == 'rejected'
                                          ? AppColors.red
                                          : AppColors.red),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 24,
                            color: AppColors.blackLighter,
                          ),
                          InkWell(
                            onTap: requestState == 'accepted' ||
                                    requestState == 'rejected'
                                ? null // Disable if already acted upon
                                : () async {
                                    // Implement accept functionality
                                    await newBookingsController
                                        .acceptParcelRequest(
                                      parcel.id ?? '',
                                      deliveryRequest["_id"] ?? '',
                                    );
                                    final controller =
                                        Get.find<NewBookingsController>();
                                    _currentIndex = 0;
                                    controller.update();
                                    _pageController.jumpToPage(1);
                                  },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Row(
                              children: [
                                Icon(
                                  requestState == 'accepted'
                                      ? Icons.check
                                      : Icons.check,
                                  color: requestState == 'rejected'
                                      ? AppColors.greyDark2
                                      : (requestState == 'accepted'
                                          ? AppColors.green
                                          : AppColors.green),
                                  size: 18,
                                ),
                                const SpaceWidget(spaceWidth: 4),
                                TextWidget(
                                  text: requestState == 'accepted'
                                      ? "accepted".tr
                                      : "accept".tr,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontColor: requestState == 'rejected'
                                      ? AppColors.greyDark2
                                      : (requestState == 'accepted'
                                          ? AppColors.green
                                          : AppColors.green),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SpaceWidget(spaceHeight: 80),
          ],
        );
      }),
    );
  }
}
