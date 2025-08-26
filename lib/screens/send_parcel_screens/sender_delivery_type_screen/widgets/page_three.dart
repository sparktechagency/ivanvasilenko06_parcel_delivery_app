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
  bool _isProcessingSelection = false;
  bool _isDisposed = false;

  Future<TimeOfDay?> _selectTime(
      BuildContext context, String title, TimeOfDay initialTime) async {
    if (!mounted || _isDisposed) return null;

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
    _isDisposed = false;

    try {
      _parcelController = Get.find<ParcelController>();
    } catch (e) {
      _parcelController = Get.put(ParcelController());
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isProcessingSelection = false;
    super.dispose();
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) async {
    if (_isProcessingSelection || !mounted || _isDisposed) return;

    _isProcessingSelection = true;

    try {
      if (args.value is PickerDateRange) {
        final DateTime? startDate = args.value.startDate;
        final DateTime? endDate = args.value.endDate;

        // Handle start date selection
        if (startDate != null &&
            _fromDateTime == null &&
            mounted &&
            !_isDisposed) {
          final TimeOfDay? startTime = await _selectTime(
            context,
            'selectStartTime'.tr,
            const TimeOfDay(hour: 9, minute: 0),
          );

          if (!mounted || _isDisposed) return;

          if (startTime != null) {
            final newFromDateTime = DateTime(
              startDate.year,
              startDate.month,
              startDate.day,
              startTime.hour,
              startTime.minute,
            );

            if (mounted && !_isDisposed) {
              setState(() {
                _fromDateTime = newFromDateTime;
              });
              _parcelController?.setStartDateTime(newFromDateTime);
            }
          }
        }

        // Handle end date selection - only show end time picker
        if (endDate != null &&
            _fromDateTime != null &&
            mounted &&
            !_isDisposed) {
          // Only show end time picker, don't show start time again
          final TimeOfDay? endTime = await _selectTime(
            context,
            'selectEndTime'.tr,
            const TimeOfDay(hour: 17, minute: 0),
          );

          if (!mounted || _isDisposed) return;

          if (endTime != null) {
            final newToDateTime = DateTime(
              endDate.year,
              endDate.month,
              endDate.day,
              endTime.hour,
              endTime.minute,
            );

            if (mounted && !_isDisposed) {
              setState(() {
                _toDateTime = newToDateTime;
              });
              _parcelController?.setEndDateTime(newToDateTime);
            }
          }
        }

        // Handle case where user selects same date for both start and end
        if (startDate != null &&
            endDate != null &&
            startDate.isAtSameMomentAs(endDate) &&
            _fromDateTime == null &&
            mounted &&
            !_isDisposed) {
          // First select start time
          final TimeOfDay? startTime = await _selectTime(
            context,
            'selectStartTime'.tr,
            const TimeOfDay(hour: 9, minute: 0),
          );

          if (!mounted || _isDisposed) return;

          if (startTime != null) {
            final newFromDateTime = DateTime(
              startDate.year,
              startDate.month,
              startDate.day,
              startTime.hour,
              startTime.minute,
            );

            if (mounted && !_isDisposed) {
              setState(() {
                _fromDateTime = newFromDateTime;
              });
              _parcelController?.setStartDateTime(newFromDateTime);
            }

            // Then select end time
            final TimeOfDay? endTime = await _selectTime(
              context,
              'selectEndTime'.tr,
              TimeOfDay(hour: startTime.hour + 1, minute: startTime.minute),
            );

            if (!mounted || _isDisposed) return;

            if (endTime != null) {
              final newToDateTime = DateTime(
                endDate.year,
                endDate.month,
                endDate.day,
                endTime.hour,
                endTime.minute,
              );

              if (mounted && !_isDisposed) {
                setState(() {
                  _toDateTime = newToDateTime;
                });
                _parcelController?.setEndDateTime(newToDateTime);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error in _onSelectionChanged: $e');
    } finally {
      if (mounted && !_isDisposed) {
        _isProcessingSelection = false;
      }
    }
  }

  // Add method to reset dates if needed
  void _resetDates() {
    if (_isDisposed) return;

    if (mounted && !_isDisposed) {
      setState(() {
        _fromDateTime = null;
        _toDateTime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

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
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _fromDateTime == null
                          ? "fromDate".tr
                          : _formatDateTime(_fromDateTime!),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.arrow_forward_ios),
                ),
                Expanded(
                  child: Container(
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
                      textAlign: TextAlign.center,
                    ),
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
            // Add reset button for better UX
            // if (_fromDateTime != null || _toDateTime != null)
            //   Center(
            //     child: TextButton(
            //       onPressed: _resetDates,
            //       child: Text(
            //         'resetDates'.tr.isNotEmpty
            //             ? 'resetDates'.tr
            //             : 'Reset Dates',
            //         style: const TextStyle(
            //           color: AppColors.black,
            //           fontSize: 14,
            //           fontWeight: FontWeight.w500,
            //         ),
            //       ),
            //     ),
            //   ),
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

// Custom Time Picker Dialog with improved state management
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
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;

    _hourController.text = _hour.toString().padLeft(2, '0');
    _minuteController.text = _minute.toString().padLeft(2, '0');
  }

  @override
  void dispose() {
    _isDisposed = true;
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _validateHour(String value) {
    if (_isDisposed || !mounted) return;

    setState(() {
      _hour = int.tryParse(value) ?? _hour;
      if (_hour < 0) _hour = 0;
      if (_hour > 23) _hour = 23;
      _hourController.text = _hour.toString().padLeft(2, '0');
    });
  }

  void _validateMinute(String value) {
    if (_isDisposed || !mounted) return;

    setState(() {
      _minute = int.tryParse(value) ?? _minute;
      if (_minute < 0) _minute = 0;
      if (_minute > 59) _minute = 59;
      _minuteController.text = _minute.toString().padLeft(2, '0');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

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
                  label: 'cancel'.tr,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  buttonRadius: BorderRadius.circular(10),
                  backgroundColor: AppColors.white,
                  textColor: AppColors.black,
                  onPressed: () {
                    if (mounted && !_isDisposed) {
                      Navigator.pop(context);
                    }
                  },
                ),
                // OK button
                ButtonWidget(
                  buttonWidth: 100,
                  buttonHeight: 40,
                  label: 'ok'.tr,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  buttonRadius: BorderRadius.circular(10),
                  backgroundColor: AppColors.black,
                  textColor: AppColors.white,
                  onPressed: () {
                    if (mounted && !_isDisposed) {
                      final selectedTime = TimeOfDay(
                        hour: _hour,
                        minute: _minute,
                      );
                      Navigator.pop(context, selectedTime);
                    }
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
