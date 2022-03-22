// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simple_app/core/one_piece/search_provider.dart';

import 'package:simple_app/screens/one_piece/widgets/search/filter/search_filter.dart';
import 'package:simple_app/shared/constants.dart';

class FilterChipList extends StatelessWidget {
  const FilterChipList({Key? key, required this.searchProvider})
      : super(key: key);

  final SearchProvider searchProvider;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          children: <Widget>[
            SearchFilter(
                label: AppLocalizations.of(context)!.superRookie,
                searchProvider: searchProvider),
            SearchFilter(
              label: AppLocalizations.of(context)!.emperors,
              searchProvider: searchProvider,
            ),
            SearchFilter(
              label: AppLocalizations.of(context)!.strawHat,
              searchProvider: searchProvider,
            ),
            SearchFilter(
              label: AppLocalizations.of(context)!.beastsPirates,
              searchProvider: searchProvider,
            ),
            SearchFilter(
              label: AppLocalizations.of(context)!.bigMomPirates,
              searchProvider: searchProvider,
            ),
          ]
              .map((Widget widget) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Constants.margin / 3.5),
                    child: widget,
                  ))
              .toList(),
        ),
      );
}
