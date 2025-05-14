import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextWidget(
          text: "Edit Profile".tr,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontColor: AppColors.black,
        ),
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SpaceWidget(spaceHeight: 20),
            Center(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : const AssetImage(AppImagePath.profileImage)
                            as ImageProvider,
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
              text: "Full Name".tr,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.black,
            ),
            const SpaceWidget(spaceHeight: 10),
            EditProfileTextFieldWidget(
              height: 50,
              controller: nameController,
              hintText: "Enter your full name",
              maxLines: 1,
              keyboardType: TextInputType.text,
            ),
            const SpaceWidget(spaceHeight: 10),
            TextWidget(
                text: "Facebook".tr,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontColor: AppColors.black),
            const SpaceWidget(spaceHeight: 10),
            EditProfileTextFieldWidget(
              height: 50,
              controller: faceBookController,
              hintText: "Enter your Facebook",
              maxLines: 1,
              keyboardType: TextInputType.text,
            ),
            const SpaceWidget(spaceHeight: 10),
            TextWidget(
                text: "Instagram".tr,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontColor: AppColors.black),
            const SpaceWidget(spaceHeight: 10),
            EditProfileTextFieldWidget(
              height: 50,
              controller: instaController,
              hintText: "Enter your Instagram",
              maxLines: 1,
              keyboardType: TextInputType.text,
            ),
            const SpaceWidget(spaceHeight: 10),
            TextWidget(
                text: "WhatsApp".tr,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontColor: AppColors.black),
            const SpaceWidget(spaceHeight: 10),
            EditProfileTextFieldWidget(
              height: 50,
              controller: whastappController,
              hintText: "Enter your WhatsApp",
              maxLines: 1,
              keyboardType: TextInputType.number,
            ),
            const SpaceWidget(spaceHeight: 20),
            Obx(() => _profileController.isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.black,
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
                              content:
                                  Text(_profileController.errorMessage.value)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Profile updated successfully")),
                        );
                        // Navigation is handled in updateProfile() with Get.back()
                      }
                    },
                    label: "Edit Profile".tr,
                    buttonHeight: 50,
                    buttonWidth: double.infinity,
                  )),
            const SpaceWidget(spaceHeight: 30),
          ],
        ),
      ),
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
