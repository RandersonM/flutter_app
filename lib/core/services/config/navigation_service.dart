import 'package:flutter/material.dart';

import 'i_navigation_service.dart';

class NavigationService implements INavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  NavigatorState? get navigator => navigatorKey.currentState;

  @override
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) async {
    if (navigator != null) {
      return navigator!.pushNamed(routeName, arguments: arguments);
    }
    debugPrint('NavigationService: Navigator não disponível');
  }

  @override
  Future<dynamic> navigateToReplacement(String routeName,
      {Object? arguments}) async {
    if (navigator != null) {
      return navigator!.pushReplacementNamed(routeName, arguments: arguments);
    }
    debugPrint('NavigationService: Navigator não disponível');
  }

  @override
  void pop([dynamic result]) {
    if (navigator != null) {
      navigator!.pop(result);
    }
  }

  @override
  void popUntil(String routeName) {
    if (navigator != null) {
      navigator!.popUntil(ModalRoute.withName(routeName));
    }
  }

  @override
  void popToFirst() {
    if (navigator != null) {
      navigator!.popUntil((route) => route.isFirst);
    }
  }

  @override
  bool canPop() {
    return navigator?.canPop() ?? false;
  }

  @override
  Route<dynamic>? getCurrentRoute() {
    return navigator?.widget.initialRoute != null
        ? null
        : ModalRoute.of(navigator!.context);
  }

  @override
  String? getCurrentRouteName() {
    final route = getCurrentRoute();
    return route?.settings.name;
  }
}
