import 'package:detail_surah/presentation/services/arabic_text_utils.dart';

enum LetterStatus {
  correct,
  wrong,
  missing,
}

class LetterComparison {
  final String letter;
  final LetterStatus status;
  final int wordIndex; // Which word this letter belongs to
  final int letterIndex; // Position within the word

  LetterComparison({
    required this.letter,
    required this.status,
    required this.wordIndex,
    required this.letterIndex,
  });
}

class LetterLevelDetectionResult {
  final List<LetterComparison> letterComparisons;
  final double accuracy;
  final int correctCount;
  final int wrongCount;
  final int missingCount;
  final int totalLetters;

  LetterLevelDetectionResult({
    required this.letterComparisons,
    required this.accuracy,
    required this.correctCount,
    required this.wrongCount,
    required this.missingCount,
    required this.totalLetters,
  });
}

class LetterLevelDetectorService {
  /// Compare user recitation with correct Arabic text at letter level
  static LetterLevelDetectionResult detectMistakesAtLetterLevel(
    String correctText,
    String userText,
  ) {
    // Normalize both texts (but keep letters separate)
    final correctWords = ArabicTextUtils.splitIntoWords(correctText);
    final userWords = ArabicTextUtils.splitIntoWords(userText);
    
    final letterComparisons = <LetterComparison>[];
    int correctCount = 0;
    int wrongCount = 0;
    int missingCount = 0;
    int totalLetters = 0;
    
    int userWordIndex = 0;
    
    // Process each word in the correct text
    for (int wordIdx = 0; wordIdx < correctWords.length; wordIdx++) {
      final correctWord = correctWords[wordIdx];
      final normalizedCorrectWord = ArabicTextUtils.normalizeWord(correctWord);
      final correctLetters = _splitIntoLetters(normalizedCorrectWord);
      
      totalLetters += correctLetters.length;
      
      if (userWordIndex < userWords.length) {
        final userWord = userWords[userWordIndex];
        final normalizedUserWord = ArabicTextUtils.normalizeWord(userWord);
        final userLetters = _splitIntoLetters(normalizedUserWord);
        
        // Compare letters in this word
        int userLetterIdx = 0;
        for (int letterIdx = 0; letterIdx < correctLetters.length; letterIdx++) {
          final correctLetter = correctLetters[letterIdx];
          
          if (userLetterIdx < userLetters.length) {
            final userLetter = userLetters[userLetterIdx];
            
            if (correctLetter == userLetter) {
              letterComparisons.add(LetterComparison(
                letter: correctLetter,
                status: LetterStatus.correct,
                wordIndex: wordIdx,
                letterIndex: letterIdx,
              ));
              correctCount++;
              userLetterIdx++;
            } else {
              // Check if user letter matches a later letter in correct word (maybe user skipped a letter)
              bool foundMatch = false;
              for (int j = userLetterIdx; j < userLetters.length && j < userLetterIdx + 2; j++) {
                if (userLetters[j] == correctLetter) {
                  // User skipped some letters
                  for (int k = userLetterIdx; k < j; k++) {
                    // Mark skipped letters as wrong
                    letterComparisons.add(LetterComparison(
                      letter: userLetters[k],
                      status: LetterStatus.wrong,
                      wordIndex: wordIdx,
                      letterIndex: letterIdx,
                    ));
                    wrongCount++;
                  }
                  foundMatch = true;
                  userLetterIdx = j + 1;
                  letterComparisons.add(LetterComparison(
                    letter: correctLetter,
                    status: LetterStatus.correct,
                    wordIndex: wordIdx,
                    letterIndex: letterIdx,
                  ));
                  correctCount++;
                  break;
                }
              }
              
              if (!foundMatch) {
                // Letter is wrong
                letterComparisons.add(LetterComparison(
                  letter: correctLetter,
                  status: LetterStatus.wrong,
                  wordIndex: wordIdx,
                  letterIndex: letterIdx,
                ));
                wrongCount++;
                userLetterIdx++; // Advance to next user letter
              }
            }
          } else {
            // User word ended, remaining letters are missing
            letterComparisons.add(LetterComparison(
              letter: correctLetter,
              status: LetterStatus.missing,
              wordIndex: wordIdx,
              letterIndex: letterIdx,
            ));
            missingCount++;
          }
        }
        
        // If user word has more letters, they're extra (we'll ignore for now)
        userWordIndex++;
      } else {
        // User text ended, all remaining letters are missing
        for (int letterIdx = 0; letterIdx < correctLetters.length; letterIdx++) {
          letterComparisons.add(LetterComparison(
            letter: correctLetters[letterIdx],
            status: LetterStatus.missing,
            wordIndex: wordIdx,
            letterIndex: letterIdx,
          ));
          missingCount++;
        }
      }
    }
    
    final accuracy = totalLetters > 0
        ? (correctCount / totalLetters) * 100
        : 0.0;
    
    return LetterLevelDetectionResult(
      letterComparisons: letterComparisons,
      accuracy: accuracy,
      correctCount: correctCount,
      wrongCount: wrongCount,
      missingCount: missingCount,
      totalLetters: totalLetters,
    );
  }
  
  /// Split Arabic word into individual letters
  static List<String> _splitIntoLetters(String word) {
    // Remove spaces and split into characters
    final cleaned = word.replaceAll(' ', '');
    final letters = <String>[];
    
    for (int i = 0; i < cleaned.length; i++) {
      final char = cleaned[i];
      final codeUnit = char.codeUnitAt(0);
      
      // Check if it's an Arabic character (U+0600 to U+06FF)
      if (codeUnit >= 0x0600 && codeUnit <= 0x06FF) {
        letters.add(char);
      } else if (char.trim().isNotEmpty) {
        // Include other non-space characters
        letters.add(char);
      }
    }
    
    return letters;
  }
}

