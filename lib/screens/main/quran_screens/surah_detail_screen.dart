import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuratDetailsPage extends StatefulWidget {
  final dynamic snap;
  const SuratDetailsPage({Key? key, required this.snap}) : super(key: key);

  @override
  State<SuratDetailsPage> createState() => _SuratDetailsPageState();
}

class _SuratDetailsPageState extends State<SuratDetailsPage> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  int currentPage = 0;
  List<List<dynamic>> pages = [];
  final ScrollController _scrollController = ScrollController();
  double estimatedAyahHeight = 100.0;

  Set<String> bookmarkedAyahs = {};

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadBookmarks();
      paginateAyahs();
    });
  }

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList('bookmarks');
    setState(() {
      bookmarkedAyahs = saved?.toSet() ?? {};
    });
  }

  Future<void> saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarks', bookmarkedAyahs.toList());
  }

  void toggleBookmark(int surah, int ayah) async {
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

  void paginateAyahs() {
    List ayahs = widget.snap.ayahs;
    double screenHeight = MediaQuery.of(context).size.height;
    int ayahsPerPage = ((screenHeight * 0.6) / estimatedAyahHeight).floor();
    for (int i = 0; i < ayahs.length; i += ayahsPerPage) {
      int end = (i + ayahsPerPage < ayahs.length)
          ? i + ayahsPerPage
          : ayahs.length;
      pages.add(ayahs.sublist(i, end));
    }
    setState(() {});
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> playAudioFromAlQuranCloud(int surah, int ayah) async {
    final url = 'https://api.alquran.cloud/v1/ayah/$surah:$ayah/ar.alafasy';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final audioUrl = jsonDecode(res.body)['data']['audio'];
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
      setState(() => isPlaying = true);
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() => isPlaying = false);
        }
      });
    }
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    setState(() => isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.snap.name ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              if (pages.isEmpty)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent &&
                          currentPage < pages.length - 1) {
                        setState(() => currentPage++);
                      } else if (scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.minScrollExtent &&
                          currentPage > 0) {
                        setState(() => currentPage--);
                      }
                      return false;
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black.withOpacity(0.2),
                      ),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: pages[currentPage].length,
                        itemBuilder: (context, index) {
                          final ayah = pages[currentPage][index];
                          final surah = widget.snap.number;
                          final ayahNum = ayah.numberInSurah;
                          return Card(
                            color: Colors.white.withOpacity(0.1),
                            child: ListTile(
                              title: Text(
                                ayah.text,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              subtitle: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isBookmarked(surah, ayahNum)
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: Colors.yellow,
                                    ),
                                    onPressed: () =>
                                        toggleBookmark(surah, ayahNum),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isPlaying ? Icons.stop : Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      if (isPlaying) {
                                        await stopAudio();
                                      } else {
                                        await playAudioFromAlQuranCloud(
                                          surah,
                                          ayahNum,
                                        );
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
                  ),
                ),
              if (pages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentPage > 0)
                        ElevatedButton(
                          onPressed: () {
                            setState(() => currentPage--);
                            _scrollController.jumpTo(0);
                          },
                          child: const Text('Previous'),
                        ),
                      Text(
                        'Page ${currentPage + 1} of ${pages.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      if (currentPage < pages.length - 1)
                        ElevatedButton(
                          onPressed: () {
                            setState(() => currentPage++);
                            _scrollController.jumpTo(0);
                          },
                          child: const Text('Next'),
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
}
