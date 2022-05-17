// Developed by Randerson Mayllon
// Copyright © 2022.

part of 'movie_bloc.dart';

abstract class MovieSearchEvent extends Equatable {
  final String query;

  const MovieSearchEvent({required this.query});

  @override
  List<Object> get props => [query];
}

class GetMovieSearchList extends MovieSearchEvent {
  const GetMovieSearchList({required String query}) : super(query: query);
}
