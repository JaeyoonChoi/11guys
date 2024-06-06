import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class GroupDetailedPage extends StatefulWidget {
  final String pin;
  GroupDetailedPage({required this.pin});

  @override
  _GroupDetailedPageState createState() => _GroupDetailedPageState();
}

class _GroupDetailedPageState extends State<GroupDetailedPage> {
  late Future<List<Appointment>> appointments;
  List<Appointment> _appointments = [];
  late AppointmentDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    appointments = fetchAppointments();
  }

  Future<List<Appointment>> fetchAppointments() async {
    String lambdaArn = 'https://2ylpznm6rb.execute-api.ap-northeast-2.amazonaws.com/default/master';

    final response = await http.post(
      Uri.parse(lambdaArn),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'function': 'getGroupSchedule',
        'pin': widget.pin,
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        List<dynamic> intervals = jsonResponse['appointments'];

        // 디버깅용 데이터 출력
        print('Fetched data from Lambda: $intervals');

        List<Appointment> appointments = [];

        for (var interval in intervals) {
          DateTime start = parseDate(interval['start']);
          DateTime end = parseDate(interval['end']);
          appointments.add(Appointment(
            startTime: start,
            endTime: end,
            subject: 'Busy',
            color: Colors.red,
          ));
        }

        // Calculate free intervals
        List<Appointment> freeIntervals = calculateFreeIntervals(appointments);
        _dataSource = AppointmentDataSource(freeIntervals);
        return freeIntervals;
      } else {
        throw Exception('Failed to load appointments');
      }
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  DateTime parseDate(String dateString) {
    return DateTime.parse(
        '${dateString.substring(0, 4)}-${dateString.substring(4, 6)}-${dateString.substring(6, 8)}T${dateString.substring(8, 10)}:${dateString.substring(10, 12)}:00');
  }

  List<Appointment> calculateFreeIntervals(List<Appointment> appointments) {
    List<Appointment> result = [];
    if (appointments.isEmpty) return result;

    // Sort appointments by start time
    appointments.sort((a, b) => a.startTime.compareTo(b.startTime));

    DateTime currentEnd = DateTime.now().subtract(Duration(days: 1));

    for (var appointment in appointments) {
      if (appointment.startTime.isAfter(currentEnd)) {
        // Add free interval
        result.add(Appointment(
          startTime: currentEnd,
          endTime: appointment.startTime,
          subject: 'Free',
          color: Colors.green,
        ));
      }
      currentEnd = appointment.endTime.isAfter(currentEnd) ? appointment.endTime : currentEnd;
    }

    // Add the last free interval until the end of the week
    DateTime endOfWeek = DateTime.now().add(Duration(days: 7 - DateTime.now().weekday));
    if (currentEnd.isBefore(endOfWeek)) {
      result.add(Appointment(
        startTime: currentEnd,
        endTime: endOfWeek,
        subject: 'Free',
        color: Colors.green,
      ));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Details'),
      ),
      body: FutureBuilder<List<Appointment>>(
        future: appointments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No free intervals found.'));
          }

          return SfCalendar(
            view: CalendarView.week,
            dataSource: _dataSource,
            timeSlotViewSettings: TimeSlotViewSettings(
              timeInterval: Duration(minutes: 30),
              timeIntervalHeight: 60,
              timeTextStyle: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}

// 겹치는 시간 찾는 메커니즘 고민
