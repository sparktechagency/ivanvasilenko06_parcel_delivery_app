import 'package:flutter/material.dart';

import '../../utils/app_size.dart';

class SpaceWidget extends StatelessWidget {
  final double spaceHeight;
  final double spaceWidth;

  const SpaceWidget({
    super.key,
    this.spaceHeight = 0.0,
    this.spaceWidth = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.initialize(context);
    if (spaceHeight != 0.0 && spaceWidth != 0.0) {
      return SizedBox(
        height: ResponsiveUtils.height(spaceHeight),
        width: ResponsiveUtils.width(spaceWidth),
      );
    } else if (spaceHeight != 0.0 && spaceWidth == 0.0) {
      return SizedBox(
        height: ResponsiveUtils.height(spaceHeight),
      );
    } else if (spaceHeight == 0.0 && spaceWidth != 0.0) {
      return SizedBox(
        width: ResponsiveUtils.width(spaceWidth),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
