import 'dart:convert';
import 'package:azkar/model/ruqyah_suunah_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class RuqyahSunnahScreen extends StatefulWidget {
  const RuqyahSunnahScreen({Key? key}) : super(key: key);

  @override
  State<RuqyahSunnahScreen> createState() => _RuqyahSunnahScreenState();
}

class _RuqyahSunnahScreenState extends State<RuqyahSunnahScreen> {
  late Future<List<RuqyahSunnahItem>> ruqyahSunnahList;

  @override
  void initState() {
    super.initState();
    ruqyahSunnahList = loadRuqyahSunnahFromJson();
  }

  Future<List<RuqyahSunnahItem>> loadRuqyahSunnahFromJson() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/lang/ruqyah_sunnah.json',
      );

      final data = json.decode(jsonString);
      final List items = data['ruqyah_sunnah'];

      final parsed = items
          .map((item) => RuqyahSunnahItem.fromJson(item))
          .toList();

      debugPrint("✅ Loaded ${parsed.length} sunnah ruqyah entries.");
      return parsed;
    } catch (e) {
      debugPrint("❌ Error loading Sunnah Ruqyah: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Ruqyah from Sunnah')),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<List<RuqyahSunnahItem>>(
          future: ruqyahSunnahList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  '❌ Error: ${snapshot.error}',
                  style: GoogleFonts.scheherazadeNew(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No Sunnah Ruqyah found.'));
            }

            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final item = data[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.scheherazadeNew(
                            color: Colors.white,
                            fontSize: 18,

                            fontWeight: FontWeight.bold,
                          ),
                          // style: GoogleFont().(

                          // ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.reference,
                          style: GoogleFonts.scheherazadeNew(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const Divider(),
                        Text(
                          item.arabic,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.scheherazadeNew(fontSize: 20),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.english,
                          style: GoogleFonts.scheherazadeNew(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
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
