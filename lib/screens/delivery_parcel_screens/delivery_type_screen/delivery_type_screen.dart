import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/button_widget/button_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class DeliveryTypeScreen extends StatefulWidget {
  DeliveryTypeScreen({super.key});

  final List<String> images = [
    AppImagePath.cycleImage,
    AppImagePath.personImage,
    AppImagePath.bikeImage,
    AppImagePath.carImage,
    AppImagePath.truckImage,
  ];

  @override
  State<DeliveryTypeScreen> createState() => _DeliveryTypeScreenState();
}

class _DeliveryTypeScreenState extends State<DeliveryTypeScreen> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextWidget(
              text: "deliveryType".tr,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
            ),
          ),
          const SpaceWidget(spaceHeight: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: ResponsiveUtils.height(150),
                    enlargeCenterPage: true,
                    autoPlay: false,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.35,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                  items: widget.images.asMap().entries.map((entry) {
                    int index = entry.key;
                    String imagePath = entry.value;
                    String title = [
                      "bicycle".tr,
                      "person".tr,
                      "bike".tr,
                      "car".tr,
                      "truck".tr
                    ][index];
                    bool isCentered = index == _currentIndex;

                    return Builder(
                      builder: (BuildContext context) {
                        return Column(
                          children: [
                            ImageWidget(
                              height: 70,
                              width: 70,
                              imagePath: imagePath,
                            ),
                            const SizedBox(height: 2),
                            TextWidget(
                              text: title,
                              fontSize: isCentered ? 15 : 14,
                              fontWeight: isCentered
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontColor: isCentered
                                  ? AppColors.black
                                  : AppColors.greyDarkLight,
                            ),
                          ],
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              Positioned(
                left: 0,
                child: IconButton(
                  icon:
                      const Icon(Icons.arrow_back_ios, color: AppColors.black),
                  onPressed: () {
                    if (_currentIndex > 0) {
                      _carouselController.jumpToPage(_currentIndex - 1);
                    }
                  },
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios,
                      color: AppColors.black),
                  onPressed: () {
                    if (_currentIndex < widget.images.length - 1) {
                      _carouselController.jumpToPage(_currentIndex + 1);
                    }
                  },
                ),
              ),
            ],
          )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                Get.back();
              },
              borderRadius: BorderRadius.circular(100),
              child: Card(
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: 3,
                child: CircleAvatar(
                  backgroundColor: AppColors.white,
                  radius: ResponsiveUtils.width(25),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
            ButtonWidget(
              onPressed: () {
                Get.toNamed(AppRoutes.selectDeliveryLocationScreen);
              },
              label: "next".tr,
              textColor: AppColors.white,
              buttonWidth: 105,
              buttonHeight: 50,
              icon: Icons.arrow_forward,
              iconColor: AppColors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
