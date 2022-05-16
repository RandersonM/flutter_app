// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

class DetailsListTile extends StatelessWidget {
  final String tileText;

  const DetailsListTile({Key? key, required this.tileText}) : super(key: key);

  @override
  Widget build(BuildContext context) => ListTile(
        dense: true,
        enabled: true,
        title: Text(
          tileText,
          textAlign: TextAlign.right,
          softWrap: true,
          style: Theme.of(context).textTheme.button,
        ),
      );
}
