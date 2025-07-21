import 'package:opfan/core/models/one_piece/today_character.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart';

abstract class IFeaturedCharacterRepository {
  Future<String> createFeaturedCharacter(TodayCharacter character);
  
  Future<TodayCharacter?> getFeaturedCharacter(String documentId);
  
  Future<CustomCharacterModel?> getTodaysFeaturedCharacter();
  
  Future<CustomCharacterModel> getRandomCharacter();
  
  Future<void> saveSelectedCharacter(CustomCharacterModel character);

  
  Future<void> updateFeaturedCharacter(String documentId, TodayCharacter character);
  
  Future<void> deleteFeaturedCharacter(String documentId);
  
  Future<List<TodayCharacter>> searchFeaturedCharacters({
    required String field,
    required dynamic value,
    String? orderBy,
    bool descending = false,
    int? limit,
  });
  
  Stream<List<TodayCharacter>> streamUserFeaturedCharacters({
    String? orderBy,
    bool descending = false,
    int? limit,
  });
  
  Future<TodayCharacter?> getCurrentCharacter();
  
  bool hasCharacterForToday();
  
  Future<void> clearCache();
  
  Future<void> clearTodaysCharacter();
  
  
  Map<String, dynamic> getServiceStatus();
} 