// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

class MaterialPageRouteWithSlideRightTransition
    extends MaterialPageRoute<dynamic> {
  MaterialPageRouteWithSlideRightTransition(
      {required Widget Function(BuildContext) builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    Offset begin = const Offset(1.0, 0);
    Offset end = Offset.zero;
    Cubic curve = Curves.easeIn;
    Animatable<Offset> tween =
        Tween<Offset>(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}
