import 'package:flutter/material.dart';

import '../../../utils/app_size.dart';

class ImageWidget extends StatelessWidget {
  final double height;
  final double width;
  final String imagePath;

  const ImageWidget({
    super.key,
    required this.height,
    required this.width,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.initialize(context);
    return Image.asset(
      imagePath,
      height: ResponsiveUtils.width(height),
      width: ResponsiveUtils.width(width),
      fit: BoxFit.cover,
    );
  }
}
