import 'package:flutter/material.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.bottom,
  });

  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize {
    const baseHeight = kToolbarHeight * 1.3;
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(baseHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) => AppBar(
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Theme.of(context).colorScheme.onPrimaryContainer,
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceContainer,
          ],
        ),
      ),
    ),
    leading: leading,
    title: title,
    actions: actions,
    bottom: bottom,
  );
}
