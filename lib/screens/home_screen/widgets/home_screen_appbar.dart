import 'package:flutter/material.dart';
import 'package:parcel_delivery_app/widgets/image_widget/app_images.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/icon_widget/icon_widget.dart';
import '../../../widgets/image_widget/image_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';

class HomeScreenAppBar extends StatelessWidget {
  final String logoImagePath;
  final String notificationIconPath;
  final VoidCallback onNotificationPressed;
  final String badgeLabel;
  final String profileImagePath;

  const HomeScreenAppBar({
    super.key,
    required this.logoImagePath,
    required this.notificationIconPath,
    required this.onNotificationPressed,
    required this.badgeLabel,
    required this.profileImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 60, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ImageWidget(
            height: 48,
            width: 170,
            imagePath: logoImagePath,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: "Notifications",
                onPressed: onNotificationPressed,
                icon: Badge(
                  isLabelVisible: true,
                  label: Text(badgeLabel),
                  backgroundColor: AppColors.red,
                  child: IconWidget(
                    icon: notificationIconPath,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              const SpaceWidget(spaceWidth: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: AppImage(
                  height: 40,
                  width: 40,
                  url: profileImagePath,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
