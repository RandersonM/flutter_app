// Developed by Randerson Mayllon
// Copyright © 2022.

part of 'search_characters_bloc.dart';

class SearchCharactersState {
  final bool isLoading;
  final List<Character> characters;
  final List<String> filters;
  final bool hasError;
  final String query;

  const SearchCharactersState(
      {required this.filters,
      required this.isLoading,
      required this.characters,
      required this.hasError,
      required this.query});

  factory SearchCharactersState.initial() {
    return const SearchCharactersState(
        characters: [],
        isLoading: false,
        hasError: false,
        filters: [],
        query: '');
  }

  factory SearchCharactersState.loading() {
    return const SearchCharactersState(
        characters: [],
        filters: [],
        isLoading: true,
        hasError: false,
        query: '');
  }

  factory SearchCharactersState.success(
      List<Character> characters, List<String>? filter) {
    return SearchCharactersState(
        characters: characters,
        filters: filter ?? [],
        isLoading: false,
        hasError: false,
        query: '');
  }

  factory SearchCharactersState.empty(String query) {
    return SearchCharactersState(
        characters: [],
        filters: [],
        isLoading: false,
        hasError: false,
        query: query);
  }

  factory SearchCharactersState.error() {
    return const SearchCharactersState(
        characters: [],
        filters: [],
        isLoading: false,
        hasError: true,
        query: '');
  }

  @override
  String toString() =>
      'CitySearchState {cities: ${characters.toString()}, isLoading: $isLoading, hasError: $hasError }';
}
