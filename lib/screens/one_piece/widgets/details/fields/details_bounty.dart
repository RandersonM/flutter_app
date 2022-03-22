// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:simple_app/shared/constants.dart';

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
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Constants.margin, vertical: Constants.margin * 2),
              child: Text(
                AppLocalizations.of(context)!.bounty,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Constants.margin),
              child: Text(
                bounty,
                style: Theme.of(context).textTheme.headline6,
              ),
            )
          ],
        ),
      );
}
