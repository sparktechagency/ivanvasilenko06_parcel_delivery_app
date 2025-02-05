import 'package:flutter/material.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_icons_path.dart';
import '../../../../constants/app_strings.dart';
import '../../../../utils/app_size.dart';
import '../../../../widgets/icon_widget/icon_widget.dart';
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
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
              textAlignment: TextAlign.start,
            ),
          ),
          const SpaceWidget(spaceHeight: 24),
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
                    height: 50,
                    color: AppColors.greyLight2,
                  ),
                  const IconWidget(
                    height: 15,
                    width: 15,
                    icon: AppIconsPath.currentLocationIcon,
                  ),
                ],
              ),
              const SpaceWidget(spaceWidth: 12),
              Expanded(
                child: Column(
                  children: [
                    // Current Location Input
                    TextFormField(
                      controller: _currentLocationController,
                      style: const TextStyle(
                        color: AppColors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "Current Location",
                        hintStyle: const TextStyle(
                          color: AppColors.greyDarkLight2,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.greyDarkLight2,
                            width: ResponsiveUtils.width(1.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.black,
                            width: ResponsiveUtils.width(1.5),
                          ),
                        ),
                      ),
                    ),
                    const SpaceWidget(spaceHeight: 12),
                    // Destination Input
                    TextFormField(
                      controller: _destinationController,
                      style: const TextStyle(
                        color: AppColors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "Destination",
                        hintStyle: const TextStyle(
                          color: AppColors.greyDarkLight2,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.greyDarkLight2,
                            width: ResponsiveUtils.width(1.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.black,
                            width: ResponsiveUtils.width(1.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SpaceWidget(spaceWidth: 16),
            ],
          ),
          const SpaceWidget(spaceHeight: 24),
          const ImageWidget(
            height: 500,
            width: double.infinity,
            imagePath: AppImagePath.senderLocationImage,
          ),
        ],
      ),
    );
  }
}
