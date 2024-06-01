import 'package:flutter/material.dart';
import 'package:calendar_final/view/screen_month1.dart';
import 'package:calendar_final/view/screen_week.dart';
import 'package:calendar_final/view/group_calendar.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calendar_final/provider/appointment_control.dart';
import 'dart:math';

class MyApp extends StatelessWidget {
  final String username;
  final String password;

  MyApp({required this.username, required this.password});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestMicrophonePermission();
    });

    return MaterialApp(
      home: MyHomePage(username: username),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String username;

  MyHomePage({required this.username});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<Appointment> _appointments = [];
  late List<Widget> _pages;
  late AppointmentDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = getCalendarDataSource(_appointments);
    _pages = [
      Page1(username: widget.username, dataSource: _dataSource),
      Page3(username: widget.username),
      Page2(username: widget.username, dataSource: _dataSource),
    ];
    _refreshAppointments();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _refreshAppointments() async {
    String lambdaArn = 'https://2ylpznm6rb.execute-api.ap-northeast-2.amazonaws.com/default/master';

    Map<String, dynamic> requestBody = {
      'function': 'getAppointments',
      'id': widget.username,
    };

    try {
      final response = await http.post(
        Uri.parse(lambdaArn),
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Lambda response: $result'); // 응답 로그 추가
        if (result['success'] == true) {
          List<dynamic> appointmentsJson = result['appointments'];
          List<Appointment> newAppointments = appointmentsJson.map((json) {
            return Appointment(
              startTime: parseCustomDateTime(json['start']),
              endTime: parseCustomDateTime(json['end']),
              subject: json['subject'],
              color: _getRandomColor(), // 랜덤 색상 설정
              startTimeZone: '',
              endTimeZone: '',
            );
          }).toList();

          setState(() {
            _appointments = newAppointments;
            _dataSource = getCalendarDataSource(_appointments);
            _pages = [
              Page1(username: widget.username, dataSource: _dataSource),
              Page3(username: widget.username),
              Page2(username: widget.username, dataSource: _dataSource),
            ];
          });
        } else {
          print('Failed to fetch appointments');
        }
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
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

  DateTime parseCustomDateTime(String dateTimeString) {
    try {
      int year = int.parse(dateTimeString.substring(0, 4));
      int month = int.parse(dateTimeString.substring(4, 6));
      int day = int.parse(dateTimeString.substring(6, 8));
      int hour = int.parse(dateTimeString.substring(8, 10));
      int minute = int.parse(dateTimeString.substring(10, 12));
      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      throw FormatException('Invalid date format: $dateTimeString');
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
            icon: Icon(Icons.all_inclusive, color: Colors.green,),
            label: 'TimeMatching',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_week),
            label: 'Week',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 1 ? null : floatingButtons(),
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

  String formatDateTime(DateTime date, TimeOfDay time) {
    final formattedDate = "${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";
    final formattedTime = "${time.hour.toString().padLeft(2, '0')}${time.minute.toString().padLeft(2, '0')}";
    return formattedDate + formattedTime;
  }

  void _insertSchedule(String subject, String startDateTime, String endDateTime) async {
    String lambdaArn = 'https://2ylpznm6rb.execute-api.ap-northeast-2.amazonaws.com/default/master';

    Map<String, dynamic> requestBody = {
      'function': 'addAppointment',
      'user_id': widget.username,
      'subject': subject,
      'start': startDateTime,
      'end': endDateTime,
      'color': 'blue',
    };

    try {
      final response = await http.post(
        Uri.parse(lambdaArn),
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Lambda response: $result'); // 응답 로그 추가
        if (result['success'] == true) {
          print('Insert successful');
          _refreshAppointments(); // 새로 추가된 일정도 새로고침
        } else {
          print('Insert failed');
        }
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }
}

// 마이크 권한
Future<void> requestMicrophonePermission() async {
  var status = await Permission.microphone.status;
  if (!status.isGranted) {
    status = await Permission.microphone.request();
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
    final path = '${dir.path}/flutter_sound_record_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _audioRecorder?.startRecorder(toFile: path);
  }

  Future<void> stopRecording() async {
    if (!_isRecorderInitialized) return;

    await _audioRecorder?.stopRecorder();
  }
}

class Page1 extends StatelessWidget {
  final String username;
  final AppointmentDataSource dataSource;

  Page1({required this.username, required this.dataSource});

  @override
  Widget build(BuildContext context) {
    return MonthScreen(username: username, dataSource: dataSource);
  }
}

class Page2 extends StatelessWidget {
  final String username;
  final AppointmentDataSource dataSource;

  Page2({required this.username, required this.dataSource});

  @override
  Widget build(BuildContext context) {
    return WeekScreen(username: username, dataSource: dataSource);
  }
}

class Page3 extends StatelessWidget {
  final String username;

  Page3({required this.username});

  @override
  Widget build(BuildContext context) {
    return GroupCalendar(username: username);
  }
}
