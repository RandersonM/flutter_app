// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:simple_app/screens/one_piece/widgets/search/filter/filter_chip_list.dart';
import 'package:simple_app/screens/one_piece/widgets/search/search_input.dart';

import 'package:simple_app/utils/constants.dart';

class SearchHeader extends StatelessWidget {
  const SearchHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSecondary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: Constants.margin * 2),
            child: SearchInput(),
          ),
          const Padding(
            padding: EdgeInsets.only(top: Constants.margin * 3),
            child: FilterChipList(),
          ),
        ],
      ));
}
