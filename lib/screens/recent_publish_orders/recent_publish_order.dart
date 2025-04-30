import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/screens/services_screen/controller/services_controller.dart';
import 'package:parcel_delivery_app/screens/services_screen/model/service_screen_model.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_button_widget/text_button_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

import '../recent_publish_order_details/recent_publish_order_details.dart';

class RecentPublishOrder extends StatelessWidget {
  const RecentPublishOrder({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ServiceController());
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
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
            // Iterate over the recentParcelList
            Column(
              children:
                  List.generate(controller.recentParcelList.length, (index) {
                ServiceScreenModel item = controller.recentParcelList[index];
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
                              // Display the parcel's status or a default message
                              TextWidget(
                                text: item.status ?? "Status not available",
                                fontSize: 15.5,
                                fontWeight: FontWeight.w500,
                                fontColor: AppColors.black,
                              ),
                              const SpaceWidget(spaceHeight: 4),
                              // Display the parcel's title or a default message
                              TextWidget(
                                text: item.serviceScreenDataList != null &&
                                        item.serviceScreenDataList!.isNotEmpty
                                    ? item.serviceScreenDataList!.first.title ??
                                        "Title not available"
                                    : "Title not available",
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
                            onPressed: () {
                              Get.to(DeliveryDetailsScreen(
                                  item: item.serviceScreenDataList!
                                      .first)); // Pass the first Data object
                            },
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
            )
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
          ],
        ),
      ),
    );
  }
}
