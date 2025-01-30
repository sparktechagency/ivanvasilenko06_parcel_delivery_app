import 'package:get/get.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/bottom_nav_bar.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Wait for 3 seconds before navigating to the HomeScreen
    Future.delayed(const Duration(seconds: 3)).then((_) {
      //Get.offAllNamed(AppRoutes.onboardingScreen);
      Get.offAll(() => BottomNavScreen());
    });
  }

  @override
  void onClose() {
    super.onClose();
    print("SplashController disposed"); // Log message to confirm disposal
  }
}
