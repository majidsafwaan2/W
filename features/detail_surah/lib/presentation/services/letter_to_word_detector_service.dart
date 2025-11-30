import 'package:detail_surah/presentation/services/arabic_text_utils.dart';
import 'package:detail_surah/presentation/services/letter_level_detector_service.dart';
import 'package:detail_surah/presentation/services/recitation_detector_service.dart';

/// Service that checks at letter level but returns word-level results
/// If any letter in a word is wrong, the whole word is marked as wrong
class LetterToWordDetectorService {
  /// Detect mistakes by checking letters, but return word-level results
  static RecitationDetectionResult detectMistakesLetterBasedWordLevel(
    String correctText,
    String userText,
  ) {
    // First, do letter-level detection
    final letterResult = LetterLevelDetectorService.detectMistakesAtLetterLevel(
      correctText,
      userText,
    );
    
    // Convert letter-level results to word-level results
    final correctWords = ArabicTextUtils.splitIntoWords(correctText);
    final wordComparisons = <WordComparison>[];
    
    int correctCount = 0;
    int wrongCount = 0;
    int missingCount = 0;
    
    // Group letter comparisons by word
    for (int wordIndex = 0; wordIndex < correctWords.length; wordIndex++) {
      final word = correctWords[wordIndex];
      
      // Get all letter comparisons for this word
      final wordLetters = letterResult.letterComparisons
          .where((lc) => lc.wordIndex == wordIndex)
          .toList();
      
      if (wordLetters.isEmpty) {
        // No letters found for this word - mark as missing
        wordComparisons.add(WordComparison(
          word: word,
          status: WordStatus.missing,
          index: wordIndex,
        ));
        missingCount++;
      } else {
        // Check if any letter in this word is wrong or missing
        bool hasMissing = false;
        bool allCorrect = true;
        
        for (final letterComp in wordLetters) {
          if (letterComp.status == LetterStatus.wrong) {
            allCorrect = false;
          } else if (letterComp.status == LetterStatus.missing) {
            hasMissing = true;
            allCorrect = false;
          }
        }
        
        // Mark word based on letter status
        if (allCorrect) {
          // All letters are correct - word is correct
          wordComparisons.add(WordComparison(
            word: word,
            status: WordStatus.correct,
            index: wordIndex,
          ));
          correctCount++;
        } else if (hasMissing) {
          // Has missing letters - mark as missing
          wordComparisons.add(WordComparison(
            word: word,
            status: WordStatus.missing,
            index: wordIndex,
          ));
          missingCount++;
        } else {
          // Has wrong letters (but no missing) - mark as wrong
          wordComparisons.add(WordComparison(
            word: word,
            status: WordStatus.wrong,
            index: wordIndex,
          ));
          wrongCount++;
        }
      }
    }
    
    final totalWords = correctWords.length;
    final accuracy = totalWords > 0
        ? (correctCount / totalWords) * 100
        : 0.0;
    
    return RecitationDetectionResult(
      wordComparisons: wordComparisons,
      accuracy: accuracy,
      correctCount: correctCount,
      wrongCount: wrongCount,
      missingCount: missingCount,
      totalWords: totalWords,
    );
  }
}

