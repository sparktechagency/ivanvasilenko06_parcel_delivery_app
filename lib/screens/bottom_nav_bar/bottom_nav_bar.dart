import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/widgets/bottom_nav_bar_item_widget.dart';
import 'package:parcel_delivery_app/screens/services_screen/services_screen.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_icons_path.dart';
import '../booking_screen/booking_screen.dart';
import '../home_screen/home_screen.dart';
import '../profile_screen/profile_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;
  late List<Widget> tabs;

  @override
  void initState() {
    tabs = [
      const HomeScreen(),
      ServicesScreen(),
      const BookingScreen(),
      const ProfileScreen(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: tabs[_currentIndex],
      extendBody: true,
      bottomNavigationBar: Container(
        height: ResponsiveUtils.height(70),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 3,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.black,
          unselectedItemColor: AppColors.greyDarkLight,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: ResponsiveUtils.width(14),
          unselectedFontSize: ResponsiveUtils.width(14),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: [
            BottomNavBarItemWidget(
              icon: AppIconsPath.homeIcon,
              label: "home".tr,
              isSelected: _currentIndex == 0,
            ),
            BottomNavBarItemWidget(
              icon: AppIconsPath.servicesIcon,
              label: "services".tr,
              isSelected: _currentIndex == 1,
            ),
            BottomNavBarItemWidget(
              icon: AppIconsPath.bookingIcon,
              label: "bookings".tr,
              isSelected: _currentIndex == 2,
            ),
            BottomNavBarItemWidget(
              icon: AppIconsPath.profileIcon,
              label: "profile".tr,
              isSelected: _currentIndex == 3,
            ),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
