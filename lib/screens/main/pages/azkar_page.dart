import 'package:azkar/screens/drawer_pages/allah_names.dart';
import 'package:azkar/screens/view/view_azkars.dart';
import 'package:azkar/widgets/azkar_title_widget.dart';
import 'package:azkar/widgets/drawer_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AzkarPage extends StatefulWidget {
  const AzkarPage({super.key});

  @override
  State<AzkarPage> createState() => _AzkarPageState();
}

class _AzkarPageState extends State<AzkarPage> {
  late HijriCalendar _hijriDate;
  @override
  void initState() {
    super.initState();
    _hijriDate = HijriCalendar.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white, // or white depending on bg
      ),
      drawer: DrawerWidget(),
      extendBodyBehindAppBar:
          true, // allows background image to go under appbar
      body: Stack(
        children: [
          Image.asset(
            "assets/bg.png",
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          // Add content here if needed
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4),
                    child: Text(
                      "${_hijriDate.toFormat("dd MMMM, yyyy")} AH",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
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
                      final pageController = PageController(
                        viewportFraction: 0.9,
                      );

                      return Column(
                        children: [
                          SizedBox(
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            child: PageView.builder(
                              scrollDirection: Axis.horizontal,
                              controller: pageController,
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                final post =
                                    posts[index].data() as Map<String, dynamic>;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFD9D9D9,
                                    ).withOpacity(0.19), // 19% opacity
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
                                        const Text(
                                          "Today's Dua",
                                          style: TextStyle(
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
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        SmoothPageIndicator(
                                          controller: pageController,
                                          count: posts.length,
                                          effect: const ExpandingDotsEffect(
                                            activeDotColor: Colors.white,
                                            dotColor: Color(0xFFD9D9D9),
                                            dotHeight: 8,
                                            dotWidth: 8,
                                            spacing: 6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  //Morning
                  AzkarTitleWidget(
                    image: "assets/morning.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) =>
                              ViewAzkarPage(azkarType: 'morningazkaar'),
                        ),
                      );
                    },
                    text: "أذكار الصباح",
                  ),

                  //Evemin
                  AzkarTitleWidget(
                    image: "assets/evening.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) =>
                              ViewAzkarPage(azkarType: 'eveningazkaar'),
                        ),
                      );
                    },
                    text: "أذكار المساء",
                  ),
                  //Night
                  AzkarTitleWidget(
                    image: "assets/night.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) =>
                              ViewAzkarPage(azkarType: 'nightAzkar'),
                        ),
                      );
                    },
                    text: "أذكار النوم",
                  ),
                  //After The Prayers
                  AzkarTitleWidget(
                    image: "assets/after.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) =>
                              ViewAzkarPage(azkarType: 'afterPrayer'),
                        ),
                      );
                    },
                    text: "بعد الصلوات",
                  ),
                  //Confronting a metaphor
                  AzkarTitleWidget(
                    image: "assets/books.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) =>
                              ViewAzkarPage(azkarType: 'metaphor'),
                        ),
                      );
                    },
                    text: "مواجهة تشبيه",
                  ),
                  //Benefits
                  AzkarTitleWidget(
                    image: "assets/benifit.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) =>
                              ViewAzkarPage(azkarType: 'azkarbenefits'),
                        ),
                      );
                    },
                    text: "فوائد الأذكار",
                  ),
                  //Allah Names
                  AzkarTitleWidget(
                    image: "assets/elements.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (builder) => AllahNames()),
                      );
                    },
                    text: "أسماء الله",
                  ),
                  //Hajj and Ummrah
                  AzkarTitleWidget(
                    image: "assets/hajj.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (builder) => AllahNames()),
                      );
                    },
                    text: "الحج والعمرة",
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
