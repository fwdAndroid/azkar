// lib/screens/location_selector.dart
import 'package:azkar/provider/language_provider.dart';
import 'package:azkar/service/prayer_location.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:provider/provider.dart';

class LocationSelector extends StatefulWidget {
  @override
  _LocationSelectorState createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<PrayerLocation> _searchResults = [];
  bool _isSearching = false;

  void _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final locations = await geo.locationFromAddress(query);
      final results = await Future.wait(
        locations.map((location) async {
          final placemarks = await geo.placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );

          String name = placemarks.isNotEmpty
              ? "${placemarks.first.locality}, ${placemarks.first.administrativeArea}"
              : "Location (${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)})";

          return PrayerLocation(
            name: name,
            latitude: location.latitude,
            longitude: location.longitude,
          );
        }),
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Access

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.localizedStrings["Select Location"] ??
              'Select Location',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    languageProvider
                        .localizedStrings["Search for a city or location"] ??
                    'Search for a city or location',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      )
                    : null,
              ),
              onChanged: _searchLocations,
            ),
          ),
          if (_isSearching)
            const Center(child: CircularProgressIndicator())
          else if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final location = _searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(location.name),
                    onTap: () => Navigator.pop(context, location),
                  );
                },
              ),
            )
          else
            Expanded(
              child: Center(
                child: Text(
                  _searchController.text.isEmpty
                      ? languageProvider
                                .localizedStrings["Search for a location"] ??
                            'Search for a location'
                      : languageProvider.localizedStrings["No results found"] ??
                            'No results found',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
