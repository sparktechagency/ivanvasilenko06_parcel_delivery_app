import 'package:flutter/material.dart';
import 'package:parcel_delivery_app/screens/booking_screen/widgets/current_order_widget.dart';
import 'package:parcel_delivery_app/screens/booking_screen/widgets/new_booking_widget.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 48),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextWidget(
              text: AppStrings.bookings,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
            ),
          ),
          const SpaceWidget(spaceHeight: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    _buildTabItem(AppStrings.currentOrders, 0),
                    const SpaceWidget(spaceHeight: 4),
                    Container(
                      height: ResponsiveUtils.height(3),
                      width: ResponsiveUtils.width(12),
                      decoration: BoxDecoration(
                        color: _currentIndex == 0
                            ? AppColors.black
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.greyDarkLight,
                ),
                Column(
                  children: [
                    _buildTabItem(AppStrings.newBookings, 1),
                    const SpaceWidget(spaceHeight: 4),
                    Container(
                      height: ResponsiveUtils.height(3),
                      width: ResponsiveUtils.width(12),
                      decoration: BoxDecoration(
                        color: _currentIndex == 1
                            ? AppColors.black
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SpaceWidget(spaceHeight: 16),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: const [
                CurrentOrderWidget(),
                NewBookingWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.jumpToPage(index); // Change PageView page
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: TextWidget(
        text: label,
        fontColor:
            _currentIndex == index ? AppColors.black : AppColors.greyDarkLight,
        fontSize: 14,
        fontWeight: _currentIndex == index ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}
