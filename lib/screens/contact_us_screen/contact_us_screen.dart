import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/screens/auth_screens/login_screen/widgets/or_widget.dart';
import 'package:parcel_delivery_app/screens/contact_us_screen/controller/contact_us_controller.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:parcel_delivery_app/widgets/text_button_widget/text_button_widget.dart';
import 'package:parcel_delivery_app/widgets/text_field_widget/text_field_widget.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/button_widget/button_widget.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final ContactUsController controller = Get.put(ContactUsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SpaceWidget(spaceHeight: 48),
            const TextWidget(
              text: "Feedback", //AppStrings.contactUs
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
            ),
            const SpaceWidget(spaceHeight: 24),

            // const SpaceWidget(spaceHeight: 2),

            //const SpaceWidget(spaceHeight: 20),
            const TextWidget(
              text: "Enjoying the app? Rate us!",
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontColor: AppColors.black,
            ),
            const SpaceWidget(spaceHeight: 2),
            const TextWidget(
              text: "Rate This Applicationa and Share yours thoughts",
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.greyDarkLight,
            ),
            const SpaceWidget(spaceHeight: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyDark, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TextWidget(
                      text: "Give Your Ratings",
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      fontColor: AppColors.black,
                    ),
                    const SpaceWidget(spaceHeight: 10),
                    RatingBar(
                      alignment: Alignment.center,
                      size: 35,
                      emptyColor: AppColors.whiteDark,
                      filledColor: AppColors.black,
                      halfFilledColor: AppColors.black,
                      filledIcon: Icons.star,
                      emptyIcon: Icons.star_border,
                      onRatingChanged: (value) {
                        controller.ratingNumber.value = value;
                      },
                      initialRating: 3,
                      maxRating: 5,
                    ),
                  ],
                ),
              ),
            ),
            const SpaceWidget(spaceHeight: 10),
            TextFieldWidget(
              controller: controller.reviewtext.value,
              hintText: "share your thoughts",
              maxLines: 3,
            ),
            // const SpaceWidget(spaceHeight: 100),
            const SpaceWidget(spaceHeight: 10),
            Obx(() {
              return controller.isLoading.value
                  ? Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: LoadingAnimationWidget.progressiveDots(
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    )
                  : ButtonWidget(
                      onPressed: controller.appPostReview,
                      label: "Submit Review".tr,
                      buttonHeight: 50,
                      buttonWidth: double.infinity,
                    );
            }),
            const SpaceWidget(spaceHeight: 16),
            const OrWidget(),
            const SpaceWidget(spaceHeight: 16),
            Center(
              child: Column(
                children: [
                  const TextWidget(
                    text: AppStrings.forAnySupport,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontColor: AppColors.greyDarkLight,
                  ),
                  const SpaceWidget(spaceHeight: 02),
                  TextButtonWidget(
                    onPressed: controller.sendEmail,
                    text: 'deliverly2025@gmail.com',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    textColor: AppColors.black,
                    decoration: TextDecoration.underline,
                  ),
                ],
              ),
            ),
            const Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: IconWidget(
                    height: 250,
                    width: 250,
                    icon: AppIconsPath.contactUsIcon,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: controller.goBack,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.black,
                  size: 24,
                ),
              ),
            ),
            ButtonWidget(
              onPressed: controller.sendEmail,
              label: AppStrings.mailUs,
              textColor: AppColors.white,
              buttonWidth: 125,
              buttonHeight: 50,
              icon: Icons.email, // Changed icon to email for better UX
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
