import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
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
  late NotificationController controller;

  Map<String, String> addressCache = {};
  Map<String, String> locationToAddressCache = {};

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
    controller = Get.put(NotificationController());
    _tabController = TabController(length: 2, vsync: this);
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (_tabController.index == 0) {
          controller.loadMoreNotifications();
        }
      }
    });

    _scrollController2.addListener(() {
      if (_scrollController2.position.pixels >=
          _scrollController2.position.maxScrollExtent - 200) {
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
      final Uri whatsappUri = Uri.parse(
          "whatsapp://send?phone=$formattedNumber&text=${Uri.encodeComponent(message)}");

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri,
            mode: LaunchMode.externalNonBrowserApplication);
        return;
      }
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

  String _getTimeAgo(String? createdAt) {
    try {
      if (createdAt == null) {
        return "Unknown time";
      }

      // Parse the createdAt timestamp (assumed to be in UTC, e.g., "2025-05-13T09:02:30.511Z")
      final DateTime createdDate = DateTime.parse(createdAt).toUtc();

      // Current time in UTC+6 (based on provided time: 07:08 PM +06, May 13, 2025)
      final DateTime now = DateTime.now().toUtc().add(const Duration(hours: 6));

      // Calculate the difference
      final Duration difference = now.difference(createdDate);

      if (difference.inSeconds < 60) {
        return "just now";
      } else if (difference.inMinutes < 60) {
        return "${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago";
      } else if (difference.inDays < 30) {
        return "${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago";
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return "$months month${months == 1 ? '' : 's'} ago";
      } else {
        final years = (difference.inDays / 365).floor();
        return "$years year${years == 1 ? '' : 's'} ago";
      }
    } catch (e) {
      log("Error in _getTimeAgo: $e");
      return "Unknown time";
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    Tab(text: "Available Deliveries"),
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
                              ...List.generate(
                                controller.notificationModel.value!.data!
                                    .notifications!.length,
                                (index) => _buildRegularNotificationCard(index),
                              ),
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

                      int totalNotifications = 0;
                      for (var parcelData in controller.parcelNotifications) {
                        if (parcelData.data?.notifications != null) {
                          totalNotifications +=
                              parcelData.data!.notifications!.length;
                        }
                      }

                      if (totalNotifications == 0) {
                        return const Center(
                            child: Text(
                                "No interested delivery notifications available."));
                      }

                      return ListView.builder(
                        controller: _scrollController2,
                        itemCount: totalNotifications,
                        itemBuilder: (context, index) {
                          return _buildParcelNotificationCard(index);
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

  Widget _buildParcelNotificationCard(int index) {
    // Find which parcel notification this index belongs to
    int currentIndex = index;
    dynamic notification;

    for (var parcelData in controller.parcelNotifications) {
      if (parcelData.data?.notifications != null) {
        if (currentIndex < parcelData.data!.notifications!.length) {
          notification = parcelData.data!.notifications![currentIndex];
          break;
        } else {
          currentIndex -= parcelData.data!.notifications!.length;
        }
      }
    }

    if (notification == null) {
      return const SizedBox(); // Return empty widget if notification not found
    }

    String title = notification.title ?? "Parcel";
    String message = notification.message ?? "No details available";
    String phoneNumber = notification.phoneNumber ?? "+375 292316347";
    DateTime? createdAtDate;
    String timeAgo = _getTimeAgo(notification.createdAt.toString());
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
    bool isRejected = notification.type == "rejected";
    bool isRequestedDelivery = notification.type == "requested";
    String? deliveryPersonName = notification.userId;
    double? rating = notification.avgRating?.toDouble();
    int price = notification.price ?? 150;

    ///// Location
    final String notificationId = notification.id;
    double? pickupLocationLat = notification.pickupLocation?.latitude;
    double? pickupLocationLong = notification.pickupLocation?.longitude;
    double? deliveryLocationLat = notification.deliveryLocation?.latitude;
    double? deliveryLocationLong = notification.deliveryLocation?.longitude;

    // Trigger address loading if coordinates are available
    if (pickupLocationLat != null && pickupLocationLong != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        cacheAddressForParcel(
            notificationId, 'pickup', pickupLocationLat, pickupLocationLong);
      });
    }
    if (deliveryLocationLat != null && deliveryLocationLong != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        cacheAddressForParcel(notificationId, 'delivery', deliveryLocationLat,
            deliveryLocationLong);
      });
    }
    // Get the specific pickup and delivery addresses for this notification
    final pickupAddress = getParcelAddress(notificationId, 'pickup');
    final deliveryAddress = getParcelAddress(notificationId, 'delivery');

    //// Date and Time Formatting
    //////////////// Date Formateed
    String formattedDate = "N/A";
    try {
      final startDate =
          DateTime.parse(notification.deliveryStartTime.toString());
      final endDate = DateTime.parse(notification.deliveryEndTime.toString());
      formattedDate =
          "${DateFormat(' dd.MM ').format(startDate)} to ${DateFormat(' dd.MM ').format(endDate)}";
    } catch (e) {
      log("Error parsing dates: $e");
    }
    /////////////

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Container(
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
                        const SpaceWidget(spaceWidth: 4),
                        TextWidget(
                          text: title,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontColor: AppColors.black,
                        ),
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
                const SpaceWidget(spaceHeight: 12),
                // Address - now using cached addresses specific to this notification
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: AppColors.greyDark2),
                    const SpaceWidget(spaceWidth: 8),
                    TextWidget(
                      text: "$pickupAddress to $deliveryAddress",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontColor: AppColors.greyDark2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                      fontWeight: FontWeight.w400,
                      fontColor: AppColors.greyDark,
                    ),
                  ],
                ),
                const SpaceWidget(spaceHeight: 8),

                const SpaceWidget(spaceHeight: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextWidget(
                    text: timeAgo,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    fontColor: AppColors.greyDark,
                  ),
                ),
                const SpaceWidget(spaceHeight: 8),

                // Buttons
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
                        onTap: () {},
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Row(
                          children: [
                            const IconWidget(
                              icon: AppIconsPath.personAddIcon,
                              color: AppColors.black,
                              width: 14,
                              height: 14,
                            ),
                            const SpaceWidget(spaceWidth: 8),
                            TextWidget(
                              text: "requestSent".tr,
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
                        onTap: () {},
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
                      )
                    ],
                  ),
                )
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

  Widget _buildRegularNotificationCard(int index) {
    // Access the notification from the controller directly using the index
    final notification =
        controller.notificationModel.value!.data!.notifications![index];

    String title = notification.title ?? "Notification";
    String name = notification.name ?? "Unknown";
    String message = notification.message ?? "No details available";
    String image = notification.image ?? "";
    String avgRating = notification.avgRating?.toString() ?? "N/A";
    String mobileNumber = notification.mobileNumber ?? "+972 54-123-4567";
    String type = notification.type ?? "";
    String price = notification.price?.toString() ?? "0";
    String timeAgo = _getTimeAgo(notification.createdAt);

    final String notificationId = notification.sId ?? 'unknown_id';
    // Safely handle location coordinates
    double? pickupLocationLat = notification.pickupLocation?.latitude;
    double? pickupLocationLong = notification.pickupLocation?.longitude;
    double? deliveryLocationLat = notification.deliveryLocation?.latitude;
    double? deliveryLocationLong = notification.deliveryLocation?.longitude;

    // Trigger address loading if coordinates are available
    if (pickupLocationLat != null && pickupLocationLong != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        cacheAddressForParcel(
            notificationId, 'pickup', pickupLocationLat, pickupLocationLong);
      });
    }
    if (deliveryLocationLat != null && deliveryLocationLong != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        cacheAddressForParcel(notificationId, 'delivery', deliveryLocationLat,
            deliveryLocationLong);
      });
    }

    // Get the specific pickup and delivery addresses for this notification
    final pickupAddress = getParcelAddress(notificationId, 'pickup');
    final deliveryAddress = getParcelAddress(notificationId, 'delivery');

    //// Date and Time Formatting
    //////////////// Date Formateed
    String formattedDate = "N/A";
    try {
      final startDate =
          DateTime.parse(notification.deliveryStartTime.toString());
      final endDate = DateTime.parse(notification.deliveryEndTime.toString());
      formattedDate =
          "${DateFormat(' dd.MM ').format(startDate)} to ${DateFormat(' dd.MM ').format(endDate)}";
    } catch (e) {
      log("Error parsing dates: $e");
    }
    /////////////

    bool isRead = notification.isRead ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              const Spacer(),
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
                  text: "$pickupAddress to $deliveryAddress",
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                fontWeight: FontWeight.w400,
                fontColor: AppColors.greyDark,
              ),
            ],
          ),
          const SpaceWidget(spaceHeight: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextWidget(
              text: timeAgo,
              fontWeight: FontWeight.w500,
              fontSize: 12,
              fontColor: AppColors.greyDark,
            ),
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
}
