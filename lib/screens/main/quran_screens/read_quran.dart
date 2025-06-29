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
              print(surah);
              return InkWell(
                onTap: () => {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SuratDetailsPage(snap: surah),
                    ),
                  ),
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
                  width: MediaQuery.of(this.context).size.width,
                  // height: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 30),
                        child: Text(
                          surah.englishName!,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Color(0xff555555),
                          ),
                        ),
                      ),
                      Text(
                        surah.revelationType!.toString().substring(15) +
                            ' • ' +
                            surah.ayahs!.length.toString() +
                            ' Verses',
                        style: const TextStyle(
                          color: Color(0xffAEAEAE),
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
