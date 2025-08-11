import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/screens/send_parcel_screens/controller/sending_parcel_controller.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
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
  ParcelController? _parcelController;

  DateTime? _fromDateTime;
  DateTime? _toDateTime;

  Future<TimeOfDay?> _selectTime(
      BuildContext context, String title, TimeOfDay initialTime) async {
    return await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return CustomTimePickerDialog(
          title: title,
          initialTime: initialTime,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize controller safely
    try {
      _parcelController = Get.find<ParcelController>();
    } catch (e) {
      _parcelController = Get.put(ParcelController());
    }
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) async {
    if (!mounted) return; // Early return if widget is not mounted

    if (args.value is PickerDateRange) {
      DateTime? startDate = args.value.startDate;
      DateTime? endDate = args.value.endDate;

      if (_fromDateTime == null) {
        if (!mounted) return; // Check if widget is still mounted

        try {
          if (!mounted) return;
          TimeOfDay? startTime = await _selectTime(context, "Select Start Time",
              const TimeOfDay(hour: 9, minute: 0));

          if (startTime != null && mounted) {
            // Check mounted again after async operation
            final newDateTime = DateTime(
              startDate!.year,
              startDate.month,
              startDate.day,
              startTime.hour,
              startTime.minute,
            );

            setState(() {
              _fromDateTime = newDateTime;
            });

            // Update controller outside setState to avoid potential issues
            _parcelController?.setStartDateTime(newDateTime);
          }
        } catch (e) {
          // Handle any errors that might occur during time selection
          if (mounted) {
            // Log error or show user feedback if needed
            debugPrint('Error selecting start time: $e');
          }
        }
      }

      if (_toDateTime == null) {
        if (!mounted) return; // Check if widget is still mounted

        try {
          if (!mounted) return;
          TimeOfDay? endTime = await _selectTime(
              context, "Select End Time", const TimeOfDay(hour: 9, minute: 0));

          if (endTime != null && mounted) {
            // Check mounted again after async operation
            final newDateTime = DateTime(
              endDate!.year,
              endDate.month,
              endDate.day,
              endTime.hour,
              endTime.minute,
            );

            setState(() {
              _toDateTime = newDateTime;
            });

            // Update controller outside setState to avoid potential issues
            _parcelController?.setEndDateTime(newDateTime);
          }
        } catch (e) {
          // Handle any errors that might occur during time selection
          if (mounted) {
            // Log error or show user feedback if needed
            debugPrint('Error selecting end time: $e');
          }
        }
      }
    }
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

// Custom Time Picker Dialog remains unchanged
// Custom Time Picker Dialog
class CustomTimePickerDialog extends StatefulWidget {
  final String title;
  final TimeOfDay initialTime;

  const CustomTimePickerDialog(
      {super.key, required this.title, required this.initialTime});

  @override
  CustomTimePickerDialogState createState() => CustomTimePickerDialogState();
}

class CustomTimePickerDialogState extends State<CustomTimePickerDialog> {
  late int _hour;
  late int _minute;
  final _hourController = TextEditingController();
  final _minuteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;

    _hourController.text = _hour.toString().padLeft(2, '0');
    _minuteController.text = _minute.toString().padLeft(2, '0');
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _validateHour(String value) {
    setState(() {
      _hour = int.tryParse(value) ?? _hour;
      if (_hour < 0) _hour = 0;
      if (_hour > 23) _hour = 23;
      _hourController.text = _hour.toString().padLeft(2, '0');
    });
  }

  void _validateMinute(String value) {
    setState(() {
      _minute = int.tryParse(value) ?? _minute;
      if (_minute < 0) _minute = 0;
      if (_minute > 59) _minute = 59;
      _minuteController.text = _minute.toString().padLeft(2, '0');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.grey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextWidget(
              text: widget.title,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
              textAlignment: TextAlign.start,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hour Input
                SizedBox(
                  width: 80,
                  child: TextField(
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "AeonikTRIAL"),
                    controller: _hourController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(hintText: 'HH'),
                    onChanged: _validateHour,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(":",
                    style:
                        TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                // Minute Input
                SizedBox(
                  width: 80,
                  child: TextField(
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "AeonikTRIAL"),
                    controller: _minuteController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                        hintText: 'MM',
                        hintStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: "AeonikTRIAL")),
                    onChanged: _validateMinute,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel button
                ButtonWidget(
                  buttonWidth: 100,
                  buttonHeight: 40,
                  label: 'Cancel',
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  buttonRadius: BorderRadius.circular(10),
                  backgroundColor: AppColors.white,
                  textColor: AppColors.black,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                // OK button
                ButtonWidget(
                  buttonWidth: 100,
                  buttonHeight: 40,
                  label: 'OK',
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  buttonRadius: BorderRadius.circular(10),
                  backgroundColor: AppColors.black,
                  textColor: AppColors.white,
                  onPressed: () {
                    final selectedTime = TimeOfDay(
                      hour: _hour, // Directly using the hour from the input
                      minute:
                          _minute, // Directly using the minute from the input
                    );
                    Navigator.pop(context, selectedTime);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
