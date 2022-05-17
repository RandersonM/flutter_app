// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:simple_app/blocs/movie/movie_bloc.dart';
import 'package:simple_app/shared/constants.dart';
import 'package:simple_app/shared/theme.dart';

class SearchMovieBar extends StatelessWidget {
  const SearchMovieBar({Key? key}) : super(key: key);

  double appBarHeight(BuildContext context) =>
      MediaQuery.of(context).size.height / 6 +
      MediaQuery.of(context).padding.top * 1.8;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: Container(),
      expandedHeight: 140,
      centerTitle: true,
      title: Text(AppLocalizations.of(context)!.movieSearchTitle,
          style: Theme.of(context).textTheme.headline6),
      flexibleSpace: Container(
        height: 200,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AppColors.purple[600]!,
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.onSecondary,
                AppColors.purple[100]!,
              ]),
          // color: Theme.of(context).colorScheme.onSecondary,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: const Padding(
            padding: EdgeInsets.only(
                top: Constants.margin * 8,
                bottom: Constants.margin * 2,
                left: Constants.margin * 2,
                right: Constants.margin * 2),
            child: SearchBox()),
      ),
    );
  }
}

class SearchBox extends StatefulWidget {
  const SearchBox({Key? key}) : super(key: key);

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      elevation: 3.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(2.0),
        ),
      ),
      child: TextField(
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: AppLocalizations.of(context)!.movieSearchHintText),
        onSubmitted: (String value) {
          BlocProvider.of<MovieSearchBloc>(context)
              .add(GetMovieSearchList(query: value));
        },
      ),
    );
  }
}
