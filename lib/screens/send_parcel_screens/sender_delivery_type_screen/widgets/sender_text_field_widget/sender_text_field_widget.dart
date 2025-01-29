import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_icons_path.dart';
import '../../../../../utils/app_size.dart';

class SenderTextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final String? suffixIcon;
  final TextInputType? keyboardType;
  final int maxLines; // Add maxLines as a parameter
  final VoidCallback? onTapSuffix;

  const SenderTextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.suffixIcon,
    this.keyboardType,
    this.maxLines = 1, // Default value is 1
    this.onTapSuffix,
  });

  @override
  State<SenderTextFieldWidget> createState() => _SenderTextFieldWidgetState();
}

class _SenderTextFieldWidgetState extends State<SenderTextFieldWidget> {
  late bool obscureText;

  @override
  void initState() {
    super.initState();
    // Initialize obscureText based on suffixIcon being a password toggle
    obscureText = widget.suffixIcon == AppIconsPath.emailIcon;
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.initialize(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        obscureText: obscureText,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        style: const TextStyle(
          color: AppColors.black,
        ),
        decoration: InputDecoration(
          fillColor: AppColors.white,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: AppColors.greyDark,
            fontWeight: FontWeight.w400,
            fontSize: ResponsiveUtils.width(15),
          ),
          suffixIcon: widget.suffixIcon != null
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                  child: Padding(
                    padding: obscureText
                        ? const EdgeInsets.all(13)
                        : const EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      obscureText
                          ? AppIconsPath.emailIcon
                          : AppIconsPath.emailIcon,
                      color: AppColors.greyDark,
                      height: ResponsiveUtils.width(18),
                      width: ResponsiveUtils.width(18),
                    ),
                  ),
                )
              : null,
          contentPadding: EdgeInsets.all(ResponsiveUtils.width(18)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.black,
              width: ResponsiveUtils.width(1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.black,
              width: ResponsiveUtils.width(1),
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.red,
              width: ResponsiveUtils.width(1),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.red,
              width: ResponsiveUtils.width(1),
            ),
          ),
        ),
      ),
    );
  }
}
