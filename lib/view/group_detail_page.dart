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
  bool _excludeNightTime = true;
  bool _viewByRatio = false;
  int _totalMembers = 0;

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
        Set<String> uniqueIds = {};

        for (var interval in intervals) {
          DateTime start = parseDate(interval['start']);
          DateTime end = parseDate(interval['end']);
          appointments.add(Appointment(
            startTime: start,
            endTime: end,
            subject: interval['subject'],
            color: Colors.red,
            id: interval['id'],
          ));
          uniqueIds.add(interval['id'].toString());
        }

        _totalMembers = uniqueIds.length;

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
      Set<String> overlappingIds = {};

      for (var appointment in appointments) {
        if (appointment.startTime.isBefore(intervalEnd) && appointment.endTime.isAfter(intervalStart)) {
          overlappingIds.add(appointment.id.toString());
        }
      }

      count = overlappingIds.length;

      if (count > 0) {
        if (!overlapMap.containsKey(count)) {
          overlapMap[count] = [];
        }
        overlapMap[count]!.add(Appointment(
          startTime: intervalStart,
          endTime: intervalEnd,
          subject: '$count명',
          color: getColorForOverlap(count, _totalMembers),
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

  Color getColorForOverlap(int count, int totalMembers) {
    if (_viewByRatio) {
      double percentage = (count / totalMembers) * 100;
      if (percentage <= 10) {
        return Colors.red.shade100;
      } else if (percentage <= 20) {
        return Colors.red.shade200;
      } else if (percentage <= 30) {
        return Colors.red.shade300;
      } else if (percentage <= 40) {
        return Colors.red.shade400;
      } else {
        return Colors.red.shade500;
      }
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('단체 캘린더'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text('PIN: ${widget.pin}'),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Checkbox(
                      shape:
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      activeColor: Color(0xff203863),
                      value: _excludeNightTime,
                      onChanged: (bool? value) {
                        setState(() {
                          _excludeNightTime = value!;
                        });
                      },
                    ),
                    Text('새벽시간 지우기'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      shape:
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      activeColor: Color(0xff203863),
                      value: _viewByRatio,
                      onChanged: (bool? value) {
                        setState(() {
                          _viewByRatio = value!;
                          appointments = fetchAppointments(); // Recalculate appointments to update colors
                        });
                      },
                    ),
                    Text('비율로 보기'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Appointment>>(
              future: appointments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('겹치는 일정이 없습니다.'));
                }

                return SfCalendar(
                  view: CalendarView.week,
                  backgroundColor: Colors.white24,
                  todayHighlightColor: Color(0xff203863),
                  headerStyle: CalendarHeaderStyle(backgroundColor: Colors.white,),
                  // todayHighlightColor: Colors.black,
                  dataSource: _dataSource,
                  timeSlotViewSettings: TimeSlotViewSettings(
                    timeInterval: Duration(minutes: 30),
                    timeIntervalHeight: 60,
                    timeTextStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    startHour: _excludeNightTime ? 6 : 0,
                    endHour: _excludeNightTime ? 24 : 24,
                  ),
                  appointmentBuilder: (context, details) {
                    final appointment = details.appointments.first;
                    return Container(
                      alignment: Alignment.center,
                      color: appointment.color,
                      child: Text(
                        appointment.subject,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
