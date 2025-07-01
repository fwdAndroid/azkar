import 'package:azkar/screens/notification/notification_helper.dart';
import 'package:azkar/service/location_service.dart';
import 'package:azkar/service/prayer_location.dart';
import 'package:azkar/service/prayer_model.dart';
import 'package:azkar/service/prayer_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimeProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();

  PrayerLocation? _currentLocation;
  List<PrayerTime> _prayerTimes = [];
  bool _isLoading = false;
  String? _error;

  bool _azanEnabled = true; // ⬅️ Toggle Azan
  bool get azanEnabled => _azanEnabled;

  PrayerLocation? get currentLocation => _currentLocation;
  List<PrayerTime> get prayerTimes => _prayerTimes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PrayerTimeProvider() {
    loadAzanPreference();
    loadLocationAndPrayerTimes();
  }

  /// ✅ Load saved Azan preference
  Future<void> loadAzanPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _azanEnabled = prefs.getBool('azan_enabled') ?? true;
    notifyListeners();
  }

  /// ✅ Update toggle and persist it
  Future<void> toggleAzanEnabled(bool value) async {
    _azanEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('azan_enabled', value);

    if (!value) {
      await NotificationHelper.cancelAllAzanNotifications();
    } else {
      await scheduleAzanNotifications(); // Reschedule if turned ON
    }
  }

  /// ✅ Main data loader
  Future<void> loadLocationAndPrayerTimes() async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentLocation = await _locationService.getSavedLocation();
      if (_currentLocation == null) {
        _currentLocation = await _locationService.getCurrentLocation();
        await _locationService.saveSelectedLocation(_currentLocation!);
      }

      _prayerTimes = await PrayerTimeService.fetchPrayerTimes(
        _currentLocation!,
      );
      _error = null;

      if (_azanEnabled) {
        await scheduleAzanNotifications();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading prayer times: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Schedule Azan Notifications
  Future<void> scheduleAzanNotifications() async {
    await NotificationHelper.cancelAllAzanNotifications();

    final now = DateTime.now();
    int id = 100;

    for (final prayer in _prayerTimes) {
      final timeString = prayer.time;
      final prayerName = prayer.name;

      try {
        final parts = timeString.split(":");
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        final scheduled = DateTime(now.year, now.month, now.day, hour, minute);

        if (scheduled.isAfter(now)) {
          await NotificationHelper.scheduleAzanNotification(
            prayerName: prayerName,
            scheduleTime: scheduled,
            id: id++,
          );
        }
      } catch (e) {
        debugPrint("Error parsing prayer time for $prayerName: $e");
      }
    }

    Fluttertoast.showToast(msg: "Azan notifications scheduled");
  }

  PrayerTime? getNextPrayer() {
    final now = DateTime.now();
    for (final prayer in _prayerTimes) {
      final timeParts = prayer.time.split(":");
      if (timeParts.length != 2) continue;

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);
      if (hour == null || minute == null) continue;

      final prayerTimeToday = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (prayerTimeToday.isAfter(now)) {
        return prayer;
      }
    }

    return null; // All passed
  }

  Future<void> updateLocation(PrayerLocation newLocation) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _locationService.saveSelectedLocation(newLocation);
      _currentLocation = newLocation;
      _prayerTimes = await PrayerTimeService.fetchPrayerTimes(newLocation);
      _error = null;

      if (_azanEnabled) {
        await scheduleAzanNotifications();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetToCurrentLocation() async {
    try {
      final currentLocation = await _locationService.getCurrentLocation();
      await updateLocation(currentLocation);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  String getPrayerTime(String prayerName) {
    final prayer = _prayerTimes.firstWhere(
      (p) => p.name == prayerName,
      orElse: () =>
          PrayerTime(name: prayerName, time: '--:--', isCurrent: false),
    );
    return prayer.time;
  }

  bool isCurrentPrayer(String prayerName) {
    return _prayerTimes.any((p) => p.name == prayerName && p.isCurrent);
  }

  /// ✅ For AndroidAlarmManager
  static Future<void> scheduleAzanStatic() async {
    final provider = PrayerTimeProvider();
    await provider.loadLocationAndPrayerTimes();
  }
}
