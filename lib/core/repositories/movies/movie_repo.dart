// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:simple_app/core/repositories/movies/movie_repo_impl.dart';

import '../../models/movies/search_movie.dart';

class MovieRepo {
  final movieApi = MovieRepoImpl();

  Future<SearchMovie> findMovieByName(String name) => movieApi.findMovie(name);
}
