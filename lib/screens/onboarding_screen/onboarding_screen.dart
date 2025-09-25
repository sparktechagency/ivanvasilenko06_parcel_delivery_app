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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed content area that changes based on current page
              Expanded(
                child: GestureDetector(
                  onPanUpdate: (details) {
                    // Handle horizontal swipe gestures
                    if (details.delta.dx > 10) {
                      // Swipe right - go to previous page
                      if (controller.currentIndex.value > 0) {
                        controller.pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    } else if (details.delta.dx < -10) {
                      // Swipe left - go to next page
                      if (controller.currentIndex.value < contents.length - 1) {
                        controller.pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    }
                  },
                  child: GetX<OnboardingController>(
                    builder: (controller) {
                      final currentContent =
                          contents[controller.currentIndex.value];
                      return SingleChildScrollView(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Animated image transition
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.3, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: ImageWidget(
                              key: ValueKey(currentContent.image),
                              imagePath: currentContent.image,
                              height: screenHeight > 700
                                  ? ResponsiveUtils.height(480)
                                  : ResponsiveUtils.height(380),
                              width: double.infinity,
                            ),
                          ),
                          const SpaceWidget(spaceHeight: 10),

                          // Fixed dots indicator
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: List.generate(
                                  contents.length,
                                  (index) => _buildDot(index, controller),
                                ),
                              ),
                            ),
                          ),
                          const SpaceWidget(spaceHeight: 10),

                          // Animated title transition
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              key: ValueKey(currentContent.title),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextWidget(
                                text: currentContent.title,
                                fontSize: 27,
                                fontWeight: FontWeight.w600,
                                fontColor: AppColors.black,
                              ),
                            ),
                          ),
                          const SpaceWidget(spaceHeight: 10),

                          // Animated description transition
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              key: ValueKey(currentContent.description),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextWidget(
                                text: currentContent.description,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontColor: AppColors.black,
                                textAlignment:
                                    isRTL ? TextAlign.right : TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 120),
                        ],
                      ));
                    },
                  ),
                ),
              ),

              // Invisible PageView for swipe detection
              SizedBox(
                height: 0,
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overScroll) {
                    overScroll.disallowIndicator();
                    return true;
                  },
                  child: PageView.builder(
                    controller: controller.pageController,
                    onPageChanged: controller.updateIndex,
                    itemCount: contents.length,
                    itemBuilder: (_, i) => const SizedBox.shrink(),
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
                const SizedBox(width: 10),
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
