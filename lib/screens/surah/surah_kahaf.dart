import 'dart:convert';
import 'package:azkar/provider/font_provider.dart';
import 'package:azkar/provider/language_provider.dart';
import 'package:azkar/provider/theme_provider.dart';
import 'package:azkar/widgets/font_setting_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class OpenSurahPage extends StatefulWidget {
  const OpenSurahPage({super.key});

  @override
  State<OpenSurahPage> createState() => _OpenSurahPageState();
}

class _OpenSurahPageState extends State<OpenSurahPage> {
  List ayahs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSurah("ar.alafasy"); // Default Qari, you can change this if needed
  }

  Future<void> fetchSurah(String qariIdentifier) async {
    setState(() {
      isLoading = true;
      ayahs = [];
    });

    final response = await http.get(
      Uri.parse('https://api.alquran.cloud/v1/surah/18/$qariIdentifier'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        ayahs = data['data']['ayahs'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      print('Failed to load Surah Kahf');
    }
  }

  String convertToArabicNumber(int number) {
    final arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.parse(d)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final fontSettings = Provider.of<FontSettings>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Colors.white,
              ),
              onPressed: () => themeProvider.toggleTheme(),
            ),
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem<int>(value: 0, child: Text('Font Settings')),
            ],
            onSelected: (value) {
              if (value == 0) {
                showDialog(
                  context: context,
                  builder: (_) => const FontSettingsDialog(),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: shareSurahText,
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          languageProvider.localizedStrings["Surah Al-Kahf"] ?? 'Surah Al-Kahf',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: ayahs.length,
                  itemBuilder: (context, index) {
                    final ayah = ayahs[index];
                    return Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              ayah['text'],
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSettings.fontSize + 4,
                                fontFamily: fontSettings.fontFamily,
                              ),
                            ),
                            subtitle: Text(
                              'آية ${convertToArabicNumber(ayah['numberInSurah'])}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSettings.fontSize,
                                fontFamily: fontSettings.fontFamily,
                              ),
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void shareSurahText() {
    if (ayahs.isEmpty) return;

    String surahText = 'سورة الكهف\n\n';
    for (var ayah in ayahs) {
      surahText +=
          '${ayah['text']} ﴿${convertToArabicNumber(ayah['numberInSurah'])}﴾\n';
    }

    Share.share(surahText, subject: 'Surah Al-Kahf');
  }
}
