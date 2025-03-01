import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:table_calendar/table_calendar.dart';

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
  bool _isSelectingFromDate = true;

  // Adding variable for selected day from calendar
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Variables for range selected
  DateTime? _rangeStartDate;
  DateTime? _rangeEndDate;
  bool _rangeApplied = false; // Flag to check if the range is applied

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
                      ? "fromDate".tr
                      : _formatDate(_fromDateTime!),
                  style: TextStyle(
                    fontSize: 16,
                    color: _fromDateTime != null
                        ? Colors.black
                        : (_isSelectingFromDate ? Colors.black : AppColors.grey),
                  ),
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
                  _toDateTime == null ? "toDate".tr : _formatDate(_toDateTime!),
                  style: TextStyle(
                    fontSize: 16,
                    color: _toDateTime != null
                        ? Colors.black
                        : (!_isSelectingFromDate ? Colors.black : AppColors.grey),
                  ),
                ),
              ),
            ),
      
            const SpaceWidget(spaceHeight: 16),
            TextWidget(
              text: "chooseYourDate".tr,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.black,
              textAlignment: TextAlign.start,
            ),
      
            const SpaceWidget(spaceHeight: 16),
      
            // Table Calendar Widget
            TableCalendar(
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.utc(2060, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  // Update the selected date (From or To) based on _isSelectingFromDate
                  if (_isSelectingFromDate) {
                    _fromDateTime = selectedDay;
                  } else {
                    _toDateTime = selectedDay;
                  }
                });
              },
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: AppColors.black, // Black for selected dates
                  shape: BoxShape.rectangle,
                ),
                selectedTextStyle: const TextStyle(color: Colors.white),
                rangeHighlightColor:
                    Colors.grey, // Default grey for in-between range
                rangeStartDecoration: BoxDecoration(
                  color: Colors.black, // Start date in black
                  shape: BoxShape.rectangle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: Colors.black, // End date in black
                  shape: BoxShape.rectangle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                // Custom builder for the start date
                rangeStartBuilder: (context, date, _) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.rectangle,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
                // Custom builder for the end date
                rangeEndBuilder: (context, date, _) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.rectangle,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
                // Custom builder to highlight days in between the range
                defaultBuilder: (context, date, _) {
                  if (_fromDateTime != null &&
                      _toDateTime != null &&
                      _rangeApplied &&
                      date.isAfter(_fromDateTime!) &&
                      date.isBefore(_toDateTime!)) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.grey, // Light grey for the range
                        shape: BoxShape.rectangle,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
      
            const SpaceWidget(spaceHeight: 16),
      
            // Apply Button
            ButtonWidget(
              buttonWidth: double.infinity,
              label: "Apply",
              backgroundColor: AppColors.black,
              onPressed: () {
                setState(() {
                  // Apply logic: Ensure _fromDateTime and _toDateTime are selected
                  if (_fromDateTime != null && _toDateTime != null) {
                    _rangeStartDate = _fromDateTime;
                    _rangeEndDate = _toDateTime;
                    _rangeApplied =
                        true; // Flag to indicate the range has been applied
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}
