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
  late final CurrentOrderController controller;

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
    parcelId = Get.arguments ?? '';

    // Simplified controller initialization
    controller = Get.find<CurrentOrderController>();

    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Ensure we have current order data
      if (controller.currentOrdersModel.value.data == null ||
          controller.currentOrdersModel.value.data!.isEmpty) {
        await controller.getCurrentOrder();
      }

      // Now find the current parcel
      _findCurrentParcel();
    } catch (e) {
      // Handle initialization errors
      if (mounted) {
        _showErrorSnackBar('Error loading delivery details: $e');
      }
    }
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

  // Function to send a WhatsApp message
  Future<void> _sendMessage() async {
    if (deliveryMan?.mobileNumber == null || deliveryMan.mobileNumber.isEmpty) {
      _showErrorSnackBar('No phone number available');
      return;
    }

    // Format the phone number (remove any non-digit characters)
    String formattedNumber =
        deliveryMan.mobileNumber.replaceAll(RegExp(r'\D'), '');

    // Ensure the number has country code format
    if (!formattedNumber.startsWith('+')) {
      formattedNumber = '+$formattedNumber';
    }

    // Remove + for certain URL schemes that don't need it
    String numberWithoutPlus = formattedNumber.startsWith('+')
        ? formattedNumber.substring(1)
        : formattedNumber;

    String message = "Hello, regarding your parcel delivery.";

    try {
      // Simplified approach - try the most reliable methods first
      List<Map<String, String>> whatsappMethods = [
        // Universal web link (works for all WhatsApp variants)
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
            //! log('❌ Failed to launch ${method['description']}: $e');
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
                  'WhatsApp opened. Please manually navigate to contact: ${deliveryMan.mobileNumber}');
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
          // If WhatsApp still fails, fallback to SMS
          try {
            final Uri smsUri = Uri(
                scheme: 'sms',
                path: deliveryMan.mobileNumber,
                queryParameters: {'body': message});

            if (await canLaunchUrl(smsUri)) {
              await launchUrl(smsUri);
            } else {
              _showErrorSnackBar('Could not launch messaging app');
            }
          } catch (e) {
            _showErrorSnackBar(
                'Unable to open WhatsApp or SMS. Please ensure WhatsApp is installed and try again.');
          }
        }
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
      //! log('An error occurred: $e');
    }
  }

  void _findCurrentParcel() {
    if (controller.currentOrdersModel.value.data != null) {
      for (var parcel in controller.currentOrdersModel.value.data!) {
        if (parcel.id == parcelId) {
          setState(() {
            currentParcel = parcel;
            deliveryMan = parcel.assignedDelivererId;
          });

          // Make sure to call both functions to get addresses
          findAddressFromCoordinates();
          findPickUpAddressFromCoordinates();
          break;
        }
      }
    }

    // If parcel not found, try refreshing the data
    if (currentParcel == null) {
      controller.getCurrentOrder().then((_) {
        if (mounted) {
          _findCurrentParcel();
        }
      });
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
      //! log("Error fetching delivery address: $e");
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
      //! log("Error fetching pickup address: $e");
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

        //! log("Delivery coordinates: Lat $latitude, Long $longitude");
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
      //! log("Error in delivery coordinates: $e");
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

        //! log("Pickup coordinates: Lat $latitude, Long $longitude");
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
      //! log("Error in pickup coordinates: $e");
    }
  }

  String _getFormattedDeliveryTime(currentParcel) {
    //! log("deliveryStartTime: ${currentParcel?.deliveryStartTime}");
    //! log("deliveryEndTime: ${currentParcel?.deliveryEndTime}");
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
      //! log("Error in _getFormattedDeliveryTime: $e");
      return "N/A";
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
      //! log("Error calculating average rating: $e");
      return "0.0";
    }
  }

//! Showing Image in App
  String _getProfileImagePath() {
    if (controller.isLoading.value) {
      //! log('⏳ Profile is still loading, returning default image URL');
      return 'https://i.ibb.co/z5YHLV9/profile.png';
    }

    final imageUrl = deliveryMan.image;
    //! log('Raw image URL from API: "$imageUrl"');
    //! log('Image URL type: ${imageUrl.runtimeType}');

    // Check for null, empty, or invalid URLs
    if (imageUrl == null ||
        imageUrl.isEmpty ||
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
      //!  log('❌ Invalid URL format: $fullImageUrl, using default image URL');
      return 'https://i.ibb.co/z5YHLV9/profile.png';
    }

    //! log('✅ Constructed URL: $fullImageUrl');
    return fullImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    // Replace the return statement in your build method with this:

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Obx(() {
          // Enhanced loading and error states
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.hexagonDots(
                    color: AppColors.black,
                    size: 40,
                  ),
                  const SpaceWidget(spaceHeight: 16),
                  const TextWidget(
                    text: "Loading delivery details...",
                    fontSize: 16,
                    fontColor: AppColors.greyDark,
                  ),
                ],
              ),
            );
          }

          if (currentParcel == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.greyDark,
                  ),
                  const SpaceWidget(spaceHeight: 16),
                  const TextWidget(
                    text: "Parcel not found",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontColor: AppColors.black,
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const TextWidget(
                    text: "Unable to load delivery details",
                    fontSize: 14,
                    fontColor: AppColors.greyDark,
                  ),
                  const SpaceWidget(spaceHeight: 24),
                  ButtonWidget(
                    onPressed: () {
                      _initializeData();
                    },
                    label: "Retry",
                    buttonWidth: 120,
                    buttonHeight: 40,
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SpaceWidget(spaceHeight: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextWidget(
                  text: "deliveryManDetails".tr,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontColor: AppColors.black,
                ),
              ),
              const SpaceWidget(spaceHeight: 24),
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
                          if (deliveryMan?.reviews != null &&
                              deliveryMan!.reviews!.isNotEmpty)
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
                        label: "parcelName".tr,
                        value: currentParcel?.title ?? "Parcel",
                      ),
                      const SpaceWidget(spaceHeight: 8),
                      SummaryInfoRowWidget(
                        icon: AppIconsPath.ratingIcon,
                        label: "ratingsText".tr,
                        value: deliveryMan?.reviews != null &&
                                deliveryMan!.reviews!.isNotEmpty
                            ? _calculateAverageRating(deliveryMan)
                            : "N/A",
                      ),
                      const SpaceWidget(spaceHeight: 8),
                      SummaryInfoRowWidget(
                        icon: AppIconsPath.callIcon,
                        label: "phoneNumber".tr,
                        value: deliveryMan?.mobileNumber ?? "N/A",
                      ),
                      const SpaceWidget(spaceHeight: 8),
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
          );
        }),
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
                      if (deliveryMan?.id == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Delivery man information not available'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      newBookingsController.isCancellingDelivery.value = true;
                      try {
                        await newBookingsController.cancelDelivery(
                            parcelId, deliveryMan!.id!);

                        await controller.getCurrentOrder();
                        controller.update();
                        Get.back();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('deliveryCancelledSuccessfully'.tr),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (error) {
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
