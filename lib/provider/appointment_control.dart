// import 'package:calendar_final/view/screen_week.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// List 예시
List<CalendarResource> resourceColl = <CalendarResource>[];

// DataBase
// List 관리
_AppointmentDataSource getCalendarDataSource() {
  // appointments 리스트 생성 <- Appointment 타입의 객체들 저장
  List<Appointment> appointments = <Appointment>[];

  appointments.add(Appointment(
  startTime: DateTime.now(),
  endTime: DateTime.now().add(Duration(hours: 2)),
  subject: 'Today',
  color: Colors.blue,
  startTimeZone: '',
  endTimeZone: '',
  ));

  appointments.add(Appointment(
    startTime: DateTime(2024,5,10,10,0),
    endTime: DateTime(2024,5,10,12,0),
    subject: 'football',
    color: Colors.red,
    startTimeZone: '',
    endTimeZone: '',
  ));

  appointments.add(Appointment(
      startTime: DateTime(2024,5,10,9,0),
      endTime: DateTime(2024,5,10,11,0),
    subject: 'test',
    color: Color.fromARGB(128, 0, 0, 255),  // 반투명
    startTimeZone: '',
    endTimeZone: '',
  ));

  appointments.add(Appointment(
    startTime: DateTime(2024,5,10,7,0),
    endTime: DateTime(2024,5,10,12,0),
    subject: 'test',
    color: Color.fromARGB(128, 0, 0, 255),  // 반투명
    startTimeZone: '',
    endTimeZone: '',
  ));


  return _AppointmentDataSource(appointments);
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source){
    appointments = source;
  }
}
//
//











// CalendarDataSource : 약속 데이터소스 설정 클래스
// mapping & Binding

// // Calendar data source and mapping


// class MeetingDataSource extends CalendarDataSource {
//   MeetingDataSource(List<Meeting> source){
//     appointments = source;
//   }
//
//   @override
//   DateTime getStartTime(int index) {
//     return appointments![index].from;
//   }
//
//   @override
//   DateTime getEndTime(int index) {
//     return appointments![index].to;
//   }
//
//   @override
//   bool isAllDay(int index) {
//     return appointments![index].isAllDay;
//   }
//
//   @override
//   String getSubject(int index) {
//     return appointments![index].eventName;
//   }
//
//   @override
//   String getStartTimeZone(int index) {
//     return appointments![index].startTimeZone;
//   }
//
//   @override
//   String getEndTimeZone(int index) {
//     return appointments![index].endTimeZone;
//   }
//
//   @override
//   Color getColor(int index) {
//     return appointments![index].background;
//   }
// }



// // Alarm (notifier when the datasource collection is modified to reflect the chnages on UI)
// // when added to the datasource or removeed from the datasource.
// events.dataSource.clear();
// events.notifyListeners(CalendarDataSourceAction.reset, null);
//
//

