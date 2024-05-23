import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calendar_final/provider/appointment_control.dart';

class WeekScreen extends StatelessWidget {
  final String username;
  final AppointmentDataSource dataSource; // 추가된 부분

  WeekScreen({required this.username, required this.dataSource}); // 수정된 부분

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SfCalendar(
          view: CalendarView.week,
          showNavigationArrow: true,
          dataSource: dataSource, // 수정된 부분
          allowDragAndDrop: true,
          onDragStart: dragStart,
          onDragUpdate: dragUpdate,
          onDragEnd: dragEnd,
          allowAppointmentResize: true,
          onAppointmentResizeStart: resizeStart,
          onAppointmentResizeUpdate: resizeUpdate,
          onAppointmentResizeEnd: resizeEnd,
          timeSlotViewSettings: TimeSlotViewSettings(
            timeIntervalHeight: -1,
            minimumAppointmentDuration: Duration(minutes: 10),
          ),
        ),
      ),
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




// onAppointmentResizeStart
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

