class ArabicNumerals {
  static const Map<int, String> _arabicNumerals = {
    0: '٠',
    1: '١',
    2: '٢',
    3: '٣',
    4: '٤',
    5: '٥',
    6: '٦',
    7: '٧',
    8: '٨',
    9: '٩',
  };

  static String convert(int number) {
    if (number == 0) return '٠';
    
    String result = '';
    int num = number;
    
    while (num > 0) {
      int digit = num % 10;
      result = _arabicNumerals[digit]! + result;
      num ~/= 10;
    }
    
    return result;
  }
}

