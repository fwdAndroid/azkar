// lib/providers/prayer_time_provider.dart
import 'package:azkar/service/location_service.dart';
import 'package:azkar/service/prayer_location.dart';
import 'package:azkar/service/prayer_model.dart';
import 'package:azkar/service/prayer_service.dart';
import 'package:flutter/material.dart';

class PrayerTimeProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  final PrayerTimeService _prayerTimeService = PrayerTimeService();

  PrayerLocation? _currentLocation;
  List<PrayerTime> _prayerTimes = [];
  bool _isLoading = false;
  String? _error;

  PrayerLocation? get currentLocation => _currentLocation;
  List<PrayerTime> get prayerTimes => _prayerTimes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PrayerTimeProvider() {
    loadLocationAndPrayerTimes();
  }

  Future<void> loadLocationAndPrayerTimes() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Try to get saved location
      _currentLocation = await _locationService.getSavedLocation();

      // If no saved location, get current location
      if (_currentLocation == null) {
        _currentLocation = await _locationService.getCurrentLocation();
        await _locationService.saveSelectedLocation(_currentLocation!);
      }

      // Fetch prayer times
      _prayerTimes = await PrayerTimeService.fetchPrayerTimes(
        _currentLocation!,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading prayer times: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLocation(PrayerLocation newLocation) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _locationService.saveSelectedLocation(newLocation);
      _currentLocation = newLocation;
      _prayerTimes = await PrayerTimeService.fetchPrayerTimes(newLocation);
      _error = null;
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
    final prayer = prayerTimes.firstWhere(
      (p) => p.name == prayerName,
      orElse: () =>
          PrayerTime(name: prayerName, time: '--:--', isCurrent: false),
    );
    return prayer.time;
  }

  // Check if a prayer is the current prayer
  bool isCurrentPrayer(String prayerName) {
    return prayerTimes.any((p) => p.name == prayerName && p.isCurrent);
  }
}
