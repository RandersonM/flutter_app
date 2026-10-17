---
paths:
  - "lib/**/*_routes.dart"
  - "lib/shared/utils/app_routes.dart"
  - "lib/shared/utils/feature_route_module.dart"
  - "lib/shared/utils/transitions/**"
  - "lib/core/services/config/*navigation*.dart"
---

# Routing

Navigation is `Navigator.pushNamed` with a module registry — no go_router.

## Add a route

1. In `lib/features/<f>/<f>_routes.dart`, the feature's
   `class XRoutes implements FeatureRouteModule`
   (`lib/shared/utils/feature_route_module.dart`):
   - a `static const myScreen = '/myScreen';` constant (lowerCamelCase path),
   - add it to `routes`,
   - **if it needs a signed-in user, add it to `privateRoutes`** — that set is what
     the guard reads,
   - build it in `getRoute(settings)`, casting `settings.arguments` to the expected
     type.
2. A new feature module must be added to `AppRoutes._modules` in
   `lib/shared/utils/app_routes.dart`.

Golden: `lib/features/crews/crews_routes.dart`.

## Auth guard

`AuthRouteMiddleware` (in `app_routes.dart`) checks every route against the
modules' `privateRoutes`. When the user is not `AuthAuthenticated`, it redirects to
`/login` with `{returnRoute, returnArguments}` so login can resume the navigation.
`main.dart` hands it `AuthBloc.state` read at navigation time, not a value
captured at the last rebuild — login's listener resumes the route before
`MaterialApp` could rebuild with the new state.
You do not edit the middleware to protect a route.

Guest mode is a product feature (login has "skip for now"), so only data the user
owns or that costs money (AI generation) should be private.

## Programmatic navigation

- From widgets: `Navigator.of(context).pushNamed(XRoutes.myScreen, arguments: model)`.
- From non-widget code: `getIt<INavigationService>()` — it owns the single
  `navigatorKey`. Never construct `NavigationService` (hook-enforced).
- BLoCs never navigate; they emit a state and a `BlocListener` navigates.

## Transitions

Custom `MaterialPageRoute` subclasses live in `lib/shared/utils/transitions/`. Reuse
them instead of defining new `PageRouteBuilder`s inline.
