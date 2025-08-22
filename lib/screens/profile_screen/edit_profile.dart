import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/screens/profile_screen/controller/profile_controller.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_field_widget/edit_profile_text_field_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController faceBookController = TextEditingController();
  final TextEditingController instaController = TextEditingController();
  final TextEditingController whastappController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final ProfileController _profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    _populateProfileData();
  }

  /// Fetches the current profile data and populates the text controllers
  void _populateProfileData() {
    final profileData = _profileController.profileData.value;

    if (profileData.data != null && profileData.data!.user != null) {
      final user = profileData.data!.user!;

      // Populate the text controllers with the current profile data
      nameController.text = user.fullName ?? '';
      faceBookController.text = user.facebook ?? '';
      instaController.text = user.instagram ?? '';
      whastappController.text = user.whatsapp ?? '';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    faceBookController.dispose();
    instaController.dispose();
    whastappController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  String _getProfileImagePath() {
    if (_profileController.isLoading.value) {
      log('⏳ Profile is still loading, returning default image URL');
      return 'https://i.ibb.co/z5YHLV9/profile.png';
    }

    final imageUrl = _profileController.profileData.value.data?.user?.image;
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
    if (cleanImageUrl.startsWith('https://') ||
        cleanImageUrl.startsWith('http://')) {
      fullImageUrl = cleanImageUrl;
    } else {
      // Remove leading slashes and ensure proper concatenation
      cleanImageUrl = cleanImageUrl.startsWith('/')
          ? cleanImageUrl.substring(1)
          : cleanImageUrl;
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
      appBar: AppBar(
        title: TextWidget(
          text: "editProfile".tr,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontColor: AppColors.black,
        ),
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColors.white,
      body: Obx(() {
        // Show loading if profile data is still being fetched
        if (_profileController.isLoading.value &&
            _profileController.profileData.value.data?.user == null) {
          return Center(
            child: LoadingAnimationWidget.hexagonDots(
              color: AppColors.black,
              size: 40,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SpaceWidget(spaceHeight: 20),
              Center(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(75),
                        child: _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                _getProfileImagePath(),
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey.withAlpha(78),
                                      borderRadius: BorderRadius.circular(75),
                                    ),
                                    child: Center(
                                      child: LoadingAnimationWidget.hexagonDots(
                                        color: AppColors.black,
                                        size: 30,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  log('❌ Error loading image: $error');
                                  return Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey.withAlpha(78),
                                      borderRadius: BorderRadius.circular(75),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 100),
                      child: InkWell(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.black,
                          child: Icon(
                            Icons.mode_edit_outline_outlined,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SpaceWidget(spaceHeight: 10),
              TextWidget(
                text: "fullName".tr,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontColor: AppColors.black,
              ),
              const SpaceWidget(spaceHeight: 10),
              EditProfileTextFieldWidget(
                height: 50,
                controller: nameController,
                hintText: "enterFullName".tr,
                maxLines: 1,
                keyboardType: TextInputType.text,
              ),
              const SpaceWidget(spaceHeight: 10),
              TextWidget(
                  text: "facebook".tr,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.black),
              const SpaceWidget(spaceHeight: 10),
              EditProfileTextFieldWidget(
                height: 50,
                controller: faceBookController,
                hintText: "enterYourFacebookId".tr,
                maxLines: 1,
                keyboardType: TextInputType.text,
              ),
              const SpaceWidget(spaceHeight: 10),
              TextWidget(
                  text: "instagram".tr,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.black),
              const SpaceWidget(spaceHeight: 10),
              EditProfileTextFieldWidget(
                height: 50,
                controller: instaController,
                hintText: "enterYourInstagramId".tr,
                maxLines: 1,
                keyboardType: TextInputType.text,
              ),
              const SpaceWidget(spaceHeight: 10),
              TextWidget(
                  text: "whatsapp".tr,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.black),
              const SpaceWidget(spaceHeight: 10),
              EditProfileTextFieldWidget(
                height: 50,
                controller: whastappController,
                hintText: "enterYourWhatsappId",
                maxLines: 1,
                keyboardType: TextInputType.number,
              ),
              const SpaceWidget(spaceHeight: 20),
              Obx(() => _profileController.isLoading.value
                  ? Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: LoadingAnimationWidget.progressiveDots(
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    )
                  : ButtonWidget(
                      onPressed: () async {
                        final userId =
                            _profileController.profileData.value.data?.user?.id;
                        if (userId == null || userId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("User ID not found")),
                          );
                          return;
                        }
                        await _profileController.updateProfile(
                          fullName: nameController.text.trim(),
                          facebook: faceBookController.text.trim(),
                          instagram: instaController.text.trim(),
                          whatsapp: whastappController.text.trim(),
                          ID: userId,
                          Image: _selectedImage,
                        );
                        if (_profileController.errorMessage.value.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    _profileController.errorMessage.value)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Profile updated successfully")),
                          );
                          // Navigation is handled in updateProfile() with Get.back()
                        }
                      },
                      label: "editProfile".tr,
                      buttonHeight: 50,
                      buttonWidth: double.infinity,
                    )),
              const SpaceWidget(spaceHeight: 30),
            ],
          ),
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 08),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => Get.back(),
              child: const CircleAvatar(
                backgroundColor: AppColors.white,
                radius: 25,
                child: Icon(Icons.arrow_back, color: AppColors.black),
              ),
            ),
            const SizedBox(),
          ],
        ),
      ),
    );
  }
}
