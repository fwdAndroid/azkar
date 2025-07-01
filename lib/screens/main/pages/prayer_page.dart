import 'dart:async';

import 'package:azkar/provider/prayer_time_provider.dart';
import 'package:azkar/widgets/hijri_widget.dart';
import 'package:azkar/widgets/prayer_times_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});

  @override
  _PrayerPageState createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  bool _initialized = false;
  Duration? _timeLeft;
  Timer? _countdownTimer;
  double _calculateProgress(
    DateTime target,
    DateTime now,
    Duration totalDuration,
  ) {
    final elapsed = now.difference(target.subtract(totalDuration));
    final percent = elapsed.inSeconds / totalDuration.inSeconds;
    return percent.clamp(0.0, 1.0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<PrayerTimeProvider>(context, listen: false);

    if (!_initialized &&
        provider.prayerTimes.isNotEmpty &&
        !provider.isLoading) {
      _initialized = true;
      provider.loadLocationAndPrayerTimes().then((_) {
        Fluttertoast.showToast(msg: "Azan rescheduled for today");
        _startCountdown(provider);
      });
    }
  }

  void _startCountdown(PrayerTimeProvider provider) {
    _countdownTimer?.cancel();

    final nextPrayer = provider.getNextPrayer();
    if (nextPrayer == null) return;

    final now = DateTime.now();
    final timeParts = nextPrayer.time.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;
    final nextPrayerTime = DateTime(now.year, now.month, now.day, hour, minute);

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final remaining = nextPrayerTime.difference(DateTime.now());

      if (remaining.isNegative) {
        timer.cancel();
        setState(() => _timeLeft = null);
      } else {
        setState(() => _timeLeft = remaining);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PrayerTimeProvider>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            await provider.loadLocationAndPrayerTimes();
            Fluttertoast.showToast(msg: "Azan rescheduled");
          },
          child: Column(
            children: [
              _buildNextPrayerCard(context, provider),

              const SizedBox(height: 30),
              const HijriWidget(),
              const SizedBox(height: 20),
              const PrayerTimesWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextPrayerCard(
    BuildContext context,
    PrayerTimeProvider provider,
  ) {
    final nextPrayer = provider.getNextPrayer();

    if (nextPrayer == null || _timeLeft == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "All prayers for today are done.",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    final now = DateTime.now();
    final timeParts = nextPrayer.time.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;
    final targetTime = DateTime(now.year, now.month, now.day, hour, minute);
    final totalDuration = targetTime.difference(now) + _timeLeft!;

    final progress = _calculateProgress(targetTime, now, totalDuration);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        children: [
          // Circular Countdown Progress
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(seconds: 1),
            builder: (context, value, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      backgroundColor: Colors.white24,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        nextPrayer.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${_timeLeft!.inHours.toString().padLeft(2, '0')}:${(_timeLeft!.inMinutes % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 16),

          // Prayer Name & Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Next Prayer",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  "${nextPrayer.name} • ${nextPrayer.time}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Starts in ${_timeLeft!.inHours}h ${_timeLeft!.inMinutes % 60}m",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
