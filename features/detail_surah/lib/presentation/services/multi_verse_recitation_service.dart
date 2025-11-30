import 'package:detail_surah/presentation/services/arabic_text_utils.dart';
import 'package:detail_surah/presentation/services/recitation_detector_service.dart';
import 'package:quran/domain/entities/detail_surah_entity.dart' show VerseEntity;

class MultiVerseRecitationResult {
  final Map<int, RecitationDetectionResult> verseResults; // verse index -> result
  final int lastRecitedVerseIndex; // Last verse that was actually recited
  final double overallAccuracy;
  final int totalCorrectWords;
  final int totalWords;

  MultiVerseRecitationResult({
    required this.verseResults,
    required this.lastRecitedVerseIndex,
    required this.overallAccuracy,
    required this.totalCorrectWords,
    required this.totalWords,
  });
}

class MultiVerseRecitationService {
  /// Detect which verses were recited and only judge those
  /// Returns results only for verses that were actually recited
  static MultiVerseRecitationResult detectMultiVerseRecitation(
    List<VerseEntity> allVerses,
    String transcription,
  ) {
    final verseResults = <int, RecitationDetectionResult>{};
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
          // Try to find this word in the transcription (allow up to 10 words ahead for flexibility)
          bool found = false;
          for (int i = tempTranscriptionIndex; i < normalizedTranscription.length && i < tempTranscriptionIndex + 10; i++) {
            if (normalizedTranscription[i] == verseWord) {
              matchedWords++;
              tempTranscriptionIndex = i + 1;
              found = true;
              break;
            }
          }
          if (!found) {
            // Don't break immediately - allow some missing words (user might skip a word)
            // Only break if we've matched less than 30% so far
            if (matchedWords < normalizedVerseWords.length * 0.3) {
              break; // Too few matches, verse probably not recited
            }
          }
        } else {
          break; // Transcription ended
        }
      }
      
      // If we matched at least 30% of the verse words, consider it recited (lowered threshold for real-time)
      final matchRatio = normalizedVerseWords.isNotEmpty 
          ? matchedWords / normalizedVerseWords.length 
          : 0.0;
      
      if (matchRatio >= 0.3 && tempTranscriptionIndex > transcriptionIndex) {
        // This verse was recited - extract the relevant part of transcription
        final verseTranscription = transcriptionWords.sublist(
          transcriptionIndex,
          tempTranscriptionIndex < transcriptionWords.length ? tempTranscriptionIndex : transcriptionWords.length,
        ).join(' ');
        
        // Detect mistakes for this verse
        final result = RecitationDetectorService.detectMistakes(
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
    int totalWords = 0;
    
    for (final result in verseResults.values) {
      totalCorrect += result.correctCount;
      totalWords += result.totalWords;
    }
    
    final overallAccuracy = totalWords > 0 
        ? (totalCorrect / totalWords) * 100 
        : 0.0;
    
    return MultiVerseRecitationResult(
      verseResults: verseResults,
      lastRecitedVerseIndex: lastRecitedVerseIndex,
      overallAccuracy: overallAccuracy,
      totalCorrectWords: totalCorrect,
      totalWords: totalWords,
    );
  }
}

