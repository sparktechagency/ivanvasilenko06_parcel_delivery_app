import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/text_widget/text_widgets.dart';

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

  // Sample suggested locations - in real app, this would come from an API
  final List<Map<String, String>> suggestedLocations = [
    {"name": "Area Name", "address": "Address in detail..."},
    {"name": "Area Name-2", "address": "Address in detail..."},
    {"name": "Area Name", "address": "Address in detail..."},
    {"name": "Area Name-2", "address": "Address in detail..."},
    {"name": "Area Name", "address": "Address in detail..."},
    {"name": "Area Name-2", "address": "Address in detail..."},
    {"name": "Area Name", "address": "Address in detail..."},
    {"name": "Area Name-2", "address": "Address in detail..."},
  ];

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
            // Header with back button and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back, size: 28),
                        SizedBox(width: 8),
                        TextWidget(
                          text: "Enter Delivery Location",
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          fontColor: AppColors.black,
                          fontStyle: FontStyle.italic,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Location input container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.black, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Current Location Input
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.rectangle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _currentLocationController,
                          decoration: const InputDecoration(
                            hintText: "Current Location",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  // Destination Input
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _destinationController,
                          decoration: const InputDecoration(
                            hintText: "Destination",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Suggested Destinations title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Suggested Destinations",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Suggested Destinations list
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: suggestedLocations.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on, color: Colors.black),
                    title: Text(
                      suggestedLocations[index]["name"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      suggestedLocations[index]["address"]!,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      // Handle location selection
                      _destinationController.text =
                          suggestedLocations[index]["name"]!;
                      Get.toNamed(AppRoutes.chooseParcelForDeliveryScreen);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
