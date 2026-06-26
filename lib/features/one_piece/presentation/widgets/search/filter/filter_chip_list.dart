// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';

import 'package:opfan/features/one_piece/presentation/widgets/search/filter/search_filter.dart';
import 'package:opfan/shared/utils/constants.dart';

class FilterChipList extends StatelessWidget {
  const FilterChipList({super.key});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          children: <Widget>[
            SearchFilter(label: AppLocalizations.of(context)!.superRookie),
            SearchFilter(
              label: AppLocalizations.of(context)!.emperors,
            ),
            SearchFilter(
              label: AppLocalizations.of(context)!.strawHat,
            ),
            SearchFilter(
              label: AppLocalizations.of(context)!.beastsPirates,
            ),
            SearchFilter(
              label: AppLocalizations.of(context)!.bigMomPirates,
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
