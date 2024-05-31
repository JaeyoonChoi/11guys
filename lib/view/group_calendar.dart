import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(GroupCalendar(username: '사용자명'));

class GroupCalendar extends StatefulWidget {
  final String username;

  GroupCalendar({required this.username});

  @override
  _GroupCalendarState createState() => _GroupCalendarState();
}

class _GroupCalendarState extends State<GroupCalendar> {
  List<Map<String, dynamic>> groups = [];

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    String lambdaArn = 'https://2ylpznm6rb.execute-api.ap-northeast-2.amazonaws.com/default/master';

    final response = await http.post(
      Uri.parse(lambdaArn),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'function': 'getUserGroups',
        'user_id': widget.username,
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        setState(() {
          groups = List<Map<String, dynamic>>.from(jsonResponse['groups']);
        });
      } else {
        print('Failed to fetch groups');
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  }

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
                      DataColumn(label: Text('PIN번호', style: TextStyle(fontSize: 16))),
                      DataColumn(label: Text('학번', style: TextStyle(fontSize: 16))),
                      DataColumn(label: Text('삭제', style: TextStyle(fontSize: 16))),
                    ],
                    rows: groups.map<DataRow>((group) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(group['club_name'], style: TextStyle(fontSize: 14))),
                          DataCell(Text(group['pin'], style: TextStyle(fontSize: 14))),
                          DataCell(Text(widget.username, style: TextStyle(fontSize: 14))),
                          DataCell(IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              bool success = await _deleteGroup(group['pin']);
                              if (success) {
                                setState(() {
                                  groups.remove(group);
                                });
                              }
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
    TextEditingController memberIdController = TextEditingController();

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
                  controller: memberIdController,
                  decoration: InputDecoration(hintText: "학번"),
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
              onPressed: () async {
                String groupName = groupNameController.text;
                String memberId = memberIdController.text;
                String pin = generateRandomPin(4);

                // RDS로 데이터 전송
                bool success = await _sendGroupData(groupName, pin, memberId);
                if (success) {
                  setState(() {
                    groups.add({
                      "club_name": groupName,
                      "pin": pin,
                      "user_id": memberId,
                    });
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _sendGroupData(String groupName, String pin, String userId) async {
    String lambdaArn = 'https://2ylpznm6rb.execute-api.ap-northeast-2.amazonaws.com/default/master';
    try {
      final response = await http.post(
        Uri.parse(lambdaArn),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'function': 'insertGroup',
          'club_name': groupName,
          'pin': pin,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse['success'];
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _deleteGroup(String pin) async {
    String lambdaArn = 'https://2ylpznm6rb.execute-api.ap-northeast-2.amazonaws.com/default/master';
    try {
      final response = await http.post(
        Uri.parse(lambdaArn),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'function': 'deleteGroup',
          'pin': pin,
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse['success'];
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  String generateRandomPin(int length) {
    final random = Random();
    String pin = '';

    for (int i = 0; i < length; i++) {
      pin += random.nextInt(10).toString();
    }

    return pin;
  }
}
