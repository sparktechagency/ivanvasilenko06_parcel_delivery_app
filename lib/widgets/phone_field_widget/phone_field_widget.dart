import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../constants/app_colors.dart';

class IntlPhoneFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String initialCountryCode;
  final String hintText;
  final ValueChanged<PhoneNumber>? onChanged;

  const IntlPhoneFieldWidget({
    super.key,
    required this.controller,
    this.initialCountryCode = 'US',
    this.hintText = '',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: controller,
      flagsButtonPadding: const EdgeInsets.only(left: 10),
      dropdownTextStyle: const TextStyle(color: AppColors.black),
      dropdownIconPosition: IconPosition.leading,
      dropdownIcon: const Icon(
        Icons.arrow_drop_down,
        color: AppColors.black,
      ),
      style: const TextStyle(
        color: AppColors.black,
      ),
      decoration: InputDecoration(
        filled: true,
        contentPadding: const EdgeInsets.all(16),
        fillColor: AppColors.grey,
        hintText: hintText,
        counterStyle: const TextStyle(color: AppColors.black),
        hintStyle: const TextStyle(
          color: AppColors.black,
          fontSize: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.grey,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.grey,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.red,
            width: 1,
          ),
        ),
      ),
      initialCountryCode: initialCountryCode,
      onChanged: onChanged,
    );
  }
}
