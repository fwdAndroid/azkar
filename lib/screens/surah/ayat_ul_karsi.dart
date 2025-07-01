import 'package:azkar/provider/font_provider.dart';
import 'package:azkar/provider/language_provider.dart';
import 'package:azkar/provider/theme_provider.dart';
import 'package:azkar/widgets/font_setting_dialog.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class AyatAlKursiScreen extends StatefulWidget {
  const AyatAlKursiScreen({super.key});

  @override
  State<AyatAlKursiScreen> createState() => _AyatAlKursiScreenState();
}

class _AyatAlKursiScreenState extends State<AyatAlKursiScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool isPlaying = false;
  bool isRepeating = false;

  final String ayahText =
      '''اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ
لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ
لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ
مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ
يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ
وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ
وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ
وَلَا يَئُودُهُ حِفْظُهُمَا ۚ
وَهُوَ الْعَلِيُّ الْعَظِيمُ''';

  @override
  void initState() {
    super.initState();
    setupAudio();
  }

  Future<void> setupAudio() async {
    try {
      await _audioPlayer.setUrl(
        'https://everyayah.com/data/Abdurrahmaan_As-Sudais_64kbps/002255.mp3',
      );

      _duration = _audioPlayer.duration ?? Duration.zero;

      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _position = position;
        });
      });

      _audioPlayer.durationStream.listen((d) {
        setState(() {
          _duration = d ?? Duration.zero;
        });
      });

      _audioPlayer.playerStateStream.listen((state) {
        setState(() {
          isPlaying = state.playing;
        });
      });
    } catch (e) {
      print('Audio error: $e');
    }
  }

  void toggleAudio() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void toggleRepeat() {
    isRepeating = !isRepeating;
    _audioPlayer.setLoopMode(isRepeating ? LoopMode.one : LoopMode.off);
    setState(() {});
  }

  String formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
        title: Text(
          languageProvider.localizedStrings["Ayat al-Kursi"] ?? 'Ayat al-Kursi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    ayahText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSettings.fontSize + 4,
                      fontFamily: fontSettings.fontFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Slider(
                      activeColor: Colors.greenAccent,
                      inactiveColor: Colors.white24,
                      value: _position.inSeconds.toDouble().clamp(
                        0.0,
                        _duration.inSeconds.toDouble(),
                      ),
                      min: 0,
                      max: _duration.inSeconds.toDouble(),
                      onChanged: (value) {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatTime(_position),
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          formatTime(_duration),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            isRepeating ? Icons.repeat_one : Icons.repeat,
                            color: isRepeating
                                ? Colors.greenAccent
                                : Colors.white,
                          ),
                          onPressed: toggleRepeat,
                        ),
                        const SizedBox(width: 30),
                        IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            size: 60,
                            color: Colors.white,
                          ),
                          onPressed: toggleAudio,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void shareSurahText() {
    if (ayahText.isEmpty) return;

    String surahText = ayahText;

    Share.share(surahText, subject: 'Surah Al-Kahf');
  }
}
