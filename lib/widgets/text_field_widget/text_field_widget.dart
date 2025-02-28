import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_icons_path.dart';
import '../../utils/app_size.dart';

class TextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final String? suffixIcon;
  final TextInputType? keyboardType;
  final int maxLines; // Add maxLines as a parameter
  final VoidCallback? onTapSuffix;
  final bool? read;

  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.suffixIcon,
    this.keyboardType,
    this.read = false,
    this.maxLines = 1, // Default value is 1
    this.onTapSuffix,
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
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
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        readOnly: widget.read!,
        controller: widget.controller,
        validator: widget.validator,
        obscureText: obscureText,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        style: const TextStyle(
          color: AppColors.black,
        ),
        decoration: InputDecoration(
          fillColor: AppColors.grey,
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
              color: AppColors.grey,
              width: ResponsiveUtils.width(0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.grey,
              width: ResponsiveUtils.width(0.5),
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.red,
              width: ResponsiveUtils.width(0.5),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.red,
              width: ResponsiveUtils.width(0.5),
            ),
          ),
        ),
      ),
    );
  }
}
