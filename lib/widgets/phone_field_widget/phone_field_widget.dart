import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'dart:io' show Platform;

import '../../constants/app_colors.dart';
import '../../utils/app_size.dart';

class IntlPhoneFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String initialCountryCode;
  final String hintText;
  final ValueChanged<PhoneNumber>? onChanged;
  final Color? borderColor;
  final Color? fillColor;
  final VoidCallback? onSubmitted;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const IntlPhoneFieldWidget({
    super.key,
    required this.controller,
    this.initialCountryCode = 'IL',
    this.hintText = '',
    this.onChanged,
    this.borderColor,
    this.fillColor,
    this.onSubmitted,
    this.textInputAction,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.initialize(context);

    final Color effectiveBorderColor = borderColor ?? AppColors.grey;
    final Color effectiveFillColor = fillColor ?? AppColors.grey;

    // Create keyboard actions config for iOS
    KeyboardActionsConfig _buildKeyboardActionsConfig() {
      return KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
        keyboardBarColor: const Color(0xFFCAD1D9), // Apple keyboard color
        actions: [
          KeyboardActionsItem(
            focusNode: focusNode ?? FocusNode(),
            toolbarButtons: [
              (node) {
                return GestureDetector(
                  onTap: () {
                    if (onSubmitted != null) {
                      onSubmitted!();
                    } else {
                      node.unfocus();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Color(0xFF0978ED), // Done button color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
            ],
          ),
        ],
      );
    }

    Widget phoneField = Container(
      decoration: BoxDecoration(
        color: effectiveFillColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntlPhoneField(
        controller: controller,
        focusNode: focusNode,
        flagsButtonPadding: EdgeInsets.only(left: ResponsiveUtils.width(10)),
        dropdownTextStyle: const TextStyle(color: AppColors.black),
        dropdownIconPosition: IconPosition.leading,
        dropdownIcon: const Icon(
          Icons.arrow_drop_down,
          color: AppColors.greyDark,
        ),
        style: const TextStyle(
          color: AppColors.black,
        ),
        // Configure keyboard and text input actions for both platforms
        keyboardType: TextInputType.phone,
        textInputAction: textInputAction ?? 
            (Platform.isIOS ? TextInputAction.done : TextInputAction.next),
        onSubmitted: (value) {
          if (onSubmitted != null) {
            onSubmitted!();
          } else if (Platform.isIOS) {
            FocusScope.of(context).unfocus();
          }
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.grey,
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.greyDark,
            fontWeight: FontWeight.w400,
            fontSize: ResponsiveUtils.width(15),
          ),
          contentPadding: EdgeInsets.all(ResponsiveUtils.width(18)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.transparent,
              width: ResponsiveUtils.width(0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: effectiveBorderColor,
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
        initialCountryCode: initialCountryCode,
        onChanged: onChanged,
      ),
    );

    // Wrap with KeyboardActions only on iOS
    if (Platform.isIOS && focusNode != null) {
      return KeyboardActions(
        config: _buildKeyboardActionsConfig(),
        child: phoneField,
      );
    }

    return phoneField;
  }
}