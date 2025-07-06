import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/core/services/firestore_service.dart';
import 'package:opfan/core/repository/interfaces/custom_character_repository_interface.dart';

class CustomCharacterRepository implements ICustomCharacterRepository {
  static final CustomCharacterRepository _instance = CustomCharacterRepository._internal();
  factory CustomCharacterRepository() => _instance;
  CustomCharacterRepository._internal();

  final FirestoreService _firestoreService = FirestoreService();
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
          .map((doc) => CustomCharacterModel.fromFirestore(doc, doc['id'] as String))
          .toList();
      
      if (orderBy != null) {
        characters.sort((a, b) {
          int comparison = 0;
          switch (orderBy) {
            case 'createdAt':
              comparison = (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now());
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
  Future<void> updateCustomCharacter(String documentId, CustomCharacterModel character) async {
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
          .map((doc) => CustomCharacterModel.fromFirestore(doc, doc['id'] as String))
          .toList();

      if (orderBy != null) {
        characters.sort((a, b) {
          int comparison = 0;
          switch (orderBy) {
            case 'createdAt':
              comparison = (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now());
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
  
    return _firestoreService.streamUserDocuments(
      collection: _collection,
      orderBy: null, // Remove ordenação temporariamente
      descending: false,
      limit: limit,
    ).map((documents) {
      var characters = documents
          .map((doc) => CustomCharacterModel.fromFirestore(doc, doc['id'] as String))
          .toList();

      // Ordenação local como fallback
      if (orderBy != null) {
        characters.sort((a, b) {
          int comparison = 0;
          switch (orderBy) {
            case 'createdAt':
              comparison = (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now());
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
  Future<List<CustomCharacterModel>> searchCustomCharactersByName(String name) async {
    try {
      final allCharacters = await getUserCustomCharacters();
      return allCharacters
          .where((character) => 
              character.name.toLowerCase().contains(name.toLowerCase()) ||
              (character.nickname?.toLowerCase().contains(name.toLowerCase()) ?? false))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar personagens por nome: $e');
    }
  }

  @override
  Future<List<CustomCharacterModel>> getCustomCharactersByDevilFruit(String devilFruit) async {
    return searchCustomCharacters(field: 'devilFruit', value: devilFruit);
  }

  @override
  Future<List<CustomCharacterModel>> getCustomCharactersByCrew(String crew) async {
    return searchCustomCharacters(field: 'crew', value: crew);
  }

  @override
  Future<List<CustomCharacterModel>> getCustomCharactersByStatus(String status) async {
    return searchCustomCharacters(field: 'status', value: status);
  }

  @override
  Future<List<CustomCharacterModel>> getCustomCharactersBySigno(String signo) async {
    return searchCustomCharacters(field: 'signo', value: signo);
  }

  @override
  Future<List<CustomCharacterModel>> getCustomCharactersWithHaki() async {
    try {
      final allCharacters = await getUserCustomCharacters();
      return allCharacters
          .where((character) => character.haki != null && character.haki!.isNotEmpty)
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
      return allCharacters
          .where((character) {
            final bounty = character.bounty;
            return bounty.compareTo(minBounty) >= 0 && bounty.compareTo(maxBounty) <= 0;
          })
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar personagens por faixa de recompensa: $e');
    }
  }
}

/// Legacy service class for backward compatibility
/// @deprecated Use CustomCharacterRepository instead
class CustomCharacterService {
  static final CustomCharacterService _instance = CustomCharacterService._internal();
  factory CustomCharacterService() => _instance;
  CustomCharacterService._internal();

  final CustomCharacterRepository _repository = CustomCharacterRepository();

  // Delegate all methods to the repository
  Future<String> createCustomCharacter(CustomCharacterModel character) => 
      _repository.createCustomCharacter(character);

  Future<CustomCharacterModel?> getCustomCharacter(String documentId) => 
      _repository.getCustomCharacter(documentId);

  Future<List<CustomCharacterModel>> getUserCustomCharacters({
    String? orderBy,
    bool descending = false,
    int? limit,
  }) => _repository.getUserCustomCharacters(
    orderBy: orderBy,
    descending: descending,
    limit: limit,
  );

  Future<void> updateCustomCharacter(String documentId, CustomCharacterModel character) => 
      _repository.updateCustomCharacter(documentId, character);

  Future<void> deleteCustomCharacter(String documentId) => 
      _repository.deleteCustomCharacter(documentId);

  Future<List<CustomCharacterModel>> searchCustomCharacters({
    required String field,
    required dynamic value,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) => _repository.searchCustomCharacters(
    field: field,
    value: value,
    orderBy: orderBy,
    descending: descending,
    limit: limit,
  );

  Stream<List<CustomCharacterModel>> streamUserCustomCharacters({
    String? orderBy,
    bool descending = false,
    int? limit,
  }) => _repository.streamUserCustomCharacters(
    orderBy: orderBy,
    descending: descending,
    limit: limit,
  );

  Future<List<CustomCharacterModel>> searchCustomCharactersByName(String name) => 
      _repository.searchCustomCharactersByName(name);

  Future<List<CustomCharacterModel>> getCustomCharactersByDevilFruit(String devilFruit) => 
      _repository.getCustomCharactersByDevilFruit(devilFruit);

  Future<List<CustomCharacterModel>> getCustomCharactersByCrew(String crew) => 
      _repository.getCustomCharactersByCrew(crew);

  Future<List<CustomCharacterModel>> getCustomCharactersByStatus(String status) => 
      _repository.getCustomCharactersByStatus(status);

  Future<List<CustomCharacterModel>> getCustomCharactersBySigno(String signo) => 
      _repository.getCustomCharactersBySigno(signo);

  Future<List<CustomCharacterModel>> getCustomCharactersWithHaki() => 
      _repository.getCustomCharactersWithHaki();

  Future<List<CustomCharacterModel>> getCustomCharactersByBountyRange({
    required String minBounty,
    required String maxBounty,
  }) => _repository.getCustomCharactersByBountyRange(
    minBounty: minBounty,
    maxBounty: maxBounty,
  );
} 