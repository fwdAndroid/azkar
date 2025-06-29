import 'package:azkar/provider/language_provider.dart';
import 'package:azkar/utils/allah_names_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllahNames extends StatefulWidget {
  const AllahNames({super.key});

  @override
  State<AllahNames> createState() => _AllahNamesState();
}

class _AllahNamesState extends State<AllahNames> {
  int currentIndex = 0;

  void _nextName() {
    setState(() {
      currentIndex = (currentIndex + 1) % names.length;
    });
  }

  void _previousName() {
    setState(() {
      currentIndex = (currentIndex - 1 + names.length) % names.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Access

    final name = names[currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final imageSize = screenWidth * 0.6;
    final fontSizeTitle = screenWidth * 0.07;
    final fontSizeArabic = screenWidth * 0.08;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          languageProvider.localizedStrings["Allah Names"] ?? "Allah Names",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            _nextName();
          } else if (details.primaryVelocity! > 0) {
            _previousName();
          }
        },
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg.png"),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${currentIndex + 1}",
                style: TextStyle(color: Colors.white, fontSize: fontSizeTitle),
              ),
              Text(
                name['transliteration']!,
                style: TextStyle(color: Colors.white, fontSize: fontSizeTitle),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    "assets/pattern RAMADAN 1.png",
                    width: imageSize,
                    height: imageSize,
                  ),
                  Text(
                    name['arabic']!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSizeArabic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                name['meaning']!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _nextName,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  languageProvider.localizedStrings["Next"] ?? "Next",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
