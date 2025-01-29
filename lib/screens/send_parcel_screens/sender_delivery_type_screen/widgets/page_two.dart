import 'package:flutter/material.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/space_widget/space_widget.dart';
import '../../../../widgets/text_widget/text_widgets.dart';

class PageTwo extends StatefulWidget {
  const PageTwo({super.key});

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  final TextEditingController _currentLocationController =
      TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void dispose() {
    _currentLocationController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 48),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextWidget(
              text: AppStrings.enterDeliveryLocation,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.black,
              fontStyle: FontStyle.italic,
              textAlignment: TextAlign.start,
            ),
          ),
          const SpaceWidget(spaceHeight: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
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
          const SpaceWidget(spaceHeight: 24),
          const ImageWidget(
            height: 400,
            width: double.infinity,
            imagePath: AppImagePath.senderLocationImage,
          ),
        ],
      ),
    );
  }
}
