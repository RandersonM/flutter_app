// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/models/one_piece/character.dart';
import 'package:opfan/screens/one_piece/blocs/search_cubit.dart';
import 'package:opfan/screens/one_piece/widgets/search/unexistent_search.dart';
import 'package:opfan/screens/one_piece/widgets/search/result_card.dart';
import 'package:opfan/screens/one_piece/widgets/search/search_header.dart';

import 'package:opfan/utils/constants.dart';

class Search extends StatelessWidget {
  const Search({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<SearchCubit, SearchState>(
          builder: (BuildContext context, SearchState state) {
        String query = '';
        List<Character> queryResults = [];

        if (state is SearchLoaded) {
          query = state.query;
          queryResults = state.queryResults;
        } else if (state is SearchLoading) {
          query = state.query;
        } else if (state is SearchInitial) {
          query = state.query;
        } else if (state is SearchError) {
          query = state.query;
        }

        return ListView(
          children: <Widget>[
            const SearchHeader(),
            if (queryResults.isNotEmpty)
              ...queryResults
                  .map((Character character) => Padding(
                        padding: const EdgeInsets.all(Constants.margin),
                        child: ResultCard(
                          character: character,
                        ),
                      ))
                  .toList()
            else
              UnexistentSearch(query: query),
          ],
        );
      });
}
