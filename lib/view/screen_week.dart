import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calendar_final/provider/appointment_control.dart';


class WeekScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        home: Scaffold(                                      // 상중하 분리
          // appBar: AppBar(),                                       //상
          body: Container(                                                        // 중
              child: SfCalendar(
                view: CalendarView.week,
                showNavigationArrow: true,
                dataSource: getCalendarDataSource(),
                // Drag & Drop
                allowDragAndDrop: true,
                onDragStart: dragStart,
                onDragUpdate: dragUpdate,
                onDragEnd: dragEnd,
                // Appointment resize
                allowAppointmentResize: true,
                onAppointmentResizeStart: resizeStart,
                onAppointmentResizeUpdate: resizeUpdate,
                onAppointmentResizeEnd: resizeEnd,
                // Change time ruler size
                timeSlotViewSettings: TimeSlotViewSettings(
                  timeIntervalHeight: -1,
                  // Minimum appointment duration
                  minimumAppointmentDuration: Duration(minutes: 10),
                ),

              ),
          ),

          //화면 전환
          // floatingActionButton: FloatingActionButton(
          //   child: Icon(Icons.swap_horiz),
          //   onPressed: (){
          //     Navigator.pop(
          //       context
          //       // context,
          //       // MaterialPageRoute(builder: (context) => NextScreen()),
          //     );
          //   },
          // ),
          // bottomNavigationBar: BottomAppBar( child: Text('0'),),                    //하
        )
    );
  }
}


// Drag & Drop
void dragStart(AppointmentDragStartDetails appointmentDragStartDetails) {
  dynamic appointment = appointmentDragStartDetails.appointment;
  CalendarResource? resource = appointmentDragStartDetails.resource;
}
void dragUpdate(AppointmentDragUpdateDetails appointmentDragUpdateDetails) {
  dynamic appointment = appointmentDragUpdateDetails.appointment;
  DateTime? draggingTime = appointmentDragUpdateDetails.draggingTime;
  Offset? draggingOffset = appointmentDragUpdateDetails.draggingPosition;
  CalendarResource? sourceResource = appointmentDragUpdateDetails.sourceResource;
  CalendarResource? targetResource = appointmentDragUpdateDetails.targetResource;
}
void dragEnd(AppointmentDragEndDetails appointmentDragEndDetails) {
  dynamic appointment = appointmentDragEndDetails.appointment!;
  CalendarResource? sourceResource = appointmentDragEndDetails.sourceResource;
  CalendarResource? targetResource = appointmentDragEndDetails.targetResource;
  DateTime? droppingTime = appointmentDragEndDetails.droppingTime;
}
//데이터 베이스 업데이트


//onAppointmentResizeStart
void resizeStart(AppointmentResizeStartDetails appointmentResizeStartDetails) {
  dynamic appointment = appointmentResizeStartDetails.appointment;
  CalendarResource? resource = appointmentResizeStartDetails.resource;
}
void resizeUpdate(AppointmentResizeUpdateDetails appointmentResizeUpdateDetails) {
  dynamic appointment = appointmentResizeUpdateDetails.appointment;
  DateTime? resizingTime = appointmentResizeUpdateDetails.resizingTime;
  Offset? resizingOffset = appointmentResizeUpdateDetails.resizingOffset;
  CalendarResource? resourceDetails = appointmentResizeUpdateDetails.resource;
}
void resizeEnd(AppointmentResizeEndDetails appointmentResizeEndDetails) {
  dynamic appointment = appointmentResizeEndDetails.appointment;
  DateTime? startTime = appointmentResizeEndDetails.startTime;
  DateTime? endTime = appointmentResizeEndDetails.endTime;
  CalendarResource? resourceDetails = appointmentResizeEndDetails.resource;
}
// 데이터베이스 업데이트