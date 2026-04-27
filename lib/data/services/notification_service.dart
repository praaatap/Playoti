import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'ployti_reminders';
  static const _channelName = 'Task Reminders';
  static const _channelDesc = 'Scheduled reminders for your tasks';

  Future<void> initialize() async {
    try {
      tz.initializeTimeZones();
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings =
          InitializationSettings(android: androidSettings, iOS: iosSettings);
      await _plugin.initialize(initSettings);
    } catch (_) {}
  }

  Future<bool> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        return granted ?? false;
      }
    } catch (_) {}
    return false;
  }

  Future<void> scheduleReminder(
      String taskId, String title, DateTime when) async {
    if (when.isBefore(DateTime.now())) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);
      final scheduled = tz.TZDateTime.from(when, tz.local);
      await _plugin.zonedSchedule(
        _notifId(taskId),
        'Ployti Reminder',
        title,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: taskId,
      );
    } catch (_) {}
  }

  Future<void> cancelReminder(String taskId) async {
    try {
      await _plugin.cancel(_notifId(taskId));
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  int _notifId(String taskId) => taskId.hashCode.abs() % 2147483647;
}
