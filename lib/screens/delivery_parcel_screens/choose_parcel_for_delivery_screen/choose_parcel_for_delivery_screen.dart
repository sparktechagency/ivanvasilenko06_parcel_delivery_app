import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_image_path.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/button_widget/button_widget.dart';
import '../controller/delivery_screens_controller.dart'; // Ensure you're using your controller

class ChooseParcelForDeliveryScreen extends StatefulWidget {
  const ChooseParcelForDeliveryScreen({super.key});

  @override
  State<ChooseParcelForDeliveryScreen> createState() =>
      _ChooseParcelForDeliveryScreenState();
}

class _ChooseParcelForDeliveryScreenState
    extends State<ChooseParcelForDeliveryScreen> {
  Set<int> selectedParcelIndices = {}; // To track selected parcels

  final DeliveryScreenController _controller =
      Get.find<DeliveryScreenController>(); // Access the controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          const ImageWidget(
            height: 450,
            width: double.infinity,
            imagePath: AppImagePath.selectParcelForDeliveryImage,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24))),
              child: Obx(() {
                final parcels = _controller.parcels; // Get the list of parcels

                if (parcels.isEmpty) {
                  return const Center(
                    child: Text(
                        "No parcels available for the selected delivery type and location."),
                  );
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          "chooseParcelForDelivery".tr,
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ...List.generate(parcels.length, (index) {
                          final parcel = parcels[index];
                          final isSelected = selectedParcelIndices
                              .contains(index); // Check if parcel is selected

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.transparent,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 2, top: 8, bottom: 8, right: 14),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: isSelected,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              selectedParcelIndices.add(index);
                                            } else {
                                              selectedParcelIndices
                                                  .remove(index);
                                            }
                                          });
                                        },
                                        activeColor: Colors.black,
                                      ),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: ImageWidget(
                                          imagePath: parcel.images.isNotEmpty
                                              ? parcel.images[
                                                  0] // First image of the parcel
                                              : AppImagePath.personImage,
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                      const SpaceWidget(spaceWidth: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            parcel.name ?? 'Unknown Parcel',
                                            // Display parcel name
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(parcel.deliveryLocation ??
                                              'Unknown location'),
                                          // Display delivery location
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        parcel.phoneNumber ?? 'N/A',
                                        // Display phone number
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16),
                                      ),
                                      Text(
                                        parcel.status ?? 'Unknown status',
                                        style: TextStyle(
                                            color: Colors.green[600],
                                            fontSize: 12), // Display status
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                Get.back(); // Go back to the previous screen
              },
              borderRadius: BorderRadius.circular(100),
              child: Card(
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: 3,
                child: const CircleAvatar(
                  backgroundColor: AppColors.white,
                  radius: 25,
                  child: Icon(Icons.arrow_back, color: AppColors.black),
                ),
              ),
            ),
            ButtonWidget(
              onPressed: () {
                // Proceed to the next screen with selected parcels
                Get.toNamed(AppRoutes.parcelForDeliveryScreen);
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
