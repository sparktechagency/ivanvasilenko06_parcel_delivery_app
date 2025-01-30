import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_size.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class ReserveBottomSheetWidget extends StatefulWidget {
  const ReserveBottomSheetWidget({super.key});

  @override
  _ReserveBottomSheetWidgetState createState() =>
      _ReserveBottomSheetWidgetState();
}

class _ReserveBottomSheetWidgetState extends State<ReserveBottomSheetWidget> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: ResponsiveUtils.height(5),
                width: ResponsiveUtils.width(50),
                decoration: BoxDecoration(
                  color: AppColors.greyDark,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SpaceWidget(spaceHeight: 20),
            const TextWidget(
              text: AppStrings.select,
              fontSize: 23,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
            ),
            const SpaceWidget(spaceHeight: 8),
            // Deliver Parcel Option
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOption = 'Deliver Parcel';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.greyLightest,
                        border: Border.all(
                          color: selectedOption == 'Deliver Parcel'
                              ? AppColors.black
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          ImageWidget(
                            height: 76,
                            width: 115,
                            imagePath: AppImagePath.deliverParcel,
                          ),
                          SpaceWidget(spaceHeight: 2),
                          TextWidget(
                            text: AppStrings.deliverParcel,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontColor: AppColors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SpaceWidget(spaceWidth: 16),
                // Send Parcel Option
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOption = 'Send Parcel';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.greyLightest,
                        border: Border.all(
                          color: selectedOption == 'Send Parcel'
                              ? AppColors.black
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          ImageWidget(
                            height: 76,
                            width: 115,
                            imagePath: AppImagePath.sendParcel,
                          ),
                          SpaceWidget(spaceHeight: 2),
                          TextWidget(
                            text: AppStrings.sendParcel,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontColor: AppColors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SpaceWidget(spaceHeight: 24),
            // Next Button
            ButtonWidget(
              onPressed: selectedOption == null
                  ? null
                  : () {
                      Get.back();

                      // Navigate to the next screen based on the selected option
                      if (selectedOption == 'Deliver Parcel') {
                        Get.toNamed(AppRoutes.deliveryTypeScreen);
                      } else if (selectedOption == 'Send Parcel') {
                        Get.toNamed(AppRoutes.senderDeliveryTypeScreen);
                      }
                      print('Selected Option: $selectedOption');
                    },
              label: AppStrings.next,
              fontWeight: FontWeight.w500,
              buttonWidth: double.infinity,
              buttonHeight: 50,
            ),
            const SpaceWidget(spaceHeight: 15),
          ],
        );
      },
    );
  }
}
