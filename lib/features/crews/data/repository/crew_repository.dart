import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/features/crews/data/repository/crew_repository_interface.dart';

class CrewRepository implements ICrewRepository {
  CrewRepository({required this._firestoreService});

  final IFirestoreService _firestoreService;
  static const String _collection = 'crews';

  /// Role keys arrive as `viceCaptain`, `vice-captain` or `vice captain`.
  static String _roleKey(String? role) =>
      (role ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  static bool _isCaptain(String? role) => _roleKey(role) == 'captain';
  static bool _isViceCaptain(String? role) => _roleKey(role) == 'vicecaptain';

  @override
  Future<String> createCrew(CrewModel crew) async {
    try {
      final data = crew.toFirestore();
      final documentId = await _firestoreService.createUserDocument(
        collection: _collection,
        data: data,
      );
      return documentId;
    } catch (e) {
      throw Exception('Erro ao criar tripulação: $e');
    }
  }

  @override
  Future<CrewModel?> getCrew(String documentId) async {
    try {
      final data = await _firestoreService.getDocument(
        collection: _collection,
        documentId: documentId,
      );

      if (data != null) {
        return CrewModel.fromFirestore(data, documentId);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar tripulação: $e');
    }
  }

  @override
  Future<List<CrewModel>> getUserCrews({
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      final documents = await _firestoreService.getUserDocuments(
        collection: _collection,
        orderBy: null, // Remove ordenação temporariamente
        descending: false,
        limit: limit,
      );

      var crews = documents.map((doc) {
        return CrewModel.fromFirestore(doc, doc['id'] as String);
      }).toList();

      if (orderBy != null) {
        crews.sort((a, b) {
          int comparison = 0;
          switch (orderBy) {
            case 'createdAt':
              comparison = (a.createdAt ?? DateTime.now()).compareTo(
                b.createdAt ?? DateTime.now(),
              );
              break;
            case 'name':
              comparison = a.name.compareTo(b.name);
              break;
            case 'members':
              comparison = a.members.length.compareTo(b.members.length);
              break;
            default:
              comparison = 0;
          }
          return descending ? -comparison : comparison;
        });
      }

      return crews;
    } catch (e) {
      throw Exception('Erro ao buscar tripulações do usuário: $e');
    }
  }

  @override
  Future<List<CrewModel>> getAllCrews({
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      final documents = await _firestoreService.getDocuments(
        collection: _collection,
        orderBy: null, // Remove ordenação temporariamente
        descending: false,
        limit: limit,
      );

      var crews = documents.map((doc) {
        return CrewModel.fromFirestore(doc, doc['id'] as String);
      }).toList();

      if (orderBy != null) {
        crews.sort((a, b) {
          int comparison = 0;
          switch (orderBy) {
            case 'createdAt':
              comparison = (a.createdAt ?? DateTime.now()).compareTo(
                b.createdAt ?? DateTime.now(),
              );
              break;
            case 'name':
              comparison = a.name.compareTo(b.name);
              break;
            case 'members':
              comparison = a.members.length.compareTo(b.members.length);
              break;
            default:
              comparison = 0;
          }
          return descending ? -comparison : comparison;
        });
      }

      return crews;
    } catch (e) {
      throw Exception('Erro ao buscar todas as tripulações: $e');
    }
  }

  @override
  Future<void> updateCrew(String documentId, CrewModel crew) async {
    try {
      final data = crew.toFirestore();
      await _firestoreService.updateDocument(
        collection: _collection,
        documentId: documentId,
        data: data,
      );
    } catch (e) {
      throw Exception('Erro ao atualizar tripulação: $e');
    }
  }

  @override
  Future<void> deleteCrew(String documentId) async {
    try {
      await _firestoreService.deleteDocument(
        collection: _collection,
        documentId: documentId,
      );
    } catch (e) {
      throw Exception('Erro ao deletar tripulação: $e');
    }
  }

  @override
  Future<List<CrewModel>> searchCrews({
    required String field,
    required dynamic value,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      final documents = await _firestoreService.queryDocuments(
        collection: _collection,
        field: field,
        value: value,
        orderBy: null, // Remove ordenação temporariamente
        descending: false,
        limit: limit,
      );

      var crews = documents
          .map((doc) => CrewModel.fromFirestore(doc, doc['id'] as String))
          .toList();

      if (orderBy != null) {
        crews.sort((a, b) {
          int comparison = 0;
          switch (orderBy) {
            case 'createdAt':
              comparison = (a.createdAt ?? DateTime.now()).compareTo(
                b.createdAt ?? DateTime.now(),
              );
              break;
            case 'name':
              comparison = a.name.compareTo(b.name);
              break;
            case 'members':
              comparison = a.members.length.compareTo(b.members.length);
              break;
            default:
              comparison = 0;
          }
          return descending ? -comparison : comparison;
        });
      }

      return crews;
    } catch (e) {
      throw Exception('Erro ao buscar tripulações: $e');
    }
  }

  @override
  Stream<List<CrewModel>> streamUserCrews({
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    return _firestoreService
        .streamUserDocuments(
          collection: _collection,
          orderBy: null, // Remove ordenação temporariamente
          descending: false,
          limit: limit,
        )
        .map((documents) {
          var crews = documents
              .map((doc) => CrewModel.fromFirestore(doc, doc['id'] as String))
              .toList();

          if (orderBy != null) {
            crews.sort((a, b) {
              int comparison = 0;
              switch (orderBy) {
                case 'createdAt':
                  comparison = (a.createdAt ?? DateTime.now()).compareTo(
                    b.createdAt ?? DateTime.now(),
                  );
                  break;
                case 'name':
                  comparison = a.name.compareTo(b.name);
                  break;
                case 'members':
                  comparison = a.members.length.compareTo(b.members.length);
                  break;
                default:
                  comparison = 0;
              }
              return descending ? -comparison : comparison;
            });
          }

          return crews;
        });
  }

  @override
  Future<List<CrewModel>> searchCrewsByName(String name) async {
    try {
      final allCrews = await getUserCrews();
      return allCrews
          .where((crew) => crew.name.toLowerCase().contains(name.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar tripulações por nome: $e');
    }
  }

  @override
  Future<List<CrewModel>> getCrewsByCaptain(String captainName) async {
    return searchCrews(field: 'captain', value: captainName);
  }

  @override
  Future<List<CrewModel>> getCrewsByViceCaptain(String viceCaptainName) async {
    return searchCrews(field: 'viceCaptain', value: viceCaptainName);
  }

  @override
  Future<List<CrewModel>> getCrewsByTag(String tag) async {
    try {
      final allCrews = await getUserCrews();
      return allCrews.where((crew) => crew.tags.contains(tag)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar tripulações por tag: $e');
    }
  }

  @override
  Future<List<CrewModel>> getCrewsWithMembers() async {
    try {
      final allCrews = await getUserCrews();
      return allCrews.where((crew) => crew.members.isNotEmpty).toList();
    } catch (e) {
      throw Exception('Erro ao buscar tripulações com membros: $e');
    }
  }

  @override
  Future<List<CrewModel>> getCrewsByMemberCount({
    required int minMembers,
    required int maxMembers,
  }) async {
    try {
      final allCrews = await getUserCrews();
      return allCrews.where((crew) {
        final memberCount = crew.members.length;
        return memberCount >= minMembers && memberCount <= maxMembers;
      }).toList();
    } catch (e) {
      throw Exception(
        'Erro ao buscar tripulações por quantidade de membros: $e',
      );
    }
  }

  @override
  Future<List<CrewModel>> getCrewsByMember(String characterId) async {
    try {
      final allCrews = await getUserCrews();
      return allCrews
          .where(
            (crew) =>
                crew.members.any((member) => member.characterId == characterId),
          )
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar tripulações por membro: $e');
    }
  }

  @override
  Future<void> addMemberToCrew(String crewId, CrewMember member) async {
    try {
      final crew = await getCrew(crewId);
      if (crew == null) {
        throw Exception('Tripulação não encontrada');
      }

      final updatedMembers = List<CrewMember>.from(crew.members)..add(member);

      List<String> updatedRolesFilled = List<String>.from(crew.rolesFilled);
      String? updatedCaptain = crew.captain;
      String? updatedViceCaptain = crew.viceCaptain;

      if (member.role != null && member.role!.isNotEmpty) {
        if (!updatedRolesFilled.contains(member.role)) {
          updatedRolesFilled.add(member.role!);
        }
        if (_isCaptain(member.role)) {
          updatedCaptain = member.name;
        } else if (_isViceCaptain(member.role)) {
          updatedViceCaptain = member.name;
        }
      }

      final updatedCrew = crew.copyWith(
        members: updatedMembers,
        rolesFilled: updatedRolesFilled,
        captain: updatedCaptain,
        viceCaptain: updatedViceCaptain,
      );

      await updateCrew(crewId, updatedCrew);
    } catch (e) {
      throw Exception('Erro ao adicionar membro à tripulação: $e');
    }
  }

  @override
  Future<void> removeMemberFromCrew(String crewId, String characterId) async {
    try {
      final crew = await getCrew(crewId);
      if (crew == null) {
        throw Exception('Tripulação não encontrada');
      }

      final removed = crew.members
          .where((member) => member.characterId == characterId)
          .toList();
      final freedRoles = removed.map((m) => m.role).whereType<String>().toSet();

      final updatedCrew = crew.copyWith(
        members: crew.members
            .where((member) => member.characterId != characterId)
            .toList(),
        rolesFilled: crew.rolesFilled
            .where((role) => !freedRoles.contains(role))
            .toList(),
        captain: removed.any((m) => _isCaptain(m.role)) ? '' : crew.captain,
        viceCaptain: removed.any((m) => _isViceCaptain(m.role))
            ? ''
            : crew.viceCaptain,
      );
      await updateCrew(crewId, updatedCrew);
    } catch (e) {
      throw Exception('Erro ao remover membro da tripulação: $e');
    }
  }

  @override
  Future<void> updateCrewMember(
    String crewId,
    String characterId,
    CrewMember updatedMember,
  ) async {
    try {
      final crew = await getCrew(crewId);
      if (crew == null) {
        throw Exception('Tripulação não encontrada');
      }

      final updatedMembers = crew.members.map((member) {
        if (member.characterId == characterId) {
          return updatedMember;
        }
        return member;
      }).toList();

      List<String> updatedRolesFilled = List<String>.from(crew.rolesFilled);
      String? updatedCaptain = crew.captain;
      String? updatedViceCaptain = crew.viceCaptain;

      final previousRole = crew.members
          .where((member) => member.characterId == characterId)
          .firstOrNull
          ?.role;
      if (previousRole != null && previousRole != updatedMember.role) {
        updatedRolesFilled.remove(previousRole);
        if (_isCaptain(previousRole)) updatedCaptain = '';
        if (_isViceCaptain(previousRole)) updatedViceCaptain = '';
      }

      if (updatedMember.role != null && updatedMember.role!.isNotEmpty) {
        if (!updatedRolesFilled.contains(updatedMember.role)) {
          updatedRolesFilled.add(updatedMember.role!);
        }

        if (_isCaptain(updatedMember.role)) {
          updatedCaptain = updatedMember.name;
        } else if (_isViceCaptain(updatedMember.role)) {
          updatedViceCaptain = updatedMember.name;
        }
      }

      final updatedCrew = crew.copyWith(
        members: updatedMembers,
        rolesFilled: updatedRolesFilled,
        captain: updatedCaptain,
        viceCaptain: updatedViceCaptain,
      );
      await updateCrew(crewId, updatedCrew);
    } catch (e) {
      throw Exception('Erro ao atualizar membro da tripulação: $e');
    }
  }

  @override
  Future<void> setCaptain(String crewId, String captainName) async {
    try {
      final crew = await getCrew(crewId);
      if (crew == null) {
        throw Exception('Tripulação não encontrada');
      }

      final updatedCrew = crew.copyWith(captain: captainName);
      await updateCrew(crewId, updatedCrew);
    } catch (e) {
      throw Exception('Erro ao definir capitão da tripulação: $e');
    }
  }

  @override
  Future<void> setViceCaptain(String crewId, String viceCaptainName) async {
    try {
      final crew = await getCrew(crewId);
      if (crew == null) {
        throw Exception('Tripulação não encontrada');
      }

      final updatedCrew = crew.copyWith(viceCaptain: viceCaptainName);
      await updateCrew(crewId, updatedCrew);
    } catch (e) {
      throw Exception('Erro ao definir vice-capitão da tripulação: $e');
    }
  }

  @override
  Future<void> addRoleToCrew(String crewId, String role) async {
    try {
      final crew = await getCrew(crewId);
      if (crew == null) {
        throw Exception('Tripulação não encontrada');
      }

      if (!crew.rolesFilled.contains(role)) {
        final updatedRoles = List<String>.from(crew.rolesFilled)..add(role);
        final updatedCrew = crew.copyWith(rolesFilled: updatedRoles);
        await updateCrew(crewId, updatedCrew);
      }
    } catch (e) {
      throw Exception('Erro ao adicionar cargo à tripulação: $e');
    }
  }

  @override
  Future<void> removeRoleFromCrew(String crewId, String role) async {
    try {
      final crew = await getCrew(crewId);
      if (crew == null) {
        throw Exception('Tripulação não encontrada');
      }

      final updatedRoles = crew.rolesFilled
          .where((existingRole) => existingRole != role)
          .toList();

      final updatedCrew = crew.copyWith(rolesFilled: updatedRoles);
      await updateCrew(crewId, updatedCrew);
    } catch (e) {
      throw Exception('Erro ao remover cargo da tripulação: $e');
    }
  }
}
