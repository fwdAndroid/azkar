// lib/models/location.dart
class PrayerLocation {
  final String name;
  final double latitude;
  final double longitude;

  PrayerLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'latitude': latitude, 'longitude': longitude};
  }

  factory PrayerLocation.fromMap(Map<String, dynamic> map) {
    return PrayerLocation(
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
