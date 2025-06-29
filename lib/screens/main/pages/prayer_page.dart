import 'package:azkar/provider/prayer_time_provider.dart';
import 'package:azkar/widgets/hijri_widget.dart';
import 'package:azkar/widgets/prayer_times_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});

  @override
  _PrayerPageState createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PrayerTimeProvider>(context, listen: false);

    // Load data if not already loaded
    if (provider.prayerTimes.isEmpty && !provider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.loadLocationAndPrayerTimes();
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,

      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async => provider.loadLocationAndPrayerTimes(),
          child: Column(
            children: [
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
}
