// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:simple_app/l10n/app_localizations.dart';

import 'package:simple_app/shared/constants.dart';

class DetailsName extends StatelessWidget {
  const DetailsName(
      {Key? key, required this.name, this.nickname, this.devilFruit})
      : super(key: key);

  final String name;
  final String? nickname;
  final String? devilFruit;
  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                top: Constants.margin * 2, bottom: Constants.margin),
            child: Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          if (nickname != null)
            Padding(
              padding: const EdgeInsets.only(bottom: Constants.margin / 2),
              child: Text(
                nickname!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          if (devilFruit != null)
            Text(
              "${AppLocalizations.of(context)!.devilFruitUserPrefix} ${devilFruit!}",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      );
}
