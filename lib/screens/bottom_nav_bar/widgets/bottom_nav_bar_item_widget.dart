import 'package:flutter/material.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';

import '../../../constants/app_colors.dart';
import '../../../utils/app_size.dart';

class BottomNavBarItemWidget extends BottomNavigationBarItem {
  BottomNavBarItemWidget({
    required String icon,
    required String label,
    required bool isSelected,
  }) : super(
          icon: IconWidget(
            icon: icon,
            height: ResponsiveUtils.width(24),
            width: ResponsiveUtils.width(24),
            color: isSelected ? AppColors.black : AppColors.greyDarkLight,
          ),
          label: label,
        );
}
