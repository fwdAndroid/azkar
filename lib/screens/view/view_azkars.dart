import 'package:azkar/provider/language_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ViewAzkarPage extends StatefulWidget {
  final String azkarType;
  const ViewAzkarPage({super.key, required this.azkarType});

  @override
  State<ViewAzkarPage> createState() => _ViewAzkarPageState();
}

class _ViewAzkarPageState extends State<ViewAzkarPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingUrl;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    return DateFormat('mm:ss').format(DateTime(0).add(duration));
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          languageProvider.localizedStrings["Azkar"] ?? "Azkar",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(widget.azkarType)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  languageProvider.localizedStrings["No Azkar found."] ??
                      "No Azkar found.",
                ),
              );
            }

            final azkarList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: azkarList.length,
              itemBuilder: (context, index) {
                final azkar = azkarList[index].data() as Map<String, dynamic>;
                final arabic = azkar['arabic'] ?? azkar['dua'] ?? '';
                final translation = azkar['translation'] ?? '';
                final audio = (azkar['audio'] ?? '').toString().trim();
                final hasAudio =
                    audio.isNotEmpty && Uri.tryParse(audio)?.isAbsolute == true;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9).withOpacity(0.19),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "﷽",
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Scheherazade',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          arabic,
                          style: GoogleFonts.scheherazadeNew(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        if (translation.isNotEmpty)
                          Text(
                            translation,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                        /// ✅ AUDIO PLAYER
                        if (hasAudio) ...[
                          const SizedBox(height: 16),
                          StreamBuilder<Duration>(
                            stream: _audioPlayer.positionStream,
                            builder: (context, snapshot) {
                              final position = snapshot.data ?? Duration.zero;
                              final total =
                                  _audioPlayer.duration ?? Duration.zero;

                              return Column(
                                children: [
                                  Slider(
                                    min: 0,
                                    max: total.inMilliseconds.toDouble().clamp(
                                      0.0,
                                      double.infinity,
                                    ),
                                    value: position.inMilliseconds
                                        .clamp(0, total.inMilliseconds)
                                        .toDouble(),
                                    onChanged: (value) {
                                      _audioPlayer.seek(
                                        Duration(milliseconds: value.toInt()),
                                      );
                                    },
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatDuration(position),
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      Text(
                                        formatDuration(total),
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _audioPlayer.playing &&
                                              _currentlyPlayingUrl == audio
                                          ? Icons.pause_circle_filled
                                          : Icons.play_circle_fill,
                                      color: Colors.white,
                                      size: 36,
                                    ),
                                    onPressed: () async {
                                      if (_currentlyPlayingUrl != audio) {
                                        await _audioPlayer.setUrl(audio);
                                        _currentlyPlayingUrl = audio;
                                        _audioPlayer.setLoopMode(
                                          LoopMode.one,
                                        ); // 🔁 Repeat mode
                                        await _audioPlayer.play();
                                      } else {
                                        if (_audioPlayer.playing) {
                                          await _audioPlayer.pause();
                                        } else {
                                          await _audioPlayer.play();
                                        }
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
