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

      await updateCrew(crewId, _withMember(crew, member));
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

      await updateCrew(crewId, _withoutMember(crew, characterId));
    } catch (e) {
      debugPrint('CrewRepository: removeMember failed: $e');
      rethrow;
    }
  }

  static CrewModel _withMember(CrewModel crew, CrewMember member) {
    final rolesFilled = List<String>.from(crew.rolesFilled);
    var captain = crew.captain;
    var viceCaptain = crew.viceCaptain;

    final role = member.role;
    if (role != null && role.isNotEmpty) {
      if (!rolesFilled.contains(role)) rolesFilled.add(role);
      if (_isCaptain(role)) {
        captain = member.name;
      } else if (_isViceCaptain(role)) {
        viceCaptain = member.name;
      }
    }

    return crew.copyWith(
      members: [...crew.members, member],
      rolesFilled: rolesFilled,
      captain: captain,
      viceCaptain: viceCaptain,
    );
  }

  static CrewModel _withoutMember(CrewModel crew, String characterId) {
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

    return crew.copyWith(
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
  }

  /// Read from the crews just before the batch, so a role taken since the
  /// form loaded is refused here; nothing is written in that case.
  @override
  Future<void> moveMember(CrewMember member, {String? toCrewId}) async {
    try {
      final characterId = member.characterId;
      final currentCrews = await getCrewsByMember(characterId);
      final updates = <String, CrewModel>{
        for (final crew in currentCrews)
          if (crew.id != null) crew.id!: _withoutMember(crew, characterId),
      };

      if (toCrewId != null) {
        final target = updates[toCrewId] ?? await getCrew(toCrewId);
        if (target == null) throw NotFoundException('crew $toCrewId');
        final role = member.role;
        if (role != null && role.isNotEmpty && target.isRoleFilled(role)) {
          throw CrewRoleTakenException(role);
        }
        updates[toCrewId] = _withMember(target, member);
      }

      await _writeCrews(updates);
    } catch (e) {
      debugPrint('CrewRepository: moveMember failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> syncMemberCopies(
    String characterId, {
    required String name,
    String? nickname,
    required String bounty,
  }) async {
    try {
      final crews = await getCrewsByMember(characterId);
      final updates = <String, CrewModel>{};
      for (final crew in crews) {
        final copy = crew.members.firstWhere(
          (member) => member.characterId == characterId,
        );
        final copyIsCurrent =
            copy.name == name &&
            copy.nickname == nickname &&
            copy.bounty == bounty;
        if (crew.id == null || copyIsCurrent) continue;

        updates[crew.id!] = crew.copyWith(
          members: [
            for (final member in crew.members)
              member.characterId == characterId
                  ? CrewMember(
                      characterId: characterId,
                      name: name,
                      nickname: nickname,
                      role: member.role,
                      bounty: bounty,
                    )
                  : member,
          ],
          captain: copy.isCaptain ? name : crew.captain,
          viceCaptain: copy.isViceCaptain ? name : crew.viceCaptain,
        );
      }

      await _writeCrews(updates);
    } catch (e) {
      debugPrint('CrewRepository: syncMemberCopies failed: $e');
      rethrow;
    }
  }

  /// One batch, so a membership change never leaves a character in two
  /// crews or in none.
  Future<void> _writeCrews(Map<String, CrewModel> crews) async {
    if (crews.isEmpty) return;
    await _firestoreService.updateDocumentsInBatch(
      collection: _collection,
      updates: {
        for (final MapEntry(key: id, value: crew) in crews.entries)
          id: crew.toFirestore(),
      },
    );
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

      final role = updatedMember.role;
      final heldByAnother = crew.members.any(
        (member) =>
            member.characterId != characterId &&
            role != null &&
            member.holdsRole(role),
      );
      if (heldByAnother) throw CrewRoleTakenException(role!);

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
