import 'package:azkar/screens/main/quran_screens/audio_quran.dart';
import 'package:azkar/screens/main/quran_screens/book_mark_screen.dart';
import 'package:azkar/screens/main/quran_screens/juz_screen.dart';
import 'package:azkar/screens/main/quran_screens/read_quran.dart';
import 'package:azkar/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  // This should be your full list of ayahs, fetched or stored globally
  // For example purposes, I initialize an empty list here
  List<dynamic> allAyahs = [];

  @override
  void initState() {
    super.initState();
    // TODO: Load your full list of ayahs here and assign to allAyahs
    // For example:
    // allAyahs = yourQuranData.surah.flatMap((s) => s.ayahs);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Scaffold(
            drawer: DrawerWidget(),
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              title: const Text('Quran', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              bottom: const TabBar(
                isScrollable: true, // ← Enables scrollable tabs
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: <Widget>[
                  Tab(text: 'Quran'),
                  Tab(text: 'Audio Quran'),
                  Tab(text: "Juz"),
                  Tab(text: 'BookMark'),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                ReadQuran(),
                AudioQuran(),
                JuzScreen(),
                BookmarksScreen(), // Pass the ayahs here
              ],
            ),
          ),
        ],
      ),
    );
  }
}
