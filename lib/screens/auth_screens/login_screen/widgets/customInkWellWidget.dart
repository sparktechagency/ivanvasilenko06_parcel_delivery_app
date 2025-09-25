import 'package:flutter/material.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

import '../../../../utils/app_size.dart';

class CustomInkWellButton extends StatelessWidget {
  final VoidCallback onTap;
  final String icon;
  final String text;

  const CustomInkWellButton({
    required this.onTap,
    required this.icon,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: double.infinity,
        height: ResponsiveUtils.height(50),
        decoration: BoxDecoration(
          color: AppColors.grey,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconWidget(
              height: 22,
              width: 22,
              icon: icon,
            ),
            const SpaceWidget(spaceWidth: 16),
            TextWidget(
              text: text,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.greyDark,
            ),
          ],
        ),
      ),
    );
  }
}
