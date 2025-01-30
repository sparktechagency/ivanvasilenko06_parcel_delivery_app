import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:parcel_delivery_app/widgets/text_button_widget/text_button_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../utils/app_size.dart';
import '../../widgets/button_widget/button_widget.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';
import '../bottom_nav_bar/bottom_nav_bar.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _sendEmail() async {
    final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'Loremipsum@123gmail.com',
        queryParameters: {
          'subject': 'Support Request',
        });

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      // You might want to show a snackbar or dialog here to inform the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SpaceWidget(spaceHeight: 48),
            const TextWidget(
              text: AppStrings.contactUs,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
            ),
            const SpaceWidget(spaceHeight: 24),
            const TextWidget(
              text: AppStrings.forAnySupport,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.greyDarkLight,
            ),
            const SpaceWidget(spaceHeight: 2),
            TextButtonWidget(
              onPressed: () {
                _sendEmail();
              },
              text: 'Loremipsum@123gmail.com',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              textColor: AppColors.black,
              decoration: TextDecoration.underline,
            ),
            const SpaceWidget(spaceHeight: 150),
            const Center(
              child: IconWidget(
                height: 250,
                width: 250,
                icon: AppIconsPath.contactUsIcon,
              ),
            ),
          ],
        ),
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
                  radius: ResponsiveUtils.width(30),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
            ButtonWidget(
              onPressed: () {
                Get.offAll(() => const BottomNavScreen());
              },
              label: AppStrings.mailUs,
              textColor: AppColors.white,
              buttonWidth: 125,
              buttonHeight: 50,
              icon: Icons.arrow_forward,
              iconColor: AppColors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
