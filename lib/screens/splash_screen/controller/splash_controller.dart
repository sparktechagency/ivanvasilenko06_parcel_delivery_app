import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';

import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  // void onInit() {
  //   super.onInit();
  //   // Wait for 3 seconds before navigating to the HomeScreen
  //   Future.delayed(const Duration(seconds: 3)).then((_) async{
  //    // Get.offAllNamed(AppRoutes.homeScreen);
  //    String token = AppAuthStorage().getToken().toString();
  //
  //     debugPrint("This is my  B token =-=-==-=-=-=-=-=-=-=-=-=-=-=-${token}");
  //
  //     if(AppAuthStorage().getToken().toString() != null){
  //
  //       Get.offAll(() => const BottomNavScreen());
  //     }
  //     Get.offAllNamed(AppRoutes.onboardingScreen);
  //    // Get.offAll(() => const BottomNavScreen());
  //   });
  // }

  void onInit() {
   WidgetsBinding.instance.addPostFrameCallback((_) {
       Future.delayed(const Duration(seconds: 3)).then((_) async{
        // Get.offAllNamed(AppRoutes.homeScreen);
        var token = await SharePrefsHelper.getString(SharedPreferenceValue.token);

         debugPrint("✅✅✅✅✅-${token} ❇️❇️❇️❇️❇️❇️❇️❇️❇️❇️❇️❇️");

         if(token!=null && token.isNotEmpty){
           Get.offAll(() => const BottomNavScreen());
         }else{
           Get.offAllNamed(AppRoutes.onboardingScreen);
         }
        // Get.offAll(() => const BottomNavScreen());
       });
   });


    super.onInit();
  }



  @override
  void onClose() {
    super.onClose();
    print("SplashController disposed"); // Log message to confirm disposal
  }
}
