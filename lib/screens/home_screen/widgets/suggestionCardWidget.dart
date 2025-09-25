import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../utils/app_size.dart';
import '../../../widgets/image_widget/image_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class SuggestionCardWidget extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final String imagePath;

  const SuggestionCardWidget({
    super.key,
    required this.onTap,
    required this.text,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: ResponsiveUtils.width(105),
        height: ResponsiveUtils.height(110),
        decoration: BoxDecoration(
          color: AppColors.greyLightest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageWidget(
              height: 51,
              width: 77,
              imagePath: imagePath,
            ),
            const SpaceWidget(spaceHeight: 4),
            TextWidget(
              text: text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.blackLight,
            ),
          ],
        ),
      ),
    );
  }
}
