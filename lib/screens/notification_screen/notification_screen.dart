import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/screens/notification_screen/controller/notification_controller.dart';
import 'package:parcel_delivery_app/services/reuseable/lat_long_to_address.dart';
import 'package:parcel_delivery_app/services/appStroage/location_storage.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
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
  late LocationStorage locationStorage;

  Map<String, String> addressCache = {};
  Map<String, String> locationToAddressCache = {};

  //! Function to fetch and return address from coordinates
  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    // Validate coordinates
    if (latitude.isNaN ||
        longitude.isNaN ||
        latitude.abs() > 90 ||
        longitude.abs() > 180) {
      return 'Invalid Location';
    }

    final String key =
        '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';

    // Check LocationStorage first for persistent cache
    String? storedAddress =
        await locationStorage.getAddressFromCoordinates(latitude, longitude);
    if (storedAddress != null && storedAddress.isNotEmpty) {
      // Also update the in-memory cache for faster subsequent access
      locationToAddressCache[key] = storedAddress;
      return storedAddress;
    }

    // Check in-memory cache second
    if (locationToAddressCache.containsKey(key)) {
      return locationToAddressCache[key]!;
    }

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout'),
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];

        // Use the same extraction logic as services_screen
        final List<String?> addressParts = [
          placemark.locality,
          placemark.subLocality,
          placemark.street,
          placemark.subAdministrativeArea,
          placemark.administrativeArea,
          placemark.country,
        ];

        for (var part in addressParts) {
          if (part != null &&
              part.trim().isNotEmpty &&
              part.toLowerCase() != 'null') {
            final address = part.trim();
            // Store in both caches
            locationToAddressCache[key] = address;
            await locationStorage.saveCoordinateAddress(
                latitude, longitude, address);
            return address;
          }
        }

        const fallback = 'Unknown Location';
        locationToAddressCache[key] = fallback;
        await locationStorage.saveCoordinateAddress(
            latitude, longitude, fallback);
        return fallback;
      } else {
        const genericAddress = 'Location Not Found';
        locationToAddressCache[key] = genericAddress;
        await locationStorage.saveCoordinateAddress(
            latitude, longitude, genericAddress);
        return genericAddress;
      }
    } catch (e) {
      // DON'T cache temporary errors - only cache if it's a permanent issue
      String errorMessage;
      bool shouldCache = false;

      if (e.toString().contains('Timeout') ||
          e.toString().contains('timeout')) {
        errorMessage = 'Location Unavailable'; // Changed from technical message
        shouldCache = false; // Allow retry
      } else if (e.toString().contains('network') ||
          e.toString().contains('internet')) {
        errorMessage = 'No Network';
        shouldCache = false; // Allow retry
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission Required';
        shouldCache = true; // Cache permission errors
      } else {
        errorMessage = 'Location Unavailable';
        shouldCache = true; // Cache unknown errors
      }

      // Only cache permanent errors
      if (shouldCache) {
        locationToAddressCache[key] = errorMessage;
        await locationStorage.saveCoordinateAddress(
            latitude, longitude, errorMessage);
      }

      return errorMessage;
    }
  }

  //! Store address by parcel ID with enhanced error handling
  void cacheAddressForParcel(String parcelId, String addressType,
      double latitude, double longitude) async {
    final cacheKey = '${parcelId}_$addressType';

    // Skip if already successfully loaded (not an error state)
    if (addressCache.containsKey(cacheKey)) {
      final existing = addressCache[cacheKey]!;
      // Only skip if it's not an error that should be retried
      if (!existing.contains('Unavailable') &&
          !existing.contains('No Network') &&
          existing != 'Loading...') {
        return; // Already have a good address
      }
    }

    try {
      String fetchedAddress =
          await getAddressFromCoordinates(latitude, longitude);

      // Store in LocationStorage for persistence across app sessions
      if (fetchedAddress.isNotEmpty &&
          !fetchedAddress.contains('Unavailable') &&
          !fetchedAddress.contains('No Network') &&
          fetchedAddress != 'Loading...') {
        // Create LocationData for persistent storage
        final locationData = LocationData(
          parcelId: parcelId,
          addressType: addressType,
          latitude: latitude,
          longitude: longitude,
          address: fetchedAddress,
          timestamp: DateTime.now(),
        );

        // Store in LocationStorage (preserves addresses from other screens)
        await locationStorage.storeLocationData(locationData);
      }

      if (mounted) {
        setState(() {
          addressCache[cacheKey] = fetchedAddress;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          addressCache[cacheKey] = 'Location Unavailable';
        });
      }
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
    // Check if widget is still mounted before calling setState
    if (mounted) {
      setState(() {
        newBookingAddress = result;
      });
    }
  }

  // final DeliveryScreenController _deliveryController =
  //     Get.put(DeliveryScreenController());

  @override
  void initState() {
    super.initState();
    controller = Get.put(NotificationController());
    locationStorage = LocationStorage.instance;

    // Initialize LocationStorage after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      locationStorage.initialize();
    });

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
    // Clear caches to prevent memory leaks
    addressCache.clear();
    locationToAddressCache.clear();
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

    // Format the phone number (remove any non-digit characters)
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Ensure the number has country code format
    if (!formattedNumber.startsWith('+')) {
      formattedNumber = '+$formattedNumber';
    }

    String numberWithoutPlus = formattedNumber.startsWith('+')
        ? formattedNumber.substring(1)
        : formattedNumber;

    try {
      List<Map<String, String>> whatsappMethods = [
        {
          'url':
              "https://wa.me/$numberWithoutPlus?text=${Uri.encodeComponent(message)}",
          'description': 'WhatsApp universal web link'
        },

        // Native WhatsApp schemes
        {
          'url':
              "whatsapp://send?phone=$numberWithoutPlus&text=${Uri.encodeComponent(message)}",
          'description': 'WhatsApp native scheme'
        },

        // Alternative API link
        {
          'url':
              "https://api.whatsapp.com/send?phone=$numberWithoutPlus&text=${Uri.encodeComponent(message)}",
          'description': 'WhatsApp API link'
        },
      ];

      bool success = false;

      for (var method in whatsappMethods) {
        try {
          final Uri uri = Uri.parse(method['url']!);
          //! log('Trying ${method['description']}: ${method['url']}');

          // Try to launch the URL
          try {
            await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            //! log('✅ Successfully launched via ${method['description']}');
            success = true;
            break;
          } catch (e) {
            //!  log('❌ Failed to launch ${method['description']}: $e');
            continue;
          }
        } catch (e) {
          //! log('❌ Error parsing URL for ${method['description']}: $e');
          continue;
        }
      }

      if (!success) {
        // Final fallback: try to open any WhatsApp app without message
        try {
          final List<String> fallbackSchemes = [
            'whatsapp://',
            'https://wa.me/',
          ];

          for (String scheme in fallbackSchemes) {
            try {
              final Uri fallbackUri = Uri.parse(scheme);
              await launchUrl(fallbackUri,
                  mode: LaunchMode.externalApplication);
              _showErrorSnackBar(
                  'WhatsApp opened. Please manually navigate to contact: $phoneNumber');
              success = true;
              break;
            } catch (e) {
              //! log('Fallback scheme $scheme failed: $e');
              continue;
            }
          }
        } catch (e) {
          //! log('All fallback methods failed: $e');
        }

        if (!success) {
          _showErrorSnackBar(
              'Unable to open WhatsApp. Please ensure WhatsApp is installed and try again.');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error opening WhatsApp: ${e.toString()}');
    }
  }

  //! Enhanced WhatsApp opening with availability check
  Future<void> _openWhatsAppWithCheck(
      String phoneNumber, String message) async {
    if (phoneNumber.isEmpty) {
      _showErrorSnackBar('No phone number available');
      return;
    }

    // Skip availability check and directly try to open WhatsApp
    // This is more reliable as the availability check can be unreliable
    //! log('Attempting to open WhatsApp for number: $phoneNumber');

    // Proceed with opening WhatsApp - let the _openWhatsApp method handle all fallbacks
    await _openWhatsApp(phoneNumber, message);
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
      //! log("Error in _getTimeAgo: $e");
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
                  tabs: [
                    Tab(text: "parcel/deliveryUpdates".tr),
                    Tab(text: "avaiableDeliveries".tr),
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
                        return Center(
                          child: LoadingAnimationWidget.hexagonDots(
                            color: AppColors.black,
                            size: 40,
                          ),
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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: TextWidget(
                                  text: "deliveryUpdates".tr,
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
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: LoadingAnimationWidget.hexagonDots(
                                      color: AppColors.black,
                                      size: 40,
                                    ),
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
                        return Center(
                          child: LoadingAnimationWidget.hexagonDots(
                            color: AppColors.black,
                            size: 40,
                          ),
                        );
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
      //! log("Error in _buildParcelNotificationCard: $e");
      timeAgo = "Unknown time";
    }
    notification.avgRating?.toDouble();
    String price = (notification.price ?? 150).toString();

    //! Location
    final String notificationId = notification.id;
    double? pickupLocationLat = notification.pickupLocation?.latitude;
    double? pickupLocationLong = notification.pickupLocation?.longitude;
    double? deliveryLocationLat = notification.deliveryLocation?.latitude;
    double? deliveryLocationLong = notification.deliveryLocation?.longitude;

    //! Trigger address loading if coordinates are available
    if (pickupLocationLat != null && pickupLocationLong != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          cacheAddressForParcel(
              notificationId, 'pickup', pickupLocationLat, pickupLocationLong);
        }
      });
    }
    if (deliveryLocationLat != null && deliveryLocationLong != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          cacheAddressForParcel(notificationId, 'delivery', deliveryLocationLat,
              deliveryLocationLong);
        }
      });
    }
    //! Get the specific pickup and delivery addresses for this notification
    final pickupAddress = getParcelAddress(notificationId, 'pickup');
    final deliveryAddress = getParcelAddress(notificationId, 'delivery');

    //! Date and Time Formatting with enhanced error handling
    String formattedDate = "Date Not Available";

    if (notification.deliveryStartTime != null &&
        notification.deliveryEndTime != null) {
      try {
        String startTimeStr = notification.deliveryStartTime.toString().trim();
        String endTimeStr = notification.deliveryEndTime.toString().trim();

        // Skip if the values are clearly invalid
        if (startTimeStr.isEmpty ||
            endTimeStr.isEmpty ||
            startTimeStr.toLowerCase() == 'null' ||
            endTimeStr.toLowerCase() == 'null') {
          formattedDate = "Date Not Available";
        } else {
          DateTime? startDate;
          DateTime? endDate;

          // Try multiple date formats in order of preference
          List<DateFormat> formats = [
            DateFormat("yyyy-MM-dd hh:mm a"),
            DateFormat("yyyy-MM-dd HH:mm:ss"),
            DateFormat("yyyy-MM-dd HH:mm"),
            DateFormat("yyyy-MM-dd"),
            DateFormat("dd/MM/yyyy HH:mm"),
            DateFormat("dd/MM/yyyy hh:mm a"),
          ];

          // Try parsing start date
          for (DateFormat format in formats) {
            try {
              startDate = format.parse(startTimeStr);
              break;
            } catch (e) {
              continue;
            }
          }

          // If format parsing fails, try DateTime.parse as fallback
          if (startDate == null) {
            try {
              startDate = DateTime.parse(startTimeStr);
            } catch (e) {
              // Skip this date if parsing completely fails
            }
          }

          // Try parsing end date
          for (DateFormat format in formats) {
            try {
              endDate = format.parse(endTimeStr);
              break;
            } catch (e) {
              continue;
            }
          }

          // If format parsing fails, try DateTime.parse as fallback
          if (endDate == null) {
            try {
              endDate = DateTime.parse(endTimeStr);
            } catch (e) {
              // Skip this date if parsing completely fails
            }
          }

          // Format the dates if both were successfully parsed
          if (startDate != null && endDate != null) {
            formattedDate =
                "${DateFormat('dd.MM').format(startDate)} to ${DateFormat('dd.MM').format(endDate)}";
          } else {
            formattedDate = "Date Not Available";
          }
        }
      } catch (e) {
        log("Error parsing dates: $e");
        formattedDate = "Date Not Available";
      }
    }

    //! Parcel ID
    //String parcelId = notification.parcelId.toString();
    //final bool hasSentRequest = controller.isRequestSent(parcelId);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                    const SizedBox(),
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
                    child: Center(
                      child: TextWidget(
                        text: "checkDeliveriesSectiontoSendRequests".tr,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        fontColor: AppColors.green,
                      ),
                    )),
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
    String name = notification.name ?? "Unknown User";
    String image = notification.image ?? "";
    String avgRating = notification.avgRating?.toString() ?? "No Rating";
    String mobileNumber = notification.mobileNumber ?? "No Phone Number";
    String type = notification.type ?? "";
    String price = (notification.price ?? 0).toString();

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
      //! log("Error parsing createdAt time: $e, value: ${notification.createdAt}");
      timeAgo = "Unknown time";
    }

    final String notificationId = notification.sId ?? 'unknown_id';
    //! Safely handle location coordinates
    double? pickupLocationLat = notification.pickupLocation?.latitude;
    double? pickupLocationLong = notification.pickupLocation?.longitude;
    double? deliveryLocationLat = notification.deliveryLocation?.latitude;
    double? deliveryLocationLong = notification.deliveryLocation?.longitude;

    //! Trigger address loading if coordinates are available
    if (pickupLocationLong != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          cacheAddressForParcel(
              notificationId, 'pickup', pickupLocationLat!, pickupLocationLong);
        }
      });
    }
    if (deliveryLocationLong != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          cacheAddressForParcel(notificationId, 'delivery',
              deliveryLocationLat!, deliveryLocationLong);
        }
      });
    }

    //! Get the specific pickup and delivery addresses for this notification
    final pickupAddress = getParcelAddress(notificationId, 'pickup');
    final deliveryAddress = getParcelAddress(notificationId, 'delivery');

    //! Date and Time Formatting with enhanced error handling
    String formattedDate = "Date Not Available";

    if (notification.deliveryStartTime != null &&
        notification.deliveryEndTime != null) {
      try {
        String startTimeStr = notification.deliveryStartTime.toString().trim();
        String endTimeStr = notification.deliveryEndTime.toString().trim();

        // Skip if the values are clearly invalid
        if (startTimeStr.isEmpty ||
            endTimeStr.isEmpty ||
            startTimeStr.toLowerCase() == 'null' ||
            endTimeStr.toLowerCase() == 'null') {
          formattedDate = "Date Not Available";
        } else {
          DateTime? startDate;
          DateTime? endDate;

          // Try multiple date formats in order of preference
          List<DateFormat> formats = [
            DateFormat("yyyy-MM-dd hh:mm a"),
            DateFormat("yyyy-MM-dd HH:mm:ss"),
            DateFormat("yyyy-MM-dd HH:mm"),
            DateFormat("yyyy-MM-dd"),
            DateFormat("dd/MM/yyyy HH:mm"),
            DateFormat("dd/MM/yyyy hh:mm a"),
          ];

          // Try parsing start date
          for (DateFormat format in formats) {
            try {
              startDate = format.parse(startTimeStr);
              break;
            } catch (e) {
              continue;
            }
          }

          // If format parsing fails, try DateTime.parse as fallback
          if (startDate == null) {
            try {
              startDate = DateTime.parse(startTimeStr);
            } catch (e) {
              // Skip this date if parsing completely fails
            }
          }

          // Try parsing end date
          for (DateFormat format in formats) {
            try {
              endDate = format.parse(endTimeStr);
              break;
            } catch (e) {
              continue;
            }
          }

          // If format parsing fails, try DateTime.parse as fallback
          if (endDate == null) {
            try {
              endDate = DateTime.parse(endTimeStr);
            } catch (e) {
              // Skip this date if parsing completely fails
            }
          }

          // Format the dates if both were successfully parsed
          if (startDate != null && endDate != null) {
            formattedDate =
                "${DateFormat('dd.MM').format(startDate)} to ${DateFormat('dd.MM').format(endDate)}";
          } else {
            formattedDate = "Date Not Available";
          }
        }
      } catch (e) {
        //! log("Error parsing dates: $e");
        formattedDate = "Date Not Available";
      }
    }
    String getProfileImagePath() {
      if (controller.isLoading.value) {
        //! log('⏳ Profile is still loading, returning default image URL');
        return 'https://i.ibb.co/z5YHLV9/profile.png';
      }

      final imageUrl = image;
      //! log('Raw image URL from API: "$imageUrl"');
      //! log('Image URL type: ${imageUrl.runtimeType}');

      // Check for null, empty, or invalid URLs
      if (imageUrl.isEmpty ||
          imageUrl.trim().isEmpty ||
          imageUrl.toLowerCase() == 'null' ||
          imageUrl.toLowerCase() == 'undefined') {
        //! log('❌ Image URL is null/empty/invalid, using default image URL');
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
        //! log('❌ Invalid URL format: $fullImageUrl, using default image URL');
        return 'https://i.ibb.co/z5YHLV9/profile.png';
      }

      //! log('✅ Constructed URL: $fullImageUrl');
      return fullImageUrl;
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
                      child: Image.network(
                        getProfileImagePath(),
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
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
                          //! log('❌ Error loading image: $error');
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
                      text: notification.title ?? "No Title",
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontColor: AppColors.greyDark2,
                    ),
                  ],
                )
              : const SizedBox(),
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
                  text:
                      "${'from'.tr} $pickupAddress ${'cityTo'.tr} $deliveryAddress",
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
          const SpaceWidget(
            spaceHeight: 8,
          ),
          type.toString() == "Requested-Delivery"
              ? const SizedBox()
              : Column(
                  children: [
                    Row(
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
                              text: notification.mobileNumber ??
                                  "No Phone Number",
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
                                    onTap: () => _openWhatsAppWithCheck(
                                        mobileNumber,
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
                    const SpaceWidget(spaceHeight: 8)
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
          type == "Requested-Delivery"
              ? Column(
                  children: [
                    const SpaceWidget(spaceHeight: 8),
                    Center(
                      child: TextWidget(
                        text: "checkNewBookingsToaccepts".tr,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        fontColor: AppColors.green,
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
          const SpaceWidget(spaceHeight: 10),
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
                  child: TextWidget(
                    text: "accepted".tr,
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
                      child: TextWidget(
                        text: "rejected".tr,
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
