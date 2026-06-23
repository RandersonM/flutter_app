// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';

import 'package:opfan/features/one_piece/presentation/widgets/details/commons/details_list_tile.dart';
import 'package:opfan/features/one_piece/presentation/widgets/details/commons/expansion_tile_title.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/widgets/atoms/dynamic_scroll.dart';

class DetailsAffiliation extends StatelessWidget {
  DetailsAffiliation({Key? key, required this.affiliations}) : super(key: key);

  final List<String> affiliations;
  final GlobalKey expansionTileKey = GlobalKey();

  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.symmetric(
          vertical: Constants.margin, horizontal: Constants.margin * 2),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: expansionTileKey,
          onExpansionChanged: (isExpanded) {
            DynamicScroll().handleExpansionScroll(
              expansionTileKey: expansionTileKey,
              isExpanded: isExpanded,
            );
          },
          tilePadding: const EdgeInsets.only(right: Constants.margin),
          title: ExpansionTileTitle(
            title: affiliations.first,
            leading:
                AppLocalizations.of(context)!.affiliation(affiliations.length),
          ),
          children: affiliations
              .map((String affiliation) =>
                  DetailsListTile(tileText: affiliation))
              .toList(),
        ),
      ));
}
