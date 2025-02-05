import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/sender_text_field_widget/sender_text_field_widget.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/space_widget/space_widget.dart';
import '../../../../widgets/text_widget/text_widgets.dart';

class PageFour extends StatefulWidget {
  PageFour({super.key});

  @override
  State<PageFour> createState() => _PageFourState();
}

class _PageFourState extends State<PageFour> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  List<File> selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        selectedImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 32),
          const TextWidget(
            text: AppStrings.enterDescription,
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
                    controller: titleController,
                    hintText: 'Enter Parcel Title',
                    maxLines: 1,
                  ),
                  const SpaceWidget(spaceHeight: 12),
                  SenderTextFieldWidget(
                    controller: descriptionController,
                    hintText: 'Write Something for description',
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
                      child: const Center(
                        child: Text(
                          '+ Add Photos',
                          style: TextStyle(
                            color: AppColors.greyLight2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (selectedImages.isNotEmpty)
                    Container(
                      height: 300,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: selectedImages.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(selectedImages[index]),
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
                                      color: Colors.red,
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
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
