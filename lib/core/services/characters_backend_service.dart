// Developed by Randerson Mayllon
// Copyright © 2022.

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart';

class CharactersBackendService {
  int _totalCount = 0;

  Future<List<CustomCharacterModel>> fetchAll() async => fetch(totalCount);

  int get totalCount {
    return _totalCount;
  }

  Future<List<CustomCharacterModel>> fetch(int page) async {
    try {
      String data = await rootBundle.loadString('assets/bounties.json');
      
      if (_totalCount == 0) {
        _totalCount = jsonDecode(data)['total_count'];
      }

      List<CustomCharacterModel> fetched =
          (jsonDecode(data)['characters'] as List)
              .map((data) => CustomCharacterModel.fromJson(data))
          .toList();
      
      final result = fetched.sublist(0, page < totalCount ? page : totalCount);

      return result;
    } catch (e) {
      debugPrint('Backend: Error - $e');
      rethrow;
    }
  }

  Future<CustomCharacterModel> fetchRandomCharacter() async {
    try {
      String data = await rootBundle.loadString('assets/bounties.json');

      if (_totalCount == 0) {
        _totalCount = jsonDecode(data)['total_count'];
      }

      List<CustomCharacterModel> characters =
          (jsonDecode(data)['characters'] as List)
              .map((data) => CustomCharacterModel.fromJson(data))
          .toList();

      final random = Random();
      final randomIndex = random.nextInt(characters.length);

      final randomCharacter = characters[randomIndex];

      return randomCharacter;
    } catch (e) {
      debugPrint('Backend: Error fetching random character - $e');
      rethrow;
    }
  }
}
