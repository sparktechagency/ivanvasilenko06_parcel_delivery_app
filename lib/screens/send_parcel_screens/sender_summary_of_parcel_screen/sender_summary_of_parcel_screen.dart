import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/screens/delivery_parcel_screens/summary_of_parcel_screen/widgets/summary_info_row_widget.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/controller/sending_parcel_controller.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_icons_path.dart';
import '../../../utils/app_size.dart';
import '../../../widgets/button_widget/button_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class SenderSummaryOfParcelScreen extends StatelessWidget {
  const SenderSummaryOfParcelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParcelController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Stack(
            children: [
              // Main content of the screen
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SpaceWidget(spaceHeight: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextWidget(
                      text: "summaryOfYourParcel".tr,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.black,
                    ),
                  ),
                  const SpaceWidget(spaceHeight: 40),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: const ImageWidget(
                                  height: 40,
                                  width: 40,
                                  imagePath: AppImagePath.sendParcel,
                                ),
                              ),
                              const SpaceWidget(spaceWidth: 8),
                              TextWidget(
                                text: controller.titleController.text,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                fontColor: AppColors.black,
                              ),
                            ],
                          ),
                          const SpaceWidget(spaceHeight: 16),
                          const Divider(
                            color: AppColors.grey,
                            thickness: 1,
                          ),
                          const SpaceWidget(spaceHeight: 16),
                          SummaryInfoRowWidget(
                            icon: AppIconsPath.deliveryTimeIcon,
                            label: "deliveryTimeText".tr,
                            value: controller
                                .formatDateTime(controller.selectedDate.value),
                          ),
                          const SpaceWidget(spaceHeight: 8),
                          SummaryInfoRowWidget(
                            icon: AppIconsPath.destinationIcon,
                            label: "currentLocationText".tr,
                            value: controller.startingLocation.string,
                          ),
                          const SpaceWidget(spaceHeight: 8),
                          SummaryInfoRowWidget(
                            icon: AppIconsPath.currentLocationIcon,
                            label: "destinationText".tr,
                            value: controller.endingLocation.string,
                          ),
                          const SpaceWidget(spaceHeight: 8),
                          SummaryInfoRowWidget(
                            icon: AppIconsPath.priceIcon,
                            label: "price".tr,
                            value: controller.priceController.text,
                          ),
                          const SpaceWidget(spaceHeight: 8),
                          SummaryInfoRowWidget(
                            icon: AppIconsPath.profileIcon,
                            label: "receiversName".tr,
                            value: controller.nameController.text,
                          ),
                          const SpaceWidget(spaceHeight: 8),
                          SummaryInfoRowWidget(
                            icon: AppIconsPath.callIcon,
                            label: "receiversNumber".tr,
                            value: controller.completePhoneNumber.value,
                          ),
                          const SpaceWidget(spaceHeight: 8),
                          SummaryInfoRowWidget(
                            icon: AppIconsPath.descriptionIcon,
                            label: "descriptionText".tr,
                            value: controller.descriptionController.text,
                          ),
                          const SpaceWidget(spaceHeight: 8),
                          Container(
                            height: 400,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.grey),
                            ),
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                              itemCount: controller.selectedImages.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(File(
                                          controller.selectedImages[index])),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // CircularProgressIndicator in the center of the screen
              Obx(() => controller.isLoading.value
                  ? Center(
                      child: LoadingAnimationWidget.hexagonDots(
                        color: AppColors.green,
                        size: 40,
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
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
                Obx(() => ButtonWidget(
                      onPressed: () async {
                        // Prevent multiple submissions
                        if (controller.isLoading.value) return;

                        // Call the submitParcelData function
                        await controller.submitParcelData();
                      },
                      label: "finish".tr,
                      textColor: AppColors.white,
                      backgroundColor: controller.isLoading.value
                          ? AppColors.greyDark2
                          : AppColors.black,
                      buttonWidth: 112,
                      buttonHeight: 50,
                      icon: Icons.arrow_forward,
                      iconColor: AppColors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      iconSize: 20,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
