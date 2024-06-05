// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:intl/intl.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Voice to Text App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: VoiceHomePage(),
//     );
//   }
// }
//
// class VoiceHomePage extends StatefulWidget {
//   @override
//   _VoiceHomePageState createState() => _VoiceHomePageState();
// }
//
// class _VoiceHomePageState extends State<VoiceHomePage> {
//   stt.SpeechToText _speechToText = stt.SpeechToText();
//   bool _isListening = false;
//   String _text = 'Press the button and start speaking';
//   double _confidence = 1.0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _listen,
//         child: Icon(_isListening ? Icons.mic_off : Icons.mic),
//       ),
//       body: SingleChildScrollView(
//         reverse: true,
//         child: Container(
//           padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
//           child: Text(
//             _text,
//             style: const TextStyle(
//               fontSize: 24.0,
//               color: Colors.black,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _listen() async {
//     if (!_isListening) {
//       bool available = await _speechToText.initialize(
//         onStatus: (val) => print('onStatus: $val'),
//         onError: (val) => print('onError: $val'),
//       );
//       if (available) {
//         setState(() => _isListening = true);
//         _speechToText.listen(
//           onResult: (val) {
//             setState(() {
//               _text = val.recognizedWords;
//               _confidence = val.hasConfidenceRating ? val.confidence : 1.0;
//             });
//             _extractDateTime(_text);
//           },
//         );
//       }
//     } else {
//       setState(() => _isListening = false);
//       _speechToText.stop();
//     }
//   }
//
//   void _extractDateTime(String text) {
//     RegExp dateRegEx = RegExp(r'\b(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})\b');
//     RegExp timeRegEx = RegExp(r'\b(\d{1,2}):(\d{2})\b');
//     String? dateString = dateRegEx.firstMatch(text)?.group(0);
//     String? timeString = timeRegEx.firstMatch(text)?.group(0);
//
//     if (dateString != null && timeString != null) {
//       DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');
//       DateTime dateTime = dateFormat.parse('$dateString $timeString');
//       print('Extracted DateTime: $dateTime');
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice to Text App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VoiceHomePage(),
    );
  }
}

class VoiceHomePage extends StatefulWidget {
  @override
  _VoiceHomePageState createState() => _VoiceHomePageState();
}

class _VoiceHomePageState extends State<VoiceHomePage> {
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: Text(
            _text,
            style: const TextStyle(
              fontSize: 24.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

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
}
//음성 인식하는 페이지를 만들었습니다..