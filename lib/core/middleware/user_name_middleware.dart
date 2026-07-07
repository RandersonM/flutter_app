// Developed by Randerson Mayllon
// Copyright © 2025.

class UserNameMiddleware {
  static const int _maxWords = 2;
  static const String _specialName = 'Slanny';
  static const String _specialNameReplacement = 'Amor da minha vida, Slanny';

  static String processDisplayName(String displayName) {
    if (displayName.isEmpty) {
      return displayName;
    }

    if (displayName.toLowerCase().contains(_specialName.toLowerCase())) {
      return _specialNameReplacement;
    }

    final words = displayName
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.length > _maxWords) {
      return words.take(_maxWords).join(' ');
    }

    return displayName;
  }

  /// Verifica se o nome foi processado pelo middleware
  static bool isProcessedName(String displayName) {
    return displayName == _specialNameReplacement ||
        displayName.split(' ').length <= _maxWords;
  }

  /// Obtém o nome original (útil para debug ou logs)
  static String getOriginalName(String processedName) {
    if (processedName == _specialNameReplacement) {
      return _specialName;
    }
    return processedName;
  }
}
