import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/screens/notification_screen/controller/notification_controller.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final NotificationController controller =
        Get.put(NotificationController()); // Initialize the controller

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: "notification".tr,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.black,
                    ),
                  ],
                ),
              ),
              const SpaceWidget(spaceHeight: 24),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (controller.error.isNotEmpty) {
                    return Center(
                      child: Text("Error: ${controller.error}"),
                    );
                  }
                  return controller.notifications.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: TextWidget(
                              text: "No notifications available.",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontColor: AppColors.greyDark2,
                              textAlignment: TextAlign.center,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: List.generate(
                                controller.notifications.length, (index) {
                              final notification =
                                  controller.notifications[index];
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: const ImageWidget(
                                                height: 40,
                                                width: 40,
                                                imagePath: AppImagePath
                                                    .sendParcel, // You can replace this with an image URL if available
                                              ),
                                            ),
                                            const SpaceWidget(spaceWidth: 8),
                                            TextWidget(
                                              text: notification.title ??
                                                  "Unknown",
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              fontColor: AppColors.black,
                                            ),
                                          ],
                                        ),
                                        const TextWidget(
                                          text: "${AppStrings.currency} 150",
                                          // Static value for now, update if needed
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontColor: AppColors.black,
                                        ),
                                      ],
                                    ),
                                    const SpaceWidget(spaceHeight: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_rounded,
                                            color: AppColors.black, size: 12),
                                        const SpaceWidget(spaceWidth: 8),
                                        TextWidget(
                                          text: notification.type ??
                                              'Location details not available',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          fontColor: AppColors.greyDark2,
                                        ),
                                      ],
                                    ),
                                    const SpaceWidget(spaceHeight: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_month,
                                            color: AppColors.black, size: 12),
                                        const SpaceWidget(spaceWidth: 8),
                                        TextWidget(
                                          text: notification.createdAt ??
                                              'Unknown date',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          fontColor: AppColors.greyDark2,
                                        ),
                                      ],
                                    ),
                                    const SpaceWidget(spaceHeight: 8),
                                    // Show contact information only when the notification is accepted
                                    if (notification.isRead != null &&
                                        notification.isRead == true) ...[
                                      Row(
                                        children: [
                                          const Icon(Icons.call,
                                              color: AppColors.black, size: 12),
                                          const SpaceWidget(spaceWidth: 8),
                                          const TextWidget(
                                            text: '+972 52 123 4567',
                                            // Placeholder phone number
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            fontColor: AppColors.greyDark2,
                                          ),
                                          const Spacer(),
                                          InkWell(
                                            onTap: _sendMessage,
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: const CircleAvatar(
                                              backgroundColor:
                                                  AppColors.whiteDark,
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
                                              backgroundColor:
                                                  AppColors.whiteDark,
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
                                    const SpaceWidget(spaceHeight: 08),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppColors.whiteLight,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: notification.isRead == null ||
                                              notification.isRead == false
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      notification.isRead =
                                                          false;
                                                    });
                                                    AppSnackBar.success(
                                                        "Notification rejected");
                                                  },
                                                  child: const Row(
                                                    children: [
                                                      Icon(Icons.close,
                                                          color: AppColors.red,
                                                          size: 16),
                                                      SpaceWidget(
                                                          spaceWidth: 4),
                                                      TextWidget(
                                                        text: "Reject",
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontColor:
                                                            AppColors.red,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                    width: 1,
                                                    height: 24,
                                                    color:
                                                        AppColors.blackLighter),
                                                InkWell(
                                                  onTap: () {
                                                    // Handle View action
                                                    // Will implement later as requested
                                                    AppSnackBar.success(
                                                        "View functionality will be added later");
                                                  },
                                                  child: const Row(
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .remove_red_eye_outlined,
                                                          color:
                                                              AppColors.black,
                                                          size: 14),
                                                      SpaceWidget(
                                                          spaceWidth: 4),
                                                      TextWidget(
                                                        text: "View",
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontColor:
                                                            AppColors.greyDark2,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                    width: 1,
                                                    height: 24,
                                                    color:
                                                        AppColors.blackLighter),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      notification.isRead =
                                                          true;
                                                    });
                                                    AppSnackBar.success(
                                                        "Notification accepted");
                                                  },
                                                  child: const Row(
                                                    children: [
                                                      Icon(Icons.check,
                                                          color:
                                                              AppColors.green,
                                                          size: 14),
                                                      SpaceWidget(
                                                          spaceWidth: 4),
                                                      TextWidget(
                                                        text: "Accept",
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontColor:
                                                            AppColors.green,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Center(
                                              child: TextWidget(
                                                text:
                                                    notification.isRead == true
                                                        ? "Accepted"
                                                        : "Rejected",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontColor:
                                                    notification.isRead == true
                                                        ? AppColors.green
                                                        : AppColors.red,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        );
                }),
              ),
            ],
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(100),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteLight,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 25,
                  child: Icon(Icons.arrow_back, color: AppColors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: '+1234567890');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showErrorSnackBar('Could not launch phone call');
    }
  }

  Future<void> _sendMessage() async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: '+1234567890',
      queryParameters: {'body': 'Hello, this is a test message'},
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showErrorSnackBar('Could not launch messaging app');
    }
  }

  void _showErrorSnackBar(String message) {
    AppSnackBar.error(message);
  }
}
