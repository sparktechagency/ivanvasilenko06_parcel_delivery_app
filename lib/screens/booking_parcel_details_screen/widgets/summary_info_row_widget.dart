import 'package:flutter/material.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/icon_widget/icon_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class SummaryInfoRowWidget extends StatelessWidget {
  final String? icon;
  final String? image;
  final String label;
  final String value;
  final bool isMultiline;

  const SummaryInfoRowWidget({
    super.key,
    this.icon,
    this.image,
    required this.label,
    required this.value,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget leadingWidget;

    if (image != null) {
      leadingWidget = ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: ImageWidget(
          height: 22,
          width: 22,
          imagePath: image!,
        ),
      );
    } else if (icon != null) {
      leadingWidget = IconWidget(
        icon: icon!,
        width: 18,
        height: 18,
      );
    } else {
      throw Exception("Either imagePath or iconData must be provided.");
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leadingWidget,
          const SpaceWidget(spaceWidth: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: ResponsiveUtils.width(140),
                child: TextWidget(
                  text: label,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.greyDark,
                  overflow: TextOverflow.ellipsis,
                  textAlignment: TextAlign.start,
                ),
              ),
              const SpaceWidget(spaceWidth: 16),
              SizedBox(
                width: ResponsiveUtils.width(150),
                child: TextWidget(
                  text: value,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.blackLight,
                  overflow: TextOverflow.ellipsis,
                  textAlignment: TextAlign.start,
                  maxLines: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
