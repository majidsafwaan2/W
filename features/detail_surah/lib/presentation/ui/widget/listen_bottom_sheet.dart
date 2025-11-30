import 'package:common/utils/provider/preference_settings_provider.dart';
import 'package:detail_surah/presentation/models/recitation_settings.dart';
import 'package:flutter/material.dart';
import 'package:resources/styles/color.dart';
import 'package:resources/styles/text_styles.dart';

class ListenBottomSheet extends StatelessWidget {
  final List<ReciterOption> reciters;
  final String selectedReciter;
  final Function(String) onReciterSelected;
  final PreferenceSettingsProvider prefSetProvider;

  const ListenBottomSheet({
    super.key,
    required this.reciters,
    required this.selectedReciter,
    required this.onReciterSelected,
    required this.prefSetProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: prefSetProvider.isDarkTheme ? kBlackBackground : Colors.white,
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
            'Listen',
            style: kHeading6.copyWith(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: prefSetProvider.isDarkTheme ? Colors.white : kBlackDark,
            ),
          ),
          const SizedBox(height: 16.0),
          ...reciters.map((reciter) {
            final isSelected = reciter.name == selectedReciter;
            return ListTile(
              title: Text(
                reciter.name,
                style: kHeading6.copyWith(
                  color: prefSetProvider.isDarkTheme ? Colors.white : kBlackDark,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: kGreenAccent)
                  : null,
              onTap: () {
                onReciterSelected(reciter.name);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}

