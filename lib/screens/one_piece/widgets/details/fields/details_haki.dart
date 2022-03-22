// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simple_app/screens/one_piece/widgets/details/commons/details_list_tile.dart';
import 'package:simple_app/screens/one_piece/widgets/details/commons/expansion_tile_title.dart';

import 'package:simple_app/shared/constants.dart';
import 'package:simple_app/shared/scroll/dynamic_scroll.dart';

class DetailsHaki extends StatelessWidget {
  DetailsHaki({Key? key, required this.haki}) : super(key: key);

  final List<String>? haki;
  final GlobalKey expansionTileKey = GlobalKey();

  @override
  Widget build(BuildContext context) => haki == null
      ? Container()
      : Card(
          margin: const EdgeInsets.symmetric(
              vertical: Constants.margin, horizontal: Constants.margin * 2),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: expansionTileKey,
              onExpansionChanged: (value) {
                if (value) {
                  DynamicScroll().scrollToSelectedContent(
                      expansionTileKey: expansionTileKey);
                }
              },
              tilePadding: EdgeInsets.zero,
              title: ExpansionTileTitle(
                title: haki!.first,
                leading: AppLocalizations.of(context)!.haki,
              ),
              children: haki!
                  .map((String hakiType) => DetailsListTile(tileText: hakiType))
                  .toList(),
            ),
          ),
        );
}
