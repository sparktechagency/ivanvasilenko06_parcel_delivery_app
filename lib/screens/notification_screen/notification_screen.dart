import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final String phoneNumber = '+1234567890';
  final String message = 'Hello, this is a test message';

  List<String> status = List.generate(6, (index) => 'pending');
  List<bool> isButtonClicked = List.generate(6, (index) => false);

  final List<String> images = List.filled(6, AppImagePath.profileImage);
  final List<String> names = List.filled(6, AppStrings.joshua);
  final List<String> details = List.filled(6, AppStrings.parcelDetails);

  bool showNotifications = false;

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showErrorSnackBar('Could not launch phone call');
    }
  }

  Future<void> _sendMessage() async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: "notification".tr,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.black,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showNotifications = !showNotifications;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 70,
                        height: 35,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: showNotifications
                              ? AppColors.green
                              : AppColors.red,
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: showNotifications
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  showNotifications ? 'ON' : 'OFF',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              alignment: showNotifications
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SpaceWidget(spaceHeight: 24),
              Expanded(
                child: showNotifications
                    ? SingleChildScrollView(
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
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
                                      Icon(Icons.location_on_rounded,
                                          color: AppColors.black, size: 12),
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
                                      Icon(Icons.calendar_month,
                                          color: AppColors.black, size: 12),
                                      SpaceWidget(spaceWidth: 8),
                                      TextWidget(
                                        text: '24-04-2024',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        fontColor: AppColors.greyDark2,
                                      ),
                                    ],
                                  ),
                                  if (status[index] == 'accepted') ...[
                                    const SpaceWidget(spaceHeight: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.call,
                                            color: AppColors.black, size: 12),
                                        const SpaceWidget(spaceWidth: 8),
                                        const TextWidget(
                                          text: '+972 52 123 4567',
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
                                  const SpaceWidget(spaceHeight: 16),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteLight,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: status[index] == 'pending'
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    status[index] = 'rejected';
                                                  });
                                                },
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.close,
                                                        color: AppColors.red,
                                                        size: 16),
                                                    SpaceWidget(spaceWidth: 4),
                                                    TextWidget(
                                                      text: "Reject",
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontColor: AppColors.red,
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
                                                onTap: () {},
                                                child: const Row(
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .remove_red_eye_outlined,
                                                        color: AppColors.black,
                                                        size: 14),
                                                    SpaceWidget(spaceWidth: 4),
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
                                                    status[index] = 'accepted';
                                                  });
                                                },
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.check,
                                                        color: AppColors.green,
                                                        size: 14),
                                                    SpaceWidget(spaceWidth: 4),
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
                                              text: status[index] == 'accepted'
                                                  ? "Accepted"
                                                  : "Rejected",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              fontColor:
                                                  status[index] == 'accepted'
                                                      ? AppColors.black
                                                      : AppColors.red,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      )
                    : const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: TextWidget(
                            text:
                                "Want to show the notification? Turn on the notification button.",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontColor: AppColors.greyDark2,
                            textAlignment: TextAlign.center,
                          ),
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
}
