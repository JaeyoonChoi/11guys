import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class GroupDetailedPage extends StatefulWidget {
  final String pin;

  GroupDetailedPage({required this.pin});

  @override
  _GroupDetailedPageState createState() => _GroupDetailedPageState();
}

class _GroupDetailedPageState extends State<GroupDetailedPage> {
  // 길게 누른 영역의 날짜 정보를 저장할 변수
  late DateTime _pressedDateTime;
  // 길게 누른 영역의 시작 시간을 저장할 변수
  TimeOfDay _pressedStartTime = TimeOfDay.now();
  // 사용자가 선택한 종료 시간을 저장할 변수
  TimeOfDay? _pressedEndTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('그룹 캘린더 상세'),
            SizedBox(width: 8.0),
            Text('PIN 번호: ${widget.pin}', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
      body: Container(
        child: SfCalendar(
          view: CalendarView.week,
          // 캘린더 영역을 길게 누르면 실행되는 콜백 함수
          onLongPress: (CalendarLongPressDetails details) {
            // 길게 누른 영역의 날짜 정보를 저장
            _pressedDateTime = details.date!;
            // 길게 누른 영역의 시작 시간을 설정
            _pressedStartTime = TimeOfDay.fromDateTime(_pressedDateTime);

            // 상태를 업데이트하여 UI 갱신
            setState(() {});

            // 새 일정 추가 다이얼로그 표시
            showDialog(
              context: context,
              builder: (BuildContext context) {
                // 일정 제목을 입력받을 텍스트 필드 컨트롤러
                final TextEditingController titleController = TextEditingController();

                return AlertDialog(
                  title: Text('새 일정 추가'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 일정 제목 입력 필드
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: '일정 제목 입력',
                        ),
                      ),
                      SizedBox(height: 16.0),
                      // 선택된 날짜 표시
                      Text('선택된 날짜: ${_pressedDateTime.year}년 ${_pressedDateTime.month}월 ${_pressedDateTime.day}일'),
                      SizedBox(height: 8.0),
                      // 시작 시간 선택 버튼
                      Row(
                        children: [
                          Text('시작 시간: '),
                          TextButton(
                            onPressed: () async {
                              // 시작 시간 선택 다이얼로그 표시
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: _pressedStartTime,
                              );
                              if (picked != null) {
                                // 선택된 시작 시간 저장
                                setState(() {
                                  _pressedStartTime = picked;
                                });
                              }
                            },
                            child: Text('${_pressedStartTime.hour}:${_pressedStartTime.minute.toString().padLeft(2, '0')}'),
                          ),
                        ],
                      ),
                      // 종료 시간 선택 버튼
                      Row(
                        children: [
                          Text('종료 시간: '),
                          TextButton(
                            onPressed: () async {
                              // 종료 시간 선택 다이얼로그 표시
                              _pressedEndTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(hour: _pressedStartTime.hour + 1, minute: _pressedStartTime.minute),
                              );
                              // 선택된 종료 시간 저장
                              setState(() {});
                            },
                            child: _pressedEndTime != null
                                ? Text('${_pressedEndTime!.hour}:${_pressedEndTime!.minute.toString().padLeft(2, '0')}')
                                : Text('선택'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    // 취소 버튼
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('취소'),
                    ),
                    // 저장 버튼
                    TextButton(
                      onPressed: () {
                        // 일정 제목 가져오기
                        final String title = titleController.text;
                        // 시작 시간 계산
                        final DateTime startDateTime = DateTime(
                          _pressedDateTime.year,
                          _pressedDateTime.month,
                          _pressedDateTime.day,
                          _pressedStartTime.hour,
                          _pressedStartTime.minute,
                        );
                        // 종료 시간 계산
                        final DateTime endDateTime = _pressedEndTime != null
                            ? DateTime(
                          _pressedDateTime.year,
                          _pressedDateTime.month,
                          _pressedDateTime.day,
                          _pressedEndTime!.hour,
                          _pressedEndTime!.minute,
                        )
                            : startDateTime.add(Duration(hours: 1));

                        // 새 일정 정보 출력
                        print('새 일정 추가: $title, $startDateTime - $endDateTime');
                        // 다이얼로그 닫기
                        Navigator.of(context).pop();
                      },
                      child: Text('저장'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
