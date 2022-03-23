// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_app/core/one_piece/models/character.dart';
import 'package:simple_app/core/one_piece/search_provider.dart';
import 'package:simple_app/screens/one_piece/widgets/search/unexistent_search.dart';
import 'package:simple_app/screens/one_piece/widgets/search/result_card.dart';
import 'package:simple_app/screens/one_piece/widgets/search/search_header.dart';

import 'package:simple_app/shared/constants.dart';

class Search extends StatelessWidget {
  const Search({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<SearchProvider>(
      builder: (BuildContext context, SearchProvider searchProvider, _) =>
          ListView(
            children: <Widget>[
              SearchHeader(
                searchProvider: searchProvider,
              ),
              if (searchProvider.queryResults.isNotEmpty)
                ...searchProvider.queryResults
                    .map((Character character) => Padding(
                          padding: const EdgeInsets.all(Constants.margin),
                          child: ResultCard(
                            character: character,
                          ),
                        ))
                    .toList()
              else
                UnexistentSearch(query: searchProvider.query),
            ],
          ));
}
