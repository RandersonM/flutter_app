import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState? get navigator => navigatorKey.currentState;

  Future<dynamic> navigateTo(String routeName, {Object? arguments}) async {
    if (navigator != null) {
      return navigator!.pushNamed(routeName, arguments: arguments);
    }
    debugPrint('NavigationService: Navigator não disponível');
  }

  Future<dynamic> navigateToReplacement(String routeName, {Object? arguments}) async {
    if (navigator != null) {
      return navigator!.pushReplacementNamed(routeName, arguments: arguments);
    }
    debugPrint('NavigationService: Navigator não disponível');
  }

  void pop([dynamic result]) {
    if (navigator != null) {
      navigator!.pop(result);
    }
  }

  void popUntil(String routeName) {
    if (navigator != null) {
      navigator!.popUntil(ModalRoute.withName(routeName));
    }
  }

  void popToFirst() {
    if (navigator != null) {
      navigator!.popUntil((route) => route.isFirst);
    }
  }

  bool canPop() {
    return navigator?.canPop() ?? false;
  }

  Route<dynamic>? getCurrentRoute() {
    return navigator?.widget.initialRoute != null 
        ? null 
        : ModalRoute.of(navigator!.context);
  }

  String? getCurrentRouteName() {
    final route = getCurrentRoute();
    return route?.settings.name;
  }
}
