import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_icons_path.dart';
import '../../../constants/app_image_path.dart';
import '../../../constants/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/icon_widget/icon_widget.dart';
import '../../../widgets/image_widget/image_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class CurrentOrderWidget extends StatefulWidget {
  const CurrentOrderWidget({super.key});

  @override
  State<CurrentOrderWidget> createState() => _CurrentOrderWidgetState();
}

class _CurrentOrderWidgetState extends State<CurrentOrderWidget> {
  bool isReceived = false;
  final List<String> images = [
    AppImagePath.sendParcel,
    AppImagePath.joshuaImage,
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          const SpaceWidget(spaceHeight: 8),
          ...List.generate(images.length, (index) {
            String currentStatus = statuses[index];
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(left: 8, right: 8, bottom: 0),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: ImageWidget(
                                  height: 40,
                                  width: 40,
                                  imagePath: images[index],
                                ),
                              ),
                              const SpaceWidget(spaceWidth: 8),
                              const TextWidget(
                                text: "Parcel",
                                fontSize: 15.5,
                                fontWeight: FontWeight.w500,
                                fontColor: AppColors.black,
                              ),
                            ],
                          ),
                          const SpaceWidget(spaceHeight: 8),
                          const Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: AppColors.black,
                                size: 12,
                              ),
                              SpaceWidget(spaceWidth: 8),
                              TextWidget(
                                text: 'Western Wall to 4 lebri street',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontColor: AppColors.greyDark2,
                              ),
                            ],
                          ),
                          const SpaceWidget(spaceHeight: 8),
                          const Row(
                            children: [
                              Icon(
                                Icons.call,
                                color: AppColors.black,
                                size: 12,
                              ),
                              SpaceWidget(spaceWidth: 8),
                              TextWidget(
                                text: '+375 292316347',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontColor: AppColors.greyDark2,
                              ),
                            ],
                          ),
                          const SpaceWidget(spaceHeight: 8),
                          const Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                color: AppColors.black,
                                size: 12,
                              ),
                              SpaceWidget(spaceWidth: 8),
                              TextWidget(
                                text: '24-04-2024',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontColor: AppColors.greyDark2,
                              ),
                            ],
                          ),
                          const SpaceWidget(spaceHeight: 16),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const TextWidget(
                            text: "${AppStrings.currency} 150",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontColor: AppColors.black,
                          ),
                          const SpaceWidget(spaceHeight: 20),
                          TextWidget(
                            text: status[index],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontColor: status[index] == AppStrings.inTransit
                                ? AppColors.green
                                : AppColors.red,
                          ),
                          const SpaceWidget(spaceHeight: 12),
                          Row(
                            children: [
                              InkWell(
                                onTap: _sendMessage,
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
                                onTap: _makePhoneCall,
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
                            if (details[index] == AppStrings.parcelDetails) {
                              Get.toNamed(AppRoutes.bookingParcelDetailsScreen);
                            } else {
                              Get.toNamed(AppRoutes.bookingViewDetailsScreen);
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
                                text: details[index],
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
                            // You might want to handle different navigation based on the text
                            if (progress[index] == "Finish Delivery".tr) {
                              // Handle finish delivery action
                              // You might want to do something different than navigating to cancel screen
                              deliveryFinished();
                            } else {
                              Get.toNamed(AppRoutes.cancelDeliveryScreen);
                            }
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Row(
                            children: [
                              progress[index] == AppStrings.deliveryManDetails
                                  ? const IconWidget(
                                      icon: AppIconsPath.deliverymanIcon,
                                      color: AppColors.greyDark2,
                                      width: 14,
                                      height: 14,
                                    )
                                  : const SizedBox.shrink(),
                              progress[index] == AppStrings.deliveryManDetails
                                  ? const SpaceWidget(spaceWidth: 8)
                                  : const SpaceWidget(spaceWidth: 0),
                              SizedBox(
                                width: ResponsiveUtils.width(120),
                                child: TextWidget(
                                  text: progress[index],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: progress[index] ==
                                          AppStrings.deliveryManDetails
                                      ? AppColors.greyDark2
                                      : progress[index] == "Finish Delivery".tr
                                          ? AppColors
                                              .green // Set green color for "Finish Delivery"
                                          : AppColors.red,
                                  // Keep red for other buttons like "Remove from Map"
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
            );
            // );
          }),
          const SpaceWidget(spaceHeight: 80),
        ],
      ),
    );
  }
}
