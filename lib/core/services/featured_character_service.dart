// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:hive/hive.dart';
import 'package:opfan/core/models/one_piece/featured_character.dart';
import 'package:opfan/core/models/character_model.dart';
import 'package:opfan/core/services/characters_backend_service.dart';

class FeaturedCharacterService {
  static const String _boxName = 'featured_characters';
  static const String _currentCharacterKey = 'current_character';

  late Box<FeaturedCharacter> _box;
  final CharactersBackendService _charactersService;

  FeaturedCharacterService(
      {required CharactersBackendService charactersService})
      : _charactersService = charactersService;

  Future<void> init() async {
    _box = await Hive.openBox<FeaturedCharacter>(_boxName);
  
  }

  Future<CharacterModel> getTodaysFeaturedCharacter() async {
    final today = _getTodayString();
    final currentCharacter = _box.get(_currentCharacterKey);

    if (currentCharacter != null && currentCharacter.isToday) {
      return currentCharacter.toCharacter();
    }

    final newCharacter = await _charactersService.fetchRandomCharacter();

    await _saveFeaturedCharacter(newCharacter, today, false);

    return newCharacter;
  }

  Future<CharacterModel> getRandomCharacter() async {
    final character = await _charactersService.fetchRandomCharacter();

    await _saveFeaturedCharacter(character, _getTodayString(), true);

    return character;
  }

  Future<void> saveSelectedCharacter(CharacterModel character) async {
    await _saveFeaturedCharacter(character, _getTodayString(), true);
  }

  Future<void> _saveFeaturedCharacter(
      CharacterModel character, String date, bool isManuallySelected) async {
    final featuredCharacter = FeaturedCharacter.fromCharacter(
      character,
      date,
      isManuallySelected: isManuallySelected,
    );

    await _box.put(_currentCharacterKey, featuredCharacter);
  }

  String _getTodayString() {
    final today = DateTime.now();
    return '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  }

  Future<void> clearCache() async {
    await _box.clear();
  }

  Future<void> clearTodaysCharacter() async {
    await _box.delete(_currentCharacterKey);
  }

  FeaturedCharacter? get currentCharacter => _box.get(_currentCharacterKey);

  bool get hasCharacterForToday {
    final current = currentCharacter;
    return current != null && current.isToday;
  }

  Map<String, dynamic> getServiceStatus() {
    final current = currentCharacter;
    return {
      'hasCharacterForToday': hasCharacterForToday,
      'currentCharacter': current?.characterName,
      'currentDate': current?.date,
      'isManuallySelected': current?.isManuallySelected ?? false,
      'cachedCharacters': _box.length,
    };
  }

  Future<void> cleanOldCharacters() async {
    final today = DateTime.now();
    final cutoffDate = today.subtract(const Duration(days: 7));

    final keysToDelete = <String>[];

    for (final key in _box.keys) {
      if (key == _currentCharacterKey) continue;

      final character = _box.get(key);
      if (character != null) {
        final characterDate = DateTime.tryParse(character.date);
        if (characterDate != null && characterDate.isBefore(cutoffDate)) {
          keysToDelete.add(key.toString());
        }
      }
    }

    for (final key in keysToDelete) {
      await _box.delete(key);
    }

  }
}
