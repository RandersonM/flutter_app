// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:simple_app/shared/constants.dart';

class CalculatorHeader extends StatelessWidget {
  const CalculatorHeader({Key? key, required this.result, required this.input})
      : super(key: key);

  final String result;
  final String input;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(Constants.margin),
            child: Text(
              input,
              style: Theme.of(context).textTheme.subtitle1!,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: Constants.margin,
                right: Constants.margin,
                bottom: Constants.margin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(AppLocalizations.of(context)!.result,
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .merge(const TextStyle(fontWeight: FontWeight.bold))),
                Text(
                  result,
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .merge(const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      );
}
