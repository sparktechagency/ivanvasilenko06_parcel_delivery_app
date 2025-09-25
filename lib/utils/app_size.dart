import 'package:flutter/material.dart';

class AppSize {
  AppSize._();
  static late Size size;

  static const double _xdHeight = 882;
  static const double _xdWidth = 375;

  static double height({required num value}) {
    double percentage = (value / _xdHeight * 100).roundToDouble() / 100;
    return size.height * percentage;
  }

  static double width({required num value}) {
    double percentage = (value / _xdWidth * 100).roundToDouble() / 100;
    return size.width * percentage;
  }
}

class ResponsiveUtils {
  ResponsiveUtils._();

  static double screenHeight = 0;
  static double screenWidth = 0;

  static void initialize(BuildContext context) {
    screenHeight = MediaQuery.sizeOf(context).height;
    screenWidth = MediaQuery.sizeOf(context).width;
  }

  // Function to calculate responsive height
  static double height(double height) {
    return screenHeight / (screenHeight / height);
  }

  // Function to calculate responsive width
  static double width(double width) {
    return screenWidth / (screenWidth / width);
  }
}
