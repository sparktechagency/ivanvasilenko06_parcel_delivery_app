import 'package:flutter/material.dart';

import '../../utils/app_size.dart';

class IconTextButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color textColor;
  final IconData icon;
  final Color iconColor;
  final FontWeight textWeight;
  final double fontSize;
  final double iconSize;

  const IconTextButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.textColor,
    required this.icon,
    required this.iconColor,
    required this.textWeight,
    required this.fontSize,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.initialize(context);
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(50, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: textWeight,
              fontSize: ResponsiveUtils.width(fontSize),
            ),
          ),
          Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
        ],
      ),
    );
  }
}
