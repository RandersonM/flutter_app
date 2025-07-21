// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/core/repository/featured_character_repository.dart';




abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  final String query;
  final List<String> statusFilters;

  const SearchInitial({
    this.query = '',
    this.statusFilters = const [],
  });

  @override
  List<Object?> get props => [query, statusFilters];
}

class SearchLoading extends SearchState {
  final String query;
  final List<String> statusFilters;

  const SearchLoading({
    required this.query,
    required this.statusFilters,
  });

  @override
  List<Object?> get props => [query, statusFilters];
}

class SearchLoaded extends SearchState {
  final String query;
  final List<CustomCharacterModel> queryResults;
  final List<String> statusFilters;

  const SearchLoaded({
    required this.query,
    required this.queryResults,
    required this.statusFilters,
  });

  @override
  List<Object?> get props => [query, queryResults, statusFilters];
}

class SearchError extends SearchState {
  final String message;
  final String query;
  final List<String> statusFilters;

  const SearchError({
    required this.message,
    required this.query,
    required this.statusFilters,
  });

  @override
  List<Object?> get props => [message, query, statusFilters];
}

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this.backend, [String initialQuery = ''])
      : super(SearchInitial(query: initialQuery)) {
    _query = initialQuery;
    if (initialQuery.isNotEmpty) {
      filter();
    }
  }

  final FeaturedCharacterRepository backend;
  List<CustomCharacterModel> _queryResults = [];
  String _query = '';
  final List<String> _statusFilters = <String>[];

  List<String> get statusFilters => List<String>.from(_statusFilters);
  List<CustomCharacterModel> get queryResults =>
      List<CustomCharacterModel>.from(_queryResults);
  String get query => _query;

  Future<void> setQuery(String query) async {
    _query = query;
    await filter();
  }

  Future<void> filter() async {
    emit(SearchLoading(
      query: _query,
      statusFilters: _statusFilters,
    ));

    try {
      List<CustomCharacterModel> partialResults =
          await backend.getAllOnePieceCharacters();

      if (_query.isNotEmpty) {
        partialResults = _applySearch(partialResults);
      }

      partialResults = _applyFilters(partialResults);
      _queryResults = partialResults;

      emit(SearchLoaded(
        query: _query,
        queryResults: _queryResults,
        statusFilters: _statusFilters,
      ));
    } catch (e) {
      emit(SearchError(
        message: e.toString(),
        query: _query,
        statusFilters: _statusFilters,
      ));
    }
  }

  List<CustomCharacterModel> _applyFilters(
      List<CustomCharacterModel> characters) {
    List<CustomCharacterModel> result = [];
    if (_statusFilters.isNotEmpty) {
      for (CustomCharacterModel character in characters) {
        bool matchesFilter = false;

        for (String affiliation in character.affiliations) {
          for (String filter in _statusFilters) {
            if (_isStrawHatFilter(filter) && _isStrawHatCharacter(character)) {
              matchesFilter = true;
              break;
            }
            if (affiliation.trim() == filter.trim()) {
              matchesFilter = true;
              break;
            }
          }
          if (matchesFilter) break;
        }

        if (!matchesFilter &&
            character.crew != null &&
            character.crew!.isNotEmpty) {
          for (String filter in _statusFilters) {
            if (_isStrawHatFilter(filter) && _isStrawHatCharacter(character)) {
              matchesFilter = true;
              break;
            }
            if (character.crew!.trim() == filter.trim()) {
              matchesFilter = true;
              break;
            }
          }
        }

        if (matchesFilter) {
          result.add(character);
        }
      }
    }
    return result.isEmpty ? characters : result;
  }

  bool _isStrawHatFilter(String filter) {
    return filter.toLowerCase().contains('chapéu de palha') ||
        filter.toLowerCase().contains('straw hat');
  }

  bool _isStrawHatCharacter(CustomCharacterModel character) {
    if (character.crew != null &&
        character.crew!.toLowerCase().contains('straw hat pirates')) {
      return true;
    }
    
    for (String affiliation in character.affiliations) {
      if (affiliation.toLowerCase().contains('straw hat pirates')) {
        return true;
      }
    }
    
    return false;
  }

  Future<void> addStatusFilter(String status) async {
    if (status.isNotEmpty) _statusFilters.clear();
    _statusFilters.add(status);
    await filter();
  }

  Future<void> removeStatusFilter(String status) async {
    _statusFilters.remove(status);
    await filter();
  }

  bool _matches(String subject) {
    return subject
        .contains(RegExp(_query, caseSensitive: false, unicode: true));
  }

  List<CustomCharacterModel> _applySearch(List<CustomCharacterModel> logs) {
    return logs.where((CustomCharacterModel character) {
      String characterName = character.name;
      String? characterNickname = character.nickname;

      if (_matches(characterName)) return true;
      if (_matches(characterNickname ?? '')) return true;

      if (character.affiliations.any((String affiliation) {
        return _matches(affiliation);
      })) return true;

      if (character.crew != null && character.crew!.isNotEmpty) {
        if (_matches(character.crew!)) return true;
      }

      return false;
    }).toList();
  }

  void clearQuery() {
    _query = '';
    filter();
  }

  void reset() {
    _query = '';
    _statusFilters.clear();
    _queryResults = [];
    emit(const SearchInitial());
  }
}
