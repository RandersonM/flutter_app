import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/shared/utils/app_routes.dart';

void main() {
  group('AuthRouteMiddleware behaviour', () {
    test('sends a guest to login with the route to resume after sign-in', () {
      final route = AuthRouteMiddleware.onGenerateRoute(
        const RouteSettings(name: AppRoutes.listCrews, arguments: 'crew-1'),
        const AuthUnauthenticated(),
      );

      expect(route?.settings.name, AppRoutes.login);
      expect(route?.settings.arguments, {
        'returnRoute': AppRoutes.listCrews,
        'returnArguments': 'crew-1',
      });
    });

    test('lets a guest open a public route', () {
      final route = AuthRouteMiddleware.onGenerateRoute(
        const RouteSettings(name: AppRoutes.calculator),
        const AuthUnauthenticated(),
      );

      expect(route?.settings.name, AppRoutes.calculator);
    });
  });
}
