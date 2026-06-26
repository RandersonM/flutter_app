// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/features/one_piece/bloc/search_cubit.dart';
import 'package:opfan/features/one_piece/presentation/widgets/search/unexistent_search.dart';
import 'package:opfan/features/one_piece/presentation/widgets/search/result_card.dart';
import 'package:opfan/features/one_piece/presentation/widgets/search/search_header.dart';

import 'package:opfan/shared/utils/constants.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<SearchCubit, SearchState>(
          builder: (BuildContext context, SearchState state) {
        String query = '';
        List<CustomCharacterModel> queryResults = [];

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
                  .map((CustomCharacterModel character) => Padding(
                        padding: const EdgeInsets.all(Constants.margin),
                        child: ResultCard(
                          character: character,
                        ),
                      ))
                  
            else
              UnexistentSearch(query: query),
          ],
        );
      });
}
