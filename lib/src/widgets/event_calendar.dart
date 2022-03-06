import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:mobile_cdv/src/lib/lozalization/localization_manager.dart';
import '../widgets/restart_widget.dart';

class EventCalendar extends StatefulWidget {
  EventCalendar({Key? key}) : super(key: key);

  @override
  State<EventCalendar> createState() => EventCalendarState();
}

class EventCalendarState extends State<EventCalendar> {

  late String? localization = calendarLocalization;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    return RestartWidget(
      child: Column(
        children: [
          TableCalendar(
            locale: localization,
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 29),
            focusedDay: DateTime.now(),
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            headerStyle: const HeaderStyle(
                titleTextStyle: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                ),
                formatButtonVisible: false
            ),
          ),
          ElevatedButton(
            onPressed: (){
              setState(() {
                switch (_calendarFormat) {
                  case CalendarFormat.week:
                    _calendarFormat = CalendarFormat.month;
                    break;
                  case CalendarFormat.month:
                    _calendarFormat = CalendarFormat.week;
                    break;
                  default:
                    _calendarFormat = CalendarFormat.week;
                    break;
                }
              });
            },
            child: Text(
                getTextFromKey("Main.Account")
            ),
          )
        ],
      )
    );
  }
}