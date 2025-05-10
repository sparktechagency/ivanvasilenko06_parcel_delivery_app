import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/screens/notification_screen/controller/notification_controller.dart';
import 'package:parcel_delivery_app/services/reuseable/lat_long_to_address.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';
import 'package:parcel_delivery_app/widgets/image_widget/app_images.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_icons_path.dart';
import '../../constants/app_image_path.dart';
import '../../widgets/icon_widget/icon_widget.dart';
import '../../widgets/image_widget/image_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  AddressService addressService = AddressService();
  String address = "Loading...";
  String newBookingAddress = "Loading...";

  // Method to get the regular address
  Future<void> _getAddress(double latitude, double longitude) async {
    String result = await addressService.getAddress(latitude, longitude);
    setState(() {
      address = result;
    });
  }

  // Method to get the new booking address
  Future<void> newAddress(double latitude, double longitude) async {
    String result =
        await addressService.getNewBookingAddress(latitude, longitude);
    setState(() {
      newBookingAddress = result;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final controller = Get.find<NotificationController>();
        if (_tabController.index == 0) {
          // First tab - load more notifications
          controller.loadMoreNotifications();
        }
      }
    });

    _scrollController2.addListener(() {
      if (_scrollController2.position.pixels >=
          _scrollController2.position.maxScrollExtent - 200) {
        final controller = Get.find<NotificationController>();
        if (_tabController.index == 1) {
          // Second tab - load more parcel notifications
          controller.loadMoreParcelNotifications();
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _scrollController2.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      AppSnackBar.error('Could not launch phone call: $e');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SpaceWidget(spaceHeight: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: "notification".tr,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.black,
                    ),
                  ],
                ),
              ),
              const SpaceWidget(spaceHeight: 16),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.whiteDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.black,
                  ),
                  labelColor: AppColors.white,
                  unselectedLabelColor: AppColors.greyDark2,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: "Parcel/Delivery Updates"),
                    Tab(text: "Interested In Delivery"),
                  ],
                ),
              ),

              const SpaceWidget(spaceHeight: 16),

              // Tab Bar View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    //////////////////// First Tab - Parcel/Delivery Updates
                    Obx(() {
                      final bool isLoading = controller.isLoading.value;
                      final bool hasError = controller.errorMessage.isNotEmpty;
                      final bool isEmpty =
                          controller.notificationModel.value == null ||
                              controller.notificationModel.value?.data
                                      ?.notifications ==
                                  null ||
                              controller.notificationModel.value!.data!
                                  .notifications!.isEmpty;

                      if (isLoading && isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (hasError && isEmpty) {
                        return Center(
                          child: Text("Error: ${controller.errorMessage}"),
                        );
                      }

                      if (isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: TextWidget(
                              text: "No notifications available.",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontColor: AppColors.greyDark2,
                              textAlignment: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Regular Notifications Section
                            if (controller.notificationModel.value?.data
                                        ?.notifications !=
                                    null &&
                                controller.notificationModel.value!.data!
                                    .notifications!.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: TextWidget(
                                  text: "Delivery Updates",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontColor: AppColors.black,
                                ),
                              ),

                              // Display regular notifications
                              ...controller
                                  .notificationModel.value!.data!.notifications!
                                  .map((notification) =>
                                      _buildRegularNotificationCard(
                                          notification))
                                  .toList(),

                              if (controller.isLoading.value &&
                                  controller.currentPage.value > 1)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                            ],

                            // Add some space at the bottom
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    }),

                    //////////////////// Second Tab - Interested In Delivery
                    Obx(() {
                      if (controller.isParcelLoading.value &&
                          controller.parcelNotifications.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.parcelError.isNotEmpty &&
                          controller.parcelNotifications.isEmpty) {
                        return Center(
                            child: Text("Error: ${controller.parcelError}"));
                      }
                      if (controller.parcelNotifications.isEmpty) {
                        return const Center(
                            child: Text(
                                "No interested delivery notifications available."));
                      }
                      return ListView.builder(
                        controller: _scrollController2,
                        itemCount: controller.parcelNotifications.length,
                        itemBuilder: (context, index) {
                          final notification =
                              controller.parcelNotifications[index];
                          return _buildParcelNotificationCard(
                              notification.data!.notifications!.first);
                        },
                      );
                    })
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(100),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteLight,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 25,
                  child: Icon(Icons.arrow_back, color: AppColors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelNotificationCard(notification) {
    String title = notification.title ?? "Parcel";
    String message = notification.message ?? "No details available";
    String address =
        notification.description ?? "Western Wall to 4 Idan street";
    String phoneNumber = notification.phoneNumber ?? "+375 292316347";
    DateTime? createdAtDate;
    try {
      createdAtDate = notification.createdAt != null
          ? DateTime.parse(notification.createdAt!)
          : null;
    } catch (e) {
      createdAtDate = null;
    }

    String date = createdAtDate != null
        ? DateFormat('dd.MM.yyyy').format(createdAtDate)
        : "24.04.2024";
    bool isRead = notification.isRead ?? false;
    bool isAccepted = notification.type == "accepted";
    bool isRejected = notification.type == "rejected";
    bool isRequestedDelivery = notification.type == "requested";
    String? deliveryPersonName = notification.userId;
    double? rating = notification.avgRating?.toDouble();
    int price = notification.price ?? 150;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(18),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.inventory_2,
                            size: 16, color: AppColors.greyDark2),
                        const SpaceWidget(spaceWidth: 4),
                        TextWidget(
                          text: title,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontColor: AppColors.black,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.receipt,
                            size: 16, color: AppColors.greyDark2),
                        const SpaceWidget(spaceWidth: 4),
                        TextWidget(
                          text: "$price",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontColor: AppColors.black,
                        ),
                      ],
                    ),
                  ],
                ),

                const SpaceWidget(spaceHeight: 12),

                // Address
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: AppColors.greyDark2),
                    const SpaceWidget(spaceWidth: 8),
                    Expanded(
                      child: TextWidget(
                        text: address,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontColor: AppColors.greyDark2,
                      ),
                    ),
                  ],
                ),

                const SpaceWidget(spaceHeight: 8),

                // Phone number
                Row(
                  children: [
                    const Icon(Icons.phone,
                        size: 16, color: AppColors.greyDark2),
                    const SpaceWidget(spaceWidth: 8),
                    Expanded(
                      child: TextWidget(
                        text: phoneNumber,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontColor: AppColors.greyDark2,
                      ),
                    ),
                    if (isRequestedDelivery) ...[
                      const TextWidget(
                        text: "Request sent",
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontColor: AppColors.greyDark2,
                      ),
                    ],

                    // WhatsApp and Call buttons
                    InkWell(
                      onTap: () => _openWhatsApp(phoneNumber, message),
                      borderRadius: BorderRadius.circular(100),
                      child: const CircleAvatar(
                        backgroundColor: AppColors.whiteDark,
                        radius: 16,
                        child: Icon(
                          Icons.message,
                          color: AppColors.black,
                          size: 16,
                        ),
                      ),
                    ),
                    const SpaceWidget(spaceWidth: 8),
                    InkWell(
                      onTap: () => _makePhoneCall(phoneNumber),
                      borderRadius: BorderRadius.circular(100),
                      child: const CircleAvatar(
                        backgroundColor: AppColors.whiteDark,
                        radius: 16,
                        child: Icon(
                          Icons.call,
                          color: AppColors.black,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SpaceWidget(spaceHeight: 8),

                // Date
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: AppColors.greyDark2),
                    const SpaceWidget(spaceWidth: 8),
                    TextWidget(
                      text: date,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontColor: AppColors.greyDark2,
                    ),
                  ],
                ),

                const SpaceWidget(spaceHeight: 12),

                // Status
                if (isAccepted)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.whiteDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: TextWidget(
                        text: "Accepted",
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontColor: AppColors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isRequestedDelivery && deliveryPersonName != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.greyLight),
                ),
              ),
              child: Column(
                children: [
                  // Delivery person info with rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          TextWidget(
                            text: deliveryPersonName,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontColor: AppColors.black,
                          ),
                        ],
                      ),
                      if (rating != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Colors.white),
                              const SpaceWidget(spaceWidth: 4),
                              TextWidget(
                                text: rating.toStringAsFixed(1),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontColor: Colors.white,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SpaceWidget(spaceHeight: 12),

                  // Action buttons
                  Row(
                    children: [
                      if (isRejected)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Handle reject action
                            },
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text("Reject"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      if (isRejected) const SpaceWidget(spaceWidth: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Handle view or accept action
                          },
                          icon: Icon(
                            isRejected ? Icons.visibility : Icons.check,
                            color: isRejected ? Colors.black : Colors.green,
                          ),
                          label: Text(isRejected ? "View" : "Accept"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor:
                                isRejected ? Colors.black : Colors.green,
                            side: BorderSide(
                              color: isRejected ? Colors.black : Colors.green,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Build a card for regular notifications
  Widget _buildRegularNotificationCard(notification) {
    String title = notification.title ?? "Notification";
    String name = notification.name ?? "Unknown";
    String message = notification.message ?? "No details available";
    String image = notification.image ?? "";
    String avgRating = notification.avgRating?.toString() ?? "N/A";
    String mobileNumber = notification.mobileNumber ?? "+972 54-123-4567";
    String type = notification.type ?? "";
    String price = notification.price?.toString() ?? "0";
    // Safely handle location coordinates
    double? pickupLocationLat = notification.pickupLocation?.latitude;
    double? pickupLocationLong = notification.pickupLocation?.longitude;
    double? deliveryLocationLat = notification.deliveryLocation?.latitude;
    double? deliveryLocationLong = notification.deliveryLocation?.longitude;

    if (pickupLocationLat != null &&
        pickupLocationLong != null &&
        deliveryLocationLat != null &&
        deliveryLocationLong != null) {
      _getAddress(pickupLocationLat, pickupLocationLong);
      newAddress(deliveryLocationLat, deliveryLocationLong);
    }

    DateTime? createdAtDate;
    try {
      createdAtDate = notification.createdAt != null
          ? DateTime.parse(notification.createdAt!)
          : null;
    } catch (e) {
      createdAtDate = null;
    }

    String date = createdAtDate != null
        ? DateFormat('MMM dd, yyyy - hh:mm a').format(createdAtDate)
        : "Unknown date";
    bool isRead = notification.isRead ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 23, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              type.toString() == "Requested-Delivery"
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: AppImage(
                        url: image,
                        width: 40,
                        height: 40,
                      ),
                    )
                  : const ImageWidget(
                      height: 40,
                      width: 40,
                      imagePath: AppImagePath.sendParcel,
                    ),
              const SpaceWidget(spaceWidth: 8),
              TextWidget(
                text: type.toString() == "Requested-Delivery" ? name : title,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontColor: AppColors.black,
              ),
              const SpaceWidget(spaceWidth: 12),
              type.toString() == "Requested-Delivery"
                  ? Container(
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
                            text: avgRating,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontColor: AppColors.white,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              Spacer(),
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
              SizedBox(
                width: ResponsiveUtils.width(180),
                child: TextWidget(
                  text: "$address to $newBookingAddress",
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.greyDark2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlignment: TextAlign.start,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          type.toString() == "Requested-Delivery"
              ? const SizedBox()
              : Row(
                  children: [
                    const Icon(
                      Icons.call,
                      color: AppColors.black,
                      size: 12,
                    ),
                    const SpaceWidget(spaceWidth: 8),
                    TextWidget(
                      text: mobileNumber,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontColor: AppColors.greyDark2,
                    ),
                  ],
                ),
          const SpaceWidget(spaceHeight: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                    fontWeight: FontWeight.w400,
                    fontColor: AppColors.greyDark,
                  ),
                ],
              ),
              type == "Cancelled"
                  ? const SizedBox()
                  : Row(
                      children: [
                        InkWell(
                          onTap: () => _openWhatsApp(mobileNumber,
                              "Hello, regarding your parcel delivery."),
                          borderRadius: BorderRadius.circular(100),
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
                          onTap: () => _makePhoneCall(mobileNumber),
                          borderRadius: BorderRadius.circular(100),
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
            ],
          ),
          const SpaceWidget(spaceHeight: 12),
          type == "Accepted"
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.whiteLight,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const TextWidget(
                    text: "Accepted",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontColor: AppColors.greyDark2,
                  ),
                )
              : type == "Cancelled"
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.whiteLight,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const TextWidget(
                        text: "Rejected",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontColor: AppColors.red,
                      ),
                    )
                  : const SizedBox()
        ],
      ),
    );
  }

// Function to make a phone call
}
