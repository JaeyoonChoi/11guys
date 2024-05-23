import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calendar_final/provider/appointment_control.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/foundation.dart';

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
          ),
        ),
      ),
    );
  }
}
