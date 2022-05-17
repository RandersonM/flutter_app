import 'package:get_it/get_it.dart';
import 'package:simple_app/blocs/movie/movie_bloc.dart';

GetIt sl = GetIt.instance;

void setUpLocators() {
  sl.registerSingleton<MovieSearchBloc>(MovieSearchBloc());
}
