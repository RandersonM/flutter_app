import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/features/custom_character/data/repository/custom_character_repository_interface.dart';
import 'package:opfan/features/crews/data/repository/crew_repository_interface.dart';

class CustomCharacterRepository implements ICustomCharacterRepository {
  final ICrewRepository _crewRepository;

  CustomCharacterRepository(this._crewRepository);

  final IFirestoreService _firestoreService = FirestoreService();
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
      throw Exception('Erro ao criar personagem customizado: $e');
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
      throw Exception('Erro ao buscar personagem customizado: $e');
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
          .map((doc) =>
              CustomCharacterModel.fromFirestore(doc, doc['id'] as String))
          .toList();

      if (orderBy != null) {
        characters.sort((a, b) {
          int comparison = 0;
          switch (orderBy) {
            case 'createdAt':
              comparison = (a.createdAt ?? DateTime.now())
                  .compareTo(b.createdAt ?? DateTime.now());
              break;
            case 'name':
              comparison = a.name.compareTo(b.name);
              break;
            case 'bounty':
              comparison = a.bounty.compareTo(b.bounty);
              break;
            default:
              comparison = 0;
          }
          return descending ? -comparison : comparison;
        });
      }

      return characters;
    } catch (e) {
      throw Exception('Erro ao buscar personagens customizados do usuário: $e');
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
          .map((doc) =>
              CustomCharacterModel.fromFirestore(doc, doc['id'] as String))
          .toList();

      if (orderBy != null) {
        characters.sort((a, b) {
          int comparison = 0;
          switch (orderBy) {
            case 'createdAt':
              comparison = (a.createdAt ?? DateTime.now())
                  .compareTo(b.createdAt ?? DateTime.now());
              break;
            case 'name':
              comparison = a.name.compareTo(b.name);
              break;
            case 'bounty':
              comparison = a.bounty.compareTo(b.bounty);
              break;
            default:
              comparison = 0;
          }
          return descending ? -comparison : comparison;
        });
      }

      return characters;
    } catch (e) {
      throw Exception('Erro ao buscar todos os personagens customizados: $e');
    }
  }

  @override
  Future<void> updateCustomCharacter(
      String documentId, CustomCharacterModel character) async {
    try {
      final data = character.toFirestoreWithEnglishKeys();
      await _firestoreService.updateUserDocument(
        collection: _collection,
        documentId: documentId,
        data: data,
      );
    } catch (e) {
      throw Exception('Erro ao atualizar personagem customizado: $e');
    }
  }

  @override
  Future<void> deleteCustomCharacter(String documentId) async {
    try {
      final character = await getCustomCharacter(documentId);
      if (character == null) {
        throw Exception('Personagem não encontrado');
      }

      final crewsWithCharacter =
          await _crewRepository.getCrewsByMember(documentId);

      for (final crew in crewsWithCharacter) {
        if (crew.id != null) {
          try {
            final member = crew.members.firstWhere(
              (member) => member.characterId == documentId,
              orElse: () =>
                  throw Exception('Membro não encontrado na tripulação'),
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
                'Erro ao remover personagem da tripulação ${crew.id}: $e');
          }
        }
      }

      await _firestoreService.deleteDocument(
        collection: _collection,
        documentId: documentId,
      );
    } catch (e) {
      throw Exception('Erro ao deletar personagem customizado: $e');
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
          .map((doc) =>
              CustomCharacterModel.fromFirestore(doc, doc['id'] as String))
          .toList();

      if (orderBy != null) {
        characters.sort((a, b) {
          int comparison = 0;
          switch (orderBy) {
            case 'createdAt':
              comparison = (a.createdAt ?? DateTime.now())
                  .compareTo(b.createdAt ?? DateTime.now());
              break;
            case 'name':
              comparison = a.name.compareTo(b.name);
              break;
            case 'bounty':
              comparison = a.bounty.compareTo(b.bounty);
              break;
            default:
              comparison = 0;
          }
          return descending ? -comparison : comparison;
        });
      }

      return characters;
    } catch (e) {
      throw Exception('Erro ao buscar personagens customizados: $e');
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
          .map((doc) =>
              CustomCharacterModel.fromFirestore(doc, doc['id'] as String))
          .toList();

      // Ordenação local como fallback
      if (orderBy != null) {
        characters.sort((a, b) {
          int comparison = 0;
          switch (orderBy) {
            case 'createdAt':
              comparison = (a.createdAt ?? DateTime.now())
                  .compareTo(b.createdAt ?? DateTime.now());
              break;
            case 'name':
              comparison = a.name.compareTo(b.name);
              break;
            case 'bounty':
              comparison = a.bounty.compareTo(b.bounty);
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
      String name) async {
    try {
      final allCharacters = await getUserCustomCharacters();
      return allCharacters
          .where((character) =>
              character.name.toLowerCase().contains(name.toLowerCase()) ||
              (character.nickname?.toLowerCase().contains(name.toLowerCase()) ??
                  false))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar personagens por nome: $e');
    }
  }

  @override
  Future<List<CustomCharacterModel>> getCustomCharactersByDevilFruit(
      String devilFruit) async {
    return searchCustomCharacters(field: 'devilFruit', value: devilFruit);
  }

  @override
  Future<List<CustomCharacterModel>> getCustomCharactersByCrew(
      String crew) async {
    return searchCustomCharacters(field: 'crew', value: crew);
  }

  @override
  Future<List<CustomCharacterModel>> getCustomCharactersByStatus(
      String status) async {
    return searchCustomCharacters(field: 'status', value: status);
  }

  @override
  Future<List<CustomCharacterModel>> getCustomCharactersBySigno(
      String signo) async {
    return searchCustomCharacters(field: 'signo', value: signo);
  }

  @override
  Future<List<CustomCharacterModel>> getCustomCharactersWithHaki() async {
    try {
      final allCharacters = await getUserCustomCharacters();
      return allCharacters
          .where((character) =>
              character.haki != null && character.haki!.isNotEmpty)
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar personagens com haki: $e');
    }
  }

  @override
  Future<List<CustomCharacterModel>> getCustomCharactersByBountyRange({
    required String minBounty,
    required String maxBounty,
  }) async {
    try {
      final allCharacters = await getUserCustomCharacters();
      return allCharacters.where((character) {
        final bounty = character.bounty;
        return bounty.compareTo(minBounty) >= 0 &&
            bounty.compareTo(maxBounty) <= 0;
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar personagens por faixa de recompensa: $e');
    }
  }
}
