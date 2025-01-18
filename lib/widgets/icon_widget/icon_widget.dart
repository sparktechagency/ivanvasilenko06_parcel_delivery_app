import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/app_size.dart';

class IconWidget extends StatelessWidget {
  final double height;
  final double width;
  final String icon;
  final Color? color;

  const IconWidget({
    super.key,
    required this.height,
    required this.width,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.initialize(context);
    return SvgPicture.asset(
      icon,
      height: ResponsiveUtils.width(height),
      width: ResponsiveUtils.width(width),
      fit: BoxFit.cover,
      color: color,
    );
  }
}
