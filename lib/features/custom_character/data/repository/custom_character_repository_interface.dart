import 'package:opfan/core/models/one_piece/custom_character_model.dart';

abstract class ICustomCharacterRepository {
  Future<String> createCustomCharacter(CustomCharacterModel character);
  Future<CustomCharacterModel?> getCustomCharacter(String documentId);
  
  Future<List<CustomCharacterModel>> getUserCustomCharacters({
    String? orderBy,
    bool descending = false,
    int? limit,
  });
  
  Future<List<CustomCharacterModel>> getAllCustomCharacters({
    String? orderBy,
    bool descending = false,
    int? limit,
  });
  
  Future<void> updateCustomCharacter(String documentId, CustomCharacterModel character);
  
  Future<void> deleteCustomCharacter(String documentId);
  
  Future<List<CustomCharacterModel>> searchCustomCharacters({
    required String field,
    required dynamic value,
    String? orderBy,
    bool descending = false,
    int? limit,
  });
  
  Stream<List<CustomCharacterModel>> streamUserCustomCharacters({
    String? orderBy,
    bool descending = false,
    int? limit,
  });
  
  Future<List<CustomCharacterModel>> searchCustomCharactersByName(String name);

  Future<List<CustomCharacterModel>> getCustomCharactersByDevilFruit(String devilFruit);
  
  Future<List<CustomCharacterModel>> getCustomCharactersByCrew(String crew);
  
  Future<List<CustomCharacterModel>> getCustomCharactersByStatus(String status);
  
  Future<List<CustomCharacterModel>> getCustomCharactersBySigno(String signo);
  
  Future<List<CustomCharacterModel>> getCustomCharactersWithHaki();
  
  Future<List<CustomCharacterModel>> getCustomCharactersByBountyRange({
    required String minBounty,
    required String maxBounty,
  });
} 