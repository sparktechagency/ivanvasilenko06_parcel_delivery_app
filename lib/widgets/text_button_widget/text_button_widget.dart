import 'package:flutter/material.dart';

import '../../utils/app_size.dart';

class TextButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final TextDecoration? decoration;
  final Color? decorationColor;

  const TextButtonWidget({
    super.key,
    required this.onPressed,
    required this.text,
    required this.textColor,
    required this.fontSize,
    this.fontStyle = FontStyle.normal,
    required this.fontWeight,
    this.decoration,
    this.decorationColor,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.initialize(context);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(50, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.center,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontStyle: fontStyle,
          fontSize: ResponsiveUtils.width(fontSize),
          fontWeight: fontWeight,
          decoration: decoration,
          decorationColor: decorationColor,
        ),
      ),
    );
  }
}
