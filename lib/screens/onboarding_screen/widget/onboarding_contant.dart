import '../../../constants/app_image_path.dart';
import '../../../constants/app_strings.dart';

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
    title: AppStrings.onboardingTitle1,
    description: AppStrings.onboardingDesc1,
  ),
  OnboardingContent(
    image: AppImagePath.onboardingImage2,
    title: AppStrings.onboardingTitle2,
    description: AppStrings.onboardingDesc2,
  ),
  OnboardingContent(
    image: AppImagePath.onboardingImage3,
    title: AppStrings.onboardingTitle3,
    description: AppStrings.onboardingDesc3,
  ),
  OnboardingContent(
    image: AppImagePath.onboardingImage4,
    title: AppStrings.onboardingTitle4,
    description: AppStrings.onboardingDesc4,
  ),
];
