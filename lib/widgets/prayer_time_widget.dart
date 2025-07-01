import 'package:azkar/provider/prayer_time_provider.dart';
import 'package:flutter/material.dart';

Widget buildNextPrayerCard(BuildContext context, PrayerTimeProvider provider) {
  final nextPrayer = provider.getNextPrayer();

  if (nextPrayer == null) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        "All prayers for today are done.",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white30),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.access_time, color: Colors.white),
        Text(
          "Next: ${nextPrayer.name}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          nextPrayer.time,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}
