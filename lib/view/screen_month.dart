// import 'package:calendar_final/view/screen_week.dart';
// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';
//
// // void main() {
// //   runApp(const MyApp());
// // }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Calendar View Toggle'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title});
//
//   final String title;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//
//   @override
//   Widget build(BuildContext context) {
//
//     return MaterialApp(
//       home: Scaffold(                                      // 상중하 분리
//         // appBar: AppBar(),                                       //상
//         body: Container(                                                        // 중
//           child: SfCalendar(
//             view: CalendarView.month,
//           )
//         ),
//
//         // 전환 버튼
//         floatingActionButton: FloatingActionButton(
//           child: Icon(Icons.swap_horiz),
//           onPressed: (){
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => WeekScreen()),
//             );
//           },
//         ),
//         bottomNavigationBar: BottomAppBar( child: Text('0'),),                    //하
//       ),
//     );
//   }
// }