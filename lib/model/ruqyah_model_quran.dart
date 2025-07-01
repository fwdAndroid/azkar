class RuqyahItem {
  final String title;
  final int surah;
  final List<Verse> verses;

  RuqyahItem({required this.title, required this.surah, required this.verses});

  factory RuqyahItem.fromJson(Map<String, dynamic> json) {
    return RuqyahItem(
      title: json['title'],
      surah: json['surah'],
      verses: List<Verse>.from(json['verses'].map((v) => Verse.fromJson(v))),
    );
  }
}

class Verse {
  final String verse_key;
  final String arabic;
  final String english;

  Verse({required this.verse_key, required this.arabic, required this.english});

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      verse_key: json['verse_key'] ?? '',
      arabic: json['arabic'] ?? '',
      english: json['english'] ?? '',
    );
  }
}
