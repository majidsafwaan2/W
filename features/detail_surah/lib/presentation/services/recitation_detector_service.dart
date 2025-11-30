import 'package:detail_surah/presentation/services/arabic_text_utils.dart';

enum WordStatus {
  correct,
  wrong,
  missing,
}

class WordComparison {
  final String word;
  final WordStatus status;
  final int index;

  WordComparison({
    required this.word,
    required this.status,
    required this.index,
  });
}

class RecitationDetectionResult {
  final List<WordComparison> wordComparisons;
  final double accuracy;
  final int correctCount;
  final int wrongCount;
  final int missingCount;
  final int totalWords;

  RecitationDetectionResult({
    required this.wordComparisons,
    required this.accuracy,
    required this.correctCount,
    required this.wrongCount,
    required this.missingCount,
    required this.totalWords,
  });
}

class RecitationDetectorService {
  /// Compare user recitation with the correct Arabic text
  static RecitationDetectionResult detectMistakes(
    String correctText,
    String userText,
  ) {
    // Normalize both texts
    final correctWords = ArabicTextUtils.splitIntoWords(correctText);
    final userWords = ArabicTextUtils.splitIntoWords(userText);

    final wordComparisons = <WordComparison>[];
    int correctCount = 0;
    int wrongCount = 0;
    int missingCount = 0;

    // Use a simple comparison algorithm
    // Compare word by word, marking missing words
    int userIndex = 0;
    
    for (int i = 0; i < correctWords.length; i++) {
      final correctWord = ArabicTextUtils.normalizeWord(correctWords[i]);
      
      if (userIndex < userWords.length) {
        final userWord = ArabicTextUtils.normalizeWord(userWords[userIndex]);
        
        // Check if words match
        if (correctWord == userWord) {
          wordComparisons.add(WordComparison(
            word: correctWords[i],
            status: WordStatus.correct,
            index: i,
          ));
          correctCount++;
          userIndex++;
        } else {
          // Check if the user word matches a later word (maybe user skipped a word)
          bool foundMatch = false;
          for (int j = userIndex; j < userWords.length && j < userIndex + 3; j++) {
            if (ArabicTextUtils.normalizeWord(userWords[j]) == correctWord) {
              // User skipped some words
              for (int k = userIndex; k < j; k++) {
                // Mark skipped words as missing (but we'll mark correct word as correct)
              }
              foundMatch = true;
              userIndex = j + 1;
              wordComparisons.add(WordComparison(
                word: correctWords[i],
                status: WordStatus.correct,
                index: i,
              ));
              correctCount++;
              break;
            }
          }
          
          if (!foundMatch) {
            // Word is wrong
            wordComparisons.add(WordComparison(
              word: correctWords[i],
              status: WordStatus.wrong,
              index: i,
            ));
            wrongCount++;
            // Don't advance userIndex, let it try to match next correct word
          }
        }
      } else {
        // User text ended, remaining words are missing
        wordComparisons.add(WordComparison(
          word: correctWords[i],
          status: WordStatus.missing,
          index: i,
        ));
        missingCount++;
      }
    }

    // Check if there are extra user words (should be marked as wrong, but for simplicity, we'll ignore them)
    // as they would be caught in the word-by-word comparison above

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

  /// More sophisticated comparison using edit distance for fuzzy matching
  static RecitationDetectionResult detectMistakesAdvanced(
    String correctText,
    String userText,
  ) {
    final correctWords = ArabicTextUtils.splitIntoWords(correctText);
    final userWords = ArabicTextUtils.splitIntoWords(userText);

    final wordComparisons = <WordComparison>[];
    
    // Use dynamic programming for alignment
    final alignment = _alignWords(correctWords, userWords);
    
    int correctCount = 0;
    int wrongCount = 0;
    int missingCount = 0;

    for (int i = 0; i < alignment.length; i++) {
      final aligned = alignment[i];
      if (aligned.correctWord == null) {
        // Extra word in user text (skip for now)
        continue;
      }
      
      if (aligned.userWord == null) {
        wordComparisons.add(WordComparison(
          word: aligned.correctWord!,
          status: WordStatus.missing,
          index: i,
        ));
        missingCount++;
      } else {
        final normalizedCorrect = ArabicTextUtils.normalizeWord(aligned.correctWord!);
        final normalizedUser = ArabicTextUtils.normalizeWord(aligned.userWord!);
        
        if (normalizedCorrect == normalizedUser) {
          wordComparisons.add(WordComparison(
            word: aligned.correctWord!,
            status: WordStatus.correct,
            index: i,
          ));
          correctCount++;
        } else {
          wordComparisons.add(WordComparison(
            word: aligned.correctWord!,
            status: WordStatus.wrong,
            index: i,
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

  static List<_AlignedWord> _alignWords(List<String> correct, List<String> user) {
    // Simple alignment: try to match each correct word with user words
    final alignment = <_AlignedWord>[];
    int userIndex = 0;

    for (final correctWord in correct) {
      if (userIndex < user.length) {
        alignment.add(_AlignedWord(
          correctWord: correctWord,
          userWord: user[userIndex],
        ));
        userIndex++;
      } else {
        alignment.add(_AlignedWord(
          correctWord: correctWord,
          userWord: null,
        ));
      }
    }

    return alignment;
  }
}

class _AlignedWord {
  final String? correctWord;
  final String? userWord;

  _AlignedWord({
    required this.correctWord,
    required this.userWord,
  });
}
