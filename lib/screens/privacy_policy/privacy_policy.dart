import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/screens/privacy_policy/controller/privacy_policy_controller.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
     final controller = Get.put(PrivacyPolicyController());
    return  Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
           padding:const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child:  Column(
             crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SpaceWidget(spaceHeight: 40),
                TextWidget(
                  text: "privacyNpolicy".tr,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  fontColor: AppColors.black,
                ),
                const SpaceWidget(spaceHeight: 20),
                Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50),
                        child: LoadingAnimationWidget.hexagonDots(
                          color: AppColors.black,
                          size: 40,
                        ),
                      ),
                    );
                  }
                  
                  if (controller.privacyPolicyData.value?.data?.content != null &&
                      controller.privacyPolicyData.value!.data!.content!.isNotEmpty) {
                    return HtmlWidget(
                      controller.privacyPolicyData.value!.data!.content!,
                      textStyle: const TextStyle(
                        color: AppColors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  }
                  
                  // Show error state with refresh button
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 60,
                            color: AppColors.greyLight,
                          ),
                          const SpaceWidget(spaceHeight: 16),
                          const TextWidget(
                            text: "No Terms Available",
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            fontColor: AppColors.black,
                          ),
                          const SpaceWidget(spaceHeight: 8),
                          const TextWidget(
                            text: "Unable to load terms and conditions.\nPlease try again.",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontColor: AppColors.greyLight,
                            textAlignment: TextAlign.center,
                          ),
                          const SpaceWidget(spaceHeight: 24),
                          ButtonWidget(
                            onPressed: () => controller.refreshTerms(),
                            label: "refresh".tr,
                            icon: Icons.refresh,
                            buttonWidth: 140,
                            buttonHeight: 45,
                            backgroundColor: AppColors.black,
                            textColor: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            buttonRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ],
        ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(),
             ButtonWidget(
              onPressed: ()=> Get.back(),
              label: "next".tr,
              icon: Icons.arrow_forward,
              buttonWidth: 150,
              buttonHeight: 50,
            ),
          ],
        ),
      ),
    );
  }
}