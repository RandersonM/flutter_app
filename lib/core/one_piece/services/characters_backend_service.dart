// Developed by Randerson Mayllon
// Copyright © 2022.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:simple_app/core/one_piece/models/character.dart';

class CharactersBackendService {
  int _totalCount = 0;

  Future<List<Character>> fetchAll() async => fetch(totalCount);

  int get totalCount {
    return _totalCount;
  }

  Future<List<Character>> fetch(int page) async {
    try {
      String data = await rootBundle.loadString('assets/bounties.json');
      
      if (_totalCount == 0) {
        _totalCount = jsonDecode(data)['total_count'];
        debugPrint('Backend: Total count loaded - $_totalCount');
      }

      List<Character> fetched = (jsonDecode(data)['characters'] as List)
          .map((data) => Character.fromJson(data))
          .toList();
      
      final result = fetched.sublist(0, page < totalCount ? page : totalCount);
      debugPrint('Backend: Returning ${result.length} characters');

      return result;
    } catch (e) {
      debugPrint('Backend: Error - $e');
      rethrow;
    }
  }
}
