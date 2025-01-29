import 'package:flutter/material.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/sender_text_field_widget/sender_text_field_widget.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/space_widget/space_widget.dart';
import '../../../../widgets/text_widget/text_widgets.dart';

class PageFive extends StatelessWidget {
  PageFive({super.key});

  final priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 32),
          const TextWidget(
            text: AppStrings.enterPrice,
            fontSize: 24,
            fontWeight: FontWeight.w500,
            fontColor: AppColors.black,
            fontStyle: FontStyle.italic,
            textAlignment: TextAlign.start,
          ),
          const SpaceWidget(spaceHeight: 8),
          const TextWidget(
            text: AppStrings.enterPriceDesc,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontColor: AppColors.black,
            fontStyle: FontStyle.italic,
            textAlignment: TextAlign.start,
          ),
          const SpaceWidget(spaceHeight: 24),
          SenderTextFieldWidget(
            controller: priceController,
            hintText: '₪ Enter Your Price',
            maxLines: 1,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
