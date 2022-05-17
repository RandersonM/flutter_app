// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:simple_app/core/models/movies/search_movie.dart';
import 'package:simple_app/core/repositories/movies/movie_repo.dart';

part 'movie_event.dart';
part 'movie_state.dart';

class MovieSearchBloc extends Bloc<MovieSearchEvent, MovieSearchState> {
  final movieRepo = MovieRepo();
  MovieSearchBloc() : super(InitialSearchState()) {
    on<MovieSearchEvent>(_searchMovie);
  }

  void _searchMovie(
      MovieSearchEvent event, Emitter<MovieSearchState> emit) async {
    emit(SearchLoadingState());
    try {
      SearchMovie movies = await movieRepo.findMovieByName(event.query);
      emit(SearchMovieHasData(movies: movies));
    } catch (e) {
      emit(SearchMovieErr(e.toString()));
    }
  }
}
