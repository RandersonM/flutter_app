// Developed by Randerson Mayllon
// Copyright © 2022.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:simple_app/core/models/one_piece/character.dart';

class CharactersBackendService {
  int _totalCount = 0;

  Future<List<Character>> fetchAll() async => fetch(totalCount);

  int get totalCount => _totalCount;

  Future<List<Character>> fetch(int page) async {
    String data = await rootBundle.loadString('assets/bounties.json');
    if (_totalCount == 0) _totalCount = jsonDecode(data)['total_count'];
    List<Character> fetched = (jsonDecode(data)['characters'] as List)
        .map((data) => Character.fromJson(data))
        .toList();

    return fetched.sublist(0, page < totalCount ? page : totalCount);
  }
}
