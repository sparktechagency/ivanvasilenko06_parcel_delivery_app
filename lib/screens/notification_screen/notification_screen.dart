import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_image_path.dart';
import '../../constants/app_strings.dart';
import '../../utils/app_size.dart';
import '../../widgets/image_widget/image_widget.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';

class NotificationScreen extends StatefulWidget {
  NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final String phoneNumber = '+1234567890';
  final String message = 'Hello, this is a test message';

  // Track the status of each item (pending, accepted, rejected)
  List<String> status = List.generate(6, (index) => 'pending');
  List<bool> isButtonClicked = List.generate(6, (index) => false); // Track if buttons are clicked

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showErrorSnackBar('Could not launch phone call');
    }
  }

  Future<void> _sendMessage() async {
    final Uri launchUri = Uri(scheme: 'sms', path: phoneNumber, queryParameters: {'body': message});
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showErrorSnackBar('Could not launch messaging app');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  final List<String> images = List.filled(6, AppImagePath.profileImage);
  final List<String> names = List.filled(6, AppStrings.joshua);
  final List<String> details = List.filled(6, AppStrings.parcelDetails);

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
                child: TextWidget(
                  text: "notification".tr,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontColor: AppColors.black,
                ),
              ),
              const SpaceWidget(spaceHeight: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(images.length, (index) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  ],
                                ),
                                const TextWidget(
                                  text: "${AppStrings.currency} 150",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontColor: AppColors.black,
                                ),
                              ],
                            ),
                            const SpaceWidget(spaceHeight: 8),
                            const Row(
                              children: [
                                Icon(Icons.location_on_rounded, color: AppColors.black, size: 12),
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
                            Row(
                              children: [
                                const Icon(Icons.calendar_month, color: AppColors.black, size: 12),
                                const SpaceWidget(spaceWidth: 8),
                                const TextWidget(
                                  text: '24-04-2024',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontColor: AppColors.greyDark2,
                                ),
                                const Spacer(),
                                if (status[index] == 'accepted') ...[
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
                              ],
                            ),
                            const SpaceWidget(spaceHeight: 16),
                            // Container for showing the status (Accepted or Rejected)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.whiteLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: status[index] == 'pending'
                                  ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        status[index] = 'rejected';
                                        isButtonClicked[index] = true; // Mark button as clicked
                                      });
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(Icons.close, color: AppColors.red, size: 16),
                                        SpaceWidget(spaceWidth: 4),
                                        TextWidget(
                                          text: "reject",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontColor: AppColors.red,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(width: 1, height: 24, color: AppColors.blackLighter),
                                  InkWell(
                                    onTap: () {
                                      // Placeholder for future View functionality
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(Icons.remove_red_eye_outlined, color: AppColors.black, size: 14),
                                        SpaceWidget(spaceWidth: 4),
                                        TextWidget(
                                          text: "view",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontColor: AppColors.greyDark2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(width: 1, height: 24, color: AppColors.blackLighter),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        status[index] = 'accepted';
                                        isButtonClicked[index] = true; // Mark button as clicked
                                      });
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(Icons.check, color: AppColors.green, size: 14),
                                        SpaceWidget(spaceWidth: 4),
                                        TextWidget(
                                          text: "accept",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontColor: AppColors.green,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                                  : Center(
                                child: TextWidget(
                                  text: status[index] == 'accepted' ? "Accepted" : "Rejected",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: status[index] == 'accepted' ? AppColors.green : AppColors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
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
              child: const CircleAvatar(
                backgroundColor: AppColors.grey,
                radius: 25,
                child: Icon(Icons.arrow_back, color: AppColors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}