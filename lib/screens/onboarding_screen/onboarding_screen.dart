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
    final screenHeight = MediaQuery.of(context).size.height;

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
                    return SingleChildScrollView(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ImageWidget(
                              imagePath: contents[i].image,
                              height: screenHeight > 700
                                  ? ResponsiveUtils.height(480)
                                  : ResponsiveUtils.height(380), // Reduce image height for small screens
                              width: double.infinity,
                            ),
                            const SpaceWidget(spaceHeight: 38),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: TextWidget(
                                text: contents[i].title,
                                fontSize: 27,
                                fontWeight: FontWeight.w600,
                                fontColor: AppColors.black,
                              ),
                            ),
                            const SpaceWidget(spaceHeight: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: TextWidget(
                                text: contents[i].description,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontColor: AppColors.black,
                                textAlignment:
                                isRTL ? TextAlign.right : TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                            // Add bottom padding to prevent content from going behind bottom nav
                            SizedBox(height: 120),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: screenHeight > 700
                    ? ResponsiveUtils.height(500)
                    : ResponsiveUtils.height(400), // Adjust position for smaller screens
                left: isRTL ? null : ResponsiveUtils.width(24),
                right: isRTL ? ResponsiveUtils.width(24) : null,
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
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: ButtonWidget(
                    onPressed: () {
                      Get.toNamed(AppRoutes.loginScreen);
                      // Get.offAll(() => const BottomNavScreen());
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
                ),
                SizedBox(width: 10),
                Flexible(
                  child: ButtonWidget(
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
                ),
              ],
            ),
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