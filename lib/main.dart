import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:azkar/firebase_options.dart';
import 'package:azkar/provider/font_provider.dart';
import 'package:azkar/provider/language_provider.dart';
import 'package:azkar/provider/prayer_time_provider.dart';
import 'package:azkar/provider/theme_provider.dart';
import 'package:azkar/screens/notification/notification_helper.dart';
import 'package:azkar/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Notification system init
  await NotificationHelper.initialize(); // 🔔 Add this

  // Android background task system init
  await AndroidAlarmManager.initialize();

  // Schedule background refresh of Azan every day
  await AndroidAlarmManager.periodic(
    const Duration(days: 1),
    0, // Unique ID
    refreshPrayerTimesCallback,
    startAt: DateTime.now().add(const Duration(minutes: 1)), // Start soon
    exact: true,
    wakeup: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => PrayerTimeProvider()),
        ChangeNotifierProvider(create: (_) => FontSettings()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// Background isolate callback
@pragma('vm:entry-point')
void refreshPrayerTimesCallback() async {
  final provider = PrayerTimeProvider();
  await provider.loadLocationAndPrayerTimes();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Azkar App',
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}
