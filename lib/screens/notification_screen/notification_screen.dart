import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
import '../delivery_parcel_screens/controller/delivery_screens_controller.dart';

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

  //! Store address by parcel ID
  void cacheAddressForParcel(String parcelId, String addressType,
      double latitude, double longitude) async {
    final cacheKey = '${parcelId}_$addressType';
    if (!addressCache.containsKey(cacheKey)) {
      String fetchedAddress =
          await getAddressFromCoordinates(latitude, longitude);
      setState(() {
        addressCache[cacheKey] = fetchedAddress;
      });
    }
  }

  //! Get address for a specific parcel
  String getParcelAddress(String parcelId, String addressType) {
    final cacheKey = '${parcelId}_$addressType';
    return addressCache[cacheKey] ?? 'Loading...';
  }

  //! Method to get the regular address
  // Future<void> _getAddress(double latitude, double longitude) async {
  //   String result = await addressService.getAddress(latitude, longitude);
  //   setState(() {
  //     address = result;
  //   });
  // }

  //! Method to get the new booking address
  Future<void> newAddress(double latitude, double longitude) async {
    String result =
        await addressService.getNewBookingAddress(latitude, longitude);
    setState(() {
      newBookingAddress = result;
    });
  }

  final DeliveryScreenController _deliveryController =
      Get.put(DeliveryScreenController());

  @override
  void initState() {
    super.initState();
    controller = Get.put(NotificationController());
    _tabController = TabController(length: 2, vsync: this);
    _setupScrollListener();
    _tabController.addListener(() {
      if (_tabController.index == 1 && controller.parcelNotifications.isEmpty) {
        controller.fetchParcelNotifications();
      }
    });
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
      // AppSnackBar.error('Could not launch phone call: $e');
    }
  }

  Future<void> _openWhatsApp(String phoneNumber, String message) async {
    if (phoneNumber.isEmpty) {
      _showErrorSnackBar('No phone number available');
      return;
    }

    //! Format the phone number (remove any non-digit characters)
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    try {
      //! Direct WhatsApp intent
      if (Platform.isAndroid) {
        //! Try Android-specific direct intent first (most reliable)
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

  String _getTimeAgo(String? localCreatedAt) {
    try {
      if (localCreatedAt == null) {
        return "Unknown time";
      }

      //! Define the format of the input time string (e.g., "2025-05-17 03:19 PM")
      final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm");

      //! Parse the input time as local DateTime
      final DateTime createdDate = formatter.parse(localCreatedAt);

      //! Current local time
      final DateTime now = DateTime.now();
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
                    //! First Tab - Parcel/Delivery Updates
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
                              //! Display regular notifications
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

                            //! Add some space at the bottom
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    }),
                    //! Second Tab - Interested In Delivery
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
    //! Find which parcel notification this index belongs to
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
      return const SizedBox();
      //! Return empty widget if notification not found
    }

    String title = notification.title ?? "Parcel";
    String timeAgo = _getTimeAgo(notification.localCreatedAt.toString());
    try {} catch (e) {
      log("Error in _buildParcelNotificationCard: $e");
      timeAgo = "Unknown time";
    }
    notification.avgRating?.toDouble();
    int price = notification.price ?? 150;

    //! Location
    final String notificationId = notification.id;
    double? pickupLocationLat = notification.pickupLocation?.latitude;
    double? pickupLocationLong = notification.pickupLocation?.longitude;
    double? deliveryLocationLat = notification.deliveryLocation?.latitude;
    double? deliveryLocationLong = notification.deliveryLocation?.longitude;

    //! Trigger address loading if coordinates are available
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
    //! Get the specific pickup and delivery addresses for this notification
    final pickupAddress = getParcelAddress(notificationId, 'pickup');
    final deliveryAddress = getParcelAddress(notificationId, 'delivery');

    //! Date and Time Formatting
    String formattedDate = "N/A";
    try {
      if (notification.deliveryStartTime != null &&
          notification.deliveryEndTime != null) {
        //! First try parsing with the expected format
        DateFormat dateFormat = DateFormat("yyyy-MM-dd hh:mm a");
        final startDate =
            dateFormat.parse(notification.deliveryStartTime.toString());
        final endDate =
            dateFormat.parse(notification.deliveryEndTime.toString());

        formattedDate =
            "${DateFormat('dd.MM').format(startDate)} to ${DateFormat('dd.MM').format(endDate)}";
      }
    } catch (e) {
      log("Error parsing dates: $e");
      try {
        //! Fallback: try parsing ISO format if the first attempt fails
        final startDate =
            DateTime.parse(notification.deliveryStartTime.toString());
        final endDate = DateTime.parse(notification.deliveryEndTime.toString());
        formattedDate =
            "${DateFormat('dd.MM').format(startDate)} to ${DateFormat('dd.MM').format(endDate)}";
      } catch (e) {
        log("Error parsing dates (fallback): $e");
        formattedDate = "N/A";
      }
    }

    //! Parcel ID
    String parcelId = notification.parcelId.toString();
    final bool hasSentRequest = controller.isRequestSent(parcelId);
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
                //! Address - now using cached addresses specific to this notification
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    hasSentRequest == false
                        ? const SizedBox()
                        : const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 12,
                              ),
                              SpaceWidget(spaceWidth: 8),
                              TextWidget(
                                text: "Request Sent",
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontColor: Colors.green,
                              ),
                            ],
                          ),
                    TextWidget(
                      text: timeAgo,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      fontColor: AppColors.greyDark,
                    ),
                  ],
                ),
                const SpaceWidget(spaceHeight: 8),

                //! Buttons
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.whiteLight,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: InkWell(
                    onTap: hasSentRequest
                        ? null
                        : () async {
                            try {
                              await _deliveryController
                                  .sendParcelRequest(parcelId);
                              controller.sentParcelIds.add(parcelId);
                              AppSnackBar.success("Request sent successfully");
                              setState(() {});
                            } catch (e) {
                              // AppSnackBar.error("Error: ${e.toString()}");
                              log("Error sending parcel request: $e");
                            } finally {
                              if (Get.isDialogOpen == true) {
                                Get.back();
                              }
                            }
                          },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconWidget(
                          icon: AppIconsPath.personAddIcon,
                          color: hasSentRequest ? Colors.grey : AppColors.black,
                          width: 14,
                          height: 14,
                        ),
                        const SpaceWidget(spaceWidth: 8),
                        TextWidget(
                          text: hasSentRequest
                              ? "requestSent".tr
                              : "sendRequest".tr,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontColor:
                              hasSentRequest ? Colors.grey : AppColors.black,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularNotificationCard(int index) {
    //! Access the notification from the controller directly using the index
    final notification =
        controller.notificationModel.value!.data!.notifications![index];

    String title = notification.title ?? "Notification";
    String name = notification.name ?? "Unknown";
    String image = notification.image ?? "";
    String avgRating = notification.avgRating?.toString() ?? "N/A";
    String mobileNumber = notification.mobileNumber ?? "N/A";
    String type = notification.type ?? "";
    String price = notification.price?.toString() ?? "0";

    //! Fixed time parsing for regular notifications
    String timeAgo = "Unknown time";
    try {
      if (notification.createdAt != null) {
        DateTime createdDate;

        //! Try parsing as ISO format first
        try {
          createdDate = DateTime.parse(notification.createdAt.toString());
        } catch (e) {
          //! If ISO parsing fails, try other common formats
          try {
            final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
            createdDate = formatter.parse(notification.createdAt.toString());
          } catch (e) {
            //! Try another common format
            final DateFormat formatter2 = DateFormat("yyyy-MM-dd hh:mm a");
            createdDate = formatter2.parse(notification.createdAt.toString());
          }
        }

        final DateTime now = DateTime.now();
        final Duration difference = now.difference(createdDate);

        if (difference.inSeconds < 60) {
          timeAgo = "just now";
        } else if (difference.inMinutes < 60) {
          timeAgo =
              "${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago";
        } else if (difference.inHours < 24) {
          timeAgo =
              "${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago";
        } else if (difference.inDays < 30) {
          timeAgo =
              "${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago";
        } else if (difference.inDays < 365) {
          final months = (difference.inDays / 30).floor();
          timeAgo = "$months month${months == 1 ? '' : 's'} ago";
        } else {
          final years = (difference.inDays / 365).floor();
          timeAgo = "$years year${years == 1 ? '' : 's'} ago";
        }
      }
    } catch (e) {
      log("Error parsing createdAt time: $e, value: ${notification.createdAt}");
      timeAgo = "Unknown time";
    }

    final String notificationId = notification.sId ?? 'unknown_id';
    //! Safely handle location coordinates
    double? pickupLocationLat = notification.pickupLocation?.latitude;
    double? pickupLocationLong = notification.pickupLocation?.longitude;
    double? deliveryLocationLat = notification.deliveryLocation?.latitude;
    double? deliveryLocationLong = notification.deliveryLocation?.longitude;

    //! Trigger address loading if coordinates are available
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

    //! Get the specific pickup and delivery addresses for this notification
    final pickupAddress = getParcelAddress(notificationId, 'pickup');
    final deliveryAddress = getParcelAddress(notificationId, 'delivery');

    //! Date and Time Formatting
    String formattedDate = "N/A";
    try {
      final startDate =
          DateTime.parse(notification.deliveryStartTime.toString());
      final endDate = DateTime.parse(notification.deliveryEndTime.toString());
      formattedDate =
          "${DateFormat('dd.MM').format(startDate)} to ${DateFormat('dd.MM').format(endDate)}";
    } catch (e) {
      log("Error parsing dates: $e");
    }

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
              type.toString() == "Requested-Delivery" &&
                      notification.avgRating! > 0
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
          type == "Requested-Delivery"
              ? Row(
            children: [
              Image.asset(
                AppImagePath.sendParcel,
                width: 16,
                height: 16,
              ),
              const SpaceWidget(spaceWidth: 8),
              TextWidget(
                text: notification.title ?? "N/A",
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontColor: AppColors.greyDark2,
              ),
            ],
          ) :const SizedBox() ,
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
                          text: notification.mobileNumber ?? "N/A",
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
                  : type.toString() == "Requested-Delivery"
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.whiteLight,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: TextWidget(
                            text:
                                "${notification.name} Sent Request for Delivery",
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontColor: AppColors.greyDark2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : const SizedBox(),
        ],
      ),
    );
  }
}
