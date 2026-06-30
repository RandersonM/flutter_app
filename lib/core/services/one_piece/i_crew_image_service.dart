abstract class ICrewImageService {
  void clearCache();

  Future<String?> generateJollyRogerImage({
    required String crewName,
    required String prompt,
    List<String>? tags,
    String? description,
  });

  Future<String?> generateBoatImage({
    required String crewName,
    required String prompt,
    List<String>? tags,
    String? description,
  });
}
