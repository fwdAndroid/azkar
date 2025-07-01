import 'package:azkar/provider/language_provider.dart';
import 'package:azkar/screens/dua/dua_page.dart';
import 'package:azkar/screens/dua/ruqqah_for_quran.dart';
import 'package:azkar/screens/dua/ruqqah_for_sunnah.dart';
import 'package:azkar/screens/surah/ayat_ul_karsi.dart';
import 'package:azkar/screens/surah/surah_kahaf.dart';
import 'package:azkar/screens/surah/surah_yasin.dart';
import 'package:azkar/screens/view/view_azkars.dart';
import 'package:azkar/screens/view/view_dua.dart';
import 'package:azkar/widgets/azkar_title_widget.dart';
import 'package:azkar/widgets/drawer_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

class AzkarPage extends StatefulWidget {
  const AzkarPage({super.key});

  @override
  State<AzkarPage> createState() => _AzkarPageState();
}

class _AzkarPageState extends State<AzkarPage> {
  late HijriCalendar _hijriDate;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    _hijriDate = HijriCalendar.now();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      drawer: DrawerWidget(),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            "assets/bg.png",
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hijri Date
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4),
                    child: Text(
                      "${_hijriDate.toFormat("dd MMMM, yyyy")} AH",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Dua Section
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('dua')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.podcasts_outlined, size: 40),
                              SizedBox(height: 10),
                              Text("No duas available"),
                            ],
                          ),
                        );
                      }

                      final posts = snapshot.data!.docs;

                      return Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                final post =
                                    posts[index].data() as Map<String, dynamic>;

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (builder) =>
                                            ViewDuaPage(uuid: post['uuid']),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFD9D9D9,
                                      ).withOpacity(0.19),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            languageProvider
                                                    .localizedStrings["Today's Dua"] ??
                                                "Today's Dua",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Expanded(
                                            child: Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                post['dua'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          // 👇 Page Indicator below the PageView
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 16.0,
                                              top: 8,
                                            ),
                                            child: Row(
                                              children: List.generate(
                                                posts.length,
                                                (index) {
                                                  bool isActive =
                                                      (_pageController
                                                          .hasClients &&
                                                      _pageController.page
                                                              ?.round() ==
                                                          index);

                                                  return AnimatedContainer(
                                                    duration: const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                        ),
                                                    width: isActive ? 12 : 8,
                                                    height: isActive ? 12 : 8,
                                                    decoration: BoxDecoration(
                                                      color: isActive
                                                          ? Colors.white
                                                          : Colors.white54,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                  //Ayat ul kursis
                  AzkarTitleWidget(
                    image: "assets/ayar.png",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (builder) => AyatAlKursiScreen(),
                      ),
                    ),
                    text: "آية الكرسي",
                  ),

                  //Surah Yasin
                  AzkarTitleWidget(
                    image: "assets/koran.png",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (builder) => SurahYasinPage()),
                    ),
                    text: "سورة يس",
                  ),

                  //Surah AlKahaf
                  AzkarTitleWidget(
                    image: "assets/quran.png",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (builder) => OpenSurahPage()),
                    ),
                    text: "سورة الكهف",
                  ),

                  //Dua
                  AzkarTitleWidget(
                    image: "assets/islam.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (builder) => RuqyahScreen()),
                      );
                    },
                    text: "الرقية من القرآن الكريم",
                  ),
                  //Dua
                  AzkarTitleWidget(
                    image: "assets/dua.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (builder) => DuaPage()),
                      );
                    },
                    text: "دعاء",
                  ),
                  //Al Raqaya From Sunnah
                  AzkarTitleWidget(
                    image: "assets/tasbih.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) => RuqyahSunnahScreen(),
                        ),
                      );
                    },
                    text: "الرقية من السنة",
                  ),
                  // Azkar Sections
                  AzkarTitleWidget(
                    image: "assets/morning.png",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (builder) =>
                            ViewAzkarPage(azkarType: 'morningazkaar'),
                      ),
                    ),
                    text: "أذكار الصباح",
                  ),
                  AzkarTitleWidget(
                    image: "assets/evening.png",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (builder) =>
                            ViewAzkarPage(azkarType: 'eveningazkaar'),
                      ),
                    ),
                    text: "أذكار المساء",
                  ),
                  AzkarTitleWidget(
                    image: "assets/night.png",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (builder) =>
                            ViewAzkarPage(azkarType: 'nightAzkar'),
                      ),
                    ),
                    text: "أذكار النوم",
                  ),
                  AzkarTitleWidget(
                    image: "assets/after.png",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (builder) =>
                            ViewAzkarPage(azkarType: 'afterPrayer'),
                      ),
                    ),
                    text: "بعد الصلوات",
                  ),
                  AzkarTitleWidget(
                    image: "assets/books.png",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (builder) =>
                            ViewAzkarPage(azkarType: 'metaphor'),
                      ),
                    ),
                    text: "مواجهة تشبيه",
                  ),
                  AzkarTitleWidget(
                    image: "assets/benifit.png",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (builder) =>
                            ViewAzkarPage(azkarType: 'azkarbenefits'),
                      ),
                    ),
                    text: "فوائد الأذكار",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
