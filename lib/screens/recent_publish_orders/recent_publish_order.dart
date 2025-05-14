import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_image_path.dart';
import 'package:parcel_delivery_app/constants/app_strings.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/services_screen/controller/services_controller.dart';
import 'package:parcel_delivery_app/screens/services_screen/model/service_screen_model.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SpaceWidget(spaceHeight: 30),
              const TextWidget(
                text: "Recent Publish Order",
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontColor: AppColors.black,
              ),
              const SpaceWidget(spaceHeight: 24),
              Obx(() {
                if (controller.loading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  );
                }

                if (controller.recentParcelList.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        const TextWidget(
                          text: "No recent orders available",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontColor: AppColors.greyDark2,
                        ),
                        const SpaceWidget(spaceHeight: 16),
                        TextButtonWidget(
                          onPressed: controller.refreshParcelList,
                          text: "Retry",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          textColor: AppColors.black,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: List.generate(controller.recentParcelList.length,
                      (index) {
                    ServiceScreenModel item =
                        controller.recentParcelList[index];

                    // Safely access data or provide default values
                    String title = "Title not available";
                    String status = "Status not available";
                    String price = "Price not available";
                    String receiverName = "Receiver not available";
                    if (item.data != null && item.data!.isNotEmpty) {
                      if (item.data!.first.title != null) {
                        title = item.data!.first.title!;
                      }
                    }

                    if (item.status != null) {
                      status = item.status!;
                    }
                    if (item.data != null &&
                        item.data!.isNotEmpty &&
                        item.data!.first.price != null) {
                      price = item.data!.first.price.toString();
                    }
                    if (item.data != null &&
                        item.data!.isNotEmpty &&
                        item.data!.first.name != null) {
                      receiverName = item.data!.first.name!;
                    }

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
                                  SizedBox(
                                    width: ResponsiveUtils.width(180),
                                    child: TextWidget(
                                      text: title,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w500,
                                      fontColor: AppColors.black,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlignment: TextAlign.start,
                                    ),
                                  ),
                                  const SpaceWidget(spaceHeight: 4),
                                  TextWidget(
                                    text: receiverName,
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
                              TextWidget(
                                text: "${AppStrings.currency} $price",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontColor: AppColors.black,
                              ),
                              TextButtonWidget(
                                onPressed: () {
                                  final dataList = item.data;
                                  if (dataList != null &&
                                      dataList.isNotEmpty &&
                                      dataList.first.id != null) {
                                    const String routeName =
                                        AppRoutes.serviceScreenDeliveryDetails;
                                    if (routeName.isNotEmpty) {
                                      try {
                                        Get.toNamed(routeName,
                                            arguments: dataList.first.id);
                                      } catch (e) {
                                        AppSnackBar.error(
                                            "Navigation error: ${e.toString()}");
                                      }
                                    } else {
                                      AppSnackBar.error(
                                          "Route name is not properly defined.");
                                    }
                                  } else {
                                    AppSnackBar.error(
                                        "Parcel details not available or ID is missing.");
                                  }
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
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 08),
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
