import 'package:azkar/api/api_calls.dart';
import 'package:azkar/model/quran_model.dart';
import 'package:azkar/screens/main/quran_screens/surah_detail_screen.dart';
import 'package:flutter/material.dart';

class ReadQuran extends StatefulWidget {
  const ReadQuran({super.key});

  @override
  State<ReadQuran> createState() => _ReadQuranState();
}

class _ReadQuranState extends State<ReadQuran> {
  late Future<QuranModel> _quranText;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _quranText = ApiCalls().getQuranText();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuranModel>(
      future: _quranText,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.data!.surahs!.length,
            itemBuilder: (BuildContext context, int index) {
              var surah = snapshot.data!.data!.surahs![index];
              return InkWell(
                onTap: () => {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SuratDetailsPage(snap: surah),
                    ),
                  ),
                },
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: const Color(
                      0xFFD9D9D9,
                    ).withOpacity(0.19), // 19% opacity
                  ),
                  margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  width: MediaQuery.of(this.context).size.width,
                  // height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        surah.name!,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),

                      Text(
                        surah.revelationType!.toString().substring(15) +
                            ' • ' +
                            surah.ayahs!.length.toString() +
                            ' Verses',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
