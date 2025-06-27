// lib/models/prayer_time.dart
class PrayerTime {
  final String name;
  final String time;
  final bool isCurrent; // Make it final

  const PrayerTime({
    required this.name,
    required this.time,
    required this.isCurrent, // Require it in constructor
  });

  factory PrayerTime.fromJson(Map<String, dynamic> json, bool isCurrent) {
    return PrayerTime(
      name: json['name'],
      time: json['time'],
      isCurrent: isCurrent,
    );
  }
}
