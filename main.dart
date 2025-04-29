import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:long_planner/homepage.dart';
import 'package:long_planner/model.dart';
import 'package:long_planner/notification.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> openAlarmPermissionSettings() async {
  if (!Platform.isAndroid) return;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final androidImplementation =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  if (androidImplementation == null) return;

  final isExactAlarmAllowed =
      await androidImplementation.canScheduleExactNotifications();

  if (isExactAlarmAllowed == false) {
    final intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }
}

Future<void> requestNotificationPermission() async {
  if (!Platform.isAndroid) return;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final androidImplementation =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  if (androidImplementation == null) return;

  final isPermissionGranted =
      await androidImplementation.areNotificationsEnabled();

  if (isPermissionGranted == false) {
    await androidImplementation.requestNotificationsPermission();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(AktiviteAdapter());

  await Hive.openBox<Aktivite>("activiteBox1");

  // 1. Timezone ayarları
  tz.initializeTimeZones();

  // 2. Bildirim sistemi kurulumu
  await NotificationService.initialize();

  // 3. Kullanıcıdan izinleri al
  await requestNotificationPermission();
  await openAlarmPermissionSettings();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Color(0xFF000004)), // düzeltme
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
