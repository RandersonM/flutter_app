import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:opfan/core/models/one_piece/today_character.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/core/services/firestore_service.dart';
import 'package:opfan/core/repository/interfaces/featured_character_repository_interface.dart';

class FeaturedCharacterRepository implements IFeaturedCharacterRepository {
  static final FeaturedCharacterRepository _instance = FeaturedCharacterRepository._internal();
  factory FeaturedCharacterRepository() => _instance;
  FeaturedCharacterRepository._internal();

  final FirestoreService _firestoreService = FirestoreService();
  
  static const String _collection = 'featuredCharacters';
  static const String _hiveBoxName = 'featured_character_box';
  static const String _currentCharacterKey = 'current_featured_character';
  
  late Box<TodayCharacter> _box;

  Future<void> _initHive() async {
    try {
      if (!Hive.isBoxOpen(_hiveBoxName)) {
        _box = await Hive.openBox<TodayCharacter>(_hiveBoxName);
      } else {
        _box = Hive.box<TodayCharacter>(_hiveBoxName);
      }
    } catch (e) {
      debugPrint('Hive initialization error, clearing cache: $e');
      if (Hive.isBoxOpen(_hiveBoxName)) {
        await Hive.deleteBoxFromDisk(_hiveBoxName);
      }
      _box = await Hive.openBox<TodayCharacter>(_hiveBoxName);
    }
  }

  @override
  Future<String> createFeaturedCharacter(TodayCharacter character) async {
    try {
      await _initHive();
      await _box.put(_currentCharacterKey, character);
      return 'local_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      throw Exception('Error creating featured character: $e');
    }
  }

  @override
  Future<TodayCharacter?> getFeaturedCharacter(String documentId) async {
    try {
      await _initHive();
      return _box.get(_currentCharacterKey);
    } catch (e) {
      throw Exception('Error getting featured character: $e');
    }
  }

  @override
  Future<CustomCharacterModel?> getTodaysFeaturedCharacter() async {
    try {
      await _initHive();
      final currentCharacter = await getCurrentCharacter();

      if (currentCharacter != null && currentCharacter.isToday) {
        final allCharacters = await getAllOnePieceCharacters();
        final foundCharacter = allCharacters.where((c) => c.id == currentCharacter.characterId).firstOrNull;
        if (foundCharacter != null) {
          return foundCharacter;
        }
      }

      final randomCharacter = await getRandomCharacter();
      final featuredCharacter = TodayCharacter.fromCharacter(
        randomCharacter,
        _getTodayString(),
        isManuallySelected: false,
      );

      await _box.put(_currentCharacterKey, featuredCharacter);
      return randomCharacter;
    } catch (e) {
      throw Exception('Error getting featured character for today: $e');
    }
  }

  @override
  Future<CustomCharacterModel> getRandomCharacter() async {
    try {
      final featuredCharacters = await _getAllFeaturedCharacters();
      
      if (featuredCharacters.isNotEmpty) {
        final random = Random();
        final randomIndex = random.nextInt(featuredCharacters.length);
        return featuredCharacters[randomIndex];
      }

      return _createDefaultCharacter();
    } catch (e) {
      throw Exception('Error getting random character: $e');
    }
  }

  @override
  Future<void> saveSelectedCharacter(CustomCharacterModel character) async {
    try {
      await _initHive();
      final featuredCharacter = TodayCharacter.fromCharacter(
        character,
        _getTodayString(),
        isManuallySelected: true,
      );
      await _box.put(_currentCharacterKey, featuredCharacter);
    } catch (e) {
      throw Exception('Error saving selected character: $e');
    }
  }

  @override
  Future<void> updateFeaturedCharacter(String documentId, TodayCharacter character) async {
    try {
      await _initHive();
      await _box.put(_currentCharacterKey, character);
    } catch (e) {
      throw Exception('Error updating featured character: $e');
    }
  }

  @override
  Future<void> deleteFeaturedCharacter(String documentId) async {
    try {
      await _initHive();
      await _box.delete(_currentCharacterKey);
    } catch (e) {
      throw Exception('Error deleting featured character: $e');
    }
  }

