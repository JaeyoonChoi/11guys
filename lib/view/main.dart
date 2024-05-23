import 'package:flutter/material.dart';

import 'package:calendar_final/view/screen_month1.dart';
import 'package:calendar_final/view/screen_week.dart';
import 'package:calendar_final/view/group_calendar.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// permission_handler
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:baseflow_plugin_template/baseflow_plugin_template.dart';

// 깃허브 테스트2
// 오세욱 테스트

// void main() => runApp(MyApp());
import 'package:syncfusion_flutter_calendar/calendar.dart';

class MyApp extends StatelessWidget {
  final String username;
  final String password; // 필요시 추가

  MyApp({required this.username, required this.password}); // 수정된 부분

  @override
  Widget build(BuildContext context) {
    // 앱이 시작할 때 권한을 요청합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestMicrophonePermission();
    });

    return MaterialApp(
      home: MyHomePage(username: username), // 수정된 부분
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String username; // 수정된 부분

  MyHomePage({required this.username}); // 수정된 부분

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<Appointment> _appointments = []; // 추가된 부분

  final List<Widget> _pages = [
    Page1(),
    Page2(),
    Page3(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String formatDateTime(DateTime date, TimeOfDay time) {
    final formattedDate = "${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";
    final formattedTime = "${time.hour.toString().padLeft(2, '0')}${time.minute.toString().padLeft(2, '0')}";
    return formattedDate + formattedTime;
  }

  void _insertSchedule(String subject, String startDateTime, String endDateTime) async {
    String lambdaArn = 'https://2ylpznm6rb.execute-api.ap-northeast-2.amazonaws.com/default/master';

    Map<String, dynamic> requestBody = {
      'function': 'insert',
      'id': widget.username, // 수정된 부분
      'subject': subject, // 일정명 추가
      'start': startDateTime,
      'end': endDateTime,
      'color': 'blue', // 색상은 임의로 지정
    };

    final response = await http.post(
      Uri.parse(lambdaArn),
      body: jsonEncode(requestBody),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['success']) {
        print('Insert successful');
      } else {
        print('Insert failed');
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> _refreshAppointments() async {
    String lambdaArn = 'https://2ylpznm6rb.execute-api.ap-northeast-2.amazonaws.com/default/master';

    Map<String, dynamic> requestBody = {
      'function': 'getAppointments',
      'id': widget.username,
    };

    final response = await http.post(
      Uri.parse(lambdaArn),
      body: jsonEncode(requestBody),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['success']) {
        List<dynamic> appointmentsJson = result['appointments'];
        List<Appointment> newAppointments = appointmentsJson.map((json) {
          return Appointment(
            startTime: DateTime.parse(json['start']),
            endTime: DateTime.parse(json['end']),
            subject: json['subject'],
            color: Colors.blue,  // 색상은 json에서 가져오도록 수정 가능
            startTimeZone: '',
            endTimeZone: '',
          );
        }).toList();

        setState(() {
          _appointments = newAppointments;
        });
      } else {
        print('Failed to fetch appointments');
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('images/magu.png', height: 150,),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _refreshAppointments,
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Month',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_week),
            label: 'Week',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.all_inclusive),
            label: 'TimeMatching',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 2 ? null : floatingButtons(),
    );
  }

  Widget floatingButtons() {
    SoundRecorder soundRecorder = SoundRecorder();
    soundRecorder.init();

    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      visible: true,
      curve: Curves.bounceIn,
      backgroundColor: Colors.lightBlue,
      children: [
        SpeedDialChild(
            child: const Icon(Icons.mic, color: Colors.white),
            label: "음성 자동 입력",
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 13.0),
            backgroundColor: Colors.blueAccent,
            labelBackgroundColor: Colors.blueAccent,
            onTap: () {}
        ),
        SpeedDialChild(
          child: const Icon(
            Icons.screenshot,
            color: Colors.white,
          ),
          label: "캡처 입력",
          backgroundColor: Colors.blueAccent,
          labelBackgroundColor: Colors.blueAccent,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.white, fontSize: 13.0),
          onTap: () {},
        ),
        SpeedDialChild(
          child: const Icon(
            Icons.keyboard_alt_outlined,
            color: Colors.white,
          ),
          label: "직접 입력",
          backgroundColor: Colors.blueAccent,
          labelBackgroundColor: Colors.blueAccent,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.white, fontSize: 13.0),
          onTap: () {
            _showInsertDialog();
          },
        ),
      ],
    );
  }

  void _showInsertDialog() {
    final TextEditingController subjectController = TextEditingController();
    DateTime? startDate;
    TimeOfDay? startTime;
    DateTime? endDate;
    TimeOfDay? endTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('직접 입력'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: InputDecoration(labelText: '일정명'),
              ),
              TextButton(
                onPressed: () async {
                  startDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (startDate != null) {
                    startTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                  }
                },
                child: Text('시작 날짜 및 시간 선택'),
              ),
              TextButton(
                onPressed: () async {
                  endDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (endDate != null) {
                    endTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                  }
                },
                child: Text('끝나는 날짜 및 시간 선택'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (startDate != null && startTime != null && endDate != null && endTime != null) {
                  String subject = subjectController.text;
                  String startDateTime = formatDateTime(startDate!, startTime!);
                  String endDateTime = formatDateTime(endDate!, endTime!);

                  _insertSchedule(subject, startDateTime, endDateTime);

                  Navigator.of(context).pop();
                } else {
                  // handle error
                }
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MonthScreen(),
    );
  }
}

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WeekScreen(),
    );
  }
}

class Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: group_calendar(),
    );
  }
}

// 마이크 권한
Future<void> requestMicrophonePermission() async {
  var status = await Permission.microphone.status;
  if (!status.isGranted) {
    status = await Permission.microphone.request();
    if (status.isGranted) {
      // 권한이 허용되었습니다.
    } else if (status.isDenied) {
      // 사용자가 권한 요청을 거부했습니다.
    } else if (status.isPermanentlyDenied) {
      // 사용자가 권한 요청을 영구적으로 거부했습니다. 설정에서 직접 변경해야 합니다.
      openAppSettings(); // 사용자를 앱 설정으로 이동시킵니다.
    }
  }
}

// 음성녹음
class SoundRecorder {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecorderInitialized = false;

  bool get isRecording => _audioRecorder?.isRecording ?? false;

  Future<void> init() async {
    _audioRecorder = FlutterSoundRecorder();

    await _audioRecorder?.openRecorder();
    _isRecorderInitialized = true;
  }

  Future<void> dispose() async {
    await _audioRecorder?.closeRecorder();
    _audioRecorder = null;
  }

  Future<void> startRecording() async {
    if (!_isRecorderInitialized) return;

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/flutter_sound_record_${DateTime
        .now()
        .millisecondsSinceEpoch}.aac';

    await _audioRecorder;
  }
}
