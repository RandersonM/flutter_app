import 'image_prompt_styles.dart';

/// Builds the Gemini image-generation prompts for a crew's jolly roger flag
/// and ship (see `CrewImageService`).
class CrewImagePrompt {
  const CrewImagePrompt._();

  static String jollyRoger({
    required String crewName,
    required String prompt,
    List<String>? tags,
    String? description,
  }) {
    final basePrompt = prompt.isNotEmpty ? prompt : 'pirate flag';
    final parts = _sharedParts(basePrompt, crewName, description, tags);

    parts.addAll([
      ImagePromptStyles.onePieceStyle,
      'pirate flag design',
      'jolly roger',
      'detailed flag design',
      ...ImagePromptStyles.common,
      'symbolic design',
      'flag waving',
      ImagePromptStyles.animeStyle,
    ]);

    return parts.join(', ');
  }

  static String boat({
    required String crewName,
    required String prompt,
    List<String>? tags,
    String? description,
  }) {
    final basePrompt = prompt.isNotEmpty ? prompt : 'pirate ship';
    final parts = _sharedParts(basePrompt, crewName, description, tags);

    parts.addAll([
      ImagePromptStyles.onePieceStyle,
      'pirate ship',
      'sailing vessel',
      'detailed ship design',
      ...ImagePromptStyles.common,
      'ocean background',
      'sails',
      'wooden ship',
      ImagePromptStyles.animeStyle,
      'adventure ship',
    ]);

    return parts.join(', ');
  }

  static List<String> _sharedParts(
    String basePrompt,
    String crewName,
    String? description,
    List<String>? tags,
  ) {
    final parts = <String>[basePrompt, 'crew name: $crewName'];

    if (description != null && description.isNotEmpty) {
      parts.add('description: $description');
    }

    if (tags != null && tags.isNotEmpty) {
      parts.add('tags: ${tags.join(', ')}');
    }

    return parts;
  }
}
