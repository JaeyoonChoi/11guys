import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calendar_final/provider/appointment_control.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/foundation.dart';
import 'package:calendar_final/view/screen_week.dart';

class MonthScreen extends StatelessWidget {
  final String username;
  final AppointmentDataSource dataSource;

  MonthScreen({required this.username, required this.dataSource});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: SfCalendar(
            view: CalendarView.month,
            monthViewSettings: MonthViewSettings(
              showTrailingAndLeadingDates: false,
              showAgenda: true,
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            ),
            dataSource: dataSource,
            showNavigationArrow: true,

            // 길게 눌러 일정 수정
            onLongPress: (details) {
              if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
                final dynamic appointment = details.appointments!.first;
                showEditDialog(context, username, appointment);
              }
            },
          ),
        ),
      ),
    );
  }
}

void showEditDialog(BuildContext context, String username, dynamic appointment) {
  final TextEditingController titleController = TextEditingController(text: appointment.subject);
  DateTime startTime = appointment.startTime;
  DateTime endTime = appointment.endTime;
  bool isRepeat = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("일정 수정"),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                // bool success = await deleteSchedule(username, appointment.startTime, appointment.endTime);
                // if (success) {
                //   Navigator.of(context).pop();
                // } else {
                //   // 오류 처리 로직
                // }
              },
            )
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),
            TextButton(
              onPressed: () async {
                TimeOfDay? selectedStartTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(startTime),
                );

                if (selectedStartTime != null) {
                  startTime = DateTime(
                    startTime.year,
                    startTime.month,
                    startTime.day,
                    selectedStartTime.hour,
                    selectedStartTime.minute,
                  );
                }
              },
              child: Text('시작 시간'),
            ),
            TextButton(
              onPressed: () async {
                TimeOfDay? selectedEndTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(endTime),
                );

                if (selectedEndTime != null) {
                  endTime = DateTime(
                    endTime.year,
                    endTime.month,
                    endTime.day,
                    selectedEndTime.hour,
                    selectedEndTime.minute,
                  );
                }
              },
              child: Text("끝 시간"),
            ),
            Row(
              children: [
                Checkbox(
                  value: isRepeat,
                  onChanged: (bool? value) {
                    isRepeat = value!;
                  },
                ),
                Text("매주 반복"),
              ],
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // bool success = await editSchedule(
              //   username,
              //   appointment.startTime,
              //   appointment.endTime,
              //   titleController.text,
              //   startTime,
              //   endTime,
              // );
              // if (success) {
              //   Navigator.of(context).pop();
              // } else {
              //   // 오류 처리 로직
              // }
            },
            child: Text("Save"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
        ],
      );
    },
  );
}
