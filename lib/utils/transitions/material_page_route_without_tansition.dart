// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

///
/// Extends MaterialPageRoute to create e navigation route without transition
/// animation.
///
class MaterialPageRouteWithoutTransition<T> extends MaterialPageRoute<T> {
  MaterialPageRouteWithoutTransition(
      {required Widget Function(BuildContext) builder, RouteSettings? settings})
      : super(
          builder: builder,
          settings: settings,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) =>
      child;
}
