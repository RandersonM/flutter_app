// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_app/blocs/one_piece/search/search_characters_bloc.dart';
import 'package:simple_app/core/models/one_piece/character.dart';

import 'package:simple_app/shared/constants.dart';

import 'result_card.dart';
import 'search_header.dart';
import 'unexistent_search.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final SearchCharactersBloc _searchBloc = SearchCharactersBloc();
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => _searchBloc,
        child: Column(
          children: <Widget>[
            const SearchHeader(),
            BlocBuilder<SearchCharactersBloc, SearchCharactersState>(
              builder: (BuildContext context, SearchCharactersState state) {
                if (state.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!state.isLoading && !state.hasError) {
                  if (state.characters.isEmpty) {
                    return UnexistentSearch(query: state.query);
                  } else {
                    return Expanded(
                      child: ListView(
                        children: <Widget>[
                          ...state.characters
                              .map((Character character) => Padding(
                                    padding:
                                        const EdgeInsets.all(Constants.margin),
                                    child: ResultCard(
                                      character: character,
                                    ),
                                  ))
                              .toList()
                        ],
                      ),
                    );
                  }
                } else {
                  return UnexistentSearch(query: state.hasError.toString());
                }
              },
            ),
          ],
        ),
      );
}
