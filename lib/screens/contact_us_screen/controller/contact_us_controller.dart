import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/screens/profile_screen/controller/profile_controller.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/utils/appLog/app_log.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsController extends GetxController {
  RxBool isLoading = false.obs;
  var ratingNumber = 3.0.obs; // Set default rating to 3
  var reviewtext = TextEditingController().obs;

  // Get profile controller instance
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  void onClose() {
    reviewtext.value.dispose();
    super.onClose();
  }

  // Get user email with safety checks
  String get userEmail =>
      profileController.profileData.value.data?.user?.email ?? 'N/A';

  // Get user name with safety checks
  String get userName =>
      profileController.profileData.value.data?.user?.fullName ?? 'User';

  Future<void> appPostReview() async {
    try {
      isLoading(true);

      // Validate input
      if (reviewtext.value.text.trim().isEmpty) {
        AppSnackBar.error("Please write a review before submitting");
        return;
      }

      Map<String, dynamic> body = {
        "rating": ratingNumber.value,
        "reviewText": reviewtext.value.text.trim()
      };

      var response = await ApiPostServices().apiPostServices(
          url: AppApiUrl.appReveiw, body: body, statusCode: 201);

      if (response['data'] != null) {
        //! appLog("Post your review successfully");
        AppSnackBar.success("Post Your Review Successfully");
        // Clear the form after successful submission
        reviewtext.value.clear();
        ratingNumber.value = 3.0;
      } else {
        AppSnackBar.error("Post Your Review Failed");
      }
    } catch (e) {
      //! appLog("Error posting review: $e");
      AppSnackBar.error("An error occurred while posting your review");
    } finally {
      isLoading(false);
    }
  }

  // Email functionality
  Future<void> sendEmail() async {
    try {
      final Uri emailLaunchUri = Uri(
          scheme: 'mailto',
          path: 'deliverly2025@gmail.com',
          queryParameters: {
            'subject': 'Support Request - Deliverly App',
            'body':
                'Hello Deliverly Support Team,\n\nI need assistance with:\n\n[Please describe your issue here]\n\nUser Information:\n- Name: $userName\n- Email: $userEmail\n- App Version: 1.0.0\n- Platform: ${Theme.of(Get.context!).platform.name}\n\nThank you for your support!\n\nBest regards,\n$userName'
          });

      try {
        if (await canLaunchUrl(emailLaunchUri)) {
          await launchUrl(emailLaunchUri);
        } else {
          showEmailAlternatives();
        }
      } catch (e) {
        debugPrint('Error launching email: $e');
        showEmailAlternatives();
      }
    } catch (e) {
      debugPrint('Error in sendEmail: $e');
      showEmailAlternatives();
    }
  }

  void showEmailAlternatives() {
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: AlertDialog(
          title: const TextWidget(
              text: 'Email Client Not Available',
              fontColor: AppColors.blackLight,
              fontSize: 18,
              fontWeight: FontWeight.w600),
          backgroundColor: AppColors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextWidget(
                text: 'No email client found. You can contact us using:',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontColor: AppColors.greyDarkLight,
              ),
              const SpaceWidget(spaceHeight: 16),
              // Copy email address option
              ListTile(
                titleAlignment: ListTileTitleAlignment.threeLine,
                leading: const Icon(Icons.copy),
                title: const TextWidget(
                  text: 'Copy Email Address',
                  fontColor: AppColors.blackLight,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                subtitle: const TextWidget(
                  text: 'deliverly2025@gmail.com',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.greyDarkLight,
                ),
                onTap: () {
                  copyEmailToClipboard();
                  Get.back();
                },
              ),

              // Open Gmail web (if available)
              ListTile(
                titleAlignment: ListTileTitleAlignment.threeLine,
                leading: const Icon(Icons.email_outlined),
                title: const TextWidget(
                  text: 'Open Gmail Web',
                  fontColor: AppColors.blackLight,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                subtitle: const TextWidget(
                  text: 'Open in browser',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.greyDarkLight,
                ),
                onTap: () {
                  openGmailWeb();
                  Get.back();
                },
              ),

              // Manual email option
              ListTile(
                titleAlignment: ListTileTitleAlignment.threeLine,
                leading: const Icon(Icons.info_outline),
                title: const TextWidget(
                  text: 'Manual Email',
                  fontColor: AppColors.blackLight,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                subtitle: const TextWidget(
                  text: 'Send email manually',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.greyDarkLight,
                ),
                onTap: () {
                  showManualEmailInfo();
                  Get.back();
                },
              ),
            ],
          ),
          actions: [
            ButtonWidget(
              label: "Close",
              fontSize: 18,
              onPressed: () => Get.back(),
              buttonWidth: 100,
              buttonHeight: 40,
            ),
            // TextButton(
            //   onPressed: () => Get.back(),
            //   child: const Text('Close'),
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> copyEmailToClipboard() async {
    try {
      await Clipboard.setData(
          const ClipboardData(text: 'deliverly2025@gmail.com'));

      Get.snackbar(
        'Copied!',
        'Email address copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.green,
        colorText: AppColors.white,
      );
    } catch (e) {
      debugPrint('Error copying to clipboard: $e');
      Get.snackbar(
        'Error',
        'Failed to copy email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
    }
  }

  Future<void> openGmailWeb() async {
    final Uri gmailUri = Uri.parse(
        'https://mail.google.com/mail/?view=cm&fs=1&to=deliverly2025@gmail.com&su=Support Request - Deliverly App&body=Hello Deliverly Support Team,%0D%0A%0D%0AI need assistance with:%0D%0A%0D%0A[Please describe your issue here]%0D%0A%0D%0AUser Information:%0D%0A- Name: $userName%0D%0A- Email: $userEmail%0D%0A- App Version: 1.0.0%0D%0A%0D%0AThank you for your support!%0D%0A%0D%0ABest regards,%0D%0A$userName');

    try {
      if (await canLaunchUrl(gmailUri)) {
        await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open Gmail web. Please copy the email address instead.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.red,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      debugPrint('Error opening Gmail web: $e');
    }
  }

  void showManualEmailInfo() {
    Get.dialog(
      AlertDialog(
        title: const Text('Manual Email Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please send your email manually with:'),
            const SizedBox(height: 16),
            const Text('To: deliverly2025@gmail.com',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Subject: Support Request - Deliverly App',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Body:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
                '- Describe your issue\n- Your Name: $userName\n- Your Email: $userEmail\n- Include device information\n- Add any relevant screenshots'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  // Navigation method
  void goBack() {
    Get.back();
  }
}
