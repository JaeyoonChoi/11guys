import 'package:flutter/material.dart';

class GroupDetailedPage extends StatelessWidget {
  final String pin;

  GroupDetailedPage({required this.pin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('그룹 캘린더 상세'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'PIN 번호: $pin',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
