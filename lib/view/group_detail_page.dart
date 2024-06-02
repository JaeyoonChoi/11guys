import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'dart:math';

class GroupDetailedPage extends StatefulWidget {
  final String pin;

  GroupDetailedPage({required this.pin});

  @override
  _GroupDetailedPageState createState() => _GroupDetailedPageState();
}

class _GroupDetailedPageState extends State<GroupDetailedPage> {
  late Future<List<Map<String, dynamic>>> overlappingIntervals;
  List<Appointment> _appointments = [];
  late AppointmentDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    overlappingIntervals = fetchOverlappingIntervals();
  }

  Future<List<Map<String, dynamic>>> fetchOverlappingIntervals() async {
    String lambdaArn = 'https://2ylpznm6rb.execute-api.ap-northeast-2.amazonaws.com/default/master';

    final response = await http.post(
      Uri.parse(lambdaArn),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'function': 'findOverlappingIntervals',
        'pin': widget.pin,
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        List<Map<String, dynamic>> intervals = List<Map<String, dynamic>>.from(jsonResponse['overlapping_intervals'].map((interval) => {
          'start': DateTime.parse(interval[0]), // 수정된 부분
          'end': DateTime.parse(interval[1]), // 수정된 부분
          'count': interval[2],
        }));

        _appointments = intervals.map((interval) {
          return Appointment(
            startTime: interval['start'],
            endTime: interval['end'],
            subject: '${interval['count']} members',
            color: _getRandomColor(),
          );
        }).toList();

        _dataSource = AppointmentDataSource(_appointments);
        return intervals;
      } else {
        throw Exception('Failed to load overlapping intervals');
      }
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  Color _getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Details'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: overlappingIntervals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No overlapping intervals found.'));
          }

          List<Map<String, dynamic>> intervals = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: SfCalendar(
                  view: CalendarView.week,
                  dataSource: _dataSource,
                  timeSlotViewSettings: TimeSlotViewSettings(
                    timeInterval: Duration(minutes: 30),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: intervals.length,
                  itemBuilder: (context, index) {
                    var interval = intervals[index];
                    return ListTile(
                      title: Text('${interval['start']} - ${interval['end']}'),
                      subtitle: Text('${interval['count']} members'),
                    );
                  },
                ),
              ),
            ],
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
