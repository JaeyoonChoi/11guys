import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calendar_final/provider/appointment_control.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/foundation.dart';
import 'package:calendar_final/view/screen_week.dart';

class MonthScreen extends StatelessWidget {
  final String username;
  final AppointmentDataSource dataSource;// 사용자 ID 추가

  MonthScreen({required this.username, required this.dataSource}); // 생성자 수정

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // appBar: AppBar(), //상
        body: Container(
          // 중
          child: SfCalendar(
            view: CalendarView.month,
            monthViewSettings: MonthViewSettings(
              showTrailingAndLeadingDates: false,
              // navigationDirection: MonthNavigationDirection.horizontal,   // 슬라이드 가로
              showAgenda: true,
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              // numberOfWeeksInView: 4,    // 요놈이 없어야 이번 달만 표시됨
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



// 일정 수정 다이얼로그 함수 : showEditDialog()
void showEditDialog(BuildContext context, String username, dynamic appointment) {
  final TextEditingController titleController = TextEditingController(text: appointment.subject);
  DateTime startTime = appointment.startTime;
  DateTime endTime = appointment.endTime;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("일정 수정"),
            // 삭제
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
            // 제목 입력 필드
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

                // 시작 시간을 선택한 경우
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

                // 끝 시간을 선택한 경우
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
          ],
        ),
        actions: [
          // 저장 버튼
          TextButton(
            onPressed: () async {
              // // Lambda로 일정 데이터 전송
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
          // 취소 버튼
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