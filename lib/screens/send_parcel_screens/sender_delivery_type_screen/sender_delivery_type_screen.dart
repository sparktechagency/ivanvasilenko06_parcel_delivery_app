import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/controller/sending_parcel_controller.dart';
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

  @override
  State<SenderDeliveryTypeScreen> createState() =>
      _SenderDeliveryTypeScreenState();
}

class _SenderDeliveryTypeScreenState extends State<SenderDeliveryTypeScreen> {
  ParcelController parcelController = Get.put(ParcelController());

  final List<String> nonProfessionalImages = [
    AppImagePath.bikeImage,
    AppImagePath.carImage,
    AppImagePath.cycleImage,
    AppImagePath.checkedPlane,
    AppImagePath.personImage,
  ];

  final List<String> professionalImages = [
    AppImagePath.truckImage,
    AppImagePath.checkingTexi,
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: PageView(
              controller: parcelController.pageController,
              onPageChanged: (index) {
                setState(() {
                  parcelController.currentStep.value = index;
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
                  onTap: parcelController.goToPreviousStep,
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
                  onPressed: parcelController.goToNextStep,
                  label: parcelController.currentStep.value == 5
                      ? "next".tr
                      : "next".tr,
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
    return Obx(() => Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // This is the stepper design
                    parcelController.currentStep.value >= index
                        ? Image.asset(
                            height: 15,
                            width: 15,
                            images[index],
                          )
                        : Image.asset(
                            height: 15,
                            width: 15,
                            images[index],
                            color: AppColors.white,
                          ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                        color: parcelController.currentStep.value >= index
                            ? AppColors.black
                            : AppColors.greyLight,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      texts[index],
                      maxLines: 1,
                      style: TextStyle(
                          color: parcelController.currentStep.value >= index
                              ? AppColors.black
                              : AppColors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 8,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              if (index < texts.length - 1)
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    margin: const EdgeInsets.only(top: 4),
                    height: 1,
                    decoration: BoxDecoration(
                      color: parcelController.currentStep.value >= index
                          ? AppColors.black
                          : AppColors.greyLight,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
            ],
          ),
        ));
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
                  Obx(() => Container(
                        height: ResponsiveUtils.height(3),
                        width: ResponsiveUtils.width(12),
                        decoration: BoxDecoration(
                          color: parcelController.isProfessional.value == false
                              ? AppColors.black
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      )),
                ],
              ),
              Column(
                children: [
                  _buildTabItem("professional".tr, 1),
                  const SpaceWidget(spaceHeight: 4),
                  Obx(() => Container(
                        height: ResponsiveUtils.height(3),
                        width: ResponsiveUtils.width(12),
                        decoration: BoxDecoration(
                          color: parcelController.isProfessional.value == true
                              ? AppColors.black
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
        const SpaceWidget(spaceHeight: 24),
        Expanded(
          child: PageView(
            controller: parcelController.tabController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                parcelController.isProfessional.value = index == 1;
              });
            },
            children: [
              _buildNonProfessionalTab(),
              _buildProfessionalTab(),
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
          parcelController.isProfessional.value = index == 1;
        });
        parcelController.tabController.jumpToPage(index);
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Obx(() => TextWidget(
            text: label,
            fontColor: parcelController.isProfessional.value == (index == 1)
                ? AppColors.black
                : AppColors.greyDarkLight,
            fontSize: 14,
            fontWeight: parcelController.isProfessional.value == (index == 1)
                ? FontWeight.w600
                : FontWeight.w400,
          )),
    );
  }

  Widget _buildNonProfessionalTab() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: CarouselSlider(
                carouselController: parcelController.carouselController,
                options: CarouselOptions(
                  height: ResponsiveUtils.height(170),
                  enlargeCenterPage: true,
                  autoPlay: false,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.35,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  onPageChanged: (index, reason) {
                    setState(() {
                      parcelController.currentStep.value = index;
                    });
                  },
                ),
                items: nonProfessionalImages.asMap().entries.map((entry) {
                  int index = entry.key;
                  String imagePath = entry.value;
                  String title = [
                    "bike".tr,
                    "car".tr,
                    "bicycle".tr,
                    "Plane".tr,
                    "person".tr,
                  ][index % 5];
                  bool isCentered =
                      index == parcelController.currentStep.value;

                  return Builder(
                    builder: (BuildContext context) {
                      return Column(
                        children: [
                          ImageWidget(
                            height: 82,
                            width: 82,
                            imagePath: imagePath,
                          ),
                          const SizedBox(height: 2),
                          Flexible(
                            child: TextWidget(
                              text: title,
                              fontSize: 14,
                              fontWeight: isCentered
                                  ? FontWeight.w600
                                  : FontWeight.w600,
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
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
                onPressed: () {
                  if (parcelController.currentStep.value > 0) {
                    setState(() {
                      parcelController.currentStep.value--;
                    });
                    parcelController.carouselController
                        .jumpToPage(parcelController.currentStep.value);
                  }
                },
              ),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon:
                    const Icon(Icons.arrow_forward_ios, color: AppColors.black),
                onPressed: () {
                  if (parcelController.currentStep.value <
                      nonProfessionalImages.length - 1) {
                    setState(() {
                      parcelController.currentStep.value++;
                    });
                    parcelController.carouselController
                        .jumpToPage(parcelController.currentStep.value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfessionalTab() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CarouselSlider(
                carouselController: parcelController.carouselController,
                options: CarouselOptions(
                  height: ResponsiveUtils.height(170),
                  enlargeCenterPage: true,
                  autoPlay: false,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.35,
                  enableInfiniteScroll: false,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  onPageChanged: (index, reason) {
                    setState(() {
                      parcelController.currentStep.value = index;
                    });
                  },
                ),
                items: professionalImages.asMap().entries.map((entry) {
                  int index = entry.key;
                  String imagePath = entry.value;
                  String title = [
                    "truck".tr,
                    "Taxi".tr,
                  ][index];
                  bool isCentered =
                      index == parcelController.currentStep.value;

                  return Builder(
                    builder: (BuildContext context) {
                      return Column(
                        children: [
                          ImageWidget(
                            height: 82,
                            width: 82,
                            imagePath: imagePath,
                          ),
                          const SizedBox(height: 2),
                          Flexible(
                            child: TextWidget(
                              text: title,
                              fontSize: isCentered ? 16 : 14,
                              fontWeight: isCentered
                                  ? FontWeight.w600
                                  : FontWeight.w600,
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
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
                onPressed: () {
                  if (parcelController.currentStep.value > 0) {
                    setState(() {
                      parcelController.currentStep.value--;
                    });
                    parcelController.carouselController
                        .jumpToPage(parcelController.currentStep.value);
                  }
                },
              ),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon:
                    const Icon(Icons.arrow_forward_ios, color: AppColors.black),
                onPressed: () {
                  if (parcelController.currentStep.value <
                      professionalImages.length - 1) {
                    setState(() {
                      parcelController.currentStep.value++;
                    });
                    parcelController.carouselController
                        .jumpToPage(parcelController.currentStep.value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
