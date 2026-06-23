// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';

import 'package:opfan/shared/utils/constants.dart';

class DetailsBounty extends StatelessWidget {
  const DetailsBounty({Key? key, required this.bounty}) : super(key: key);

  final String bounty;
  @override
  Widget build(BuildContext context) => Card(
        borderOnForeground: true,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(Constants.margin * 2)),
        margin: const EdgeInsets.all(Constants.margin * 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              spacing: Constants.margin / 2,
              children: [
                const SizedBox.shrink(),
                Icon(
                  Icons.monetization_on,
                  size: 28,
                  color: Colors.amber[700],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: Constants.margin * 2),
                  child: Text(
                    AppLocalizations.of(context)!.bounty,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: Constants.margin),
              child: Text(
                '฿${Constants.formatBounty(bounty)}',
                style: Theme.of(context).textTheme.headlineSmall
              ),
            )
          ],
        ),
      );
}
