import 'package:get_it/get_it.dart';

import 'blocs/movie/movie_search_bloc.dart';

GetIt sl = GetIt.instance;

void setUpLocators() {
  sl.registerSingleton<MovieSearchBloc>(MovieSearchBloc());
}
