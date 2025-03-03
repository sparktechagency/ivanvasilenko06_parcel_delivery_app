import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/page_five.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/page_four.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/page_six.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/page_three.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/page_two.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';

import '../../../constants/app_colors.dart';
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
    "vehicleType".tr,
    "location".tr,
    "deliveryTimeText".tr,
    "descriptionText".tr,
    "price".tr,
    "phone".tr,
  ];
  final List<String> images = [
    AppImagePath.stepper1,
    AppImagePath.stepper2,
    AppImagePath.stepper3,
    AppImagePath.stepper4,
    AppImagePath.stepper5,
    AppImagePath.stepper6,
  ];

  @override
  State<SenderDeliveryTypeScreen> createState() =>
      _SenderDeliveryTypeScreenState();
}

class _SenderDeliveryTypeScreenState extends State<SenderDeliveryTypeScreen> {
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
                  _currentStep = index;
                });
              },
              children: [
                _buildPage1(),
                const PageTwo(),
                const PageThree(),
                const PageFour(),
                PageFive(),
                PageSix(),
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
                    if (_currentStep == 0) {
                      Get.back();
                    } else {
                      setState(() {
                        _currentStep--;
                        _pageController.jumpToPage(_currentStep);
                      });
                    }
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
                    if (_currentStep < 5) {
                      setState(() {
                        _currentStep++;
                        _pageController.jumpToPage(_currentStep);
                      });
                    } else {
                      Get.toNamed(AppRoutes.senderSummaryOfParcelScreen);
                    }
                  },
                  label: _currentStep == 5 ? "next".tr : "next".tr,
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
        ],
      ),
    );
  }

  Widget _buildStep(int index) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //This is the stepper desig
                _currentStep >= index
                    ? Image.asset(
                        height: 15,
                        width: 15,
                        widget.images[index],
                      )
                    : Image.asset(
                        height: 15,
                        width: 15,
                        widget.images[index],
                        color: AppColors.white,
                      ),
                const SizedBox(height: 4),
                Container(
                  height: 10,
                  width: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                    color: _currentStep >= index
                        ? AppColors.black
                        : AppColors.greyLight,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.texts[index],
                  maxLines: 1,
                  style: TextStyle(
                      color: _currentStep >= index
                          ? AppColors.black
                          : AppColors.white,
                      fontWeight: _currentStep >= index
                          ? FontWeight.normal
                          : FontWeight.normal,
                      fontSize: 8,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          if (index < widget.texts.length - 1)
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                margin: const EdgeInsets.only(top: 4),
                height: 1,
                decoration: BoxDecoration(
                  color: _currentStep >= index
                      ? AppColors.black
                      : AppColors.greyLight,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildPage1() {
    final isRTL = Get.locale?.languageCode == 'he';
    return Column(
      children: [
        const SpaceWidget(spaceHeight: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextWidget(
            text: "senderDeliveryType".tr,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontColor: AppColors.black,
            textAlignment: isRTL ? TextAlign.right : TextAlign.left,
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
                  _buildTabItem("nonProfessional".tr, 0),
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
                  _buildTabItem("professional".tr, 1),
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
        const SpaceWidget(spaceHeight: 24),
        Expanded(
          child: PageView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
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
                              "bicycle".tr,
                              "person".tr,
                              "bike".tr,
                              "car".tr,
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
                            height: ResponsiveUtils.height(150),
                            enlargeCenterPage: true,
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
                            String title = ["truck".tr][index];
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
        fontSize: 14,
        fontWeight:
            _currentIndexTab == index ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}
