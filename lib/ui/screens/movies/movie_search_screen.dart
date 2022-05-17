// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:simple_app/blocs/movie/movie_bloc.dart';
import 'package:simple_app/shared/bottom_navigation/bottom_navigation.dart';
import 'package:simple_app/shared/theme.dart';

import 'widgets/search_movie_bar.dart';
import 'widgets/movie_detail.dart';

class MovieSearchSreen extends StatefulWidget {
  const MovieSearchSreen({Key? key}) : super(key: key);

  @override
  _MovieSearchSreenState createState() => _MovieSearchSreenState();
}

class _MovieSearchSreenState extends State<MovieSearchSreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieSearchBloc(),
      child: Scaffold(
          drawer: null,
          extendBody: true,
          bottomNavigationBar:
              const BottomNavigation(BottomNavigationPages.counter),
          body: CustomScrollView(
            slivers: <Widget>[
              const SearchMovieBar(),
              SliverToBoxAdapter(
                child: BlocBuilder<MovieSearchBloc, MovieSearchState>(
                    builder: (BuildContext context, MovieSearchState state) {
                  if (state is SearchLoadingState) {
                    return const Center(
                      heightFactor: 10,
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (state is SearchMovieHasData) {
                    return Stack(
                        alignment: Alignment.center,
                        fit: StackFit.loose,
                        children: <Widget>[MovieDetail(movie: state.movies)]);
                  } else {
                    return Center(
                      heightFactor: 6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(AppLocalizations.of(context)!.noMoviesFound),
                          Icon(
                            Icons.movie_filter_sharp,
                            color:
                                Theme.of(context).appBarTheme.iconTheme!.color,
                            size: IconSize.big,
                          )
                        ],
                      ),
                    );
                  }
                }),
              )
            ],
          )),
    );
  }
}
