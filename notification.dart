import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'scheduled_activity_channel';
  static const String _channelName = 'Scheduled Activities';
  static const String _channelDescription =
      'Channel for scheduled activity notifications';

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('ic_notification');

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notificationsPlugin.initialize(
      settings,
      // 🔁 Bildirime tıklanınca hata olmaması için try-catch ekledik
      onDidReceiveNotificationResponse: (notificationResponse) {
        try {
          debugPrint('Notification Tapped: ${notificationResponse.payload}');
        } catch (e) {
          debugPrint('Bildirim callback hatası: $e');
        }
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> requestAndroidPermission() async {
    final bool? granted =
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
    debugPrint('Android Notification Permission Granted: $granted');
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    if (scheduledTZDate.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint(
        'Hata: Geçmiş bir tarih ($scheduledDate) için bildirim zamanlanamaz.',
      );
      return;
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
      debugPrint(
        'Bildirim ID $id ile "$title" için $scheduledDate zamanına kuruldu.',
      );
    } catch (e) {
      debugPrint('Bildirim zamanlanırken hata oluştu (ID: $id): $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      debugPrint('Bildirim ID $id başarıyla iptal edildi.');
    } catch (e) {
      debugPrint('Bildirim iptal edilirken hata oluştu (ID: $id): $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('Tüm zamanlanmış bildirimler iptal edildi.');
    } catch (e) {
      debugPrint('Tüm bildirimler iptal edilirken hata oluştu: $e');
    }
  }
}
