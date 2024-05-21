import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calendar_final/view/screen_week.dart';
import 'package:calendar_final/provider/appointment_control.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/foundation.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // MaterialApp 위젯을 반환합니다. 이 위젯은 Material Design 앱을 구현하는 데 필요한 여러 기능을 제공합니다.
    return MaterialApp(
      // 앱의 홈페이지로 MyHomePage 위젯을 지정합니다.
      home: MonthScreen(),
    );
  }
}

class MonthScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold( // 상중하 분리
        // appBar: AppBar(),                                       //상
        body: Container( // 중
            child: SfCalendar(
              view: CalendarView.month,
              // monthViewSettings: MonthViewSettings(
              //     appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
              monthViewSettings: MonthViewSettings(
                  showAgenda: true,
                  appointmentDisplayMode: MonthAppointmentDisplayMode
                      .appointment,
                  numberOfWeeksInView: 4),
              dataSource: getCalendarDataSource(),
              showNavigationArrow: true,
            )
        ),

        // FAB
        // floatingActionButton: FloatingActionButton(
        //   child: Icon(Icons.add),
        //   onPressed: (){
        //     month-week 전환
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => WeekScreen()),
        //     );
        //     )
        //   },
        // ),
        // bottomNavigationBar: BottomAppBar( child: Text('0'),),                    //하
        // bottomNavigationBar: BottomNavigationBarExample(),
      ),
    );
  }
}


  // @override
  // Widget build(BuildContext context) {
  //
  //   return MaterialApp(
  //       home: Scaffold(                                      // 상중하 분리
  //         // appBar: AppBar(),                                       //상
  //         body: Container(                                                        // 중
  //             child: SfCalendar(
  //               view: CalendarView.month,
  //             ),
  //         ),
  //
  //         //화면 전환
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
  //       )
  //   );
  // }
// }

//
// class BottomNavigationBarExample extends StatefulWidget {
//   const BottomNavigationBarExample({super.key});
//
//   @override
//   State<BottomNavigationBarExample> createState() =>
//       _BottomNavigationBarExampleState();
// }
//
// class _BottomNavigationBarExampleState
//     extends State<BottomNavigationBarExample> {
//   int _selectedIndex = 0;
//   static const TextStyle optionStyle =
//   TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
//   static const List<Widget> _widgetOptions = <Widget>[
//     Text(
//       'Index 0: Home',
//       style: optionStyle,
//     ),
//     Text(
//       'Index 1: Business',
//       style: optionStyle,
//     ),
//     Text(
//       'Index 2: School',
//       style: optionStyle,
//     ),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('BottomNavigationBar Sample'),
//       ),
//       body: Center(
//         child: _widgetOptions.elementAt(_selectedIndex),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.business),
//             label: 'Business',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.school),
//             label: 'School',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.amber[800],
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }
