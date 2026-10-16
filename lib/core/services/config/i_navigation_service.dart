import 'package:flutter/material.dart';

abstract class INavigationService {
  /// Handed to `MaterialApp.navigatorKey`. Must come from the single
  /// registered instance — a second key would silently detach programmatic
  /// navigation from the live navigator.
  GlobalKey<NavigatorState> get navigatorKey;

  NavigatorState? get navigator;

  Future<dynamic> navigateTo(String routeName, {Object? arguments});

  Future<dynamic> navigateToReplacement(String routeName, {Object? arguments});

  void pop([dynamic result]);

  void popUntil(String routeName);

  void popToFirst();

  bool canPop();

  Route<dynamic>? getCurrentRoute();

  String? getCurrentRouteName();
}
