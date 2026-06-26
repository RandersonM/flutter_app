abstract class ICharacterImageService {
  void clearCache();

  Future<String?> generateCharacterImage({
    required String characterName,
    required String prompt,
    required String race,
    String? devilFruit,
    List<String>? haki,
    String? status,
    List<String>? occupations,
  });
}
