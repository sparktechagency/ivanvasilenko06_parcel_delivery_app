import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_image_path.dart';
import '../../../constants/app_strings.dart';
import '../../../widgets/button_widget/button_widget.dart';
import '../../../widgets/image_widget/image_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class EarnMoneyCardWidget extends StatelessWidget {
  final VoidCallback onTap;

  const EarnMoneyCardWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.greyLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: ImageWidget(
              height: 180,
              width: double.infinity,
              imagePath: AppImagePath.earnMoney,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextWidget(
                  text: AppStrings.earnMoneyDesc,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.black,
                  textAlignment: TextAlign.start,
                ),
                const SpaceWidget(spaceHeight: 12),
                ButtonWidget(
                  onPressed: onTap,
                  label: AppStrings.earnMoneyInYourRadius,
                  buttonWidth: 250,
                  buttonHeight: 50,
                  icon: Icons.arrow_forward,
                  iconColor: AppColors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
