// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

import 'package:simple_app/core/one_piece/models/character.dart';
import 'package:simple_app/core/one_piece/services/characters_backend_service.dart';

enum LoadState {
  initialFetching,
  moreFetching,
  unitialized,
  fetched,
  noMoreData,
  error
}

class CharactersProvider extends ChangeNotifier {
  CharactersProvider() {
    backend = CharactersBackendService();
  }

  @visibleForTesting
  late CharactersBackendService backend;

  List<Character> _characters = [];
  int _pages = 0;

  LoadState _loadState = LoadState.unitialized;

  //Give a copy to avoid anyone changing the original list
  List<Character> get characters => List<Character>.from(_characters);

  set characters(List<Character> newCharacters) {
    _characters = newCharacters;
    notifyListeners();
  }

  bool get hasMoreData => characters.length < backend.totalCount;

  LoadState get loadState => _loadState;

  set loadState(LoadState newState) {
    _loadState = newState;
    notifyListeners();
  }

  bool isLoading() =>
      _loadState == LoadState.initialFetching ||
      _loadState == LoadState.moreFetching;

  fetchData() async {
    if (!isLoading() && hasMoreData) {
      _loadState = (_loadState == LoadState.unitialized)
          ? LoadState.initialFetching
          : LoadState.moreFetching;
    }
    try {
      if (_loadState != LoadState.noMoreData) {
        _pages += 10;

        characters = await backend.fetch(_pages);
        await Future.delayed(const Duration(seconds: 1));

        loadState = hasMoreData ? LoadState.fetched : LoadState.noMoreData;
        notifyListeners();
      }
    } catch (e) {
      _loadState = LoadState.error;
      notifyListeners();
    }
  }
}
