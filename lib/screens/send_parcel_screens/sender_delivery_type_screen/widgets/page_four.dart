import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/controller/sending_parcel_controller.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/sender_text_field_widget/sender_text_field_widget.dart';

import '../../../../constants/app_colors.dart';
import '../../../../widgets/space_widget/space_widget.dart';
import '../../../../widgets/text_widget/text_widgets.dart';

class PageFour extends StatelessWidget {
  PageFour({super.key});

  ParcelController parcelController = Get.put(ParcelController());
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    // Update images in the controller
    parcelController.selectedImages
        .addAll(images.map((image) => File(image.path).path));
    }

  void _removeImage(int index) {
    parcelController.selectedImages.removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 32),
          TextWidget(
            text: "enterDescription".tr,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontColor: AppColors.black,
            textAlignment: TextAlign.start,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SpaceWidget(spaceHeight: 24),
                  SenderTextFieldWidget(
                    controller: parcelController.titleController,
                    hintText: "enterParcelTitle".tr,
                    maxLines: 1,
                  ),
                  const SpaceWidget(spaceHeight: 12),
                  SenderTextFieldWidget(
                    controller: parcelController.descriptionController,
                    hintText: "WriteSomethingForDescription".tr,
                    maxLines: 4,
                  ),
                  const SpaceWidget(spaceHeight: 16),
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.greyLight2,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "addPhotos".tr,
                          style: const TextStyle(
                            color: AppColors.greyLight2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Ensure that the Obx widget is correctly wrapped around the image list display
                  Obx(() => parcelController.selectedImages.isNotEmpty
                      ? SizedBox(
                          height: 300,
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: parcelController.selectedImages.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(File(parcelController
                                            .selectedImages[index])),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppColors.black,
                                          // color: AppColors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      : Container()),
                  // Show an empty container when no images are selected
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
