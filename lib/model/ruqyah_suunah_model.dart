class RuqyahSunnahItem {
  final String title;
  final String reference;
  final String arabic;
  final String english;

  RuqyahSunnahItem({
    required this.title,
    required this.reference,
    required this.arabic,
    required this.english,
  });

  factory RuqyahSunnahItem.fromJson(Map<String, dynamic> json) {
    return RuqyahSunnahItem(
      title: json['title'],
      reference: json['reference'],
      arabic: json['arabic'],
      english: json['english'],
    );
  }
}
