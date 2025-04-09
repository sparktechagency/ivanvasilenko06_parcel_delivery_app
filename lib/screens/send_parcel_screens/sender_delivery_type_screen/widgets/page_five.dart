import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/controller/sending_parcel_controller.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/sender_text_field_widget/sender_text_field_widget.dart';

import '../../../../constants/app_colors.dart';
import '../../../../widgets/space_widget/space_widget.dart';
import '../../../../widgets/text_widget/text_widgets.dart';

class PageFive extends StatelessWidget {
  PageFive({super.key});

  final ParcelController parcelController =
      Get.put(ParcelController()); // Initialize the controller

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 32),
          TextWidget(
            text: "enterPrice".tr,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontColor: AppColors.black,
            textAlignment: TextAlign.start,
          ),
          const SpaceWidget(spaceHeight: 8),
          TextWidget(
            text: "enterPriceDesc".tr,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontColor: AppColors.black,
            textAlignment: TextAlign.start,
          ),
          const SpaceWidget(spaceHeight: 24),
          SenderTextFieldWidget(
            controller: parcelController.priceController,
            hintText: "enterYourPrice".tr,
            maxLines: 1,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
