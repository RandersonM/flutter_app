import 'package:flutter/material.dart';

import 'package:simple_app/blocs/movie/movie_search_bloc.dart';
import 'package:simple_app/service_locator.dart';
import 'package:simple_app/shared/bottom_navigation/bottom_navigation.dart';

import '../../../core/models/movies/search_movie.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/movie_detail.dart';

class MovieSearch extends StatefulWidget {
  const MovieSearch({Key? key}) : super(key: key);

  @override
  _MovieSearchState createState() => _MovieSearchState();
}

class _MovieSearchState extends State<MovieSearch> {
  final _bloc = sl.get<MovieSearchBloc>();
  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:
          const BottomNavigation(BottomNavigationPages.counter),
      appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(150.0 + MediaQuery.of(context).padding.top),
          child: const SearchMovieBar()),
      body: StreamBuilder<SearchMovie>(
        stream: _bloc.movieStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MovieDetail(movie: snapshot.data!);
          } else {
            return const Center(
              child: Text('No Movie yet'),
            );
          }
        },
      ),
    );
  }
}
