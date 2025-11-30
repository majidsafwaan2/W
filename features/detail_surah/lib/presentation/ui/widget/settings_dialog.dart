import 'package:common/utils/provider/preference_settings_provider.dart';
import 'package:detail_surah/presentation/models/recitation_settings.dart';
import 'package:flutter/material.dart';
import 'package:resources/styles/color.dart';
import 'package:resources/styles/text_styles.dart';

class SettingsDialog extends StatefulWidget {
  final RecitationSettings settings;
  final Function(RecitationSettings) onSettingsChanged;
  final PreferenceSettingsProvider prefSetProvider;

  const SettingsDialog({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required this.prefSetProvider,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late RecitationSettings _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.settings;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.prefSetProvider.isDarkTheme
          ? kBlackBackground
          : Colors.white,
      title: Text(
        'Settings',
        style: kHeading6.copyWith(
          color: widget.prefSetProvider.isDarkTheme
              ? Colors.white
              : kBlackDark,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Size
            Text(
              'Text Size',
              style: kHeading6.copyWith(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: widget.prefSetProvider.isDarkTheme
                    ? Colors.white
                    : kBlackDark,
              ),
            ),
            Slider(
              value: _currentSettings.textSize,
              min: 20.0,
              max: 40.0,
              divisions: 20,
              label: _currentSettings.textSize.toStringAsFixed(0),
              onChanged: (value) {
                setState(() {
                  _currentSettings = _currentSettings.copyWith(textSize: value);
                });
              },
            ),
            const SizedBox(height: 20.0),
            // Recitation Speed
            Text(
              'Recitation Speed',
              style: kHeading6.copyWith(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: widget.prefSetProvider.isDarkTheme
                    ? Colors.white
                    : kBlackDark,
              ),
            ),
            Slider(
              value: _currentSettings.recitationSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: '${_currentSettings.recitationSpeed.toStringAsFixed(1)}x',
              onChanged: (value) {
                setState(() {
                  _currentSettings = _currentSettings.copyWith(
                    recitationSpeed: value,
                  );
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSettingsChanged(_currentSettings);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

