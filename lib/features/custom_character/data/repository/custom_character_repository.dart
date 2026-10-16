import 'package:flutter/material.dart';
import 'package:opfan/core/errors/app_exceptions.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/features/custom_character/data/repository/i_custom_character_repository.dart';
import 'package:opfan/features/crews/data/repository/i_crew_repository.dart';

class CustomCharacterRepository implements ICustomCharacterRepository {
  final ICrewRepository _crewRepository;

  CustomCharacterRepository(
    this._crewRepository, {
    required this._firestoreService,
  });

  final IFirestoreService _firestoreService;
  static const String _collection = 'custom_characters';

  @override
  Future<String> createCustomCharacter(CustomCharacterModel character) async {
    try {
      final data = character.toFirestoreWithEnglishKeys();
      final documentId = await _firestoreService.createUserDocument(
        collection: _collection,
        data: data,
      );
      return documentId;
    } catch (e) {
      debugPrint('CustomCharacterRepository: create failed: $e');
      rethrow;
    }
  }

  @override
  Future<CustomCharacterModel?> getCustomCharacter(String documentId) async {
    try {
      final data = await _firestoreService.getDocument(
        collection: _collection,
        documentId: documentId,
      );

      if (data != null) {
        return CustomCharacterModel.fromFirestore(data, documentId);
      }
      return null;
    } catch (e) {
      debugPrint('CustomCharacterRepository: get failed: $e');
      rethrow;
    }
  }

