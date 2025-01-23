import 'package:flutter/material.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/screens/home_screen/widgets/earn_money_card_widget.dart';
import 'package:parcel_delivery_app/screens/home_screen/widgets/home_screen_appbar.dart';
import 'package:parcel_delivery_app/screens/home_screen/widgets/suggestionCardWidget.dart';

import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeScreenAppBar(
            logoImagePath: AppImagePath.appLogo,
            notificationIconPath: AppIconsPath.notificationIcon,
            onNotificationPressed: () {},
            badgeLabel: "1",
            profileImagePath: AppImagePath.profileImage,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextWidget(
                      text: AppStrings.suggestions,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontColor: AppColors.black,
                      fontStyle: FontStyle.italic,
                    ),
                    const SpaceWidget(spaceHeight: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SuggestionCardWidget(
                          onTap: () {},
                          text: AppStrings.deliverParcel,
                          imagePath: AppImagePath.deliverParcel,
                        ),
                        SuggestionCardWidget(
                          onTap: () {},
                          text: AppStrings.sendParcel,
                          imagePath: AppImagePath.sendParcel,
                        ),
                        SuggestionCardWidget(
                          onTap: () {},
                          text: AppStrings.reserve,
                          imagePath: AppImagePath.reserve,
                        ),
                      ],
                    ),
                    const SpaceWidget(spaceHeight: 24),
                    const TextWidget(
                      text: AppStrings.earnMoney,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontColor: AppColors.black,
                      fontStyle: FontStyle.italic,
                    ),
                    const SpaceWidget(spaceHeight: 16),
                    EarnMoneyCardWidget(
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
