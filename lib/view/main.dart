import 'package:flutter/material.dart';
import 'package:calendar_final/view/screen_month1.dart';
import 'package:calendar_final/view/screen_week.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

// permission_handler
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:baseflow_plugin_template/baseflow_plugin_template.dart';

// 깃허브 테스트2

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 앱이 시작할 때 권한을 요청합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestMicrophonePermission();
    });


    return MaterialApp(
      home: MyHomePage(),

    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();

}

class MyHomePageState extends State<MyHomePage> {

  int _selectedIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Image.asset('images/logo.png', height: 150,),
        flexibleSpace: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset('images/logo.png', height: 300, fit: BoxFit.cover),
            // SizedBox(width: 10), // 이미지 간의 간격 조정
            Image.asset('images/magu.png', height: 150,),
          ]
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
      floatingActionButton: floatingButtons(),
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
    return Center(
      child: Text('시간매칭'),
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


//FAB
//Floating Action Button
Widget floatingButtons() {

  // Soundrecorder 인스턴스 생성
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
          onTap: () {}),

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
        onTap: () {},
      )
    ],
  );
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

  Future<String?> stopRecording() async {
    if (!_isRecorderInitialized) return null;

    final path = await _audioRecorder?.stopRecorder();
    return path;
  }
}





//         onTap: () async {
//           if (_soundRecorder.isRecording) {
//             final path = await _soundRecorder.stopRecording();
//             print("녹음 완료: $path");
//           } else {
//             await _soundRecorder.startRecording();
//           }
//         },
