// lib/services/location_service.dart
import 'dart:convert';

import 'package:azkar/service/prayer_location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _locationKey = 'selected_location';

  Future<PrayerLocation> getCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      final placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String locationName = placemarks.isNotEmpty
          ? "${placemarks.first.locality}, ${placemarks.first.administrativeArea}"
          : "Current Location";

      return PrayerLocation(
        name: locationName,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  Future<void> saveSelectedLocation(PrayerLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationKey, location.toMap().toString());
  }

  Future<PrayerLocation?> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locationString = prefs.getString(_locationKey);
    if (locationString != null) {
      try {
        final locationMap = Map<String, dynamic>.from(
          Map<String, String>.from(json.decode(locationString)),
        );
        return PrayerLocation.fromMap(locationMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }
}
