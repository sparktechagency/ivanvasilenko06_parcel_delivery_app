import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/screens/booking_screen/widgets/new_booking_widget.dart';
import 'package:parcel_delivery_app/screens/history_screen/widgets/history_order_widget.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.black,
                    size: 22,
                  ),
                ),
                const TextWidget(
                  text: AppStrings.history,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.black,
                  fontStyle: FontStyle.italic,
                ),
              ],
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
                    _buildTabItem(AppStrings.orders, 0),
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
                Column(
                  children: [
                    _buildTabItem(AppStrings.bookings, 1),
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
                HistoryOrderWidget(),
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
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
