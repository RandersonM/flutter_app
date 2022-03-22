// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

import 'package:simple_app/core/one_piece/models/character.dart';
import 'package:simple_app/core/one_piece/services/characters_backend_service.dart';

class SearchProvider extends ChangeNotifier {
  SearchProvider([String initialQuery = '']) {
    backend = CharactersBackendService();

    query = initialQuery;
  }

  @visibleForTesting
  late CharactersBackendService backend;

  List<Character> _queryResults = [];
  late String _query;
  final List<String> _statusFilters = <String>[];

  List<String> get statusFilters => _statusFilters;

  List<Character> get queryResults => _queryResults;

  String get query => _query;

  set query(String query) {
    _query = query;
    filter();
    notifyListeners();
  }

  Future<void> filter() async {
    List<Character> partialResults = await backend.fetchAll();

    if (query.isNotEmpty) partialResults = _applySearch(partialResults);

    partialResults = _applyFilters(partialResults);

    _queryResults = partialResults;
  }

  List<Character> _applyFilters(List<Character> characters) {
    List<Character> result = [];
    if (statusFilters.isNotEmpty) {
      for (Character character in characters) {
        character.affiliations.where((String affiliation) {
          if (statusFilters.contains(affiliation)) {
            result.add(character);
            return true;
          } else {
            return false;
          }
        }).toList();
      }
    }
    return result.isEmpty ? characters : result;
  }

  void addStatusFilter(String status) {
    if (status.isNotEmpty) statusFilters.clear();
    statusFilters.add(status);
    filter();
    notifyListeners();
  }

  void removeStatusFilter(String status) {
    statusFilters.remove(status);
    filter();
    notifyListeners();
  }

  bool _matches(String subject) {
    return subject
        .contains(RegExp(_query, caseSensitive: false, unicode: true));
  }

  List<Character> _applySearch(List<Character> logs) {
    return logs.where((Character character) {
      String characterName = character.name;
      String? characterNickname = character.nickname;

      if (_matches(characterName)) return true;
      if (_matches(characterNickname ?? '')) return true;

      return character.affiliations.any((String affiliation) {
        return _matches(affiliation);
      });
    }).toList();
  }
}
