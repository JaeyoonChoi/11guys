import 'package:flutter/material.dart';
//FAB
import 'package:flutter_speed_dial/flutter_speed_dial.dart';


class group_calendar extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        // appBar: ,
        body: Text('시간매칭', style: TextStyle(fontFamily: 'HancomMalangMalang',),),
        floatingActionButton: floatingButtons(),
        // floatingActionButtonLocation: FloatingActionButtonLocation.,
        ),
      );
  }
}


// FAB
// Floating Action Button

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
        // @준식
        onTap: () {}    // onTap이 눌렀을 때 실행되는 거
      ),
    ]
  );
}
