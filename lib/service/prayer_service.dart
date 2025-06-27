import 'dart:convert';

import 'package:azkar/service/prayer_location.dart';
import 'package:azkar/service/prayer_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PrayerTimeService {
  static Future<List<PrayerTime>> fetchPrayerTimes(
    PrayerLocation location,
  ) async {
    try {
      final today = DateTime.now();
      final formattedDate = DateFormat('dd-MM-yyyy').format(today);

      final response = await http.get(
        Uri.parse(
          'http://api.aladhan.com/v1/timings/$formattedDate?latitude=${location.latitude}&longitude=${location.longitude}&method=2',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data']['timings'];
        return _parsePrayerTimes(data);
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      throw Exception('Error getting prayer times: $e');
    }
  }

  static List<PrayerTime> _parsePrayerTimes(Map<String, dynamic> timings) {
    final now = DateTime.now();
    final currentTime = DateFormat('HH:mm').format(now);

    final prayers = {
      'Fajr': timings['Fajr'],
      'Sunrise': timings['Sunrise'],
      'Dhuhr': timings['Dhuhr'],
      'Asr': timings['Asr'],
      'Maghrib': timings['Maghrib'],
      'Isha': timings['Isha'],
    };

    String? currentPrayer;
    final List<PrayerTime> prayerTimes = [];

    // Find the current prayer
    prayers.forEach((name, time) {
      if (_isTimeAfter(currentTime, time)) {
        currentPrayer = name;
      }
    });

    // If no current prayer found, set Fajr as current
    if (currentPrayer == null) {
      currentPrayer = 'Fajr';
    }

    // Create prayer time objects
    prayers.forEach((name, time) {
      prayerTimes.add(
        PrayerTime(name: name, time: time, isCurrent: name == currentPrayer),
      );
    });

    return prayerTimes;
  }

  static bool _isTimeAfter(String current, String target) {
    final currentParts = current.split(':').map(int.parse).toList();
    final targetParts = target.split(':').map(int.parse).toList();

    final currentMinutes = currentParts[0] * 60 + currentParts[1];
    final targetMinutes = targetParts[0] * 60 + targetParts[1];

    return currentMinutes >= targetMinutes;
  }
}
