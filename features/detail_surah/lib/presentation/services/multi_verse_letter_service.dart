import 'package:detail_surah/presentation/services/arabic_text_utils.dart';
import 'package:detail_surah/presentation/services/letter_level_detector_service.dart';
import 'package:quran/domain/entities/detail_surah_entity.dart' show VerseEntity;

class MultiVerseLetterRecitationResult {
  final Map<int, LetterLevelDetectionResult> verseResults; // verse index -> result
  final int lastRecitedVerseIndex; // Last verse that was actually recited
  final double overallAccuracy;
  final int totalCorrectLetters;
  final int totalLetters;

  MultiVerseLetterRecitationResult({
    required this.verseResults,
    required this.lastRecitedVerseIndex,
    required this.overallAccuracy,
    required this.totalCorrectLetters,
    required this.totalLetters,
  });
}

class MultiVerseLetterRecitationService {
  /// Detect which verses were recited and only judge those at letter level
  static MultiVerseLetterRecitationResult detectMultiVerseRecitationAtLetterLevel(
    List<VerseEntity> allVerses,
    String transcription,
  ) {
    final verseResults = <int, LetterLevelDetectionResult>{};
    int lastRecitedVerseIndex = -1;
    
    // Normalize transcription
    final transcriptionWords = ArabicTextUtils.splitIntoWords(transcription);
    final normalizedTranscription = transcriptionWords.map((w) => ArabicTextUtils.normalizeWord(w)).toList();
    
    int transcriptionIndex = 0;
    
    // Try to match verses sequentially
    for (int verseIndex = 0; verseIndex < allVerses.length; verseIndex++) {
      final verse = allVerses[verseIndex];
      final verseWords = ArabicTextUtils.splitIntoWords(verse.text.arab);
      final normalizedVerseWords = verseWords.map((w) => ArabicTextUtils.normalizeWord(w)).toList();
      
      // Check if we can find this verse's words in the remaining transcription
      int matchedWords = 0;
      int tempTranscriptionIndex = transcriptionIndex;
      
      for (final verseWord in normalizedVerseWords) {
        if (tempTranscriptionIndex < normalizedTranscription.length) {
          // Try to find this word in the transcription
          bool found = false;
          for (int i = tempTranscriptionIndex; i < normalizedTranscription.length && i < tempTranscriptionIndex + 5; i++) {
            if (normalizedTranscription[i] == verseWord) {
              matchedWords++;
              tempTranscriptionIndex = i + 1;
              found = true;
              break;
            }
          }
          if (!found) {
            break; // Can't find this word, verse might not be complete
          }
        } else {
          break; // Transcription ended
        }
      }
      
      // If we matched at least 50% of the verse words, consider it recited
      final matchRatio = normalizedVerseWords.isNotEmpty 
          ? matchedWords / normalizedVerseWords.length 
          : 0.0;
      
      if (matchRatio >= 0.5 && tempTranscriptionIndex > transcriptionIndex) {
        // This verse was recited - extract the relevant part of transcription
        final verseTranscription = transcriptionWords.sublist(
          transcriptionIndex,
          tempTranscriptionIndex < transcriptionWords.length ? tempTranscriptionIndex : transcriptionWords.length,
        ).join(' ');
        
        // Detect mistakes at letter level for this verse
        final result = LetterLevelDetectorService.detectMistakesAtLetterLevel(
          verse.text.arab,
          verseTranscription,
        );
        
        verseResults[verseIndex] = result;
        lastRecitedVerseIndex = verseIndex;
        transcriptionIndex = tempTranscriptionIndex;
      } else {
        // This verse wasn't recited, stop here
        break;
      }
    }
    
    // Calculate overall accuracy from recited verses only
    int totalCorrect = 0;
    int totalLetters = 0;
    
    for (final result in verseResults.values) {
      totalCorrect += result.correctCount;
      totalLetters += result.totalLetters;
    }
    
    final overallAccuracy = totalLetters > 0 
        ? (totalCorrect / totalLetters) * 100 
        : 0.0;
    
    return MultiVerseLetterRecitationResult(
      verseResults: verseResults,
      lastRecitedVerseIndex: lastRecitedVerseIndex,
      overallAccuracy: overallAccuracy,
      totalCorrectLetters: totalCorrect,
      totalLetters: totalLetters,
    );
  }
}

