import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/screens/notification_screen/controller/notification_controller.dart';
import 'package:parcel_delivery_app/screens/notification_screen/notification_model/notification_model.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/app_images.dart';
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
    final NotificationController controller = Get.put(NotificationController());

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
                  if (controller.notifications.isEmpty) {
                    return const Center(
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
                    );
                  }

                  // Group notifications by type
                  final Map<String, List<NotificationDataList>>
                      groupedNotifications = {};

                  for (var notification in controller.notifications) {
                    final type = notification.type ?? "unknown";
                    if (!groupedNotifications.containsKey(type)) {
                      groupedNotifications[type] = [];
                    }
                    groupedNotifications[type]!.add(notification);
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: groupedNotifications.entries.map((entry) {
                        final type = entry.key;
                        final notificationList = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: TextWidget(
                                text: _formatTypeName(type),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontColor: AppColors.black,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: notificationList.map((notification) {
                                // Check for image based on type
                                final bool isReceiverType =
                                    notification.type?.toLowerCase() ==
                                        "recciver";

                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.only(
                                      bottom: 8, left: 16, right: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Image based on notification type
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: isReceiverType &&
                                                    notification.image !=
                                                        null &&
                                                    notification
                                                        .image!.isNotEmpty
                                                ? AppImage(
                                                    url: notification.image!,
                                                    height: 40,
                                                    width: 40,
                                                  )
                                                : const ImageWidget(
                                                    height: 40,
                                                    width: 40,
                                                    imagePath:
                                                        AppImagePath.sendParcel,
                                                  ),
                                          ),
                                          const SpaceWidget(spaceWidth: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextWidget(
                                                  text: notification.title ??
                                                      "Unknown",
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  fontColor: AppColors.black,
                                                ),
                                                if (notification.message !=
                                                        null &&
                                                    notification
                                                        .message!.isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    child: TextWidget(
                                                      text:
                                                          notification.message!,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontColor:
                                                          AppColors.greyDark2,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (notification.description != null &&
                                          notification
                                              .description!.isNotEmpty) ...[
                                        const SpaceWidget(spaceHeight: 12),
                                        Row(
                                          children: [
                                            const Icon(Icons.info_outline,
                                                color: AppColors.black,
                                                size: 14),
                                            const SpaceWidget(spaceWidth: 8),
                                            Flexible(
                                              child: TextWidget(
                                                text: notification.description!,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontColor: AppColors.greyDark2,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],

                                      if (notification.phoneNumber != null &&
                                              notification
                                                  .phoneNumber!.isNotEmpty ||
                                          notification.mobileNumber != null &&
                                              notification.mobileNumber!
                                                  .isNotEmpty) ...[
                                        const SpaceWidget(spaceHeight: 12),
                                        Row(
                                          children: [
                                            const Icon(Icons.call,
                                                color: AppColors.black,
                                                size: 14),
                                            const SpaceWidget(spaceWidth: 8),
                                            TextWidget(
                                              text: notification.phoneNumber
                                                          ?.isNotEmpty ==
                                                      true
                                                  ? notification.phoneNumber!
                                                  : notification.mobileNumber ??
                                                      "",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              fontColor: AppColors.greyDark2,
                                            ),
                                            const Spacer(),
                                            if (notification.phoneNumber
                                                        ?.isNotEmpty ==
                                                    true ||
                                                notification.mobileNumber
                                                        ?.isNotEmpty ==
                                                    true) ...[
                                              InkWell(
                                                onTap: () => _sendMessage(
                                                    notification.phoneNumber
                                                                ?.isNotEmpty ==
                                                            true
                                                        ? notification
                                                            .phoneNumber!
                                                        : notification
                                                            .mobileNumber!),
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: const CircleAvatar(
                                                  backgroundColor:
                                                      AppColors.whiteDark,
                                                  radius: 18,
                                                  child: IconWidget(
                                                    icon: AppIconsPath
                                                        .whatsAppIcon,
                                                    color: AppColors.black,
                                                    width: 18,
                                                    height: 18,
                                                  ),
                                                ),
                                              ),
                                              const SpaceWidget(spaceWidth: 8),
                                              InkWell(
                                                onTap: () => _makePhoneCall(
                                                    notification.phoneNumber
                                                                ?.isNotEmpty ==
                                                            true
                                                        ? notification
                                                            .phoneNumber!
                                                        : notification
                                                            .mobileNumber!),
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
                                          ],
                                        ),
                                      ],

                                      // Time information
                                      const SpaceWidget(spaceHeight: 8),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: TextWidget(
                                          text: _formatDateTime(
                                              notification.createdAt),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          fontColor: AppColors.greyDark2,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SpaceWidget(spaceHeight: 16),
                          ],
                        );
                      }).toList(),
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

  // Helper method to format notification type for display
  String _formatTypeName(String type) {
    if (type.toLowerCase() == "recciver") {
      return "Receiver Notifications";
    } else if (type.toLowerCase() == "parcel_update") {
      return "Parcel Updates";
    } else {
      // Capitalize first letter and add spaces before capital letters
      return type
              .replaceAllMapped(
                RegExp(r'([A-Z])'),
                (match) => ' ${match.group(0)}',
              )
              .trim()
              .capitalize ??
          type;
    }
  }

  // Helper method to format date time for display
  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) {
      return '';
    }

    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateTimeStr;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Clean phone number of any potential whitespace or unwanted characters
    final cleanPhoneNumber = phoneNumber.trim();
    if (cleanPhoneNumber.isEmpty) {
      _showErrorSnackBar('Invalid phone number');
      return;
    }

    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        _showErrorSnackBar('Could not launch phone call');
      }
    } catch (e) {
      _showErrorSnackBar('Error initiating call: $e');
    }
  }

  Future<void> _sendMessage(String phoneNumber) async {
    // Clean phone number of any potential whitespace or unwanted characters
    final cleanPhoneNumber = phoneNumber.trim();
    if (cleanPhoneNumber.isEmpty) {
      _showErrorSnackBar('Invalid phone number');
      return;
    }

    final Uri launchUri = Uri(
      scheme: 'sms',
      path: cleanPhoneNumber,
      queryParameters: {'body': 'Hello regarding your parcel delivery'},
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        _showErrorSnackBar('Could not launch messaging app');
      }
    } catch (e) {
      _showErrorSnackBar('Error sending message: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    AppSnackBar.error(message);
  }
}
