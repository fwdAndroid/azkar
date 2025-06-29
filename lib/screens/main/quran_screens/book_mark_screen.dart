import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  Set<String> bookmarkedIds = {};
  Map<String, List<Map<String, dynamic>>> groupedAyahs =
      {}; // SurahName: [AyahMap]
  bool isLoading = true;
  late AudioPlayer _audioPlayer;
  String? currentlyPlaying;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('bookmarks') ?? [];

    bookmarkedIds = saved.toSet();
    groupedAyahs.clear();

    for (final id in bookmarkedIds) {
      final parts = id.split(':');
      if (parts.length != 2) continue;
      final surah = parts[0];
      final ayah = parts[1];

      final url = 'https://api.alquran.cloud/v1/ayah/$surah:$ayah/ar.alafasy';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        final surahName = data['surah']['englishName'];

        if (!groupedAyahs.containsKey(surahName)) {
          groupedAyahs[surahName] = [];
        }
        groupedAyahs[surahName]!.add(data);
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> removeBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    bookmarkedIds.remove(id);

    groupedAyahs.forEach((surah, ayahList) {
      ayahList.removeWhere(
        (ayah) => '${ayah['surah']['number']}:${ayah['numberInSurah']}' == id,
      );
    });

    groupedAyahs.removeWhere((surah, ayahList) => ayahList.isEmpty);

    await prefs.setStringList('bookmarks', bookmarkedIds.toList());
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Removed from bookmarks')));
  }

  Future<void> playAudio(String url, String id) async {
    if (currentlyPlaying == id) {
      await _audioPlayer.stop();
      setState(() => currentlyPlaying = null);
      return;
    }

    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      setState(() => currentlyPlaying = id);

      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() => currentlyPlaying = null);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Audio failed')));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (groupedAyahs.isEmpty) {
      return const Center(
        child: Text(
          'No bookmarked Ayahs yet',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return ListView(
      children: groupedAyahs.entries.map((entry) {
        final surahName = entry.key;
        final ayahList = entry.value;

        return ExpansionTile(
          title: Text(
            surahName,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          children: ayahList.map((ayah) {
            final id = '${ayah['surah']['number']}:${ayah['numberInSurah']}';
            return Card(
              color: Colors.black.withOpacity(0.2),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(
                  ayah['text'],
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                subtitle: Text(
                  'Ayah ${ayah['numberInSurah']}',
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      icon: Icon(
                        currentlyPlaying == id ? Icons.stop : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () => playAudio(ayah['audio'], id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeBookmark(id),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
