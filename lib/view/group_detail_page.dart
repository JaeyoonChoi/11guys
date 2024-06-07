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

        // Calculate overlapping intervals
        List<Appointment> overlappingIntervals = calculateOverlappingIntervals(appointments);
        _dataSource = AppointmentDataSource(overlappingIntervals);
        return overlappingIntervals;
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

  List<Appointment> calculateOverlappingIntervals(List<Appointment> appointments) {
    if (appointments.isEmpty) return [];

    // Get the earliest start time and the latest end time
    DateTime earliestStart = appointments.first.startTime;
    DateTime latestEnd = appointments.first.endTime;

    for (var appointment in appointments) {
      if (appointment.startTime.isBefore(earliestStart)) {
        earliestStart = appointment.startTime;
      }
      if (appointment.endTime.isAfter(latestEnd)) {
        latestEnd = appointment.endTime;
      }
    }

    // Create 5-minute intervals between the earliest start and latest end
    List<DateTime> intervals = [];
    DateTime current = earliestStart;

    while (current.isBefore(latestEnd)) {
      intervals.add(current);
      current = current.add(Duration(minutes: 5));
    }

    // Count overlaps
    Map<int, List<Appointment>> overlapMap = {};

    for (int i = 0; i < intervals.length - 1; i++) {
      int count = 0;
      DateTime intervalStart = intervals[i];
      DateTime intervalEnd = intervals[i + 1];

      for (var appointment in appointments) {
        if (appointment.startTime.isBefore(intervalEnd) && appointment.endTime.isAfter(intervalStart)) {
          count++;
        }
      }

      if (count > 0) {
        if (!overlapMap.containsKey(count)) {
          overlapMap[count] = [];
        }
        overlapMap[count]!.add(Appointment(
          startTime: intervalStart,
          endTime: intervalEnd,
          subject: '$count overlaps',
          color: getColorForOverlap(count),
        ));
      }
    }

    // Merge intervals of the same color
    List<Appointment> mergedIntervals = [];

    overlapMap.forEach((count, appointments) {
      if (appointments.isNotEmpty) {
        Appointment current = appointments[0];

        for (int i = 1; i < appointments.length; i++) {
          if (appointments[i].startTime == current.endTime && appointments[i].color == current.color) {
            current = Appointment(
              startTime: current.startTime,
              endTime: appointments[i].endTime,
              subject: current.subject,
              color: current.color,
            );
          } else {
            mergedIntervals.add(current);
            current = appointments[i];
          }
        }
        mergedIntervals.add(current);
      }
    });

    return mergedIntervals;
  }

  Color getColorForOverlap(int count) {
    if (count == 1) {
      return Colors.red.shade100;
    } else if (count == 2) {
      return Colors.red.shade200;
    } else if (count == 3) {
      return Colors.red.shade300;
    } else if (count == 4) {
      return Colors.red.shade400;
    } else {
      return Colors.red.shade500;
    }
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
            return Center(child: Text('No overlapping intervals found.'));
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
