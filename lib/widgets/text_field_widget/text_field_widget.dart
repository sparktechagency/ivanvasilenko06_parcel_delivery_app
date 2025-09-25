import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'dart:io';

import '../../constants/app_colors.dart';
import '../../constants/app_icons_path.dart';
import '../../utils/app_size.dart';

class TextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final String? suffixIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  final VoidCallback? onTapSuffix;
  final bool? read;
  final VoidCallback? onSubmitted;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.suffixIcon,
    this.keyboardType,
    this.read = false,
    this.maxLines = 1,
    this.onTapSuffix,
    this.onSubmitted,
    this.textInputAction,
    this.focusNode,
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
    
    Widget textField = Container(
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
        textInputAction: widget.textInputAction ?? TextInputAction.send,
        focusNode: widget.focusNode,
        onFieldSubmitted: (value) {
          if (widget.onSubmitted != null) {
            widget.onSubmitted!();
          }
        },
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

    // Wrap with KeyboardActions for iOS to show Done button
    if (Platform.isIOS && widget.focusNode != null) {
      return KeyboardActions(
        config: _buildKeyboardActionsConfig(),
        child: textField,
      );
    }

    return textField;
  }

  KeyboardActionsConfig _buildKeyboardActionsConfig() {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Colors.grey[200],
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
          focusNode: widget.focusNode!,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () {
                  node.unfocus();
                  if (widget.onSubmitted != null) {
                    widget.onSubmitted!();
                  }
                },
                child: Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    "Done",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              );
            }
          ],
        ),
      ],
    );
  }
}
