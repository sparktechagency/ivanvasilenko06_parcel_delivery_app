import 'package:get/get.dart';

import '../../../constants/app_image_path.dart';

class OnboardingContent {
  String title;
  String description;
  String image;

  OnboardingContent({
    required this.title,
    required this.image,
    required this.description,
  });
}

List<OnboardingContent> contents = [
  OnboardingContent(
    image: AppImagePath.onboardingImage1,
    title: "onboardingTitle1".tr,
    description: "onboardingDesc1".tr,
  ),
  OnboardingContent(
    image: AppImagePath.onboardingImage2,
    title: "onboardingTitle2".tr,
    description: "onboardingDesc2".tr,
  ),
  OnboardingContent(
    image: AppImagePath.onboardingImage3,
    title: "onboardingTitle3".tr,
    description: "onboardingDesc3".tr,
  ),
  OnboardingContent(
    image: AppImagePath.onboardingImage4,
    title: "onboardingTitle4".tr,
    description: "onboardingDesc4".tr,
  ),
];
