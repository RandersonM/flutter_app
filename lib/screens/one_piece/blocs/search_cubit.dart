// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:opfan/core/one_piece/models/character.dart';
import 'package:opfan/core/services/characters_backend_service.dart';

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
  final List<Character> queryResults;
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

  final CharactersBackendService backend;
  List<Character> _queryResults = [];
  String _query = '';
  final List<String> _statusFilters = <String>[];

  List<String> get statusFilters => List<String>.from(_statusFilters);
  List<Character> get queryResults => List<Character>.from(_queryResults);
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
      List<Character> partialResults = await backend.fetchAll();

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

  List<Character> _applyFilters(List<Character> characters) {
    List<Character> result = [];
    if (_statusFilters.isNotEmpty) {
      for (Character character in characters) {
        character.affiliations.where((String affiliation) {
          if (_statusFilters.contains(affiliation)) {
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
