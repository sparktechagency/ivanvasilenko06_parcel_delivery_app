import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../constants/app_colors.dart';
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

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) async {
    if (args.value is PickerDateRange) {
      DateTime? startDate = args.value.startDate;
      DateTime? endDate = args.value.endDate;

      if (startDate != null && _fromDateTime == null) {
        // Select Start Time only when picking fromDate for the first time
        TimeOfDay? startTime = await _selectTime(context, "Select Start Time");
        if (startTime != null) {
          setState(() {
            _fromDateTime = DateTime(
                startDate.year, startDate.month, startDate.day,
                startTime.hour, startTime.minute
            );
          });
        }
      }

      if (endDate != null && _toDateTime == null) {
        // Select End Time only when picking toDate for the first time
        TimeOfDay? endTime = await _selectTime(context, "Select End Time");
        if (endTime != null) {
          setState(() {
            _toDateTime = DateTime(
                endDate.year, endDate.month, endDate.day,
                endTime.hour, endTime.minute
            );
          });
        }
      }
    }
  }

  Future<TimeOfDay?> _selectTime(BuildContext context, String title) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
      helpText: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SpaceWidget(spaceHeight: 32),
            TextWidget(
              text: "enterDeliveryTime".tr,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
              textAlignment: TextAlign.start,
            ),
            const SpaceWidget(spaceHeight: 8),
            TextWidget(
              text: "enterDeliveryTimeDesc".tr,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.black,
              textAlignment: TextAlign.start,
            ),
            const SpaceWidget(spaceHeight: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // From Date & Time Display
                Container(
                  padding: const EdgeInsets.all(08),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _fromDateTime == null
                        ? "fromDate".tr
                        : _formatDateTime(_fromDateTime!),
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios),
                // To Date & Time Display
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _toDateTime == null
                        ? "toDate".tr
                        : _formatDateTime(_toDateTime!),
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SpaceWidget(spaceHeight: 16),

            // Syncfusion DatePicker
            SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
              startRangeSelectionColor: AppColors.black,
              endRangeSelectionColor: AppColors.black,
              rangeSelectionColor: AppColors.greyLight,
              onSelectionChanged: _onSelectionChanged,
              backgroundColor: AppColors.white,
              selectionShape: DateRangePickerSelectionShape.rectangle,
              headerStyle: const DateRangePickerHeaderStyle(
                backgroundColor: AppColors.white,
                textStyle: TextStyle(
                    color: AppColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SpaceWidget(spaceHeight: 16),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
