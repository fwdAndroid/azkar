import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// ✅ Initialize notifications
  static Future<void> initialize() async {
    tzdata.initializeTimeZones();

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  /// ✅ Schedule Azan notification with sound
  static Future<void> scheduleAzanNotification({
    required String prayerName,
    required DateTime scheduleTime,
    required int id,
  }) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      '$prayerName Azan',
      'Time for $prayerName prayer',
      tz.TZDateTime.from(scheduleTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'azan_channel',
          'Azan Notifications',
          channelDescription: 'Plays Azan at prayer time',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(
            'azan',
          ), // 🗂️ Place azan.mp3 in res/raw
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  /// ❌ Cancel all scheduled Azan notifications
  static Future<void> cancelAllAzanNotifications() async {
    for (int id = 100; id < 200; id++) {
      await _flutterLocalNotificationsPlugin.cancel(id);
    }
  }
}
