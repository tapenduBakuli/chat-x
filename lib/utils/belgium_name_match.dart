/// Pure helpers for matching Belgian place names tolerantly (case, accents,
/// spaces/punctuation, English vs local names). No Flutter/package imports so
/// they can be unit tested on their own.
class BelgiumNameMatch {
  const BelgiumNameMatch._();

  static const Map<String, String> _accents = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
    'ç': 'c',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ñ': 'n',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ý': 'y', 'ÿ': 'y',
  };

  /// Local/alternative names -> one canonical key (already normalized).
  static const Map<String, String> _aliases = {
    'gent': 'ghent',
    'antwerpen': 'antwerp',
    'anvers': 'antwerp',
    'brugge': 'bruges',
    'brussel': 'brussels',
    'bruxelles': 'brussels',
    'luik': 'liege',
    'namen': 'namur',
  };

  /// Lowercase, accents removed, everything but letters/digits dropped.
  static String normalize(String input) {
    final StringBuffer sb = StringBuffer();
    for (final int rune in input.toLowerCase().runes) {
      final String ch = String.fromCharCode(rune);
      final String c = _accents[ch] ?? ch;
      final int code = c.codeUnitAt(0);
      final bool alnum = (code >= 48 && code <= 57) || (code >= 97 && code <= 122);
      if (c.length == 1 && alnum) sb.write(c);
    }
    return sb.toString();
  }

  /// Normalized name with known local/English aliases folded together.
  static String key(String input) {
    final String n = normalize(input);
    return _aliases[n] ?? n;
  }

  /// True when both names denote the same place (empty never matches).
  static bool same(String a, String b) {
    final String ka = key(a);
    return ka.isNotEmpty && ka == key(b);
  }
}
