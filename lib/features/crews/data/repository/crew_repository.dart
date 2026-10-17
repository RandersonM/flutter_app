import 'package:flutter/foundation.dart';
import 'package:opfan/core/errors/app_exceptions.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/features/crews/data/repository/i_crew_repository.dart';

class CrewRepository implements ICrewRepository {
  CrewRepository({required this._firestoreService});

  final IFirestoreService _firestoreService;
  static const String _collection = 'crews';

  /// Role keys arrive as `viceCaptain`, `vice-captain` or `vice captain`.
  static String _roleKey(String? role) =>
      (role ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  static bool _isCaptain(String? role) => _roleKey(role) == 'captain';
  static bool _isViceCaptain(String? role) => _roleKey(role) == 'vicecaptain';

  /// Legacy crews can hold a role twice, so a leaving holder hands the title to
  /// the one left instead of blanking it.
  static String _remainingHolder(
    List<CrewMember> members,
    bool Function(CrewMember) holdsRole,
  ) => members.where(holdsRole).firstOrNull?.name ?? '';

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
      debugPrint('CrewRepository: create failed: $e');
      rethrow;
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
      debugPrint('CrewRepository: getCrew failed: $e');
      rethrow;
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
      debugPrint('CrewRepository: getUserCrews failed: $e');
      rethrow;
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
      debugPrint('CrewRepository: getAllCrews failed: $e');
      rethrow;
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
      debugPrint('CrewRepository: update failed: $e');
      rethrow;
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
      debugPrint('CrewRepository: delete failed: $e');
      rethrow;
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
      debugPrint('CrewRepository: search failed: $e');
      rethrow;
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
      debugPrint('CrewRepository: searchByName failed: $e');
      rethrow;
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
      debugPrint('CrewRepository: getByTag failed: $e');
      rethrow;
    }
  }

  @override
  Future<List<CrewModel>> getCrewsWithMembers() async {
    try {
      final allCrews = await getUserCrews();
      return allCrews.where((crew) => crew.members.isNotEmpty).toList();
    } catch (e) {
      debugPrint('CrewRepository: getWithMembers failed: $e');
      rethrow;
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
      debugPrint('CrewRepository: getByMemberCount failed: $e');
      rethrow;
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
      debugPrint('CrewRepository: getByMember failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> addMemberToCrew(String crewId, CrewMember member) async {
    try {
      final crew = await getCrew(crewId);
      if (crew == null) {
        throw NotFoundException('crew $crewId');
      }

      final role = member.role;
      if (role != null && role.isNotEmpty && crew.isRoleFilled(role)) {
        throw CrewRoleTakenException(role);
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
      debugPrint('CrewRepository: addMember failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeMemberFromCrew(String crewId, String characterId) async {
    try {
      final crew = await getCrew(crewId);
      if (crew == null) {
        throw NotFoundException('crew $crewId');
      }

      final removed = crew.members
          .where((member) => member.characterId == characterId)
          .toList();
      final remaining = crew.members
          .where((member) => member.characterId != characterId)
          .toList();
      final freedRoles = removed
          .map((m) => m.role)
          .whereType<String>()
          .where((role) => !remaining.any((m) => m.holdsRole(role)))
          .toSet();

      final updatedCrew = crew.copyWith(
        members: remaining,
        rolesFilled: crew.rolesFilled
            .where((role) => !freedRoles.contains(role))
            .toList(),
        captain: removed.any((m) => m.isCaptain)
            ? _remainingHolder(remaining, (m) => m.isCaptain)
            : crew.captain,
        viceCaptain: removed.any((m) => m.isViceCaptain)
            ? _remainingHolder(remaining, (m) => m.isViceCaptain)
            : crew.viceCaptain,
      );
      await updateCrew(crewId, updatedCrew);
    } catch (e) {
      debugPrint('CrewRepository: removeMember failed: $e');
      rethrow;
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
        throw NotFoundException('crew $crewId');
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
        final others = updatedMembers
            .where((member) => member.characterId != characterId)
            .toList();
        if (!others.any((member) => member.holdsRole(previousRole))) {
          updatedRolesFilled.remove(previousRole);
        }
        if (_isCaptain(previousRole)) {
          updatedCaptain = _remainingHolder(others, (m) => m.isCaptain);
        }
        if (_isViceCaptain(previousRole)) {
          updatedViceCaptain = _remainingHolder(others, (m) => m.isViceCaptain);
        }
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
      debugPrint('CrewRepository: updateMember failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> setCaptain(String crewId, String captainName) async {
    try {
      final crew = await getCrew(crewId);
      if (crew == null) {
        throw NotFoundException('crew $crewId');
      }

      final updatedCrew = crew.copyWith(captain: captainName);
      await updateCrew(crewId, updatedCrew);
    } catch (e) {
      debugPrint('CrewRepository: setCaptain failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> setViceCaptain(String crewId, String viceCaptainName) async {
    try {
      final crew = await getCrew(crewId);
      if (crew == null) {
        throw NotFoundException('crew $crewId');
      }

      final updatedCrew = crew.copyWith(viceCaptain: viceCaptainName);
      await updateCrew(crewId, updatedCrew);
    } catch (e) {
      debugPrint('CrewRepository: setViceCaptain failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> addRoleToCrew(String crewId, String role) async {
    try {
      final crew = await getCrew(crewId);
      if (crew == null) {
        throw NotFoundException('crew $crewId');
      }

      if (!crew.rolesFilled.contains(role)) {
        final updatedRoles = List<String>.from(crew.rolesFilled)..add(role);
        final updatedCrew = crew.copyWith(rolesFilled: updatedRoles);
        await updateCrew(crewId, updatedCrew);
      }
    } catch (e) {
      debugPrint('CrewRepository: addRole failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeRoleFromCrew(String crewId, String role) async {
    try {
      final crew = await getCrew(crewId);
      if (crew == null) {
        throw NotFoundException('crew $crewId');
      }

      final updatedRoles = crew.rolesFilled
          .where((existingRole) => existingRole != role)
          .toList();

      final updatedCrew = crew.copyWith(rolesFilled: updatedRoles);
      await updateCrew(crewId, updatedCrew);
    } catch (e) {
      debugPrint('CrewRepository: removeRole failed: $e');
      rethrow;
    }
  }
}
