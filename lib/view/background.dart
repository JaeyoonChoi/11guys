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

import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart';


class MyApp extends StatelessWidget {
  final String username;
  final String password;

  MyApp({required this.username, required this.password});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestMicrophonePermission();  // 마이크 권한 요청
    });

    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white, // 앱의 기본 색상 설정
        fontFamily: 'HancomMalangMalang',
        textTheme: TextTheme(

        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          focusColor: Colors.black,
          hoverColor: Colors.black,
        )
        // floatingActionButtonTheme: Colors.white,
        // bottomNavigationBarTheme: Colors.white,
      ),
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
  // 음성 인식 관련 변수 선언
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _text = '말 하세요';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _dataSource = getCalendarDataSource(_appointments);  // 일정 데이터를 위한 데이터 소스 생성
    _pages = [
      Page1(username: widget.username, dataSource: _dataSource),  // 월간 뷰 페이지
      Page3(username: widget.username),  // 그룹 캘린더 페이지
      Page2(username: widget.username, dataSource: _dataSource),  // 주간 뷰 페이지
    ];
    _refreshAppointments();  // 일정 데이터를 새로고침
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;  // 선택된 네비게이션 바 인덱스 업데이트
    });
  }

  Future<void> _refreshAppointments() async {
    String lambdaArn = 'https://2ylpznm6rb.execute-api.ap-northeast-2.amazonaws.com/default/master';

    Map<String, dynamic> requestBody = {
      'function': 'getAppointments',  // 람다 함수의 'getAppointments' 호출
      'id': widget.username,
    };

    try {
      final response = await http.post(
        Uri.parse(lambdaArn),
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},  // JSON 형식의 헤더 설정
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);  // 응답 바디를 JSON으로 디코딩
        print('Lambda response: $result');  // 디버그용 로그
        if (result['success'] == true) {
          List<dynamic> appointmentsJson = result['appointments'];
          List<Appointment> newAppointments = appointmentsJson.map((json) {
            return Appointment(
              startTime: parseCustomDateTime(json['start']),  // 시작 시간 파싱
              endTime: parseCustomDateTime(json['end']),  // 종료 시간 파싱
              subject: json['subject'],
              color: _getRandomColor(),  // 랜덤 색상 설정
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
      // 로고 건들기
      appBar: AppBar(
        backgroundColor: Colors.white,
        // centerTitle: true,
        flexibleSpace: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.0), // 왼쪽에 약간의 패딩 추가
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image.asset('assets/images/magu_logo.png', height: 40),
                  // Image.asset('assets/images/magu_logo.png', height: 30),
                  Image.asset(
                      'assets/images/magu_text.png',
                      height: 30,
                      // color:Colors.grey,
                  ),
                ],
              )             // Image.asset('images/magu.png', height: 150,),
            ),
            IconButton(
        icon: Icon(Icons.refresh),
        onPressed: _refreshAppointments,  // 새로고침 버튼 눌렀을 때 일정 새로고침
      ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,  // 페이지 스택
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor : Colors.white,
        selectedItemColor: Colors.black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Month',  // 월간 뷰
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.all_inclusive, color: Color(0xFFb2ddef),),
            label: 'TimeMatching',  // 타임 매칭
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_week),
            label: 'Week',  // 주간 뷰
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,  // 네비게이션 바 아이템 클릭 시 호출
      ),
      floatingActionButton: _selectedIndex == 1 ? null : floatingButtons(),  // 플로팅 버튼
    );
  }

  Widget floatingButtons() {
    SoundRecorder soundRecorder = SoundRecorder();
    soundRecorder.init();  // 음성 녹음기 초기화

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
            onTap: () {
              showSpeechDialog();
            }
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
            showInsertDialog();  // 직접 입력 다이얼로그 호출
          },
        ),
      ],
    );
  }

  void showInsertDialog() {
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
                decoration: InputDecoration(labelText: '일정명'),  // 일정명 입력 필드
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
                child: Text('시작 날짜&시간 선택'),  // 시작 날짜 및 시간 선택 버튼
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
                child: Text('끝 날짜&시간 선택'),  // 끝나는 날짜 및 시간 선택 버튼
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),  // 취소 버튼
            ),
            ElevatedButton(
              onPressed: () {
                if (startDate != null && startTime != null && endDate != null && endTime != null) {
                  String subject = subjectController.text;
                  String startDateTime = formatDateTime(startDate!, startTime!);  // 시작 날짜 및 시간 포맷팅
                  String endDateTime = formatDateTime(endDate!, endTime!);  // 끝나는 날짜 및 시간 포맷팅

                  _insertSchedule(subject, startDateTime, endDateTime);  // 일정 데이터 입력/전송

                  Navigator.of(context).pop();
                } else {
                  // handle error
                }
              },
              child: Text('확인'),  // 확인 버튼
            ),
          ],
        );
      },
    );
  }


  void showSpeechDialog() {
    // _listen();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("마이크를 누르고 말 하세요"),
              content: Text(_text), //인식된 텍스트를 다이얼로그에 표시
              actions: [
                IconButton(
                  icon: Icon(_isListening ? Icons.stop : Icons.mic_none),  //음성 인식 상태에 따라 아이콘 변경
                  // icon: Icon(Icons.mic),  // test
                  onPressed: () {
                    _listen(); // 음성 인식 시작/중지
                    setState(() {});  // 상태 업데이트
                    // if (!_isListening) Navigator.of(context).pop(); // 음성 인식이 중지되면 다이얼로그 닫기
                  },
                ),
                
                // IconButton(
                //   // icon: Icon(_isListening ? Icons.mic_off : Icons.mic_none),  //음성 인식 상태에 따라 아이콘 변경
                //   icon: Icon(Icons.refresh),  // test
                //   onPressed: () {
                //     _listen();
                //     // todo
                //     // refresh
                //   },
                // ),
                
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // todo
                    // 데이터 전송
                    
                    Navigator.of(context).pop();  // 다이얼로그 닫기
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
// 음성 인식 관련 함수들
  void _listen() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (val) {
            setState(() {
              _text = val.recognizedWords;
              _confidence = val.hasConfidenceRating ? val.confidence : 1.0;
            });
            _extractDateTime(_text);
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }
  void _extractDateTime(String text) {
    RegExp exp = RegExp(r'(\d{1,2})월\s(\d{1,2})일\s(\d{1,2})시\s(\d{2})분\s(.*)');
    var matches = exp.firstMatch(text);
    if (matches != null) {
      var year = DateTime.now().year.toString(); // 현재 연도 사용
      var month = matches.group(1)!.padLeft(2, '0');
      var day = matches.group(2)!.padLeft(2, '0');
      var hour = matches.group(3)!.padLeft(2, '0');
      var minute = matches.group(4)!.padLeft(2, '0');
      var description = matches.group(5);

      var dateTime = '$year$month${day}T$hour$minute';
      print('Extracted: ($dateTime, $description)');
    }
  }


  String formatDateTime(DateTime date, TimeOfDay time) {
    final formattedDate = "${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";
    final formattedTime = "${time.hour.toString().padLeft(2, '0')}${time.minute.toString().padLeft(2, '0')}";
    return formattedDate + formattedTime;
  }

  // 일정 데이터 입력/전송
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
        print('Lambda response: $result');  // 응답 로그 추가
        if (result['success'] == true) {
          print('Insert successful');
          _refreshAppointments();  // 새로 추가된 일정도 새로고침
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

// 마이크 권한 요청 함수
Future<void> requestMicrophonePermission() async {
  var status = await Permission.microphone.status;
  if (!status.isGranted) {
    status = await Permission.microphone.request();
  }
}

// 음성 녹음 클래스
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

// 페이지 클래스 정의
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
