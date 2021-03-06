import 'dart:math';
import 'storage/globals.dart' as globals;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:mobile_cdv/src/logic/time_operations.dart';
import 'package:mobile_cdv/src/logic/structures/schedule.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification service
/// Needed to be called once on start
/// Is a singleton
class NotificationService {
  // Singleton pattern
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  // Instance of NotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialization
  Future<void> init() async {
    tz.initializeTimeZones();

    // Android settings
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('notifications_icon');

    // iOS settings
    const IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      // TODO IDK if needed (iOS < 10.0) and how it works. Needs testing
      // onDidReceiveLocalNotification: (int id, String title, String body, String payload) async
      //   {
      //
      //   }
    );

    // Initializes settings for both android and iOS
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  /// Helper function for setNotificationQueue()
  Future<void> setNotification(int id, String title, String body, int seconds) async {
    tz.TZDateTime time = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));

    /*
    Due to the weird bug, somehow it may see some dates in future as in past
    So I've placed this if statement here.
    If this will result in missing notifications TODO: fix
    */
    if (time.isAfter(tz.TZDateTime.now(tz.local))) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        time,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'Main Channel',
            'Main Channel',
            importance: Importance.max,
            priority: Priority.max,
            icon: 'notifications_icon',
          ),
          iOS: IOSNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
      );
    }
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Sets notification queue using Schedule and setting variables from globals
  Future<void> setNotificationQueue() async {
    int secondsOffset = globals.notificationsTime;
    cancelAllNotifications();

    List<ScheduleTableItem> schedule =  Schedule().list();
    int slice = 0;

    // Slices schedule to set only valid notifications
    while (slice < schedule.length - 1) {
      // +60 just to be sure
      if (DateTime.now().difference(schedule[slice].startDate).inSeconds < globals.notificationsTime + 60) { break; }
      slice++;
    }
    schedule = schedule.sublist(slice);

    DateTime scheduledTime;
    int? notificationTime;
    for (int i = 0; i < min(schedule.length, globals.notificationQueueSize); i++) {
      // Ignores canceled lessons
      if (schedule[i].status == globals.lessonCanceledStatus) { continue; }

      // Sets notification for evening if lesson is in the morning
      scheduledTime = schedule[i].startDate;
      if (scheduledTime.hour <= 9) {
        notificationTime = getSecondsUntilScheduledDate(DateTime(
            scheduledTime.year, scheduledTime.month, scheduledTime.day - 1, 21));
      }
      else {
        notificationTime = getSecondsUntilScheduledDate(scheduledTime) - secondsOffset;
      }

      // Sets notification
      setNotification
      (
          i,
          '${schedule[i].subjectName} [${schedule[i].room}]',
          '${formatScheduleTime(schedule[i].startDate)}-${formatScheduleTime(schedule[i].endDate)}',
          notificationTime,
      );
    }
  }

  // TODO IDK if needed. Needs testing
  // // Needs a call in main
  // // Call to ask for permissions for IOS,
  // void requestIOSPermission(
  //     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
  //   flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //       IOSFlutterLocalNotificationsPlugin>()
  //       ?.requestPermissions
  //     (
  //     alert: true,
  //     badge: true,
  //     sound: true,
  //   );
  // }
}