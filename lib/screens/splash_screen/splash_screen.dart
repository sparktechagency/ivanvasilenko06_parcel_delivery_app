import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_image_path.dart';

import '../../widgets/image_widget/image_widget.dart';
import 'controller/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    return const AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: ImageWidget(
            imagePath: AppImagePath.splashImage,
            height: double.infinity,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}
