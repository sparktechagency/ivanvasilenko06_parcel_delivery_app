import 'package:flutter/material.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class ProfileCardWidget extends StatelessWidget {
  final String titleText;
  final String subtitleText;
  final String? additionalText;
  final String? badgeIcon;

  const ProfileCardWidget({
    super.key,
    required this.titleText,
    required this.subtitleText,
    this.additionalText,
    this.badgeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextWidget(
                    text: titleText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontColor: AppColors.black,
                  ),
                  if (badgeIcon != null) const SpaceWidget(spaceWidth: 8),
                  if (badgeIcon != null)
                    IconWidget(
                      height: 12,
                      width: 12,
                      icon: badgeIcon!,
                    ),
                ],
              ),
              TextWidget(
                text: subtitleText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontColor: AppColors.greyDarkLight,
              ),
            ],
          ),
          Row(
            children: [
              if (additionalText != null)
                TextWidget(
                  text: "${AppStrings.currency} ${additionalText!}",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontColor: Colors.black,
                ),
              if (additionalText != null) const SpaceWidget(spaceWidth: 16),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.greyDark2,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
