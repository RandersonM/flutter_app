// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

import 'package:opfan/shared/utils/constants.dart';

class DetailsName extends StatelessWidget {
  const DetailsName({super.key, required this.name, this.nickname});

  final String name;
  final String? nickname;
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
        ],
      );
}
