import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/screens/booking_screen/current_order/controller/current_order_controller.dart';
import 'package:parcel_delivery_app/screens/booking_screen/new_booking/controller/new_bookings_controller.dart';
import 'package:parcel_delivery_app/utils/appLog/app_log.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/api_url.dart';
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

  late final CurrentOrderController currentOrderController;
  late final NewBookingsController newBookingsController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    currentOrderController =
        Get.put(CurrentOrderController(), tag: 'booking_screen');
    newBookingsController = Get.put(NewBookingsController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentOrderController.getCurrentOrder();
    });
  }

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    // Validate coordinates
    if (latitude.isNaN || longitude.isNaN || 
        latitude.abs() > 90 || longitude.abs() > 180) {
      return 'Invalid coordinates';
    }

    final String key = '$latitude,$longitude';
    if (locationToAddressCache.containsKey(key)) {
      return locationToAddressCache[key]!;
    }

    try {
      // Add timeout to prevent hanging
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude, 
        longitude
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Address lookup timeout');
        },
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];

        // Get single address property in priority order: locality > subLocality > street > subAdministrativeArea
        String newAddress;

        if (placemark.locality != null && placemark.locality!.trim().isNotEmpty) {
          newAddress = placemark.locality!.trim();
        } else if (placemark.subLocality != null && placemark.subLocality!.trim().isNotEmpty) {
          newAddress = placemark.subLocality!.trim();
        } else if (placemark.street != null && placemark.street!.trim().isNotEmpty) {
          newAddress = placemark.street!.trim();
        } else if (placemark.subAdministrativeArea != null && placemark.subAdministrativeArea!.trim().isNotEmpty) {
          newAddress = placemark.subAdministrativeArea!.trim();
        } else if (placemark.administrativeArea != null && placemark.administrativeArea!.trim().isNotEmpty) {
          newAddress = placemark.administrativeArea!.trim();
        } else if (placemark.country != null && placemark.country!.trim().isNotEmpty) {
          newAddress = placemark.country!.trim();
        } else {
          // Final fallback with coordinates (formatted nicely)
          newAddress = '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
        }

        locationToAddressCache[key] = newAddress;
        return newAddress;
      } else {
        // Fallback to coordinates if no placemarks found
        final coordinateAddress = '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
        locationToAddressCache[key] = coordinateAddress;
        return coordinateAddress;
      }
    } catch (e) {
      // Enhanced error handling with specific error types
      
      if (e.toString().contains('timeout')) {
        return 'Address lookup timed out';
      } else if (e.toString().contains('network') || e.toString().contains('internet')) {
        return 'Network error - please check your connection';
      } else if (e.toString().contains('permission')) {
        return 'Location permission required';
      } else {
        return 'Error fetching address: $e';
      }
      
      // // Always provide coordinates as final fallback
      // final coordinateAddress = '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
      // locationToAddressCache[key] = coordinateAddress;
      // return coordinateAddress;
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

  void _openBottomSheet() {
    double selectedRating = 1.0;

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
                      initialRating: selectedRating,
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
                        setState(() {
                          selectedRating = rating;
                        });
                        appLog('Rating: $rating');
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
                    onPressed: () async {
                      // Set the rating value in the controller
                      final currentOrderController =
                          Get.find<CurrentOrderController>(tag: 'current');
                      currentOrderController.rating.value = selectedRating;
                      await currentOrderController.givingReview();
                      Navigator.pop(context);
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

    final String formattedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    try {
      //! Use different approaches based on platform
      if (Platform.isAndroid) {
        //! For Android, use Intent.ACTION_DIAL (doesn't require permission)
        final Uri phoneUri = Uri.parse('tel:$formattedNumber');
        await launchUrl(phoneUri,
            mode: LaunchMode.externalNonBrowserApplication);
      } else if (Platform.isIOS) {
        //! For iOS
        final Uri phoneUri = Uri.parse('tel://$formattedNumber');
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          throw 'Could not launch $phoneUri';
        }
      } else {
        //! For other platforms
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

  //! Function to send a message

  Future<void> _openWhatsApp(String phoneNumber, String message) async {
    if (phoneNumber.isEmpty) {
      _showErrorSnackBar('No phone number available');
      return;
    }

    // Format the phone number (remove any non-digit characters)
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Ensure the number has country code (add + if not present)
    if (!formattedNumber.startsWith('+')) {
      formattedNumber = '+$formattedNumber';
    }

    try {
      // Try different WhatsApp URL schemes in order of reliability
      List<String> whatsappUrls = [
        "whatsapp://send?phone=$formattedNumber&text=${Uri.encodeComponent(message)}",
        "https://wa.me/$formattedNumber?text=${Uri.encodeComponent(message)}",
        "https://api.whatsapp.com/send?phone=$formattedNumber&text=${Uri.encodeComponent(message)}"
      ];

      for (String urlString in whatsappUrls) {
        try {
          final Uri uri = Uri.parse(urlString);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return;
          }
        } catch (e) {
          log('Failed to launch $urlString: $e');
          continue;
        }
      }

      // If all methods fail, show error
      log('Could not find any working WhatsApp method');
      _showErrorSnackBar('WhatsApp not installed or unable to open');
    } catch (e) {
      log('Error opening WhatsApp: $e');
      _showErrorSnackBar('Error opening WhatsApp: ${e.toString()}');
    }
  }

  //! Helper method to show error messages
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

  // Helper method to check if review already exists for a parcel
  bool hasAlreadyReviewed(String parcelId, dynamic parcel) {
    if (parcel.assignedDelivererId?.reviews == null) return false;
    return parcel.assignedDelivererId!.reviews!
        .any((review) => review.parcelId == parcelId);
  }

  void deliveryFinished(String parcelId, String status) {
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
                      onPressed: () async {
                        try {
                          final currentOrderController =
                              Get.find<CurrentOrderController>(tag: 'current');
                          // Set the parcel ID to finish
                          currentOrderController.finishedParcelId.value =
                              parcelId;
                          currentOrderController.parcelStatus.value = status;
                          // Call the finishedDelivery method
                          currentOrderController.finishedDelivery();
                          await currentOrderController.getCurrentOrder();
                          _currentIndex = 0;
                          currentOrderController.update();
                          _pageController.jumpToPage(0);
                          Navigator.pop(context);
                        } catch (e) {
                          Get.back();
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

  void removeParcelConfirmation(String parcelId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Dialog(
            shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(10)), // Flat corners
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
                          Navigator.pop(context);
                          try {
                            //! Get the correct controller instance
                            final controller =
                                Get.find<NewBookingsController>();
                            await controller.removeParcelFromMap(parcelId);
                            await currentOrderController.getCurrentOrder();
                            _currentIndex = 0;
                            controller.update();
                            _pageController.jumpToPage(0);

                            Get.back();
                          } catch (e) {
                            // Close loading dialog
                            Get.back();
                            // Get.snackbar(
                            //   'Error',
                            //   'Failed to remove parcel: ${e.toString()}',
                            //   snackPosition: SnackPosition.BOTTOM,
                            // );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
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

          //! <This one is tab bar  ===================>
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    Stack(
                      children: [
                        _buildTabItem("newBookings".tr, 1),

                        // Badge for new bookings
                        Obx(() {
                          final newBookingsController =
                              Get.find<NewBookingsController>();
                          final allParcels = currentOrderController
                              .currentOrdersModel.value.data;
                          final parcelsWithRequests = allParcels
                                  ?.where((parcel) =>
                                      parcel.typeParcel == "sendParcel" &&
                                      parcel.deliveryRequests != null &&
                                      parcel.deliveryRequests!.isNotEmpty)
                                  .toList() ??
                              [];
                          // Show badge if there are new bookings and user hasn't visited the tab
                          if (parcelsWithRequests.isNotEmpty &&
                              !newBookingsController
                                  .hasVisitedNewBookings.value) {
                            return Positioned(
                              right: -0.01,
                              top: -0.01,
                              child: Container(
                                width: 08,
                                height: 08,
                                decoration: const BoxDecoration(
                                  color: AppColors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
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
                // Mark new bookings as visited when user swipes to tab 1
                if (index == 1) {
                  newBookingsController.markNewBookingsAsVisited();
                }
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
        _pageController.jumpToPage(index);

        // Mark new bookings as visited when user switches to tab 1
        if (index == 1) {
          newBookingsController.markNewBookingsAsVisited();
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: TextWidget(
          text: label,
          fontColor: _currentIndex == index
              ? AppColors.black
              : AppColors.greyDarkLight,
          fontSize: 14,
          fontWeight:
              _currentIndex == index ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _currentOrderWidget() {
    return Obx(() {
      final data = currentOrderController.currentOrdersModel.value.data;
      if (data == null || data.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ImageWidget(
                  imagePath: AppImagePath.sendParcel,
                  width: 50,
                  height: 50,
                ),
                const SpaceWidget(spaceHeight: 16),
                TextWidget(
                  text: "No current orders available".tr,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.greyDark2,
                ),
              ],
            ),
          ),
        );
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

                //! Get the delivery and pickup addresses for this specific parcel
                final deliveryAddress = getParcelAddress(parcelId, 'delivery');
                final pickupAddress = getParcelAddress(parcelId, 'pickup');

                //! Date Formateed
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
                //!
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
                                  if (data[index].status != "REQUESTED" &&
                                      data[index].status != "PENDING" &&
                                      data[index].status != "WAITING")
                                    Column(
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
                                              text:
                                                  data[index].phoneNumber ?? "",
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              fontColor: AppColors.greyDark2,
                                            ),
                                          ],
                                        ),
                                        const SpaceWidget(spaceHeight: 8),
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

                                  // Only show status for sendParcel type
                                  if (data[index].typeParcel.toString() ==
                                      "sendParcel") ...[
                                    TextWidget(
                                      text: data[index].status == "PENDING" ||
                                              data[index].status ==
                                                  "REQUESTED" ||
                                              data[index].status == "WAITING"
                                          ? "Waiting"
                                          : data[index].status == "IN_TRANSIT"
                                              ? "In Transit"
                                              : data[index].status ==
                                                      "DELIVERED"
                                                  ? "Delivered"
                                                  : "",
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      fontColor: data[index].status ==
                                                  "PENDING" ||
                                              data[index].status ==
                                                  "REQUESTED" ||
                                              data[index].status == "WAITING"
                                          ? AppColors.red
                                          : data[index].status == "IN_TRANSIT"
                                              ? AppColors.green
                                              : data[index].status ==
                                                      "DELIVERED"
                                                  ? AppColors.green
                                                  : AppColors.black,
                                    ),
                                  ],
                                  const SpaceWidget(spaceHeight: 12),
                                  // Show contact buttons for both sendParcel and deliveryRequest if in transit
                                  if ((data[index].typeParcel.toString() ==
                                              "sendParcel" &&
                                          data[index].status == "IN_TRANSIT") ||
                                      (data[index].typeParcel.toString() ==
                                              "deliveryRequest" &&
                                          data[index].status == "IN_TRANSIT") ||
                                      (data[index].typeParcel.toString() ==
                                              "assignedParcel" &&
                                          data[index].status ==
                                              "IN_TRANSIT")) ...[
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            String phoneNumber = "";
                                            if (data[index]
                                                    .typeParcel
                                                    .toString() ==
                                                "deliveryRequest") {
                                              // For deliveryRequest type
                                              if (data[index].status ==
                                                  "IN_TRANSIT") {
                                                phoneNumber = data[index]
                                                        .senderId
                                                        ?.mobileNumber
                                                        .toString() ??
                                                    "";
                                              }
                                            } else if (data[index]
                                                    .typeParcel
                                                    .toString() ==
                                                "assignedParcel") {
                                              // For finished Delivery
                                              if (data[index].status ==
                                                  "IN_TRANSIT") {
                                                phoneNumber = data[index]
                                                        .senderId
                                                        ?.mobileNumber
                                                        .toString() ??
                                                    "";
                                              }
                                            } else {
                                              // For sendParcel type
                                              if (data[index].status ==
                                                  "IN_TRANSIT") {
                                                phoneNumber = data[index]
                                                        .assignedDelivererId
                                                        ?.mobileNumber
                                                        .toString() ??
                                                    "";
                                              }
                                            }
                                            _openWhatsApp(phoneNumber,
                                                "Hello, regarding your parcel delivery.");
                                          },
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: const CircleAvatar(
                                            backgroundColor:
                                                AppColors.whiteDark,
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
                                          onTap: () {
                                            String phoneNumber = "";
                                            if (data[index]
                                                    .typeParcel
                                                    .toString() ==
                                                "deliveryRequest") {
                                              // For deliveryRequest type
                                              if (data[index].status ==
                                                  "IN_TRANSIT") {
                                                phoneNumber = data[index]
                                                        .senderId
                                                        ?.mobileNumber
                                                        .toString() ??
                                                    "";
                                              }
                                            } else if (data[index]
                                                    .typeParcel
                                                    .toString() ==
                                                "assignedParcel") {
                                              // For finished Delivery
                                              if (data[index].status ==
                                                  "IN_TRANSIT") {
                                                phoneNumber = data[index]
                                                        .senderId
                                                        ?.mobileNumber
                                                        .toString() ??
                                                    "";
                                              }
                                            } else {
                                              // For sendParcel type
                                              if (data[index].status ==
                                                  "IN_TRANSIT") {
                                                phoneNumber = data[index]
                                                        .assignedDelivererId
                                                        ?.mobileNumber
                                                        .toString() ??
                                                    "";
                                              }
                                            }
                                            _makePhoneCall(phoneNumber);
                                          },
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: const CircleAvatar(
                                            backgroundColor:
                                                AppColors.whiteDark,
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
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    // Navigate to appropriate screen based on type
                                    if (data[index].typeParcel.toString() ==
                                        "deliveryRequest") {
                                      Get.toNamed(AppRoutes.viewDetailsScreen,
                                          arguments: data[index].id);
                                    } else {
                                      Get.toNamed(AppRoutes.parcelDetailsScreen,
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
                                        text:
                                            data[index].typeParcel.toString() ==
                                                    "deliveryRequest"
                                                ? "viewDetails".tr
                                                : "parcelDetails".tr,
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
                                    // Handle actions based on parcel type and status
                                    if (data[index].typeParcel.toString() ==
                                        "deliveryRequest") {
                                      if (data[index].status == "IN_TRANSIT") {
                                        String parcelId = data[index].id ?? "";
                                        // Always set status to DELIVERED when finishing
                                        deliveryFinished(parcelId, "DELIVERED");
                                      } else if (data[index].status ==
                                              "REQUESTED" ||
                                          data[index].status == "PENDING" ||
                                          data[index].status == "WAITING") {
                                        String parcelId = data[index].id ?? "";
                                        removeParcelConfirmation(parcelId);
                                        // Cancel Delivery
                                      }
                                    } else if (data[index]
                                            .typeParcel
                                            .toString() ==
                                        "assignedParcel") {
                                      if (data[index].status == "IN_TRANSIT") {
                                        String parcelId = data[index].id ?? "";
                                        deliveryFinished(parcelId, "DELIVERED");
                                      }
                                    } else {
                                      // For sendParcel type
                                      if (data[index].status == "IN_TRANSIT") {
                                        Get.toNamed(
                                            AppRoutes.deliveryManDetails,
                                            arguments: data[index].id);
                                      } else if (data[index].status ==
                                          "DELIVERED") {
                                        // Check if review already exists
                                        if (hasAlreadyReviewed(
                                            data[index].id ?? "",
                                            data[index])) {
                                          _showErrorSnackBar(
                                              "You have already reviewed this delivery");
                                        } else {
                                          final currentOrderController =
                                              Get.find<CurrentOrderController>(
                                                  tag: 'current');
                                          // Set parcel ID and user ID for review
                                          currentOrderController.parcelID
                                              .value = data[index].id ?? "";
                                          currentOrderController.userID.value =
                                              data[index]
                                                      .assignedDelivererId
                                                      ?.id ??
                                                  "";
                                          _openBottomSheet();
                                        }
                                      } else {
                                        // Remove from map option
                                        String parcelId = data[index].id ?? "";
                                        removeParcelConfirmation(parcelId);
                                      }
                                    }
                                  },
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Row(
                                    children: [
                                      if (data[index].typeParcel.toString() ==
                                              "sendParcel" &&
                                          data[index].status == "IN_TRANSIT")
                                        const IconWidget(
                                          icon: AppIconsPath.deliverymanIcon,
                                          color: AppColors.greyDark2,
                                          width: 14,
                                          height: 14,
                                        ),
                                      if (data[index].typeParcel.toString() ==
                                              "sendParcel" &&
                                          data[index].status == "IN_TRANSIT")
                                        const SpaceWidget(spaceWidth: 8)
                                      else
                                        const SpaceWidget(spaceWidth: 0),
                                      SizedBox(
                                        width: ResponsiveUtils.width(120),
                                        child: TextWidget(
                                          text:
                                              data[index].status == "DELIVERED"
                                                  ? "rateDriver".tr
                                                  : _getActionButtonText(
                                                      data[index]),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontColor:
                                              data[index].status == "DELIVERED"
                                                  ? AppColors.greyDark2
                                                  : _getActionButtonColor(
                                                      data[index]),
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

  // Helper method to determine the action button text based on parcel type and status
  String _getActionButtonText(dynamic parcel) {
    if (parcel.typeParcel.toString() == "deliveryRequest") {
      // For deliveryRequest type
      if (parcel.status == "IN_TRANSIT") {
        return "Finish Delivery".tr;
      } else if (parcel.status == "REQUESTED" ||
          parcel.status == "PENDING" ||
          parcel.status == "WAITING") {
        return "cancelRequest".tr;
      }
    } else if (parcel.typeParcel.toString() == "assignedParcel") {
      // For finished Delivery
      if (parcel.status == "IN_TRANSIT") {
        return "Finish Delivery".tr;
      }
    } else {
      // For sendParcel type
      if (parcel.status == "IN_TRANSIT") {
        return "deliveryManDetails".tr;
      } else if (parcel.status == "DELIVERED") {
        // Check if review already exists
        if (hasAlreadyReviewed(parcel.id ?? "", parcel)) {
          return "Review Given".tr;
        } else {
          return "Giving Review".tr;
        }
      } else {
        return "removeFromMap".tr;
      }
    }
    return ""; // Default fallback
  }

  // Helper method to determine the action button color based on parcel type and status
  Color _getActionButtonColor(dynamic parcel) {
    if (parcel.typeParcel.toString() == "deliveryRequest") {
      // For deliveryRequest type
      if (parcel.status == "IN_TRANSIT") {
        return AppColors.green; // Green for finish delivery
      } else if (parcel.status == "REQUESTED" ||
          parcel.status == "PENDING" ||
          parcel.status == "WAITING") {
        return AppColors.red; // Red for cancel delivery
      }
    } else if (parcel.typeParcel.toString() == "assignedParcel") {
      // For finished Delivery
      if (parcel.status == "IN_TRANSIT") {
        return AppColors.green;
      }
    } else {
      // For sendParcel type
      if (parcel.status == "IN_TRANSIT") {
        return AppColors.greyDark2;
      } else if (parcel.status == "DELIVERED") {
        // Check if review already exists
        if (hasAlreadyReviewed(parcel.id ?? "", parcel)) {
          return AppColors.greyDark2; // Grey for already reviewed
        } else {
          return AppColors.green; // Green for giving review
        }
      } else {
        return AppColors.red;
      }
    }
    return AppColors.black; // Default fallback
  }

  Widget _newBookingWidget() {
    return SingleChildScrollView(
      child: Obx(() {
        final newBookingsController = Get.find<NewBookingsController>();
        if (currentOrderController.currentOrdersModel.value.data == null) {
          // Only call getCurrentOrder if not already loading
          if (!currentOrderController.isLoading.value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              currentOrderController.getCurrentOrder();
            });
          }
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.black,
                size: 40,
              ),
            ),
          );
        }
        final allParcels = currentOrderController.currentOrdersModel.value.data;
        // Filter only parcels that have deliveryRequests
        final parcelsWithRequests = allParcels
                ?.where((parcel) =>
                    parcel.typeParcel == "sendParcel" &&
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
                    fontSize: 14,
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
              final deliveryRequest = parcel.deliveryRequests!.first;
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
                  '${parcel.id}-${deliveryRequest.id ?? ""}';
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

              String getProfileImagePath() {
                if (currentOrderController.isLoading.value) {
                  log('⏳ Profile is still loading, returning default image URL');
                  return 'https://i.ibb.co/z5YHLV9/profile.png';
                }

                final imageUrl = deliveryRequest.image!;
                log('Raw image URL from API: "$imageUrl"');
                log('Image URL type: ${imageUrl.runtimeType}');

                // Check for null, empty, or invalid URLs
                if (imageUrl.isEmpty ||
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                getProfileImagePath(),
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'https://i.ibb.co/z5YHLV9/profile.png',
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.cover,
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Center(
                                      child: LoadingAnimationWidget.hexagonDots(
                                        color: AppColors.black,
                                        size: 20,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // AppImage(
                              //   url: (newBookingsController.isLoading.value ||
                              //           deliveryRequest.image == null ||
                              //           deliveryRequest.image
                              //               .toString()
                              //               .isEmpty)
                              //       ? AppImagePath.dummyProfileImage
                              //       : deliveryRequest.image!,
                              //   height: 40,
                              //   width: 40,
                              // ),
                            ),
                            const SpaceWidget(spaceWidth: 8),
                            SizedBox(
                              width:
                                  (deliveryRequest.fullName?.length ?? 0) <= 12
                                      ? ResponsiveUtils.width(60)
                                      : ResponsiveUtils.width(180),
                              child: TextWidget(
                                text: deliveryRequest.fullName ?? '',
                                fontSize: 15.5,
                                fontWeight: FontWeight.w500,
                                fontColor: AppColors.black,
                                overflow: TextOverflow.ellipsis,
                                textAlignment: TextAlign.start,
                                maxLines: 1,
                              ),
                            ),
                            const SpaceWidget(spaceWidth: 5),
                            if ((deliveryRequest.reviews?.isNotEmpty == true &&
                                deliveryRequest.reviews!
                                            .map((r) => r.rating ?? 0)
                                            .reduce((a, b) => a + b) /
                                        deliveryRequest.reviews!.length >
                                    0.0))
                              Container(
                                width: ResponsiveUtils.width(55),
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
                                    const SpaceWidget(spaceWidth: 4),
                                    TextWidget(
                                      text: (deliveryRequest.reviews!
                                                  .map((r) => r.rating ?? 0)
                                                  .reduce((a, b) => a + b) /
                                              deliveryRequest.reviews!.length)
                                          .toStringAsFixed(1),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      fontColor: AppColors.white,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SpaceWidget(spaceHeight: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                            TextWidget(
                              text: "${AppStrings.currency} ${parcel.price}",
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
                            Flexible(
                              child: TextWidget(
                                text: "$pickupAddress to $deliveryAddress",
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
                              text: allParcels?.first.deliveryType == 'bike'
                                  ? 'Bike'
                                  : allParcels?.first.deliveryType == 'bicycle'
                                      ? 'Bicycle'
                                      : allParcels?.first.deliveryType == 'car'
                                          ? 'Car'
                                          : allParcels?.first.deliveryType ==
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
                                                          : allParcels?.first
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
                                      deliveryRequest.id ?? '',
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
                                      deliveryRequest.id ?? '',
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