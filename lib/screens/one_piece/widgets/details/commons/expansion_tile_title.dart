// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

import 'package:simple_app/utils/constants.dart';

class ExpansionTileTitle extends StatelessWidget {
  const ExpansionTileTitle(
      {Key? key, required this.title, required this.leading})
      : super(key: key);

  final String title;
  final String leading;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Constants.margin),
            child: Text(
              leading,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          )
        ],
      );
}
