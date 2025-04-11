import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/screens/services_screen/controller/services_controller.dart';
import 'package:parcel_delivery_app/screens/services_screen/model/promote_delivery_parcel.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_button_widget/text_button_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

class RecentPublishOrder extends StatelessWidget {
  const RecentPublishOrder({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ServiceController());
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SpaceWidget(spaceHeight: 48),
                const TextWidget(
                  text: "Recent Publish Order",
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontColor: AppColors.black,
                ),
                const SpaceWidget(spaceHeight: 24),
                ...List.generate(controller.parcelList.length, (index) {
                  DeliveryPromote item = controller.parcelList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const ImageWidget(
                              height: 51,
                              width: 65,
                              imagePath: AppImagePath.sendParcel,
                            ),
                            const SpaceWidget(spaceWidth: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  text: item.status ?? "",
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w500,
                                  fontColor: AppColors.black,
                                ),
                                const SpaceWidget(spaceHeight: 4),
                                TextWidget(
                                  text: item.deliveryLocation ?? "",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontColor: AppColors.black,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const TextWidget(
                              text: "${AppStrings.currency} 150",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontColor: AppColors.black,
                            ),
                            TextButtonWidget(
                              onPressed: () {},
                              text: "seeDetails".tr,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              textColor: AppColors.greyDark2,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(100),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.grey, // Background color of CircleAvatar
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20), // Shadow color
                      blurRadius: 10, // Spread of the shadow
                      offset: const Offset(0, 4), // Position of the shadow (x, y)
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.transparent, // Set to transparent since Container handles color
                  radius: 25,
                  child: Icon(Icons.arrow_back, color: AppColors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
