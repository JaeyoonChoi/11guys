import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:calendar_final/provider/appointment_control.dart';
import 'package:calendar_final/view/main.dart';
import 'main.dart';

class WeekScreen extends StatelessWidget {
  final String username;
  final AppointmentDataSource dataSource;

  WeekScreen({required this.username, required this.dataSource});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SfCalendar(
            view: CalendarView.week,
            showNavigationArrow: true,
            dataSource: dataSource,
            // Drag & Drop
            allowDragAndDrop: false,
            onDragStart: dragStart,
            onDragUpdate: dragUpdate,
            onDragEnd: dragEnd,
            // 크기 조정
            allowAppointmentResize: false,
            onAppointmentResizeStart: resizeStart,
            onAppointmentResizeUpdate: resizeUpdate,
            onAppointmentResizeEnd: resizeEnd,
            timeSlotViewSettings: TimeSlotViewSettings(
              timeIntervalHeight: -1,
              minimumAppointmentDuration: Duration(minutes: 10),
            ),

            // 길게 눌렀을 때 호출되는 콜백
            onLongPress: (details) {
              // 셀을 길게 눌렀을 때
              if (details.targetElement == CalendarElement.calendarCell && details.date != null) {
                DateTime selectedDate = details.date!;
                DateTime endDate = selectedDate.add(Duration(hours: 1));
                showInsertDialog(context, username, selectedDate, endDate);
              }
              // 블럭을 길게 눌렀을 때
              else if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
                final dynamic appointment = details.appointments!.first;
                showEditDialog(context, appointment);
              }
            }
        ),
      ),
    );
  }

  // 일정 추가 다이얼로그 함수 : showInsertDialog()
  void showInsertDialog(BuildContext context, String username, DateTime startTime, DateTime endTime) {
    final TextEditingController titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("일정 추가"),
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
                  child: Text('시작 시간')
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
                  child: Text("끝 시간")
              ),
            ],
          ),
          actions: [
            // 저장 버튼
            TextButton(
              onPressed: () async {
                // Lambda로 일정 데이터 전송
                bool success = await insertSchedule(username, titleController.text, startTime, endTime);
                if (success) {
                  // 데이터 소스 갱신 및 새로고침 로직을 여기 추가할 수 있습니다.
                  // 예: dataSource.notifyListeners();

                  Navigator.of(context).pop();
                } else {
                  // 오류 처리 로직
                }
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

  Future<bool> insertSchedule(String username, String subject, DateTime start, DateTime end) async {
    String lambdaArn = 'https://2ylpznm6rb.execute-api.ap-northeast-2.amazonaws.com/default/master';

    Map<String, dynamic> requestBody = {
      'function': 'insert',
      'id': username,
      'subject': subject,
      'start': formatDateTime(start),
      'end': formatDateTime(end),
      'color': 'blue', // 필요에 따라 색상 설정
    };

    try {
      final response = await http.post(
        Uri.parse(lambdaArn),
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['success'] == true;
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }

  String formatDateTime(DateTime dateTime) {
    final formattedDate = "${dateTime.year}${dateTime.month.toString().padLeft(2, '0')}${dateTime.day.toString().padLeft(2, '0')}";
    final formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}${dateTime.minute.toString().padLeft(2, '0')}";
    return formattedDate + formattedTime;
  }

  // 일정 수정 다이얼로그 함수 : showEditDialog()
  void showEditDialog(BuildContext context, dynamic appointment) {
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
                onPressed: () {
                  // 일정 삭제 로직
                  // todo
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
              onPressed: () {
                // 일정 수정 로직 추가
                appointment.subject = titleController.text;
                appointment.startTime = startTime;
                appointment.endTime = endTime;
                Navigator.of(context).pop();
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
}

// Drag & Drop
void dragStart(AppointmentDragStartDetails appointmentDragStartDetails) {
  dynamic appointment = appointmentDragStartDetails.appointment;
  CalendarResource? resource = appointmentDragStartDetails.resource;
}
void dragUpdate(AppointmentDragUpdateDetails appointmentDragUpdateDetails) {
  dynamic appointment = appointmentDragUpdateDetails.appointment;
  DateTime? draggingTime = appointmentDragUpdateDetails.draggingTime;
  Offset? draggingOffset = appointmentDragUpdateDetails.draggingPosition;
  CalendarResource? sourceResource = appointmentDragUpdateDetails.sourceResource;
  CalendarResource? targetResource = appointmentDragUpdateDetails.targetResource;
}
void dragEnd(AppointmentDragEndDetails appointmentDragEndDetails) {
  dynamic appointment = appointmentDragEndDetails.appointment!;
  CalendarResource? sourceResource = appointmentDragEndDetails.sourceResource;
  CalendarResource? targetResource = appointmentDragEndDetails.targetResource;
  DateTime? droppingTime = appointmentDragEndDetails.droppingTime;
}

// onAppointmentResizeStart
void resizeStart(AppointmentResizeStartDetails appointmentResizeStartDetails) {
  dynamic appointment = appointmentResizeStartDetails.appointment;
  CalendarResource? resource = appointmentResizeStartDetails.resource;
}
void resizeUpdate(AppointmentResizeUpdateDetails appointmentResizeUpdateDetails) {
  dynamic appointment = appointmentResizeUpdateDetails.appointment;
  DateTime? resizingTime = appointmentResizeUpdateDetails.resizingTime;
  Offset? resizingOffset = appointmentResizeUpdateDetails.resizingOffset;
  CalendarResource? resourceDetails = appointmentResizeUpdateDetails.resource;
}
void resizeEnd(AppointmentResizeEndDetails appointmentResizeEndDetails) {
  dynamic appointment = appointmentResizeEndDetails.appointment;
  DateTime? startTime = appointmentResizeEndDetails.startTime;
  DateTime? endTime = appointmentResizeEndDetails.endTime;
  CalendarResource? resourceDetails = appointmentResizeEndDetails.resource;
}
