// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UnexistentSearch extends StatelessWidget {
  const UnexistentSearch({Key? key, required this.query}) : super(key: key);

  final String query;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: MediaQuery.of(context).size.height / 2,
        child: Center(
          child: Text(
              query.isEmpty
                  ? AppLocalizations.of(context)!.noResearchYet
                  : '${AppLocalizations.of(context)!.noResultsFound} "$query".',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText2!),
        ),
      );
}
