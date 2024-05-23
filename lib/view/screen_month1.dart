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
                showAgenda: true,
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                numberOfWeeksInView: 4),
            dataSource: dataSource,
            showNavigationArrow: true,
          ),
        ),
        // FAB
        // floatingActionButton: FloatingActionButton(
        //   child: Icon(Icons.add),
        //   onPressed: (){
        //     month-week 전환
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => WeekScreen(username: username)), // username 전달
        //     );
        //   },
        // ),
        // bottomNavigationBar: BottomAppBar( child: Text('0'),), //하
        // bottomNavigationBar: BottomNavigationBarExample(),
      ),
    );
  }
}