  @override
  Future<List<CustomCharacterModel>> getUserCustomCharacters({
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

      var characters = documents
          .map(
            (doc) =>
                CustomCharacterModel.fromFirestore(doc, doc['id'] as String),
          )
          .toList();

      if (orderBy != null) {
        characters.sort((a, b) {
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
            case 'bounty':
              comparison = a.bountyValue.compareTo(b.bountyValue);
              break;
            default:
              comparison = 0;
          }
          return descending ? -comparison : comparison;
        });
      }

      return characters;
    } catch (e) {
      debugPrint('CustomCharacterRepository: getUserCharacters failed: $e');
      rethrow;
    }
  }

  @override
  Future<List<CustomCharacterModel>> getAllCustomCharacters({
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      final documents = await _firestoreService.getDocuments(
        collection: _collection,
        orderBy: orderBy,
        descending: descending,
        limit: limit,
      );

      var characters = documents
          .map(
            (doc) =>
                CustomCharacterModel.fromFirestore(doc, doc['id'] as String),
          )
          .toList();

      if (orderBy != null) {
        characters.sort((a, b) {
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
            case 'bounty':
              comparison = a.bountyValue.compareTo(b.bountyValue);
              break;
            default:
              comparison = 0;
          }
          return descending ? -comparison : comparison;
        });
      }

      return characters;
    } catch (e) {
      debugPrint('CustomCharacterRepository: getAll failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCustomCharacter(
    String documentId,
    CustomCharacterModel character,
  ) async {
    try {
      final data = character.toFirestoreWithEnglishKeys();
      await _firestoreService.updateUserDocument(
        collection: _collection,
        documentId: documentId,
        data: data,
      );
    } catch (e) {
      debugPrint('CustomCharacterRepository: update failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCustomCharacter(String documentId) async {
    try {
      final character = await getCustomCharacter(documentId);
      if (character == null) {
        throw NotFoundException('custom character $documentId');
      }

      final crewsWithCharacter = await _crewRepository.getCrewsByMember(
        documentId,
      );

      for (final crew in crewsWithCharacter) {
        if (crew.id != null) {
          try {
            final member = crew.members.firstWhere(
              (member) => member.characterId == documentId,
              orElse: () => throw NotFoundException(
                'member $documentId in crew ${crew.id}',
              ),
            );

            await _crewRepository.removeMemberFromCrew(crew.id!, documentId);

            if (member.role?.toLowerCase() == 'captain' &&
                crew.captain == member.name) {
              await _crewRepository.setCaptain(crew.id!, '');
            } else if ((member.role?.toLowerCase() == 'vice-captain' ||
                    member.role?.toLowerCase() == 'vicecaptain') &&
                crew.viceCaptain == member.name) {
              await _crewRepository.setViceCaptain(crew.id!, '');
            }
          } catch (e) {
            debugPrint(
              'CustomCharacterRepository: crew ${crew.id} cleanup failed: $e',
            );
          }
        }
      }

      await _firestoreService.deleteDocument(
        collection: _collection,
        documentId: documentId,
      );
    } catch (e) {
      debugPrint('CustomCharacterRepository: delete failed: $e');
      rethrow;
    }
  }

  @override
  Future<List<CustomCharacterModel>> searchCustomCharacters({
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

      var characters = documents
          .map(
            (doc) =>
                CustomCharacterModel.fromFirestore(doc, doc['id'] as String),
          )
          .toList();

      if (orderBy != null) {
        characters.sort((a, b) {
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
            case 'bounty':
              comparison = a.bountyValue.compareTo(b.bountyValue);
              break;
            default:
              comparison = 0;
          }
          return descending ? -comparison : comparison;
        });
      }

      return characters;
    } catch (e) {
      debugPrint('CustomCharacterRepository: search failed: $e');
      rethrow;
    }
  }

  @override
  Stream<List<CustomCharacterModel>> streamUserCustomCharacters({
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
          var characters = documents
              .map(
                (doc) => CustomCharacterModel.fromFirestore(
                  doc,
                  doc['id'] as String,
                ),
              )
              .toList();

          // Ordenação local como fallback
          if (orderBy != null) {
            characters.sort((a, b) {
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
                case 'bounty':
                  comparison = a.bountyValue.compareTo(b.bountyValue);
                  break;
                default:
                  comparison = 0;
              }
              return descending ? -comparison : comparison;
            });
          }

          return characters;
        });
  }

  @override
  Future<List<CustomCharacterModel>> searchCustomCharactersByName(
    String name,
  ) async {
    try {
      final allCharacters = await getUserCustomCharacters();
      return allCharacters
          .where(
            (character) =>
                character.name.toLowerCase().contains(name.toLowerCase()) ||
                (character.nickname?.toLowerCase().contains(
                      name.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    } catch (e) {
      debugPrint('CustomCharacterRepository: searchByName failed: $e');
      rethrow;
    }
  }

  @override
  Future<List<CustomCharacterModel>> getCustomCharactersByDevilFruit(
    String devilFruit,
  ) async {
    return searchCustomCharacters(field: 'devilFruit', value: devilFruit);
  }

  @override
  Future<List<CustomCharacterModel>> getCustomCharactersByCrew(
    String crew,
  ) async {
    return searchCustomCharacters(field: 'crew', value: crew);
  }

  @override
  Future<List<CustomCharacterModel>> getCustomCharactersByStatus(
    String status,
  ) async {
    return searchCustomCharacters(field: 'status', value: status);
  }

  @override
  Future<List<CustomCharacterModel>> getCustomCharactersBySigno(
    String signo,
  ) async {
    return searchCustomCharacters(field: 'signo', value: signo);
  }

  @override
  Future<List<CustomCharacterModel>> getCustomCharactersWithHaki() async {
    try {
      final allCharacters = await getUserCustomCharacters();
      return allCharacters
          .where(
            (character) => character.haki != null && character.haki!.isNotEmpty,
          )
          .toList();
    } catch (e) {
      debugPrint('CustomCharacterRepository: getWithHaki failed: $e');
      rethrow;
    }
  }

  @override
  Future<List<CustomCharacterModel>> getCustomCharactersByBountyRange({
    required String minBounty,
    required String maxBounty,
  }) async {
    try {
      final min = CustomCharacterModel.parseBounty(minBounty);
      final max = CustomCharacterModel.parseBounty(maxBounty);
      final allCharacters = await getUserCustomCharacters();
      return allCharacters
          .where((c) => c.bountyValue >= min && c.bountyValue <= max)
          .toList();
    } catch (e) {
      debugPrint('CustomCharacterRepository: getByBountyRange failed: $e');
      rethrow;
    }
  }
}
