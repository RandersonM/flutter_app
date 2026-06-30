import 'package:flutter/material.dart';

abstract class INavigationService {
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
