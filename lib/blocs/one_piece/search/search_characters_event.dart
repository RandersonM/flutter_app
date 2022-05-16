// Developed by Randerson Mayllon
// Copyright © 2022.

part of 'search_characters_bloc.dart';

abstract class SearchCharactersEvent {}

class SearchStateInitial extends SearchCharactersEvent {}

class GetSearchResult extends SearchCharactersEvent {
  final String query;
  GetSearchResult(this.query) : super();
}

class GetFilterResult extends SearchCharactersEvent {
  final String filter;
  GetFilterResult(this.filter) : super();
}
