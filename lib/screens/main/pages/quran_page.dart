import 'package:azkar/screens/main/quran_screens/audio_quran.dart';
import 'package:azkar/screens/main/quran_screens/read_quran.dart';
import 'package:flutter/material.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Quran'),
          bottom: const TabBar(
            dividerColor: Colors.transparent,
            tabs: <Widget>[
              Tab(text: 'Flights', icon: Icon(Icons.flight)),
              Tab(text: 'Trips', icon: Icon(Icons.luggage)),
            ],
          ),
        ),
        body: const TabBarView(children: <Widget>[ReadQuran(), AudioQuran()]),
      ),
    );
  }
}
