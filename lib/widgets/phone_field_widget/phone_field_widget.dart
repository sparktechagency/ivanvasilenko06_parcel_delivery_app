import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
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

  const IntlPhoneFieldWidget({
    super.key,
    required this.controller,
    this.initialCountryCode = 'IL',
    this.hintText = '',
    this.onChanged,
    this.borderColor,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.initialize(context);

    final Color effectiveBorderColor = borderColor ?? AppColors.grey;
    final Color effectiveFillColor = fillColor ?? AppColors.grey;

    return Container(
      decoration: BoxDecoration(
        color: effectiveFillColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntlPhoneField(
        controller: controller,
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
        // Add iOS-specific keyboard configuration
        keyboardType: TextInputType.phone,
        textInputAction: Platform.isIOS ? TextInputAction.done : TextInputAction.next,
        onSubmitted: Platform.isIOS ? (value) {
          // Dismiss keyboard on iOS when done button is pressed
          FocusScope.of(context).unfocus();
        } : null,
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
  }
}
