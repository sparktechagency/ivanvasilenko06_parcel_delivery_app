
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/controller/sending_parcel_controller.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/sender_text_field_widget/sender_text_field_widget.dart';

import '../../../../constants/app_colors.dart';
import '../../../../widgets/phone_field_widget/phone_field_widget.dart';
import '../../../../widgets/space_widget/space_widget.dart';
import '../../../../widgets/text_widget/text_widgets.dart';

class PageSix extends StatelessWidget {
  PageSix({super.key});

  final ParcelController parcelController = Get.put(ParcelController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 32),
          TextWidget(
            text: "enterReceiversDetails".tr,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontColor: AppColors.black,
            textAlignment: TextAlign.start,
          ),
          const SpaceWidget(spaceHeight: 8),
          TextWidget(
            text: "enterReceiversDetailsDesc".tr,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontColor: AppColors.black,
            textAlignment: TextAlign.start,
          ),
          const SpaceWidget(spaceHeight: 24),
          SenderTextFieldWidget(
            controller: parcelController.nameController,
            hintText: "enterReceiversName".tr,
            maxLines: 1,
          ),
          const SpaceWidget(spaceHeight: 16),
          IntlPhoneFieldWidget(
            hintText: "enterReceiversNumber".tr,
            controller: parcelController.phoneController,
            onChanged: (phone) {
              parcelController.updatePhoneNumber(phone.completeNumber);
              //! log("Complete number: ${phone.completeNumber}");
              //! log("Country code: ${phone.countryCode}");
              //! log("Number without code: ${phone.number}");
            },
            fillColor: AppColors.white,
            borderColor: AppColors.black,
            initialCountryCode: "IL", // Default to Israel
          ),
        ],
      ),
    );
  }
}
