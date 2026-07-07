import 'package:opfan/features/crews/data/models/crew_model.dart';

abstract class ICrewRepository {
  Future<String> createCrew(CrewModel crew);
  Future<CrewModel?> getCrew(String documentId);

  Future<List<CrewModel>> getUserCrews({
    String? orderBy,
    bool descending = false,
    int? limit,
  });

  Future<List<CrewModel>> getAllCrews({
    String? orderBy,
    bool descending = false,
    int? limit,
  });

  Future<void> updateCrew(String documentId, CrewModel crew);

  Future<void> deleteCrew(String documentId);

  Future<List<CrewModel>> searchCrews({
    required String field,
    required dynamic value,
    String? orderBy,
    bool descending = false,
    int? limit,
  });

  Stream<List<CrewModel>> streamUserCrews({
    String? orderBy,
    bool descending = false,
    int? limit,
  });

  Future<List<CrewModel>> searchCrewsByName(String name);

  Future<List<CrewModel>> getCrewsByCaptain(String captainName);

  Future<List<CrewModel>> getCrewsByViceCaptain(String viceCaptainName);

  Future<List<CrewModel>> getCrewsByTag(String tag);

  Future<List<CrewModel>> getCrewsWithMembers();

  Future<List<CrewModel>> getCrewsByMemberCount({
    required int minMembers,
    required int maxMembers,
  });

  Future<List<CrewModel>> getCrewsByMember(String characterId);

  Future<void> addMemberToCrew(String crewId, CrewMember member);

  Future<void> removeMemberFromCrew(String crewId, String characterId);

  Future<void> updateCrewMember(
    String crewId,
    String characterId,
    CrewMember updatedMember,
  );

  Future<void> setCaptain(String crewId, String captainName);

  Future<void> setViceCaptain(String crewId, String viceCaptainName);

  Future<void> addRoleToCrew(String crewId, String role);

  Future<void> removeRoleFromCrew(String crewId, String role);
}
