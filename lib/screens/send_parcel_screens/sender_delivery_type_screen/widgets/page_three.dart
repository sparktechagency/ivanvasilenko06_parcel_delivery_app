import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/space_widget/space_widget.dart';
import '../../../../widgets/text_widget/text_widgets.dart';

class PageThree extends StatefulWidget {
  const PageThree({super.key});

  @override
  State<PageThree> createState() => _PageThreeState();
}

class _PageThreeState extends State<PageThree> {
  DateTime? _fromDateTime;
  DateTime? _toDateTime;
  bool _isSelectingFromDate = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 32),
          const TextWidget(
            text: AppStrings.enterDeliveryTime,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontColor: AppColors.black,
            textAlignment: TextAlign.start,
          ),
          const SpaceWidget(spaceHeight: 8),
          const TextWidget(
            text: AppStrings.enterDeliveryTimeDesc,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontColor: AppColors.black,
            textAlignment: TextAlign.start,
          ),
          const SpaceWidget(spaceHeight: 24),
          // From Date Container
          GestureDetector(
            onTap: () {
              setState(() {
                _isSelectingFromDate = true;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                    color: _isSelectingFromDate ? Colors.black : AppColors.grey,
                    width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _fromDateTime == null
                    ? "From Date"
                    : _formatDate(_fromDateTime!),
                style: TextStyle(
                    fontSize: 16,
                    color:
                        _isSelectingFromDate ? Colors.black : AppColors.grey),
              ),
            ),
          ),

          const SpaceWidget(spaceHeight: 16),

          // To Date Container
          GestureDetector(
            onTap: () {
              setState(() {
                _isSelectingFromDate = false;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                    color:
                        !_isSelectingFromDate ? Colors.black : AppColors.grey,
                    width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _toDateTime == null ? "To Date" : _formatDate(_toDateTime!),
                style: TextStyle(
                    fontSize: 16,
                    color:
                        !_isSelectingFromDate ? Colors.black : AppColors.grey),
              ),
            ),
          ),

          const SpaceWidget(spaceHeight: 16),
          const TextWidget(
            text: "Choose Your date",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontColor: AppColors.black,
            textAlignment: TextAlign.start,
          ),

          // Cupertino Date Picker
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.dateAndTime,
              initialDateTime: _isSelectingFromDate
                  ? (_fromDateTime ?? DateTime.now())
                  : (_toDateTime ?? DateTime.now()),
              use24hFormat: false,
              onDateTimeChanged: (DateTime newDateTime) {
                setState(() {
                  if (_isSelectingFromDate) {
                    _fromDateTime = newDateTime;
                  } else {
                    _toDateTime = newDateTime;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
