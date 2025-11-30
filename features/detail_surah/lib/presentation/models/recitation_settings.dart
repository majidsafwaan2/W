class RecitationSettings {
  final String selectedTranslation;
  final String selectedReciter;
  final bool hideTextUntilSpoken;
  final bool highlightAfterAyah;
  final double textSize;
  final double recitationSpeed;

  RecitationSettings({
    this.selectedTranslation = 'English - Saheeh International',
    this.selectedReciter = 'Abdul Basit',
    this.hideTextUntilSpoken = false,
    this.highlightAfterAyah = false,
    this.textSize = 28.0,
    this.recitationSpeed = 1.0,
  });

  RecitationSettings copyWith({
    String? selectedTranslation,
    String? selectedReciter,
    bool? hideTextUntilSpoken,
    bool? highlightAfterAyah,
    double? textSize,
    double? recitationSpeed,
  }) {
    return RecitationSettings(
      selectedTranslation: selectedTranslation ?? this.selectedTranslation,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      hideTextUntilSpoken: hideTextUntilSpoken ?? this.hideTextUntilSpoken,
      highlightAfterAyah: highlightAfterAyah ?? this.highlightAfterAyah,
      textSize: textSize ?? this.textSize,
      recitationSpeed: recitationSpeed ?? this.recitationSpeed,
    );
  }
}

class TranslationOption {
  final String name;
  final String code;
  final String language;

  TranslationOption({
    required this.name,
    required this.code,
    required this.language,
  });
}

class ReciterOption {
  final String name;
  final String id;

  ReciterOption({
    required this.name,
    required this.id,
  });
}

