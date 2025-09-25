import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_icons_path.dart';
import '../../utils/app_size.dart';

class EditProfileTextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final String? suffixIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  final VoidCallback? onTapSuffix;
  final bool? read;
  final double? height;
  final double? width;

  const EditProfileTextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.suffixIcon,
    this.keyboardType,
    this.read = false,
    this.maxLines = 1,
    this.onTapSuffix,
    this.height,
    this.width,
  });

  @override
  State<EditProfileTextFieldWidget> createState() =>
      _EditProfileTextFieldWidgetState();
}

class _EditProfileTextFieldWidgetState
    extends State<EditProfileTextFieldWidget> {
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
      height: widget.height, // Use custom height if provided, else null (auto)
      width: widget.width, // Use custom width if provided, else null (auto)
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
                    if (widget.onTapSuffix != null) {
                      widget.onTapSuffix!();
                    } else {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    }
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
