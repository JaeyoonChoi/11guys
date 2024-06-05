import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
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
            // 셀을 길게 눌렀을 때-----------------------------------------
            // 선택된 셀의 상세 정보 받기
            if (details.targetElement == CalendarElement.calendarCell && details.date != null) {
              // 선택된 셀의 시작, 끝 시간 계산 (기본 1시간 설정)
              DateTime selectedDate = details.date!;
              DateTime endDate = selectedDate.add(Duration(hours: 1));
              // 일정 추가 다이얼로그 표시
              showInsertDialog(context, selectedDate, endDate);
            }
            // 블럭을 길게 눌럿을 때---------------------------------------
            else if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
              // 선택된 이벤트(일정) 가져오기
              final dynamic appointment = details.appointments!.first;
              // 일정 수정 다이얼로그 표시
              showEditDialog(context, appointment);
            }
          }

        ),
      ),
    );
  }
}


// 일정 추가 다이얼로그 함수 : showInsertDialog()
void showInsertDialog(BuildContext context, DateTime startTime, DateTime endTime) {
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
                onPressed: () async{
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
              // }
            },
                child: Text('시작 시간')),

            TextButton(
                onPressed: () async{
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

            // gpt 제안
            // SizedBox(height: 20),
            // // 선택한 셀의 시작 시간을 표시합니다.
            // Row(
            //   children: [
            //     Text("Start: ${startTime.toString()}"),
            //   ],
            // ),
            // SizedBox(height: 10),
            // // 선택한 셀의 끝 시간을 표시합니다.
            // Row(
            //   children: [
            //     Text("End: ${endTime.toString()}"),
            //   ],
            // ),
          ],
        ),
        actions: [
          // 저장 버튼
          TextButton(
            onPressed: () {
              // 여기서 데이터를 dataSource에 추가하는 로직을 구현할 수 있습니다.
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


// // Drag & Drop
// void dragStart(AppointmentDragStartDetails appointmentDragStartDetails) {
//   dynamic appointment = appointmentDragStartDetails.appointment;
//   CalendarResource? resource = appointmentDragStartDetails.resource;
// }
// void dragUpdate(AppointmentDragUpdateDetails appointmentDragUpdateDetails) {
//   dynamic appointment = appointmentDragUpdateDetails.appointment;
//   DateTime? draggingTime = appointmentDragUpdateDetails.draggingTime;
//   Offset? draggingOffset = appointmentDragUpdateDetails.draggingPosition;
//   CalendarResource? sourceResource = appointmentDragUpdateDetails.sourceResource;
//   CalendarResource? targetResource = appointmentDragUpdateDetails.targetResource;
// }
// void dragEnd(AppointmentDragEndDetails appointmentDragEndDetails) {
//   dynamic appointment = appointmentDragEndDetails.appointment!;
//   CalendarResource? sourceResource = appointmentDragEndDetails.sourceResource;
//   CalendarResource? targetResource = appointmentDragEndDetails.targetResource;
//   DateTime? droppingTime = appointmentDragEndDetails.droppingTime;
// }
//
//
// // onAppointmentResizeStart
// void resizeStart(AppointmentResizeStartDetails appointmentResizeStartDetails) {
//   dynamic appointment = appointmentResizeStartDetails.appointment;
//   CalendarResource? resource = appointmentResizeStartDetails.resource;
// }
// void resizeUpdate(AppointmentResizeUpdateDetails appointmentResizeUpdateDetails) {
//   dynamic appointment = appointmentResizeUpdateDetails.appointment;
//   DateTime? resizingTime = appointmentResizeUpdateDetails.resizingTime;
//   Offset? resizingOffset = appointmentResizeUpdateDetails.resizingOffset;
//   CalendarResource? resourceDetails = appointmentResizeUpdateDetails.resource;
// }
// void resizeEnd(AppointmentResizeEndDetails appointmentResizeEndDetails) {
//   dynamic appointment = appointmentResizeEndDetails.appointment;
//   DateTime? startTime = appointmentResizeEndDetails.startTime;
//   DateTime? endTime = appointmentResizeEndDetails.endTime;
//   CalendarResource? resourceDetails = appointmentResizeEndDetails.resource;
// }

