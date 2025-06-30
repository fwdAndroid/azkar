import 'package:azkar/provider/font_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FontSettingsDialog extends StatelessWidget {
  const FontSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final fontSettings = Provider.of<FontSettings>(context);

    return AlertDialog(
      title: const Text('Font Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Font Size'),
          Slider(
            min: 18,
            max: 48,
            divisions: 15,
            label: fontSettings.fontSize.toStringAsFixed(0),
            value: fontSettings.fontSize,
            onChanged: (value) => fontSettings.setFontSize(value),
          ),
          const SizedBox(height: 12),
          const Text('Font Type'),
          DropdownButton<String>(
            value: fontSettings.fontFamily,
            isExpanded: true,
            items: ['Amiri', 'Scheherazade']
                .map(
                  (font) =>
                      DropdownMenuItem<String>(value: font, child: Text(font)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) fontSettings.setFontFamily(value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
