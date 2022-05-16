import 'dart:async';

import 'package:simple_app/core/models/movies/search_movie.dart';
import 'package:simple_app/core/repositories/movies/movie_repo.dart';

import '../base_bloc.dart';

class MovieSearchBloc implements BaseBloc {
  final movieRepo = MovieRepo();
  final _movieController = StreamController<SearchMovie>();
  final _queryController = StreamController<String>();

  Stream<SearchMovie> get movieStream => _movieController.stream;
  Function(String) get addQuery => _queryController.sink.add;

  MovieSearchBloc() {
    _queryController.stream.listen(fetchMovie);
  }

  void fetchMovie(String name) async {
    final movie = await movieRepo.findMovieByName(name);
    _movieController.sink.add(movie);
  }

  @override
  Future<void> dispose() async {
    await _movieController.close();

    await _queryController.close();
    print("Disposing MovieSearchBloc");
  }
}
