import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_image_path.dart';
import '../../../constants/app_strings.dart';
import '../../../widgets/image_widget/image_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class NewBookingWidget extends StatefulWidget {
  const NewBookingWidget({super.key});

  @override
  State<NewBookingWidget> createState() => _NewBookingWidgetState();
}

class _NewBookingWidgetState extends State<NewBookingWidget> {
  final List<String> images = [
    AppImagePath.profileImage,
    AppImagePath.profileImage,
    AppImagePath.profileImage,
  ];

  final List<String> names = [
    AppStrings.joshua,
    AppStrings.joshua,
    AppStrings.joshua,
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
                                const TextWidget(
                                  text: 'Parcel 1',
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
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextWidget(
                              text: "${AppStrings.currency} 150",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontColor: AppColors.black,
                            ),
                            SpaceWidget(spaceHeight: 50),
                            TextWidget(
                              text: 'Recently Published',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontColor: AppColors.greyDark2,
                              fontStyle: FontStyle.italic,
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
                            onTap: () {},
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.close,
                                  color: AppColors.red,
                                  size: 16,
                                ),
                                SpaceWidget(spaceWidth: 4),
                                TextWidget(
                                  text: AppStrings.reject,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: AppColors.red,
                                  fontStyle: FontStyle.italic,
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.remove_red_eye_outlined,
                                  color: AppColors.black,
                                  size: 14,
                                ),
                                SpaceWidget(spaceWidth: 4),
                                TextWidget(
                                  text: AppStrings.view,
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
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.check,
                                  color: AppColors.green,
                                  size: 14,
                                ),
                                SpaceWidget(spaceWidth: 4),
                                TextWidget(
                                  text: AppStrings.accept,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: AppColors.green,
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
