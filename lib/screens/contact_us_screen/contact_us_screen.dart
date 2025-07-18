import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/screens/profile_screen/controller/profile_controller.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:parcel_delivery_app/widgets/text_button_widget/text_button_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../utils/app_size.dart';
import '../../widgets/button_widget/button_widget.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';

class ContactUsScreen extends StatelessWidget {
  final ProfileController controller  = Get.put(ProfileController());
   ContactUsScreen({super.key});

  Future<void> _sendEmail() async {
    // Get user email from controller
    final String userEmail = controller.profileData.value.data?.user?.email ?? 'N/A';
    final String userName = controller.profileData.value.data?.user?.fullName ?? 'User';

    final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'deliverly2025@gmail.com',
        queryParameters: {
          'subject': 'Support Request - Deliverly App',
          'body': 'Hello Deliverly Support Team,\n\nI need assistance with:\n\n[Please describe your issue here]\n\nUser Information:\n- Name: $userName\n- Email: $userEmail\n- App Version: 1.0.0\n- Platform: ${Theme.of(Get.context!).platform.name}\n\nThank you for your support!\n\nBest regards,\n$userName'
        });

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        // Show user-friendly error message with alternative options
        _showEmailAlternatives();
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      _showEmailAlternatives();
    }
  }

  void _showEmailAlternatives() {
    Get.dialog(
      AlertDialog(
        title: const Text('Email Client Not Available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('No email client found. You can contact us using:'),
            const SizedBox(height: 16),

            // Copy email address option
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Email Address'),
              subtitle: const Text('deliverly2025@gmail.com'),
              onTap: () {
                _copyEmailToClipboard();
                Get.back();
              },
            ),

            // Open Gmail web (if available)
            ListTile(
              leading: const Icon(Icons.web),
              title: const Text('Open Gmail Web'),
              subtitle: const Text('Open in browser'),
              onTap: () {
                _openGmailWeb();
                Get.back();
              },
            ),

            // Manual email option
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Manual Email'),
              subtitle: const Text('Send email manually'),
              onTap: () {
                _showManualEmailInfo();
                Get.back();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _copyEmailToClipboard() async {
    // You'll need to import 'package:flutter/services.dart' for this
    await Clipboard.setData(const ClipboardData(text: 'deliverly2025@gmail.com'));
    Get.snackbar(
      'Copied!',
      'Email address copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.green ?? Colors.green,
      colorText: AppColors.white,
    );
  }

  Future<void> _openGmailWeb() async {
    // Get user email from controller
    final String userEmail = controller.profileData.value.data?.user?.email ?? 'N/A';
    final String userName = controller.profileData.value.data?.user?.fullName ?? 'User';

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
          backgroundColor: AppColors.red ?? Colors.red,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      debugPrint('Error opening Gmail web: $e');
    }
  }

  void _showManualEmailInfo() {
    // Get user email from controller
    final String userEmail = controller.profileData.value.data?.user?.email ?? 'N/A';
    final String userName = controller.profileData.value.data?.user?.fullName ?? 'User';

    Get.dialog(
      AlertDialog(
        title: const Text('Manual Email Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please send your email manually with:'),
            const SizedBox(height: 16),
            const Text('To: deliverly2025@gmail.com', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Subject: Support Request - Deliverly App', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Body:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('- Describe your issue\n- Your Name: $userName\n- Your Email: $userEmail\n- Include device information\n- Add any relevant screenshots'),
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
              text: 'deliverly2025@gmail.com',
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
                  radius: ResponsiveUtils.width(25),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
            ButtonWidget(
              onPressed: () {
                _sendEmail(); // Changed this to call _sendEmail instead of navigation
              },
              label: AppStrings.mailUs,
              textColor: AppColors.white,
              buttonWidth: 125,
              buttonHeight: 50,
              icon: Icons.email, // Changed icon to email for better UX
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