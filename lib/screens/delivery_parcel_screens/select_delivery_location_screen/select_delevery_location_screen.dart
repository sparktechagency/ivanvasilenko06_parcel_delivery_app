import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/utils/appLog/app_log.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_icons_path.dart';
import '../../../widgets/text_widget/text_widgets.dart';
import '../controller/delivery_screens_controller.dart'; // Import the controller

class SelectDeliveryLocationScreen extends StatefulWidget {
  const SelectDeliveryLocationScreen({super.key});

  @override
  State<SelectDeliveryLocationScreen> createState() =>
      _SelectDeliveryLocationScreenState();
}

class _SelectDeliveryLocationScreenState
    extends State<SelectDeliveryLocationScreen> {
  final TextEditingController _currentLocationController =
      TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final DeliveryScreenController _controller =
      Get.find<DeliveryScreenController>();

  final List<Map<String, String>> suggestedLocations = [
    {"name": "Mirpur DOHS", "address": "Address in Mirpur..."},
    {"name": "Chittagong", "address": "Address in Chittagong..."},
    {"name": "Dhaka", "address": "Address in Dhaka..."},
    {"name": "Gulshan", "address": "Address in Gulshan..."},
  ];

  @override
  void initState() {
    super.initState();
    // Get the delivery type from the previous screen
    final deliveryType = Get.arguments as String;
    appLog('🆓🆓 Selected Delivery Type: $deliveryType');
  }

  @override
  void dispose() {
    _currentLocationController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back, size: 28),
                        const SizedBox(width: 8),
                        TextWidget(
                          text: "enterDeliveryLocation".tr,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          fontColor: AppColors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 24),
                Column(
                  children: [
                    const IconWidget(
                      height: 15,
                      width: 15,
                      icon: AppIconsPath.destinationIcon,
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppColors.greyLight2,
                    ),
                    const IconWidget(
                      height: 15,
                      width: 15,
                      icon: AppIconsPath.currentLocationIcon,
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 12, right: 24, top: 16, bottom: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.black, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _currentLocationController,
                          decoration: InputDecoration(
                              hintText: "currentLocationText".tr),
                        ),
                        const Divider(height: 2),
                        TextFormField(
                          controller: _destinationController,
                          decoration:
                              InputDecoration(hintText: "destinationText".tr),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: suggestedLocations.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on_rounded,
                        color: Colors.black),
                    title: Text(suggestedLocations[index]["name"]!),
                    subtitle: Text(suggestedLocations[index]["address"]!),
                    onTap: () {
                      _destinationController.text =
                          suggestedLocations[index]["name"]!;
                      _controller.setSelectedDeliveryLocation(
                        suggestedLocations[index]["name"]!,
                      );
                      Get.toNamed(AppRoutes.chooseParcelForDeliveryScreen);
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
                Get.toNamed(AppRoutes.chooseParcelForDeliveryScreen,
                    arguments: {
                      'deliveryType': 'car',
                      // Example delivery type
                      'deliveryLocation': 'Mirpur, DOHS'
                      // Example delivery location
                    });
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
