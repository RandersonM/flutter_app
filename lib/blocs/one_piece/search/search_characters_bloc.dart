// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:bloc/bloc.dart';
import 'package:simple_app/core/models/one_piece/character.dart';
import 'package:simple_app/core/repositories/one_piece/characters_backend_service.dart';

part 'search_characters_event.dart';
part 'search_characters_state.dart';

class SearchCharactersBloc
    extends Bloc<SearchCharactersEvent, SearchCharactersState> {
  SearchCharactersBloc() : super(SearchCharactersState.initial()) {
    final CharactersBackendService _apiRepository = CharactersBackendService();
    late List<String> _statusFilters = [];
    bool _matches(String subject, String _query) {
      return subject
          .contains(RegExp(_query, caseSensitive: false, unicode: true));
    }

    Future<List<Character>> _applySearch(String query) async {
      List<Character> logs = await _apiRepository.fetchAll();
      return logs.where((Character character) {
        String characterName = character.name;
        String? characterNickname = character.nickname;

        if (_matches(characterName, query)) return true;
        if (_matches(characterNickname ?? '', query)) return true;

        return character.affiliations.any((String affiliation) {
          return _matches(affiliation, query);
        });
      }).toList();
    }

    Future<List<Character>> _getSearchResults(String query) async {
      // Simulating network latency
      await Future.delayed(const Duration(seconds: 1));

      return await _applySearch(query);
    }

    Future<List<Character>> _applyFilters() async {
      List<Character> result = [];
      List<Character> characters = await _apiRepository.fetchAll();

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

    on<GetFilterResult>((event, emit) async {
      try {
        if (event.filter.isEmpty) {
          emit(SearchCharactersState.initial());
        } else {
          emit(SearchCharactersState.loading());
          if (_statusFilters.isNotEmpty) _statusFilters.clear();
          _statusFilters.add(event.filter);

          List<Character> characters = await _applyFilters();
          emit(SearchCharactersState.success(characters, _statusFilters));
        }
      } catch (e) {
        emit(SearchCharactersState.error());
      }
    });

    on<GetSearchResult>((event, emit) async {
      try {
        if (event.query.isEmpty) {
          emit(SearchCharactersState.initial());
        } else {
          emit(SearchCharactersState.loading());

          List<Character> characters = await _getSearchResults(event.query);

          if (characters.isEmpty) {
            emit(SearchCharactersState.empty(event.query));
          } else {
            emit(SearchCharactersState.success(characters, []));
          }
        }
      } catch (e) {
        emit(SearchCharactersState.error());
      }
    });
  }
}
