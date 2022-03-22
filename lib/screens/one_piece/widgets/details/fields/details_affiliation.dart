// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:simple_app/screens/one_piece/widgets/details/commons/details_list_tile.dart';
import 'package:simple_app/screens/one_piece/widgets/details/commons/expansion_tile_title.dart';
import 'package:simple_app/shared/constants.dart';
import 'package:simple_app/shared/scroll/dynamic_scroll.dart';

class DetailsAffiliation extends StatelessWidget {
  DetailsAffiliation({Key? key, required this.affiliations}) : super(key: key);

  final List<String> affiliations;
  final GlobalKey expansionTileKey = GlobalKey();

  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.symmetric(horizontal: Constants.margin * 2),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: expansionTileKey,
          onExpansionChanged: (value) {
            if (value) {
              DynamicScroll()
                  .scrollToSelectedContent(expansionTileKey: expansionTileKey);
            }
          },
          tilePadding: EdgeInsets.zero,
          title: ExpansionTileTitle(
            title: affiliations.first,
            leading: AppLocalizations.of(context)!.affiliation,
          ),
          children: affiliations
              .map((String affiliation) =>
                  DetailsListTile(tileText: affiliation))
              .toList(),
        ),
      ));
}
