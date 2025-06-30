import 'package:azkar/provider/font_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;

class ReadQuran extends StatelessWidget {
  const ReadQuran({super.key});

  @override
  Widget build(BuildContext context) {
    final fontSettings = Provider.of<FontSettings>(context);

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView.builder(
          itemCount: quran.totalSurahCount,
          itemBuilder: (context, surahIndex) {
            int surahNum = surahIndex + 1;
            int verseCount = quran.getVerseCount(surahNum);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 🕌 Surah name header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Center(
                    child: Text(
                      '${quran.getSurahName(surahNum)} (${quran.getSurahNameEnglish(surahNum)})',
                      style: TextStyle(
                        fontSize: fontSettings.fontSize + 4,
                        fontFamily: fontSettings.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // 📖 Ayahs list
                ListView.builder(
                  itemCount: verseCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, ayahIndex) {
                    final ayah = quran.getVerse(
                      surahNum,
                      ayahIndex + 1,
                      verseEndSymbol: true,
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      child: Text(
                        ayah,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: fontSettings.fontSize,
                          fontFamily: fontSettings.fontFamily,
                        ),
                      ),
                    );
                  },
                ),

                const Divider(thickness: 1),
              ],
            );
          },
        ),
      ),
    );
  }
}
