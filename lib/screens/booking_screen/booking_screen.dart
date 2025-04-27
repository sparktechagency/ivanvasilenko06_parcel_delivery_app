import 'package:flutter/material.dart';
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
  String address = "Loading...";
  String newBookingAddress = "Loading...";
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

  bool isReceived = false;
  final List<String> images = [
    AppImagePath.sendParcel,
  ];

  final List<String> names = [
    AppStrings.parcel,
    AppStrings.joshua,
    AppStrings.parcel,
  ];

  final List<String> details = [
    "parcelDetails".tr,
    "viewDetails".tr,
    "parcelDetails".tr,
  ];

  final List<String> status = [
    "waiting".tr,
    "",
    "inTransit".tr,
  ];

  final List<String> progress = [
    "removeFromMap".tr,
    "Finish Delivery".tr,
    "deliveryManDetails".tr,
  ];

  final List<String> received = [
    "Delivery received?",
    "Sending Successfully?",
    "Delivery Completed?",
  ];

  List<String> statuses = ["not received", "not delivered", "not completed"];

  // Function to make a phone call
  final String phoneNumber = '+1234567890';

  // Replace with actual phone number
  final String message = 'Hello, this is a test message';

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
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
      path: phoneNumber,
      queryParameters: {'body': message},
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

  // Helper method to show error messages
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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

  // Function to get the address from coordinates with caching
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
            '${placemarks[0].locality}, ${placemarks[0].country}';
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

  Future<void> newAddress(double latitude, double longitude) async {
    final String key = '$latitude,$longitude';
    if (addressCache.containsKey(key)) {
      setState(() {
        newBookingAddress = addressCache[key]!;
      });
      return;
    }
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        String newAddress =
            '${placemarks[0].locality}, ${placemarks[0].country}';
        setState(() {
          newBookingAddress = newAddress;
        });
        addressCache[key] = newAddress; // Cache the address
      } else {
        setState(() {
          newBookingAddress = 'No address found';
        });
      }
    } catch (e) {
      setState(() {
        newBookingAddress = 'Error fetching address';
      });
    }
  }

  String formatDeliveryDate(dynamic deliveryEndTime) {
    if (deliveryEndTime is String) {
      try {
        final parsedDate = DateTime.parse(deliveryEndTime);
        return DateFormat('yyyy-MM-dd , hh:mm').format(parsedDate);
      } catch (e) {
        return "Invalid Date Format";
      }
    } else if (deliveryEndTime is DateTime) {
      return DateFormat('yyyy-MM-dd , hh:mm').format(deliveryEndTime);
    } else {
      return "Unknown Date";
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
                final deliverLocation =
                    data[index].deliveryLocation?.coordinates;
                final date =
                    formatDeliveryDate(data[index].deliveryEndTime ?? "");
                final isUserSender =
                    data[index].senderId == data[index].senderId;

                if (deliverLocation != null &&
                    deliverLocation.length == 2 &&
                    address == "Loading...") {
                  // Schedule the address fetch for after this build cycle completes
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final latitude = deliverLocation[1];
                    final longitude = deliverLocation[0];
                    _getAddress(latitude, longitude);
                  });
                }

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
                                        text: address,
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
                                        text: date,
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
                                        onTap: _sendMessage,
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
                                        onTap: _makePhoneCall,
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
                                      Get.toNamed(
                                          AppRoutes.bookingParcelDetailsScreen,
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
                                    } else {
                                      Get.toNamed(
                                          AppRoutes.cancelDeliveryScreen,
                                          arguments: data[index].id);
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
                                                      : "removeFromMap".tr,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontColor:
                                              data[index].status == "IN_TRANSIT"
                                                  ? AppColors.greyDark2
                                                  : !isUserSender
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
                    text: "noNewBookings".tr,
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
            const SpaceWidget(spaceHeight: 8),
            ...List.generate(parcelsWithRequests.length, (index) {
              final parcel = parcelsWithRequests[index];
              final deliveryRequest = parcel.deliveryRequests!.first;
              String formattedDate = formatDeliveryDate(parcel.deliveryEndTime);
              final deliveryLocation = parcel.deliveryLocation?.coordinates;

              // Track the request state locally using a unique key for the request
              final String requestKey = '${parcel.id}-${deliveryRequest.id}';
              final requestState =
                  newBookingsController.requestStates[requestKey] ?? 'pending';

              if (deliveryLocation != null &&
                  deliveryLocation.length == 2 &&
                  newBookingAddress == "Loading...") {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final longitude = deliveryLocation[0];
                  final latitude = deliveryLocation[1];
                  newAddress(latitude, longitude);
                });
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
                                      url: deliveryRequest.image,
                                      height: 40,
                                      width: 40,
                                    ),
                                  ),
                                  const SpaceWidget(spaceWidth: 8),
                                  TextWidget(
                                    text: deliveryRequest.fullName ?? '',
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
                                  TextWidget(
                                    text: newBookingAddress,
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
                                    Icons.phone,
                                    color: AppColors.black,
                                    size: 12,
                                  ),
                                  const SpaceWidget(spaceWidth: 8),
                                  TextWidget(
                                    text: deliveryRequest.mobileNumber ??
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
                                      deliveryRequest.id ?? '',
                                    );
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