  @override
  Future<List<TodayCharacter>> searchFeaturedCharacters({
    required String field,
    required dynamic value,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      await _initHive();
      final currentCharacter = _box.get(_currentCharacterKey);
      if (currentCharacter != null) {
        return [currentCharacter];
      }
      return [];
    } catch (e) {
      throw Exception('Error searching featured characters: $e');
    }
  }

  @override
  Stream<List<TodayCharacter>> streamUserFeaturedCharacters({
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    return Stream.fromFuture(() async {
      await _initHive();
      final currentCharacter = _box.get(_currentCharacterKey);
      if (currentCharacter != null) {
        return [currentCharacter];
      }
      return <TodayCharacter>[];
    }());
  }

  @override
  Future<TodayCharacter?> getCurrentCharacter() async {
    try {
      await _initHive();
      return _box.get(_currentCharacterKey);
    } catch (e) {
      debugPrint('Error getting current character: $e');
      return null;
    }
  }

  @override
  bool hasCharacterForToday() {
    try {
      if (!Hive.isBoxOpen(_hiveBoxName)) return false;
      final box = Hive.box<TodayCharacter>(_hiveBoxName);
      final character = box.get(_currentCharacterKey);
      return character?.isToday ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _initHive();
      await _box.clear();
    } catch (e) {
      throw Exception('Error clearing cache: $e');
    }
  }

  @override
  Future<void> clearTodaysCharacter() async {
    try {
      await _initHive();
      await _box.delete(_currentCharacterKey);
    } catch (e) {
      throw Exception('Error clearing today\'s character: $e');
    }
  }

  @override
  Map<String, dynamic> getServiceStatus() {
    return {
      'collection': _collection,
      'hiveBox': _hiveBoxName,
      'message': 'FeaturedCharacterRepository using Firestore for global characters and Hive for daily featured',
    };
  }

  Future<List<CustomCharacterModel>> getAllOnePieceCharacters({int? limit}) async {
    try {
      final documents = await _firestoreService.getDocuments(
        collection: _collection,
        limit: limit,
      );
      
      
      return documents
          .map((doc) => CustomCharacterModel.fromFirestore(doc, doc['id'] as String))
          .toList();
    } catch (e) {
      debugPrint('Error getting all One Piece characters: $e');
      return [_createDefaultCharacter()];
    }
  }

  Future<List<CustomCharacterModel>> searchOnePieceCharacters(String query) async {
    try {
      final allCharacters = await getAllOnePieceCharacters();
      return allCharacters
          .where((character) => 
              character.name.toLowerCase().contains(query.toLowerCase()) ||
              (character.nickname?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    } catch (e) {
      debugPrint('Error searching One Piece characters: $e');
      return [];
    }
  }

  Future<List<CustomCharacterModel>> _getAllFeaturedCharacters() async {
    try {
      final documents = await _firestoreService.getDocuments(
        collection: _collection,
        limit: 100,
      );

      return documents
          .map((doc) => CustomCharacterModel.fromFirestore(doc, doc['id'] as String))
          .toList();
    } catch (e) {
      debugPrint('Error getting all featured characters: $e');
      return [];
    }
  }

  String _getTodayString() {
    final today = DateTime.now();
    return '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  }

  CustomCharacterModel _createDefaultCharacter() {
    return CustomCharacterModel(
      name: 'Monkey D. Luffy',
      nickname: 'Straw Hat Luffy',
      image: 'https://static.wikia.nocookie.net/onepiece/images/6/6d/Monkey_D._Luffy_Anime_Post_Timeskip_Infobox.png',
      bounty: '3,000,000,000',
      affiliations: ['Straw Hat Pirates'],
      occupation: ['Pirate Captain'],
      devilFruit: 'Gomu Gomu no Mi',
      haki: ['Observation Haki', 'Armament Haki', 'Conqueror Haki'],
      status: 'Alive',
      age: 19,
    );
  }
}

