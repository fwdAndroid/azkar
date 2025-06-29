import 'package:azkar/api/api_calls.dart';
import 'package:azkar/model/qari_model.dart';
import 'package:azkar/model/quran_audio_model.dart';
import 'package:azkar/provider/language_provider.dart';
import 'package:azkar/screens/main/quran_screens/audio_surrah_screen.dart';
import 'package:azkar/widgets/qari_custom_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AudioQuran extends StatefulWidget {
  const AudioQuran({super.key});

  @override
  State<AudioQuran> createState() => _AudioQuranState();
}

class _AudioQuranState extends State<AudioQuran> {
  late Future<QuranAudio> _quranAudio;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _quranAudio = ApiCalls().getQuranAudio();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Access

    ApiCalls apiServices = ApiCalls();
    return FutureBuilder(
      future: apiServices.getQariList(),
      builder: (BuildContext context, AsyncSnapshot<List<Qari>> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              languageProvider.localizedStrings["Qari's data not found"] ??
                  "Qari's data not found",
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return Container(
          margin: const EdgeInsets.only(top: 20),
          height: 150,
          child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  QariCustomTile(
                    qari: snapshot.data![index],
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AudioSurahScreen(qari: snapshot.data![index]),
                        ),
                      );
                    },
                  ),
                  Divider(),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
