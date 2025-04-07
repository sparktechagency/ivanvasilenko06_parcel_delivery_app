import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_image_path.dart';
import '../../../widgets/button_widget/button_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';
import '../controller/delivery_screens_controller.dart';

class DeliveryTypeScreen extends StatefulWidget {
  DeliveryTypeScreen({super.key});

  final List<String> images = [
    AppImagePath.bikeImage,
    AppImagePath.carImage,
    AppImagePath.checkingTexi,
    AppImagePath.cycleImage,
    AppImagePath.truckImage,
    AppImagePath.checkedPlane,
    AppImagePath.personImage,
  ];

  @override
  State<DeliveryTypeScreen> createState() => _DeliveryTypeScreenState();
}

class _DeliveryTypeScreenState extends State<DeliveryTypeScreen> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  final DeliveryScreenController _controller =
      Get.put(DeliveryScreenController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carouselController.jumpToPage(_currentIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images ?? [];
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
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: 170,
                    enlargeCenterPage: true,
                    autoPlay: false,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.35,
                    enableInfiniteScroll: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                      // Update the selected delivery type as a string (no enum)
                      String selectedType = [
                        "bike",
                        "car",
                        "Taxi",
                        "bicycle",
                        "truck",
                        "Plane",
                        "person"
                      ][index];
                      _controller.setSelectedDeliveryType(selectedType);
                    },
                  ),
                  items: images.asMap().entries.map((entry) {
                    int index = entry.key;
                    String imagePath = entry.value;
                    String title = [
                      "bike".tr,
                      "car".tr,
                      "Taxi".tr,
                      "bicycle".tr,
                      "truck".tr,
                      "Plane".tr,
                      "person".tr
                    ][index];

                    bool isCentered = index == _currentIndex;

                    return Builder(
                      builder: (BuildContext context) {
                        return Column(
                          children: [
                            ImageWidget(
                                height: 75, width: 75, imagePath: imagePath),
                            const SizedBox(height: 1),
                            Flexible(
                              child: TextWidget(
                                text: title,
                                fontSize: isCentered ? 16 : 14,
                                fontWeight: isCentered
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                fontColor: isCentered
                                    ? AppColors.black
                                    : AppColors.greyDarkLight,
                              ),
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
                    // Infinite loop for the carousel
                    _carouselController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios,
                      color: AppColors.black),
                  onPressed: () {
                    // Infinite loop for the carousel
                    _carouselController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ],
          ),
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
              child: const CircleAvatar(
                backgroundColor: AppColors.white,
                radius: 25,
                child: Icon(Icons.arrow_back, color: AppColors.black),
              ),
            ),
            ButtonWidget(
              onPressed: () {
                // Passing the selected delivery type as an argument to the next screen
                Get.toNamed(AppRoutes.selectDeliveryLocationScreen,
                    arguments: _controller.selectedDeliveryType.value);
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
