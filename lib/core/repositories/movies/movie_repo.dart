import 'package:simple_app/core/repositories/movies/request_status.dart';

import '../../models/movies/search_movie.dart';

class MovieRepo {
  final movieApi = Http();

  Future<SearchMovie> findMovieByName(name) => movieApi.findMovie(name);
}
