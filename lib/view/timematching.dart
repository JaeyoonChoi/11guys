import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class TimeMatchingPage extends StatefulWidget {
  final String pin;
  final String username;
  TimeMatchingPage({required this.pin, required this.username});

  @override
  _TimeMatchingPageState createState() => _TimeMatchingPageState();
}

class _TimeMatchingPageState extends State<TimeMatchingPage> {
  late Future<List<Appointment>> appointments;
  List<Appointment> _appointments = [];
  late AppointmentDataSource _dataSource;
  bool _excludeNightTime = true;
  bool _viewByRatio = false;
  int _totalMembers = 0;

  @override
  void initState() {
    super.initState();
    _refreshAppointments();
  }

  void _refreshAppointments() {
    setState(() {
      appointments = fetchAppointments();
    });
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

        // Fetch user appointments and add them to the list
        List<Appointment> userAppointments = await fetchUserAppointments();
        overlappingIntervals.addAll(userAppointments);

        return overlappingIntervals;
      } else {
        throw Exception('Failed to load appointments');
      }
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  Future<List<Appointment>> fetchUserAppointments() async {
    String lambdaArn = 'https://2ylpznm6rb.execute-api.ap-northeast-2.amazonaws.com/default/master';

    final response = await http.post(
      Uri.parse(lambdaArn),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'function': 'get_timematching',
        'pin': widget.pin,
        'user_id': widget.username,
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        List<dynamic> intervals = jsonResponse['appointments'];

        List<Appointment> appointments = [];

        for (var interval in intervals) {
          DateTime start = parseDate(interval['start']);
          DateTime end = parseDate(interval['end']);
          appointments.add(Appointment(
            startTime: start,
            endTime: end,
            subject: interval['subject'],
            color: Colors.lightGreen, // 연두색 블록
          ));
        }

        return appointments;
      } else {
        throw Exception('Failed to load user appointments');
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

    // Merge intervals of the same color into 30-minute blocks
    List<Appointment> mergedIntervals = [];
    DateTime blockStart = earliestStart;
    DateTime blockEnd = blockStart.add(Duration(minutes: 30));

    while (blockStart.isBefore(latestEnd)) {
      List<Appointment> blockAppointments = [];

      overlapMap.forEach((count, appointments) {
        for (var appointment in appointments) {
          if (appointment.startTime.isBefore(blockEnd) && appointment.endTime.isAfter(blockStart)) {
            blockAppointments.add(appointment);
          }
        }
      });

      if (blockAppointments.isNotEmpty) {
        int maxCount = blockAppointments.map((a) => int.parse(a.subject.replaceAll('명', ''))).reduce((a, b) => a > b ? a : b);
        mergedIntervals.add(Appointment(
          startTime: blockStart,
          endTime: blockEnd,
          subject: '$maxCount명',
          color: getColorForOverlap(maxCount, _totalMembers),
        ));
      }

      blockStart = blockEnd;
      blockEnd = blockStart.add(Duration(minutes: 30));
    }

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

  Future<void> _showAddAppointmentDialog(DateTime startTime) async {
    TextEditingController subjectController = TextEditingController();
    TextEditingController durationController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('약속 잡기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: subjectController,
                decoration: InputDecoration(hintText: '약속 내용'),
              ),
              TextField(
                controller: durationController,
                decoration: InputDecoration(hintText: '시간 (시간 단위)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () async {
                String subject = subjectController.text;
                int duration = int.parse(durationController.text);
                DateTime endTime = startTime.add(Duration(hours: duration));

                bool success = await _addTimematching(subject, startTime, endTime);
                if (success) {
                  _refreshAppointments(); // Refresh the appointments
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _addTimematching(String subject, DateTime startTime, DateTime endTime) async {
    String lambdaArn = 'https://2ylpznm6rb.execute-api.ap-northeast-2.amazonaws.com/default/master';

    try {
      final response = await http.post(
        Uri.parse(lambdaArn),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'function': 'add_timematching',
          'pin': widget.pin,
          'user_id': widget.username,
          'subject': subject,
          'start': _formatDateTime(startTime),
          'end': _formatDateTime(endTime),
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print('Add Timematching Response: $jsonResponse');
        return jsonResponse['success'];
      } else {
        print('Add Timematching Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Add Timematching Exception: $e');
      return false;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return dateTime.year.toString() +
        dateTime.month.toString().padLeft(2, '0') +
        dateTime.day.toString().padLeft(2, '0') +
        dateTime.hour.toString().padLeft(2, '0') +
        dateTime.minute.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('시간 매칭'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshAppointments,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text('PIN: ${widget.pin}'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Checkbox(
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
                      value: _viewByRatio,
                      onChanged: (bool? value) {
                        setState(() {
                          _viewByRatio = value!;
                          _refreshAppointments(); // Recalculate appointments to update colors
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
                  onTap: (details) {
                    if (details.targetElement == CalendarElement.calendarCell) {
                      _showAddAppointmentDialog(details.date!);
                    }
                  },
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
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
