import 'package:flutter/material.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/screens/home_screen/widgets/home_screen_appbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          HomeScreenAppBar(
            logoImagePath: AppImagePath.appLogo,
            notificationIconPath: AppIconsPath.notificationIcon,
            onNotificationPressed: () {},
            badgeLabel: "1",
            profileImagePath: AppImagePath.profileImage,
          ),
        ],
      ),
    );
  }
}
