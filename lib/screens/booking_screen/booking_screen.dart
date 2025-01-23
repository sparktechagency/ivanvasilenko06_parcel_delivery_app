import 'package:flutter/material.dart';
import 'package:parcel_delivery_app/screens/booking_screen/widgets/current_order_widget.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_image_path.dart';
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

  final List<String> images = [
    AppImagePath.sendParcel,
    AppImagePath.profileImage,
    AppImagePath.sendParcel,
  ];
  final List<String> names = [
    AppStrings.parcel,
    AppStrings.joshua,
    AppStrings.parcel,
  ];
  final List<String> details = [
    AppStrings.parcelDetails,
    AppStrings.viewDetails,
    AppStrings.parcelDetails,
  ];
  final List<String> status = [
    AppStrings.waiting,
    "",
    AppStrings.inTransit,
  ];
  final List<String> progress = [
    AppStrings.removeFromMap,
    AppStrings.cancelDelivery,
    AppStrings.deliveryManDetails,
  ];

  final String phoneNumber = '+1234567890'; // Replace with actual phone number
  final String message = 'Hello, this is a test message';

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        _showErrorSnackBar('Could not launch phone call');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    }
  }

  // Function to send a message
  Future<void> _sendMessage() async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        _showErrorSnackBar('Could not launch messaging app');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
      print('An error occurred: $e');
    }
  }

  // Helper method to show error messages
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

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
              fontSize: 30,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.black,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SpaceWidget(spaceHeight: 24),
          Row(
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
              const VerticalDivider(
                thickness: 1,
                color: AppColors.greyDark,
                width: 20,
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
                CurrentOrderWidget(),
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
