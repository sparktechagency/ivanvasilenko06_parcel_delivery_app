import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/controller/sending_parcel_controller.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/page_five.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/page_four.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/page_six.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/page_three.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/sender_delivery_type_screen/widgets/page_two.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

class SenderDeliveryTypeScreen extends StatefulWidget {
  const SenderDeliveryTypeScreen({super.key});

  @override
  State<SenderDeliveryTypeScreen> createState() =>
      _SenderDeliveryTypeScreenState();
}

class _SenderDeliveryTypeScreenState extends State<SenderDeliveryTypeScreen> {
  int currentCarouselIndex = 0;
  ParcelController parcelController = Get.put(ParcelController());

  @override
  void initState() {
    super.initState();
    // Initially set the delivery type and vehicle type
    parcelController.selectedDeliveryType.value =
        "non-professional"; // Default to non-professional
    parcelController.selectedVehicleType.value =
        'bike'; // Default vehicle for non-professional
  }

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
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
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
                PageFour(),
                PageFive(),
                PageSix(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return _buildStep(index);
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: parcelController.goToPreviousStep,
                  borderRadius: BorderRadius.circular(100),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 25,
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                ),
                ButtonWidget(
                  onPressed: () {
                    parcelController.goToNextStep();
                  },
                  label: parcelController.currentStep.value == 5
                      ? "next".tr
                      : "next".tr,
                  textColor: Colors.white,
                  buttonWidth: 105,
                  buttonHeight: 50,
                  icon: Icons.arrow_forward,
                  iconColor: Colors.white,
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
                            color: Colors.white,
                          ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                        color: parcelController.currentStep.value >= index
                            ? Colors.black
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      texts[index],
                      maxLines: 1,
                      style: TextStyle(
                        color: parcelController.currentStep.value >= index
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 8,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                          ? Colors.black
                          : Colors.grey,
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
            fontColor: Colors.black,
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
                  _buildTabItem("nonProfessional".tr, "non-professional"),
                  const SpaceWidget(spaceHeight: 4),
                  Obx(() => Container(
                        height: 3,
                        width: 12,
                        decoration: BoxDecoration(
                          color: parcelController.selectedDeliveryType.value ==
                                  "non-professional"
                              ? Colors.black
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ))
                ],
              ),
              Column(
                children: [
                  _buildTabItem("professional".tr, "professional"),
                  const SpaceWidget(spaceHeight: 4),
                  Obx(() => Container(
                        height: 3,
                        width: 12,
                        decoration: BoxDecoration(
                          color: parcelController.selectedDeliveryType.value ==
                                  "professional"
                              ? Colors.black
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ))
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
              if (index == 1) {
                parcelController.selectedDeliveryType.value = "professional";
                parcelController.selectedVehicleType.value = 'truck';
              } else if (index == 0) {
                parcelController.selectedDeliveryType.value =
                    "non-professional";
                parcelController.selectedVehicleType.value = 'bike';
              }
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

  Widget _buildTabItem(String label, String deliveryType) {
    return InkWell(
      onTap: () {
        parcelController.selectedDeliveryType.value = deliveryType;
        parcelController.tabController
            .jumpToPage(deliveryType == "professional" ? 1 : 0);
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Obx(() => TextWidget(
            text: label,
            fontColor:
                parcelController.selectedDeliveryType.value == deliveryType
                    ? Colors.black
                    : Colors.grey,
            fontSize: 14,
            fontWeight:
                parcelController.selectedDeliveryType.value == deliveryType
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
                  height: 170,
                  enlargeCenterPage: true,
                  autoPlay: false,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.35,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentCarouselIndex = index;
                    });
                    String vehicle = [
                      "bike",
                      "car",
                      "bicycle",
                      "Plane",
                      "person"
                    ][index % 5];
                    parcelController.selectedVehicleType.value = vehicle;
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
                  bool isCentered = index == currentCarouselIndex;

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
                                  : FontWeight.w400,
                              fontColor:
                                  isCentered ? Colors.black : Colors.grey,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }).toList(),
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
                  height: 170,
                  enlargeCenterPage: true,
                  autoPlay: false,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.35,
                  enableInfiniteScroll: false,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentCarouselIndex = index;
                    });
                    String vehicle = [
                      "truck",
                      "Taxi",
                    ][index];
                    parcelController.selectedVehicleType.value = vehicle;
                  },
                ),
                items: professionalImages.asMap().entries.map((entry) {
                  int index = entry.key;
                  String imagePath = entry.value;
                  String title = [
                    "truck".tr,
                    "Taxi".tr,
                  ][index];
                  bool isCentered = index == currentCarouselIndex;

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
                                  : FontWeight.w400,
                              fontColor:
                                  isCentered ? Colors.black : Colors.grey,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
