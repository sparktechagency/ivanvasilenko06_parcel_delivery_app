import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/onboarding_screen/widget/onboarding_contant.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/image_widget/image_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

import 'controller/onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  OnboardingScreen({super.key}) {
    Get.put(OnboardingController());
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Get.locale?.languageCode == 'he';
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overScroll) {
                  overScroll.disallowIndicator();
                  return true;
                },
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.updateIndex,
                  itemCount: contents.length,
                  itemBuilder: (_, i) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ImageWidget(
                            imagePath: contents[i].image,
                            height: 500,
                            width: double.infinity,
                          ),
                          const SpaceWidget(spaceHeight: 56),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: TextWidget(
                              text: contents[i].title,
                              fontSize: 27,
                              fontWeight: FontWeight.w600,
                              fontColor: AppColors.black,
                            ),
                          ),
                          const SpaceWidget(spaceHeight: 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: TextWidget(
                              text: contents[i].description,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontColor: AppColors.black,
                              textAlignment:
                                  isRTL ? TextAlign.right : TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              isRTL
                  ? Positioned(
                      bottom: ResponsiveUtils.height(200),
                      right: ResponsiveUtils.width(24),
                      child: GetX<OnboardingController>(
                        builder: (controller) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            contents.length,
                            (index) => _buildDot(index, controller),
                          ),
                        ),
                      ),
                    )
                  : Positioned(
                      bottom: ResponsiveUtils.height(200),
                      left: ResponsiveUtils.width(24),
                      child: GetX<OnboardingController>(
                        builder: (controller) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            contents.length,
                            (index) => _buildDot(index, controller),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ButtonWidget(
                onPressed: () {
                  Get.toNamed(AppRoutes.loginScreen);
                },
                label: "login".tr,
                textColor: AppColors.black,
                fontSize: 16,
                buttonRadius: BorderRadius.circular(100),
                buttonWidth: 155,
                buttonHeight: 50,
                backgroundColor: AppColors.white,
                borderColor: AppColors.black,
                fontWeight: FontWeight.w500,
              ),
              ButtonWidget(
                onPressed: () {
                  Get.toNamed(AppRoutes.countrySelectScreen);
                },
                label: "signUp".tr,
                textColor: AppColors.white,
                fontSize: 16,
                buttonWidth: 155,
                buttonHeight: 50,
                buttonRadius: BorderRadius.circular(100),
                backgroundColor: AppColors.black,
                borderColor: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index, OnboardingController controller) {
    return Container(
      height: ResponsiveUtils.height(6),
      margin: const EdgeInsets.all(3),
      width: controller.currentIndex.value == index
          ? ResponsiveUtils.width(40)
          : ResponsiveUtils.width(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: controller.currentIndex.value == index
            ? AppColors.black
            : AppColors.greyLight,
      ),
    );
  }
}
