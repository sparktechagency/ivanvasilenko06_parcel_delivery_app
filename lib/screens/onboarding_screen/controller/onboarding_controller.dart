import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  // Observable variable for the current page index
  RxInt currentIndex = 0.obs;

  // PageController for the PageView
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // Function to update the current index
  void updateIndex(int index) {
    currentIndex.value = index;
  }
}
