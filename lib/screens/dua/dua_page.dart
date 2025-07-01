import 'dart:convert';

import 'package:azkar/model/dua_model.dart';
import 'package:azkar/provider/font_provider.dart';
import 'package:azkar/provider/theme_provider.dart';
import 'package:azkar/widgets/font_setting_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DuaPage extends StatefulWidget {
  const DuaPage({super.key});

  @override
  State<DuaPage> createState() => _DuaPageState();
}

class _DuaPageState extends State<DuaPage> {
  Future<List<Dua>> loadDuas() async {
    final jsonString = await rootBundle.loadString('assets/lang/dua.json');
    final List<dynamic> jsonResponse = json.decode(jsonString);
    return jsonResponse.map((data) => Dua.fromJson(data)).toList();
  }

  late Future<List<Dua>> _duasFuture;
  List<Dua> _allDuas = [];
  List<Dua> _filteredDuas = [];
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _duasFuture = loadDuas();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredDuas = _allDuas.where((dua) {
        return dua.name.toLowerCase().contains(query) ||
            dua.english.toLowerCase().contains(query) ||
            dua.arabic.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSettings = Provider.of<FontSettings>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Duas', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
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
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<List<Dua>>(
          future: _duasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error loading duas: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No duas found.'));
            }

            if (_allDuas.isEmpty) {
              _allDuas = snapshot.data!;
              _filteredDuas = _allDuas;
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.inputDecorationTheme.prefixIconColor,
                      ),
                      hintText: 'Search Duas...',
                      hintStyle: theme.inputDecorationTheme.hintStyle,
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.border,
                      focusedBorder: theme.inputDecorationTheme.border,
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredDuas.isEmpty
                      ? Center(
                          child: Text(
                            'No Duas match your search.',
                            style: TextStyle(
                              fontSize: fontSettings.fontSize + 4,
                              fontFamily: fontSettings.fontFamily,
                              color: theme.disabledColor,
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filteredDuas.length,
                          itemBuilder: (context, index) {
                            final dua = _filteredDuas[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 4,
                              shadowColor: theme.primaryColorLight,
                              color: theme.cardColor,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dua.name,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      dua.arabic,
                                      style: TextStyle(
                                        fontSize: fontSettings.fontSize + 4,
                                        fontFamily: fontSettings.fontFamily,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      dua.english,
                                      style: TextStyle(
                                        fontSize: fontSettings.fontSize + 4,
                                        fontFamily: fontSettings.fontFamily,
                                        height: 1.4,
                                      ),
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
          },
        ),
      ),
    );
  }
}
