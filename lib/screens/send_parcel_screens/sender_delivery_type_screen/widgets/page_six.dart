import 'package:flutter/material.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/sender_text_field_widget/sender_text_field_widget.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/phone_field_widget/phone_field_widget.dart';
import '../../../../widgets/space_widget/space_widget.dart';
import '../../../../widgets/text_widget/text_widgets.dart';

class PageSix extends StatelessWidget {
  PageSix({super.key});

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String fullPhoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 32),
          const TextWidget(
            text: AppStrings.enterReceiversDetails,
            fontSize: 24,
            fontWeight: FontWeight.w500,
            fontColor: AppColors.black,
            fontStyle: FontStyle.italic,
            textAlignment: TextAlign.start,
          ),
          const SpaceWidget(spaceHeight: 8),
          const TextWidget(
            text: AppStrings.enterReceiversDetailsDesc,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontColor: AppColors.black,
            fontStyle: FontStyle.italic,
            textAlignment: TextAlign.start,
          ),
          const SpaceWidget(spaceHeight: 24),
          SenderTextFieldWidget(
            controller: nameController,
            hintText: 'Enter your name',
            maxLines: 1,
          ),
          const SpaceWidget(spaceHeight: 16),
          IntlPhoneFieldWidget(
            controller: phoneController,
            hintText: 'Enter your phone number',
            onChanged: (phone) {
              fullPhoneNumber = phone.completeNumber;
            },
            fillColor: AppColors.white,
            borderColor: AppColors.black,
          ),
        ],
      ),
    );
  }
}
