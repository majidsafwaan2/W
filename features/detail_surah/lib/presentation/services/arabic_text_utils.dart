class ArabicTextUtils {
  // Remove diacritics (harakat) from Arabic text
  static String removeHarakat(String text) {
    const harakat = [
      '\u064B', // Fathatan
      '\u064C', // Dammatan
      '\u064D', // Kasratan
      '\u064E', // Fatha
      '\u064F', // Damma
      '\u0650', // Kasra
      '\u0651', // Shadda
      '\u0652', // Sukun
      '\u0653', // Maddah
      '\u0654', // Hamza Above
      '\u0655', // Hamza Below
      '\u0656', // Subscript Alef
      '\u0657', // Inverted Damma
      '\u0658', // Mark Noon Ghunna
      '\u0659', // Zwarakay
      '\u065A', // Vowel Sign Small V Above
      '\u065B', // Vowel Sign Inverted Small V Above
      '\u065C', // Vowel Sign Dot Below
      '\u065D', // Reversed Damma
      '\u065E', // Fatha With Two Dots
      '\u065F', // Wavy Hamza Below
      '\u0670', // Superscript Alef
    ];
    
    String result = text;
    for (final haraka in harakat) {
      result = result.replaceAll(haraka, '');
    }
    return result;
  }

  // Normalize Alef variations to standard Alef
  static String normalizeAlef(String text) {
    return text
        .replaceAll('\u0622', '\u0627') // Alef with Madda -> Alef
        .replaceAll('\u0623', '\u0627') // Alef with Hamza Above -> Alef
        .replaceAll('\u0625', '\u0627') // Alef with Hamza Below -> Alef
        .replaceAll('\u0671', '\u0627'); // Alef Wasla -> Alef
  }

  // Normalize Taa Marbuta to Haa
  static String normalizeTaaMarbuta(String text) {
    return text.replaceAll('\u0629', '\u0647'); // Taa Marbuta -> Haa
  }

  // Normalize Yaa variations
  static String normalizeYaa(String text) {
    return text.replaceAll('\u0649', '\u064A'); // Alef Maksura -> Yaa
  }

  // Normalize Arabic text completely
  static String normalizeArabic(String text) {
    String normalized = text;
    normalized = removeHarakat(normalized);
    normalized = normalizeAlef(normalized);
    normalized = normalizeTaaMarbuta(normalized);
    normalized = normalizeYaa(normalized);
    // Remove extra spaces
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }

  // Split Arabic text into words
  static List<String> splitIntoWords(String text) {
    // Remove harakat and normalize
    final normalized = normalizeArabic(text);
    // Split by space and filter empty strings
    return normalized.split(' ').where((word) => word.isNotEmpty).toList();
  }

  // Normalize a single word
  static String normalizeWord(String word) {
    return normalizeArabic(word);
  }
}
