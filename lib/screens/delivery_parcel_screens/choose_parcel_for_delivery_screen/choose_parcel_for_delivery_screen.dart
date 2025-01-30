import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_size.dart';
import '../../../widgets/button_widget/button_widget.dart';

class ChooseParcelForDeliveryScreen extends StatefulWidget {
  const ChooseParcelForDeliveryScreen({super.key});

  @override
  State<ChooseParcelForDeliveryScreen> createState() =>
      _ChooseParcelForDeliveryScreenState();
}

class _ChooseParcelForDeliveryScreenState
    extends State<ChooseParcelForDeliveryScreen> {
  Set<int> selectedParcelIndices = {};

  // Sample parcel data - in a real app, this would come from an API
  final List<Map<String, dynamic>> parcels = [
    {
      'id': 1,
      'name': 'Parcel 1',
      'location': 'Western Wall',
      'distance': '4km away',
      'price': 150,
    },
    {
      'id': 2,
      'name': 'Parcel 2',
      'location': 'Western Wall',
      'distance': '4km away',
      'price': 120,
    },
    {
      'id': 3,
      'name': 'Parcel 3',
      'location': 'Western Wall',
      'distance': '4km away',
      'price': 150,
    },
  ];

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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Choose parcel for delivery',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...List.generate(parcels.length, (index) {
                        final parcel = parcels[index];
                        final isSelected =
                            selectedParcelIndices.contains(index);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.transparent!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 2, top: 8, bottom: 8, right: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                            selectedParcelIndices.remove(index);
                                          }
                                        });
                                      },
                                      activeColor: Colors.black,
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: const ImageWidget(
                                        imagePath: AppImagePath.sendParcel,
                                        // Add your parcel image
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
                                          parcel['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(parcel['location']),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₪ ${parcel['price']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      parcel['distance'],
                                      style: TextStyle(
                                        color: Colors.green[600],
                                        fontSize: 12,
                                      ),
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
              ),
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
                Get.toNamed(AppRoutes.parcelForDeliveryScreen);
              },
              label: AppStrings.next,
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
