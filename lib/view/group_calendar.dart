import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class GroupCalendar extends StatelessWidget {
  final String username; // 사용자 ID 추가

  GroupCalendar({required this.username}); // 생성자 수정

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // appBar: ,
        body: Text('시간매칭', style: TextStyle(fontFamily: 'HancomMalangMalang',),),
        floatingActionButton: floatingButtons(),
      ),
    );
  }
}

// FAB
Widget floatingButtons() {
  return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      visible: true,
      curve: Curves.bounceIn,
      backgroundColor: Colors.lightGreen,
      children: [
        SpeedDialChild(
            child: const Icon(Icons.group, color: Colors.white),
            label: "그룹 만들기",
            labelStyle: const TextStyle(
                color: Colors.white,
                fontSize: 13.0,
                fontFamily: 'HancomMalangMalang',
                fontWeight: FontWeight.w100), // font 굵기 조정
            backgroundColor: Colors.green,
            labelBackgroundColor: Colors.green,
            onTap: () {} // onTap이 눌렀을 때 실행되는 거
        ),
      ]
  );
}
