import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'group_detail_page.dart';
import 'timematching.dart';

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

  Future<List<Map<String, String>>> _fetchGroupMembers(String pin) async {
    String lambdaArn = 'https://2ylpznm6rb.execute-api.ap-northeast-2.amazonaws.com/default/master';

    final response = await http.post(
      Uri.parse(lambdaArn),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'function': 'getGroupMembers',
        'pin': pin,
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        return List<Map<String, String>>.from(jsonResponse['members'].map((member) => {
          'user_id': member['user_id'].toString(),
          'name': member['name'].toString()
        }));
      } else {
        print('Failed to fetch group members');
        return [];
      }
    } else {
      print('Error: ${response.statusCode}');
      return [];
    }
  }

  void _showGroupMembersDialog(String pin) async {
    List<Map<String, String>> members = await _fetchGroupMembers(pin);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('그룹 멤버'),
          content: SingleChildScrollView(
            child: ListBody(
              children: members.map((member) => Text('${member['user_id']} (${member['name']})')).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
        print('Delete Group Response: $jsonResponse');
        return jsonResponse['success'];
      } else {
        print('Delete Group Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Delete Group Exception: $e');
      return false;
    }
  }

  void _showDeleteGroupDialog(BuildContext context) {
    TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('그룹 캘린더 삭제'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: pinController,
                  decoration: InputDecoration(hintText: "PIN번호"),
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
                String pin = pinController.text;
                bool success = await _deleteGroup(pin);
                if (success) {
                  setState(() {
                    groups.removeWhere((group) => group['pin'] == pin);
                  });
                  print('Successfully deleted group');
                } else {
                  print('Failed to delete group');
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                      DataColumn(label: Text('인원 수', style: TextStyle(fontSize: 16))),
                      DataColumn(label: Text('시간매칭', style: TextStyle(fontSize: 16))), // '시간매칭' 열 추가
                    ],
                    rows: groups.map<DataRow>((group) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(
                            Text(group['club_name'], style: TextStyle(fontSize: 14)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GroupDetailedPage(
                                    pin: group['pin'],
                                  ),
                                ),
                              );
                            },
                          ),
                          DataCell(
                            GestureDetector(
                              child: Text(group['members_count'].toString(), style: TextStyle(fontSize: 14)), // 인원 수 표시
                              onTap: () {
                                _showGroupMembersDialog(group['pin']);
                              },
                            ),
                          ),
                          DataCell(
                            Icon(Icons.access_time, color: Colors.grey), // 시계 모양의 아이콘 추가
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TimeMatchingPage(
                                    pin: group['pin'],
                                  ),
                                ),
                              );
                            },
                          ),
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
          label: "새 그룹 캘린더",
          labelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 13.0,
            fontFamily: 'HancomMalangMalang',
            fontWeight: FontWeight.w100,
          ),
          backgroundColor: Colors.green,
          labelBackgroundColor: Colors.green,
          onTap: () {
            _showCreateGroupDialog(context);
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.group_add, color: Colors.white),
          label: "그룹 캘린더 참가",
          labelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 13.0,
            fontFamily: 'HancomMalangMalang',
            fontWeight: FontWeight.w100,
          ),
          backgroundColor: Colors.blue,
          labelBackgroundColor: Colors.blue,
          onTap: () {
            _showJoinGroupDialog(context);
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.delete, color: Colors.white),
          label: "그룹 캘린더 삭제",
          labelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 13.0,
            fontFamily: 'HancomMalangMalang',
            fontWeight: FontWeight.w100,
          ),
          backgroundColor: Colors.red,
          labelBackgroundColor: Colors.red,
          onTap: () {
            _showDeleteGroupDialog(context);
          },
        ),
      ],
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    TextEditingController groupNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('새 그룹 캘린더'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: groupNameController,
                  decoration: InputDecoration(hintText: "그룹명"),
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
                String pin = generateRandomPin(4);

                // RDS로 데이터 전송
                bool success = await _sendGroupData(groupName, pin, widget.username);
                if (success) {
                  setState(() {
                    groups.add({
                      "club_name": groupName,
                      "pin": pin,
                      "user_id": widget.username,
                      "members_count": 1, // 인원 수 추가
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

  void _showJoinGroupDialog(BuildContext context) {
    TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('그룹 캘린더 참가'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: pinController,
                  decoration: InputDecoration(hintText: "PIN번호"),
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
                String pin = pinController.text;
                bool success = await _joinGroup(pin, widget.username);
                if (success) {
                  print('Successfully joined group');
                  _fetchGroups();
                } else {
                  print('Failed to join group');
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
        print('Insert Group Response: $jsonResponse');
        return jsonResponse['success'];
      } else {
        print('Insert Group Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Insert Group Exception: $e');
      return false;
    }
  }

  Future<bool> _joinGroup(String pin, String userId) async {
    String lambdaArn = 'https://2ylpznm6rb.execute-api.ap-northeast-2.amazonaws.com/default/master';
    try {
      final response = await http.post(
        Uri.parse(lambdaArn),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'function': 'joinGroup',
          'pin': pin,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print('Join Group Response: $jsonResponse');
        return jsonResponse['success'];
      } else {
        print('Join Group Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Join Group Exception: $e');
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
