import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:math';     // 핀 번호 랜덤 생성 위해

void main() => runApp(GroupCalendar(username: '사용자명'));

class GroupCalendar extends StatefulWidget {
  final String username;

  GroupCalendar({required this.username});

  @override
  _GroupCalendarState createState() => _GroupCalendarState();
}

class _GroupCalendarState extends State<GroupCalendar> {
  List<Map<String, dynamic>> groups = []; // 여러 데이터 타입을 저장하기 위해 dynamic 사용
  //여기에 그룹명, 인원 수, 학번 입력한 리스트가 저장되어있음

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('그룹 캘린더'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: groups.isEmpty
                      ? Text('그룹이 없습니다')
                      : DataTable(
                    headingRowHeight: 56.0,
                    dataRowHeight: 64.0,
                    columns: const <DataColumn>[
                      DataColumn(label: Text('그룹명', style: TextStyle(fontSize: 16))),
                      // DataColumn(label: Text('인원수', style: TextStyle(fontSize: 16))), // 인원 수 열  (그룹명만 넣기 허전해서 일단 만들어 놓음)
                      DataColumn(label: Text('PIN번호', style: TextStyle(fontSize: 16))), // PIN 열
                      DataColumn(label: Text('인원 추가', style: TextStyle(fontSize: 16))), // 인원 추가 열
                      DataColumn(label: Text('그룹 삭제', style: TextStyle(fontSize: 16))), // 삭제 열 추가
                    ],
                    rows: groups.map<DataRow>((group) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(group['name'], style: TextStyle(fontSize: 14))),
                          DataCell(Text(group['pin'], style: TextStyle(fontSize: 14))),
                          DataCell(IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              _showAddMemberDialog(group['name']);
                            },
                          )),
                          DataCell(IconButton( // 삭제 버튼 추가
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteGroup(group['pin']);
                            },
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: floatingButtons(context),
      ),
    );
  }


  Widget floatingButtons(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      visible: true,
      curve: Curves.bounceIn,
      backgroundColor: Colors.lightGreen,
      children: [
        SpeedDialChild(
            child: const Icon(Icons.group, color: Colors.white),
            label: "그룹 캘린더",
            labelStyle: const TextStyle(
                color: Colors.white, fontSize: 13.0, fontFamily: 'HancomMalangMalang', fontWeight: FontWeight.w100),
            backgroundColor: Colors.green,
            labelBackgroundColor: Colors.green,
            onTap: () {
              _showCreateGroupDialog(context);
            }),
      ],
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    TextEditingController groupNameController = TextEditingController();
    TextEditingController memberCountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('그룹 캘린더'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: groupNameController,
                  decoration: InputDecoration(hintText: "그룹명"),
                ),
                TextField(
                  controller: memberCountController,
                  decoration: InputDecoration(hintText: "인원 수"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
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
              onPressed: () {
                setState(() {
                  groups.add({
                    "name": groupNameController.text,
                    "count": memberCountController.text,
                    "pin" : generateRandomPin(4),   // pin 생성
                    "members": [] // 멤버 ID를 저장하기 위한 리스트 추가
                  });
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddMemberDialog(String groupName) {
    List<TextEditingController> controllers = [TextEditingController()];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('인원 추가'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    for (var controller in controllers)
                      TextField(
                        controller: controller,
                        decoration: InputDecoration(hintText: "학번"),
                        keyboardType: TextInputType.number,
                      ),
                    TextButton(
                      child: Text('인원 추가'),
                      onPressed: () {
                        setState(() {
                          controllers.add(TextEditingController());
                        });
                      },
                    ),
                  ],
                ),
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
                  onPressed: () {
                    // 여기에 학번 추가 로직을 구현하세요.
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteGroup(String groupName) {
    // todo
    // '정말 삭제하시겠습니까?' -> yes/or 선택 추가
    setState(() {
      groups.removeWhere((group) => group['name'] == groupName);
    });
  }
}



// pin 번호 랜덤 생성
String generateRandomPin(int length) {
  final random = Random();
  String pin = '';

  for (int i = 0; i < length; i++) {
    // 0부터 9까지의 숫자를 랜덤으로 선택하여 PIN에 추가
    pin += random.nextInt(10).toString();
  }

  return pin;
}