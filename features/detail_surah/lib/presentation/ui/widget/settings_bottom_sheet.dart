import 'package:common/utils/provider/preference_settings_provider.dart';
import 'package:detail_surah/presentation/models/recitation_settings.dart';
import 'package:flutter/material.dart';
import 'package:resources/styles/color.dart';
import 'package:resources/styles/text_styles.dart';

class SettingsBottomSheet extends StatefulWidget {
  final RecitationSettings settings;
  final Function(RecitationSettings) onSettingsChanged;
  final PreferenceSettingsProvider prefSetProvider;

  const SettingsBottomSheet({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required this.prefSetProvider,
  });

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  late RecitationSettings _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.settings;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: widget.prefSetProvider.isDarkTheme ? kBlackBackground : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: kGrey,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            'Recite Settings',
            style: kHeading6.copyWith(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: widget.prefSetProvider.isDarkTheme ? Colors.white : kBlackDark,
            ),
          ),
          const SizedBox(height: 20.0),
          // Text Size
          Text(
            'Text Size',
            style: kHeading6.copyWith(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: widget.prefSetProvider.isDarkTheme ? Colors.white : kBlackDark,
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
              color: widget.prefSetProvider.isDarkTheme ? Colors.white : kBlackDark,
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
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: () {
                  widget.onSettingsChanged(_currentSettings);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreenAccent,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

