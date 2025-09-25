import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_strings.dart';
import '../../../../utils/app_size.dart';
import '../../../../widgets/space_widget/space_widget.dart';
import '../../../../widgets/text_widget/text_widgets.dart';

class OrWidget extends StatelessWidget {
  const OrWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: ResponsiveUtils.width(50),
          height: ResponsiveUtils.height(1),
          color: AppColors.greyLighter,
        ),
        const SpaceWidget(spaceWidth: 10),
        const TextWidget(
          text: AppStrings.or,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontColor: AppColors.greyLighter,
          fontStyle: FontStyle.italic,
        ),
        const SpaceWidget(spaceWidth: 10),
        Container(
          width: ResponsiveUtils.width(50),
          height: ResponsiveUtils.height(1),
          color: AppColors.greyLighter,
        ),
      ],
    );
  }
}
