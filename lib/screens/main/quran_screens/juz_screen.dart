import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JuzScreen extends StatefulWidget {
  const JuzScreen({Key? key}) : super(key: key);

  @override
  State<JuzScreen> createState() => _JuzScreenState();
}

class _JuzScreenState extends State<JuzScreen> {
  int selectedJuz = 1;
  List<dynamic> ayahs = [];
  bool loading = false;

  late AudioPlayer _audioPlayer;
  bool isPlaying = false;

  Set<String> bookmarkedAyahs = {};

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    loadBookmarks();
    fetchJuz(selectedJuz);
  }

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('bookmarks') ?? [];
    setState(() {
      bookmarkedAyahs = saved.toSet();
    });
  }

  Future<void> saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarks', bookmarkedAyahs.toList());
  }

  Future<void> toggleBookmark(int surah, int ayah) async {
    final id = '$surah:$ayah';
    setState(() {
      if (bookmarkedAyahs.contains(id)) {
        bookmarkedAyahs.remove(id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Removed from bookmarks')));
      } else {
        bookmarkedAyahs.add(id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bookmarked')));
      }
    });
    await saveBookmarks();
  }

  bool isBookmarked(int surah, int ayah) {
    return bookmarkedAyahs.contains('$surah:$ayah');
  }

  Future<void> fetchJuz(int juzNumber) async {
    setState(() {
      loading = true;
      ayahs = [];
    });

    final url = 'https://api.alquran.cloud/v1/juz/$juzNumber/ar.alafasy';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        ayahs = data['data']['ayahs'] ?? [];
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load Juz data')));
    }
  }

  Future<void> playAudio(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      setState(() => isPlaying = true);
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() => isPlaying = false);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to play audio')));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Juz selection row
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 30,
            itemBuilder: (context, index) {
              final juzNum = index + 1;
              final selected = juzNum == selectedJuz;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selected ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedJuz = juzNum;
                    });
                    fetchJuz(juzNum);
                  },
                  child: Text('Juz $juzNum'),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: ayahs.length,
                  itemBuilder: (context, index) {
                    final ayah = ayahs[index];
                    final surah = ayah['surah']['number'];
                    final ayahNum = ayah['numberInSurah'];
                    final text = ayah['text'];
                    final audioUrl = ayah['audio'];

                    final isBookmarkedNow = isBookmarked(surah, ayahNum);

                    return Card(
                      color: Colors.black.withOpacity(0.2),
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: ListTile(
                        title: Text(
                          text,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Text(
                          'Surah ${surah}, Ayah ${ayahNum}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isBookmarkedNow
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: Colors.yellow,
                              ),
                              onPressed: () => toggleBookmark(surah, ayahNum),
                            ),
                            IconButton(
                              icon: Icon(
                                isPlaying ? Icons.stop : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (isPlaying) {
                                  _audioPlayer.stop();
                                  setState(() => isPlaying = false);
                                } else {
                                  playAudio(audioUrl);
                                }
                              },
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
  }
}
