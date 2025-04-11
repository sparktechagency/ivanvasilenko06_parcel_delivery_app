import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/screens/delivery_parcel_screens/controller/delivery_screens_controller.dart';
import 'package:parcel_delivery_app/screens/delivery_parcel_screens/summary_of_parcel_screen/widgets/summary_info_row_widget.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../utils/app_size.dart';
import '../../../widgets/button_widget/button_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class SummaryOfParcelScreen extends StatefulWidget {
  const SummaryOfParcelScreen({super.key});

  @override
  State<SummaryOfParcelScreen> createState() => _SummaryOfParcelScreenState();
}

class _SummaryOfParcelScreenState extends State<SummaryOfParcelScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryScreenController>();

    // Fetching data from controller
    final startingLocation = controller.startingCoordinates.value;
    final endingLocation = controller.endingCoordinates.value;
    initState() {
      final deliveryScreenController = Get.find<DeliveryScreenController>();
      deliveryScreenController.fetchDeliveryParcelsList();
      super.initState();
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextWidget(
              text: "summaryOfParcel".tr,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
            ),
          ),
          const SpaceWidget(spaceHeight: 40),
          // Expanded(
          //   child: SingleChildScrollView(
          //     padding: const EdgeInsets.symmetric(horizontal: 16),
          //     child: Column(
          //       children: [
          //         // Displaying parcel info with icons
          //         Row(
          //           children: [
          //             ClipRRect(
          //               borderRadius: BorderRadius.circular(100),
          //               child: const ImageWidget(
          //                 height: 40,
          //                 width: 40,
          //                 imagePath: AppImagePath.sendParcel,
          //               ),
          //             ),
          //             const SpaceWidget(spaceWidth: 8),
          //             const TextWidget(
          //               text: AppStrings.parcel1,
          //               fontSize: 20,
          //               fontWeight: FontWeight.w500,
          //               fontColor: AppColors.black,
          //             ),
          //           ],
          //         ),
          //         const SpaceWidget(spaceHeight: 16),
          //         const Divider(
          //           color: AppColors.grey,
          //           thickness: 1,
          //         ),
          //         const SpaceWidget(spaceHeight: 16),
          //         SummaryInfoRowWidget(
          //           image: AppImagePath.profileImage,
          //           label: "sendersName".tr,
          //           value: AppStrings.joshua,
          //         ),
          //         const SpaceWidget(spaceHeight: 8),
          //         SummaryInfoRowWidget(
          //           icon: AppIconsPath.ratingIcon,
          //           label: "ratingsText".tr,
          //           value: AppStrings.ratings,
          //         ),
          //         const SpaceWidget(spaceHeight: 8),
          //         SummaryInfoRowWidget(
          //           icon: AppIconsPath.profileIcon,
          //           label: "receiversName".tr,
          //           value: AppStrings.arial,
          //         ),
          //         const SpaceWidget(spaceHeight: 8),
          //         SummaryInfoRowWidget(
          //           icon: AppIconsPath.callIcon,
          //           label: "receiversNumber".tr,
          //           value: AppStrings.number,
          //         ),
          //         const SpaceWidget(spaceHeight: 8),
          //         SummaryInfoRowWidget(
          //           icon: AppIconsPath.deliveryTimeIcon,
          //           label: "deliveryTimeText".tr,
          //           value: AppStrings.deliveryTime,
          //         ),
          //         const SpaceWidget(spaceHeight: 8),
          //
          //         // Display starting location
          //         SummaryInfoRowWidget(
          //           icon: AppIconsPath.destinationIcon,
          //           label: "currentLocationText".tr,
          //           value: startingLocation != null
          //               ? "${startingLocation.latitude}, ${startingLocation.longitude}"
          //               : "Not set",
          //         ),
          //         const SpaceWidget(spaceHeight: 8),
          //
          //         // Display destination location
          //         SummaryInfoRowWidget(
          //           icon: AppIconsPath.currentLocationIcon,
          //           label: "destinationText".tr,
          //           value: endingLocation != null
          //               ? "${endingLocation.latitude}, ${endingLocation.longitude}"
          //               : "Not set",
          //         ),
          //         const SpaceWidget(spaceHeight: 8),
          //
          //         // Display radius
          //         SummaryInfoRowWidget(
          //           icon: AppIconsPath.priceIcon,
          //           label: "price",
          //           value: controller.parcels.isNotEmpty
          //               ? "${controller.parcels.first.price}"
          //               : "Not set",
          //         ),
          //         const SpaceWidget(spaceHeight: 8),
          //         SummaryInfoRowWidget(
          //           icon: AppIconsPath.descriptionIcon,
          //           label: "descriptionText".tr,
          //           value: AppStrings.description,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          Expanded(
            child: ListView.separated(
              itemCount: controller.parcels.length,
              itemBuilder: (context, index) {
                return SummaryInfoRowWidget(
                  image: AppImagePath.profileImage,
                  label: "sendersName".tr,
                  value: AppStrings.joshua,
                );
              },
              separatorBuilder: (_, __) {
                return const SizedBox(
                  height: 10,
                );
              },
            ),
          )
        ],
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
                Get.back();
              },
              label: "sendRequest".tr,
              textColor: AppColors.white,
              buttonWidth: 180,
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
