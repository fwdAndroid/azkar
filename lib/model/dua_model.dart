class Dua {
  final int index;
  final String name;
  final String english;
  final String arabic;

  Dua({
    required this.index,
    required this.name,
    required this.english,
    required this.arabic,
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      index: json['index'],
      name: json['name'],
      english: json['english'],
      arabic: json['arabic'],
    );
  }
}
