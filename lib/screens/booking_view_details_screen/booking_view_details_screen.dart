import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_icons_path.dart';
import '../../constants/app_image_path.dart';
import '../../constants/app_strings.dart';
import '../../utils/app_size.dart';
import '../../widgets/icon_widget/icon_widget.dart';
import '../../widgets/image_widget/image_widget.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';
import '../booking_parcel_details_screen/widgets/summary_info_row_widget.dart';

class BookingViewDetailsScreen extends StatefulWidget {
  const BookingViewDetailsScreen({super.key});

  @override
  State<BookingViewDetailsScreen> createState() =>
      _BookingViewDetailsScreenState();
}

class _BookingViewDetailsScreenState extends State<BookingViewDetailsScreen> {
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
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 48),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextWidget(
              text: AppStrings.summary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
            ),
          ),
          const SpaceWidget(spaceHeight: 40),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: const ImageWidget(
                              height: 40,
                              width: 40,
                              imagePath: AppImagePath.sendParcel,
                            ),
                          ),
                          const SpaceWidget(spaceWidth: 8),
                          const TextWidget(
                            text: AppStrings.parcel1,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            fontColor: AppColors.black,
                          ),
                        ],
                      ),
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
                                height: 18,
                                width: 18,
                              ),
                            ),
                          ),
                          const SpaceWidget(spaceWidth: 10),
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
                    ],
                  ),
                  const SpaceWidget(spaceHeight: 16),
                  const Divider(
                    color: AppColors.grey,
                    thickness: 1,
                  ),
                  const SpaceWidget(spaceHeight: 16),
                  const SummaryInfoRowWidget(
                    image: AppImagePath.profileImage,
                    label: AppStrings.sendersName,
                    value: AppStrings.joshua,
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const SummaryInfoRowWidget(
                    icon: AppIconsPath.ratingIcon,
                    label: AppStrings.ratingsText,
                    value: AppStrings.ratings,
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const SummaryInfoRowWidget(
                    icon: AppIconsPath.profileIcon,
                    label: AppStrings.receiversName,
                    value: AppStrings.arial,
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const SummaryInfoRowWidget(
                    icon: AppIconsPath.callIcon,
                    label: AppStrings.receiversNumber,
                    value: AppStrings.number,
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const SummaryInfoRowWidget(
                    icon: AppIconsPath.deliveryTimeIcon,
                    label: AppStrings.deliveryTimeText,
                    value: AppStrings.deliveryTime,
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const SummaryInfoRowWidget(
                    icon: AppIconsPath.destinationIcon,
                    label: AppStrings.currentLocationText,
                    value: AppStrings.currentLocation,
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const SummaryInfoRowWidget(
                    icon: AppIconsPath.currentLocationIcon,
                    label: AppStrings.destinationText,
                    value: AppStrings.destination,
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const SummaryInfoRowWidget(
                    icon: AppIconsPath.priceIcon,
                    label: AppStrings.price,
                    value: "${AppStrings.currency} 150",
                  ),
                  const SpaceWidget(spaceHeight: 8),
                  const SummaryInfoRowWidget(
                    icon: AppIconsPath.descriptionIcon,
                    label: AppStrings.descriptionText,
                    value: AppStrings.description,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 24),
        child: Row(
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
          ],
        ),
      ),
    );
  }
}
