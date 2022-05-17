// Developed by Randerson Mayllon
// Copyright © 2022.

part of 'movie_bloc.dart';

abstract class MovieSearchState extends Equatable {
  const MovieSearchState();

  @override
  List<Object> get props => [];
}

class InitialSearchState extends MovieSearchState {}

class SearchLoadingState extends MovieSearchState {}

class SearchMovieErr extends MovieSearchState {
  final String message;

  const SearchMovieErr(this.message);
}

class SearchMovieHasData extends MovieSearchState {
  final SearchMovie movies;

  const SearchMovieHasData({required this.movies});

  @override
  List<Object> get props => [movies];
}
