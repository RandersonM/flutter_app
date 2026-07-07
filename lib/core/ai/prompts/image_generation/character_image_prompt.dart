import 'image_prompt_styles.dart';

/// Builds the Gemini image-generation prompt for a custom character
/// portrait (see `CharacterImageService`).
class CharacterImagePrompt {
  const CharacterImagePrompt._();

  static String build({
    required String prompt,
    required String race,
    String? status,
    List<String>? occupations,
  }) {
    final basePrompt = prompt.isNotEmpty ? prompt : 'One Piece character';

    final parts = <String>[basePrompt, 'race: $race'];

    if (status != null && status.isNotEmpty) {
      parts.add('status: $status');
    }

    if (occupations != null && occupations.isNotEmpty) {
      parts.add('occupations: ${occupations.join(', ')}');
    }

    parts.addAll([
      ImagePromptStyles.animeStyle,
      ImagePromptStyles.onePieceUniverse,
      'detailed character design',
      ...ImagePromptStyles.common,
    ]);

    return parts.join(', ');
  }
}
