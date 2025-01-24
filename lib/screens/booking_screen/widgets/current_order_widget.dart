import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final List<String> images = [
    AppImagePath.sendParcel,
    AppImagePath.profileImage,
    AppImagePath.sendParcel,
  ];

  final List<String> names = [
    AppStrings.parcel,
    AppStrings.joshua,
    AppStrings.parcel,
  ];

  final List<String> details = [
    AppStrings.parcelDetails,
    AppStrings.viewDetails,
    AppStrings.parcelDetails,
  ];

  final List<String> status = [
    AppStrings.waiting,
    "",
    AppStrings.inTransit,
  ];

  final List<String> progress = [
    AppStrings.removeFromMap,
    AppStrings.cancelDelivery,
    AppStrings.deliveryManDetails,
  ];

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          const SpaceWidget(spaceHeight: 8),
          ...List.generate(images.length, (index) {
            return Card(
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              elevation: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                                TextWidget(
                                  text: names[index],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontColor: AppColors.black,
                                ),
                                names[index] == AppStrings.joshua
                                    ? const SpaceWidget(spaceWidth: 8)
                                    : const SizedBox.shrink(),
                                names[index] == AppStrings.joshua
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.yellow,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.star_rounded,
                                              color: AppColors.white,
                                              size: 10,
                                            ),
                                            TextWidget(
                                              text: AppStrings.ratings,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              fontColor: AppColors.white,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
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
                                  fontStyle: FontStyle.italic,
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
                                  fontStyle: FontStyle.italic,
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
                                  fontStyle: FontStyle.italic,
                                ),
                              ],
                            ),
                            const SpaceWidget(spaceHeight: 16),
                          ],
                        ),
                        Column(
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
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontColor: status[index] == AppStrings.inTransit
                                  ? AppColors.green
                                  : AppColors.red,
                              fontStyle: FontStyle.italic,
                            ),
                            const SpaceWidget(spaceHeight: 8),
                            Row(
                              children: [
                                InkWell(
                                  onTap: _sendMessage,
                                  borderRadius: BorderRadius.circular(100),
                                  child: const CircleAvatar(
                                    backgroundColor: AppColors.whiteDark,
                                    radius: 20,
                                    child: Icon(
                                      Icons.message,
                                      color: AppColors.black,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SpaceWidget(spaceWidth: 8),
                                InkWell(
                                  onTap: _makePhoneCall,
                                  borderRadius: BorderRadius.circular(100),
                                  child: const CircleAvatar(
                                    backgroundColor: AppColors.whiteDark,
                                    radius: 20,
                                    child: Icon(
                                      Icons.call,
                                      color: AppColors.black,
                                      size: 20,
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
                                Get.toNamed(
                                    AppRoutes.bookingParcelDetailsScreen);
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
                                  size: 14,
                                ),
                                const SpaceWidget(spaceWidth: 8),
                                TextWidget(
                                  text: details[index],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: AppColors.greyDark2,
                                  fontStyle: FontStyle.italic,
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Row(
                              children: [
                                progress[index] == AppStrings.deliveryManDetails
                                    ? const IconWidget(
                                        icon: AppIconsPath.profileIcon,
                                        color: AppColors.greyDark2,
                                        width: 12,
                                        height: 12,
                                      )
                                    : const SizedBox.shrink(),
                                progress[index] == AppStrings.deliveryManDetails
                                    ? const SpaceWidget(spaceWidth: 8)
                                    : const SpaceWidget(spaceWidth: 0),
                                TextWidget(
                                  text: progress[index],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: progress[index] ==
                                          AppStrings.deliveryManDetails
                                      ? AppColors.greyDark2
                                      : AppColors.red,
                                  fontStyle: FontStyle.italic,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SpaceWidget(spaceHeight: 80),
        ],
      ),
    );
  }
}
