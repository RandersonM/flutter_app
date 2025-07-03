// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar({Key? key, this.title, this.leading, this.actions})
      : super(key: key);

  final Widget? leading;

  final Widget? title;
  
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.3);

  @override
  Widget build(BuildContext context) => AppBar(
        flexibleSpace: Container(
            decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.onSecondary,
                Colors.white,
              ]),
        )),
        leading: leading,
        title: title,
        actions: actions,
      );
}
