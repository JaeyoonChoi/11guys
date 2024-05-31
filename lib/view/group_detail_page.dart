import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class GroupDetailedPage extends StatelessWidget {
  final String pin;

  GroupDetailedPage({required this.pin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('그룹 캘린더 상세'),
            SizedBox(width: 8.0),
            Text('            PIN 번호: $pin', style: TextStyle(fontSize: 20)),
          ],
        )
      ),
      body: Container(
        child: SfCalendar(
          view: CalendarView.week,
        )
      )
    );
  }
}
