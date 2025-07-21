import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/profile_screen/controller/profile_controller.dart';
import 'package:parcel_delivery_app/screens/profile_screen/widgets/profile_card_widget.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/api_url.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constant.dart';
import '../../constants/app_image_path.dart';
import '../../controller/language_controller.dart';
import '../../services/appStroage/share_helper.dart';
import '../../utils/app_size.dart';
import '../../widgets/image_widget/image_widget.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';

class ProfileScreen extends StatefulWidget {
  final ProfileController? profileController;

  const ProfileScreen({super.key, this.profileController});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.put(ProfileController());

  void _saveLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
  }

  void showUserLanguage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "changeLanguage".tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: GetBuilder<LocalizationController>(
                      builder: (localizationController) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            localizationController.setLanguage(Locale(
                              AppConstants.languages[0].languageCode,
                              AppConstants.languages[0].countryCode,
                            ));
                            localizationController.setSelectedIndex(0);
                            _saveLanguage('en');
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: const ImageWidget(
                                  height: 40,
                                  width: 45,
                                  imagePath: AppImagePath.usaFlag,
                                ),
                              ),
                              const SizedBox(width: 05),
                              const Text(
                                'English',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () {
                            localizationController.setLanguage(Locale(
                              AppConstants.languages[1].languageCode,
                              AppConstants.languages[1].countryCode,
                            ));
                            localizationController.setSelectedIndex(1);
                            _saveLanguage('he');
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: const ImageWidget(
                                  height: 40,
                                  width: 45,
                                  imagePath: AppImagePath.israeilFlag,
                                ),
                              ),
                              const SizedBox(width: 05),
                              const Text(
                                'Hebrew',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Dialog(
            shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(10)), // Flat corners
            ),
            backgroundColor: AppColors.grey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextWidget(
                    text: "areYouSureYouWantToLogOut".tr,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontColor: AppColors.black,
                    textAlignment: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ButtonWidget(
                        buttonWidth: 100,
                        buttonHeight: 40,
                        label: 'No',
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        buttonRadius: BorderRadius.circular(10),
                        backgroundColor: AppColors.white,
                        textColor: AppColors.black,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      ButtonWidget(
                        buttonWidth: 100,
                        buttonHeight: 40,
                        label: 'Yes',
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        buttonRadius: BorderRadius.circular(10),
                        backgroundColor: AppColors.black,
                        textColor: AppColors.white,
                        onPressed: () async {
                          await SharePrefsHelper.remove(
                              SharedPreferenceValue.token);
                          // Sign out from Google
                          final GoogleSignIn googleSignIn = GoogleSignIn();
                          try {
                            await googleSignIn.signOut();
                            await googleSignIn.disconnect();
                          } catch (e) {
                            // Handle error if needed
                          }
                          Get.toNamed(AppRoutes.splashScreen);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showDeleteProfile(String profileId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Dialog(
            shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(10)), // Flat corners
            ),
            backgroundColor: AppColors.grey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const TextWidget(
                    text: 'Are you sure Delete your profile?',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontColor: AppColors.black,
                    textAlignment: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ButtonWidget(
                        buttonWidth: 100,
                        buttonHeight: 40,
                        label: 'No',
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        buttonRadius: BorderRadius.circular(10),
                        backgroundColor: AppColors.white,
                        textColor: AppColors.black,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      ButtonWidget(
                        buttonWidth: 100,
                        buttonHeight: 40,
                        label: 'Yes',
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        buttonRadius: BorderRadius.circular(10),
                        backgroundColor: AppColors.black,
                        textColor: AppColors.white,
                        onPressed: () async {
                          await profileController.deleteProfile();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  String _getProfileImagePath() {
    if (profileController.isLoading.value) {
      log('⏳ Profile is still loading, returning default image URL');
      return 'https://i.ibb.co/z5YHLV9/profile.png';
    }

    final imageUrl = profileController.profileData.value.data?.user?.image;
    log('Raw image URL from API: "$imageUrl"');
    log('Image URL type: ${imageUrl.runtimeType}');

    // Check for null, empty, or invalid URLs
    if (imageUrl == null ||
        imageUrl.isEmpty ||
        imageUrl.trim().isEmpty ||
        imageUrl.toLowerCase() == 'null' ||
        imageUrl.toLowerCase() == 'undefined') {
      log('❌ Image URL is null/empty/invalid, using default image URL');
      return 'https://i.ibb.co/z5YHLV9/profile.png';
    }

    String fullImageUrl;
    // Trim and clean the URL
    String cleanImageUrl = imageUrl.trim();
    if (cleanImageUrl.startsWith('https://') || cleanImageUrl.startsWith('http://')) {
      fullImageUrl = cleanImageUrl;
    } else {
      // Remove leading slashes and ensure proper concatenation
      cleanImageUrl = cleanImageUrl.startsWith('/') ? cleanImageUrl.substring(1) : cleanImageUrl;
      fullImageUrl = "${AppApiUrl.liveDomain}/$cleanImageUrl";
    }

    // Validate the constructed URL
    final uri = Uri.tryParse(fullImageUrl);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      log('❌ Invalid URL format: $fullImageUrl, using default image URL');
      return 'https://i.ibb.co/z5YHLV9/profile.png';
    }

    log('✅ Constructed URL: $fullImageUrl');
    return fullImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (profileController.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWidget(
                  text: profileController.errorMessage.value,
                  fontSize: 16,
                  fontColor: AppColors.red,
                ),
                const SizedBox(height: 16),
                ButtonWidget(
                  label: 'Retry',
                  onPressed: () => profileController.refreshProfileData(),
                  backgroundColor: AppColors.black,
                  textColor: AppColors.white,
                ),
              ],
            ),
          );
        }
        if (profileController.profileData.value.data == null) {
          return const Center(
              child: TextWidget(text: "No profile data available"));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SpaceWidget(spaceHeight: 48),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    text: "profile".tr,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontColor: AppColors.black,
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                    ),
                    child: PopupMenuButton<int>(
                      padding: EdgeInsets.zero,
                      icon: const SizedBox(
                        height: 20,
                        width: 20,
                        child: Icon(
                          Icons.more_vert,
                          color: AppColors.black,
                          size: 24,
                        ),
                      ),
                      color: AppColors.white,
                      onSelected: (value) {
                        if (value == 1) {
                          Get.toNamed(AppRoutes.contactUsScreen);
                        } else if (value == 2) {
                          showUserLanguage();
                        } else if (value == 3) {
                          Get.toNamed(AppRoutes.editProfile);
                        } else if (value == 4) {
                          showLogoutDialog();
                        } else if (value == 5) {
                          showDeleteProfile(profileController
                              .profileData.value.data!.user!.id!);
                        }
                      },
                      splashRadius: 6,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          child: Text("contactUs".tr),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Text("changeLanguage".tr),
                        ),
                        PopupMenuItem(
                          value: 3,
                          child: Text("Edit Profile".tr),
                        ),
                        PopupMenuItem(
                          value: 4,
                          child: Text("Logout".tr),
                        ),
                        PopupMenuItem(
                          value: 5,
                          child: Text("Delete Account".tr),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SpaceWidget(spaceHeight: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: ResponsiveUtils.width(120),
                      height: ResponsiveUtils.width(120),
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          // Replace this part in your build method:

                          InkWell(
                            onTap: () => Get.toNamed(AppRoutes.editProfile),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: SizedBox(
                                width: ResponsiveUtils.width(120),
                                height: ResponsiveUtils.width(120),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    _getProfileImagePath(),
                                    height: 116,
                                    width: 116,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 116,
                                        width: 116,
                                        decoration: BoxDecoration(
                                          color: AppColors.grey.withAlpha(78),
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                                : null,
                                            strokeWidth: 2,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      log('❌ Error loading image: $error');
                                      return Container(
                                        height: 116,
                                        width: 116,
                                        decoration: BoxDecoration(
                                          color: AppColors.grey.withAlpha(78),
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: AppColors.greyDark2,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // InkWell(
                          //   onTap: () => Get.toNamed(AppRoutes.editProfile),
                          //   splashColor: Colors.transparent,
                          //   highlightColor: Colors.transparent,
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(4),
                          //     child: SizedBox(
                          //       width: ResponsiveUtils.width(120),
                          //       height: ResponsiveUtils.width(120),
                          //       child: ClipRRect(
                          //         borderRadius: BorderRadius.circular(100),
                          //         child: AppImage(
                          //           url: profileController
                          //                       .profileData
                          //                       .value
                          //                       .data
                          //                       ?.user
                          //                       ?.image
                          //                       ?.isNotEmpty ??
                          //                   false
                          //               ? profileController.profileData.value
                          //                   .data!.user!.image!
                          //               : AppImagePath.profileImage,
                          //           height: 116,
                          //           width: 116,
                          //           fit: BoxFit.cover,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          Positioned(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: ResponsiveUtils.width(55),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.yellow,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: AppColors.white,
                                      size: 12,
                                    ),
                                    const SpaceWidget(spaceWidth: 4),
                                    TextWidget(
                                      text: profileController
                                          .profileData.value.data!.averageRating
                                          .toString(),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      fontColor: AppColors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SpaceWidget(spaceHeight: 16),
                      Row(
                        children: [
                          TextWidget(
                            text: profileController
                                    .profileData.value.data?.user?.fullName ??
                                'N/A',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontColor: AppColors.black,
                          ),
                          const Spacer(),
                          TextWidget(
                            text: profileController
                                    .profileData.value.data?.user?.country ??
                                'N/A',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontColor: AppColors.black,
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.greyDark2,
                            size: 16,
                          ),
                        ],
                      ),

                    const SpaceWidget(spaceHeight: 12),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        // Get.toNamed(AppRoutes.historyScreen);
                      },
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: AppColors.greyLight,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const IconWidget(
                                  height: 14,
                                  width: 14,
                                  icon: AppIconsPath.basicInfoIcon1,
                                ),
                                const SpaceWidget(spaceWidth: 6),
                                TextWidget(
                                  text:
                                      "${profileController.profileData.value.data?.user?.totalOrders} "
                                      "${"orderCompleted".tr}",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontColor: AppColors.greyDark2,
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 20,
                              color: AppColors.blackLighter,
                            ),
                            Row(
                              children: [
                                const IconWidget(
                                  height: 14,
                                  width: 14,
                                  icon: AppIconsPath.basicInfoIcon2,
                                ),
                                const SpaceWidget(spaceWidth: 6),
                                TextWidget(
                                  text:
                                      "${profileController.profileData.value.data?.user?.totalReceivedParcels} "
                                      "${"orderDelivered".tr}",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontColor: AppColors.greyDark2,
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 20,
                              color: AppColors.blackLighter,
                            ),
                            Row(
                              children: [
                                const IconWidget(
                                  height: 14,
                                  width: 14,
                                  icon: AppIconsPath.basicInfoIcon3,
                                ),
                                const SpaceWidget(spaceWidth: 6),
                                TextWidget(
                                  text:
                                      "${profileController.profileData.value.data?.user?.totalDelivered}  "
                                      "${"orderReceived".tr}",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontColor: AppColors.greyDark2,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SpaceWidget(spaceHeight: 8),
                    const Divider(
                      color: AppColors.grey,
                      thickness: 1,
                    ),
                    ProfileCardWidget(
                      titleText: "credits".tr,
                      subtitleText: "yourEarning".tr,
                      additionalText:
                          "${profileController.profileData.value.data?.user?.totalEarning} ",
                    ),
                    const Divider(
                      color: AppColors.grey,
                      thickness: 1,
                    ),
                    ProfileCardWidget(
                      titleText: "name".tr,
                      subtitleText: profileController
                              .profileData.value.data?.user?.fullName ??
                          'N/A',
                    ),
                    const Divider(
                      color: AppColors.grey,
                      thickness: 1,
                    ),
                    ProfileCardWidget(
                      titleText: "phoneNumber".tr,
                      subtitleText: profileController
                              .profileData.value.data?.user?.mobileNumber ??
                          'N/A',
                    ),
                    const Divider(
                      color: AppColors.grey,
                      thickness: 1,
                    ),
                    ProfileCardWidget(
                      titleText: "whatsapp".tr,
                      subtitleText: profileController
                              .profileData.value.data?.user?.mobileNumber ??
                          'N/A',
                    ),
                    const Divider(
                      color: AppColors.grey,
                      thickness: 1,
                    ),
                    ProfileCardWidget(
                      titleText: "verifiedEmail".tr,
                      subtitleText: profileController
                              .profileData.value.data?.user?.email ??
                          'N/A',
                      badgeIcon: AppIconsPath.badgeIcon,
                    ),
                    const Divider(
                      color: AppColors.grey,
                      thickness: 1,
                    ),
                    const SpaceWidget(spaceHeight: 16),
                    TextWidget(
                      text: "addTrustOverYou".tr,
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.black,
                    ),
                    const SpaceWidget(spaceHeight: 4),
                    ProfileCardWidget(
                      titleText: "facebook".tr,
                      subtitleText: profileController
                              .profileData.value.data?.user?.facebook ??
                          'N/A',
                    ),
                    const Divider(
                      color: AppColors.grey,
                      thickness: 1,
                    ),
                    ProfileCardWidget(
                      titleText: "instagram".tr,
                      subtitleText: profileController
                              .profileData.value.data?.user?.instagram ??
                          'N/A',
                    ),
                    const Divider(
                      color: AppColors.grey,
                      thickness: 1,
                    ),
                    ProfileCardWidget(
                      titleText: "whatsapp".tr,
                      subtitleText: profileController
                              .profileData.value.data?.user?.whatsapp ??
                          'N/A',
                    ),
                    const SpaceWidget(spaceHeight: 90),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
