import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/page_four.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/page_three.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/page_two.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../widgets/button_widget/button_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class SenderDeliveryTypeScreen extends StatefulWidget {
  SenderDeliveryTypeScreen({super.key});

  final List<String> nonProfessionalImages = [
    AppImagePath.cycleImage,
    AppImagePath.personImage,
    AppImagePath.bikeImage,
    AppImagePath.carImage,
  ];
  final List<String> professionalImages = [
    AppImagePath.truckImage,
  ];
  final List<String> texts = [
    "Vehicle Type",
    "Location",
    "Delivery Time",
    "Description",
    "Price",
    "Phone",
  ];

  @override
  State<SenderDeliveryTypeScreen> createState() =>
      _SenderDeliveryTypeScreenState();
}

class _SenderDeliveryTypeScreenState extends State<SenderDeliveryTypeScreen> {
  int _currentIndex = 0;
  int _currentIndexP = 0;
  int _currentIndexNP = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  int _currentIndexTab = 0;
  final PageController _pageController = PageController();
  final PageController _tabController = PageController();
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _currentStep = index;
                });
              },
              children: [
                _buildPage1(),
                const PageTwo(),
                const PageThree(),
                PageFour(),
                _buildPage5(),
                _buildPage6(),
              ],
            ),
          ),
          // Horizontal Stepper
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return _buildStep(index);
              }),
            ),
          ),
          // Buttons
          Padding(
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
                      radius: ResponsiveUtils.width(30),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
                ButtonWidget(
                  onPressed: () {
                    if (_currentStep < 5) {
                      setState(() {
                        _currentStep++;
                        _pageController.jumpToPage(_currentStep);
                      });
                    } else {
                      Get.toNamed(AppRoutes.selectDeliveryLocationScreen);
                    }
                  },
                  label: _currentStep == 5 ? AppStrings.next : AppStrings.next,
                  textColor: AppColors.white,
                  buttonWidth: 100,
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
        ],
      ),
    );
  }

  Widget _buildStep(int index) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 10,
            width: 10,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color:
                  _currentStep >= index ? AppColors.black : AppColors.greyLight,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.texts[index],
            style: TextStyle(
              color: _currentStep >= index ? AppColors.black : AppColors.grey,
              fontWeight:
                  _currentStep >= index ? FontWeight.normal : FontWeight.normal,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return Column(
      children: [
        const SpaceWidget(spaceHeight: 48),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TextWidget(
            text: AppStrings.senderDeliveryType,
            fontSize: 24,
            fontWeight: FontWeight.w500,
            fontColor: AppColors.black,
            fontStyle: FontStyle.italic,
            textAlignment: TextAlign.start,
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
                  _buildTabItem(AppStrings.nonProfessional, 0),
                  const SpaceWidget(spaceHeight: 4),
                  Container(
                    height: ResponsiveUtils.height(3),
                    width: ResponsiveUtils.width(12),
                    decoration: BoxDecoration(
                      color: _currentIndexTab == 0
                          ? AppColors.black
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  _buildTabItem(AppStrings.professional, 1),
                  const SpaceWidget(spaceHeight: 4),
                  Container(
                    height: ResponsiveUtils.height(3),
                    width: ResponsiveUtils.width(12),
                    decoration: BoxDecoration(
                      color: _currentIndexTab == 1
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
        const SpaceWidget(spaceHeight: 12),
        Expanded(
          child: PageView(
            controller: _tabController,
            onPageChanged: (index) {
              setState(() {
                _currentIndexTab = index;
              });
            },
            children: [
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: CarouselSlider(
                          carouselController: _carouselController,
                          options: CarouselOptions(
                            height: ResponsiveUtils.height(100),
                            enlargeCenterPage: false,
                            autoPlay: false,
                            aspectRatio: 16 / 9,
                            viewportFraction: 0.35,
                            enableInfiniteScroll: false,
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 800),
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentIndexNP = index;
                              });
                            },
                          ),
                          items: widget.nonProfessionalImages
                              .asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key;
                            String imagePath = entry.value;
                            String title = [
                              "Bicycle",
                              "Person",
                              "Bike",
                              "Car",
                            ][index];
                            bool isCentered = index == _currentIndexNP;

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
                                      fontSize: 14,
                                      fontWeight: isCentered
                                          ? FontWeight.w600
                                          : FontWeight.w600,
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
                          icon: const Icon(Icons.arrow_back_ios,
                              color: AppColors.black),
                          onPressed: () {
                            if (_currentIndexNP > 0) {
                              _carouselController
                                  .jumpToPage(_currentIndexNP - 1);
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
                            if (_currentIndexNP <
                                widget.nonProfessionalImages.length - 1) {
                              _carouselController
                                  .jumpToPage(_currentIndexNP + 1);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: CarouselSlider(
                          carouselController: _carouselController,
                          options: CarouselOptions(
                            height: ResponsiveUtils.height(100),
                            enlargeCenterPage: false,
                            autoPlay: false,
                            aspectRatio: 16 / 9,
                            viewportFraction: 0.35,
                            enableInfiniteScroll: false,
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 800),
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentIndexP = index;
                              });
                            },
                          ),
                          items: widget.professionalImages
                              .asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key;
                            String imagePath = entry.value;
                            String title = ["Truck"][index];
                            bool isCentered = index == _currentIndexP;

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
                                      fontSize: 14,
                                      fontWeight: isCentered
                                          ? FontWeight.w600
                                          : FontWeight.w600,
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
                          icon: const Icon(Icons.arrow_back_ios,
                              color: AppColors.black),
                          onPressed: () {
                            if (_currentIndexP > 0) {
                              _carouselController
                                  .jumpToPage(_currentIndexP - 1);
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
                            if (_currentIndexP <
                                widget.professionalImages.length - 1) {
                              _carouselController
                                  .jumpToPage(_currentIndexP + 1);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPage2() {
    return Center(
      child: Text('Page 2 Content'),
    );
  }

  Widget _buildPage3() {
    return Center(
      child: Text('Page 3 Content'),
    );
  }

  Widget _buildPage4() {
    return Center(
      child: Text('Page 4 Content'),
    );
  }

  Widget _buildPage5() {
    return Center(
      child: Text('Page 5 Content'),
    );
  }

  Widget _buildPage6() {
    return Center(
      child: Text('Page 6 Content'),
    );
  }

  Widget _buildTabItem(String label, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndexTab = index;
        });
        _tabController.jumpToPage(index); // Change PageView page
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: TextWidget(
        text: label,
        fontColor: _currentIndexTab == index
            ? AppColors.black
            : AppColors.greyDarkLight,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
