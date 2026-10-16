---
paths:
  - "lib/**/bloc/**/*.dart"
  - "lib/**/cubit/**/*.dart"
  - "lib/app/di/**/*.dart"
---

# BLoC / Cubit

## Pick one

- **Cubit** for simple state with no event branching (toggle, form, chat stream).
- **Bloc** when several events drive transitions or you need event transformers.
- Both live in `bloc/`. Files: `x_bloc.dart`, `x_event.dart`, `x_state.dart`
  (separate files, no `part`/`part of`).

## Dependencies — enforced by the post-edit hook

- Everything arrives through the constructor, typed as an **abstract interface**
  (`I*Repository` / `I*Service`). Never `getIt`, never `FirebaseAuth.instance`,
  never `new Connectivity()` inline.
- **Never depend on another BLoC/Cubit.** Need the current uid? Inject `IAuthService`.
  Need connectivity? Inject `IConnectivityService`, or let the screen react with
  a `BlocListener` and dispatch an event. Changing the user's profile? Call
  `IAuthService.updateBodyProfile`; `AuthBloc` follows through `profileChanges`
  (golden: Sanji / Zoro).
- No `package:flutter/material.dart` / `widgets.dart` / `BuildContext`. Use
  `dart:ui` (`Locale`) or `package:flutter/foundation.dart`. No colours, widgets or
  `ThemeMode` in state — map them in the widget.

## State

New code uses a **sealed** hierarchy with Equatable — the compiler then forces
exhaustive `switch` in the UI:

```dart
sealed class CrewsState extends Equatable {
  const CrewsState();
  @override
  List<Object?> get props => [];
}

final class CrewsInitial extends CrewsState { const CrewsInitial(); }
final class CrewsLoading extends CrewsState { const CrewsLoading(); }

final class CrewsLoaded extends CrewsState {
  const CrewsLoaded({required this.crews, this.query = ''});
  final List<CrewModel> crews;
  final String query;
  CrewsLoaded copyWith({List<CrewModel>? crews, String? query}) =>
      CrewsLoaded(crews: crews ?? this.crews, query: query ?? this.query);
  @override
  List<Object?> get props => [crews, query];
}

final class CrewsError extends CrewsState {
  const CrewsError(this.failure);
  final CrewsFailure failure;
  @override
  List<Object?> get props => [failure];
}

enum CrewsFailure { network, notFound, permissionDenied, unknown }
```

- Immutable, `const` constructors, `copyWith` on the data-carrying state.
- Use a nullable-clearing sentinel or explicit `clearX` flags when `copyWith` must
  set a field back to null (golden: `vegapunk_chat_state.dart`, `duels_state.dart`).
- Existing `abstract class XState extends Equatable` files are fine; don't migrate
  them in passing.
- Tiny cubits may use a single state class (`ThemeState`, `CalculatorState`).

## Failures carry no text

States never hold user-facing strings — no `XError('Erro ao carregar: $e')`, no
`e.toString()`. Catch, `debugPrint` the cause, emit a failure enum; the widget maps
it to `AppLocalizations` (see `i18n.md`). Raw keys for the UI to localize are also
fine (`VegapunkChatReady.activeToolName`).

## Events

- `sealed class XEvent extends Equatable`, subclasses `final class`.
- Imperative, verb first: `LoadCrews`, `DeleteGoal`, `SaveFinances`. Auth's
  `AuthSignInRequested` style is legacy-consistent only inside auth.
- Handlers are private `_onLoadCrews`, registered in the constructor with
  `on<LoadCrews>(_onLoadCrews)`.

## Lifecycle

- Cancel every `StreamSubscription` and `Timer` in `close()`, then
  `return super.close()` (golden: `lib/core/connectivity/connectivity_cubit.dart`).
- Guard `emit` after awaits with `if (isClosed) return;` in long async handlers.

## Registration

- Feature BLoC → `getIt.registerFactory<XBloc>(() => XBloc(repo: getIt<IXRepository>()))`
  in `lib/app/di/features_module.dart`, plus a getter in the module's extension.
- Runtime args → `registerFactoryParam`. App-wide singletons are the exception
  and belong in `core_module.dart` / their own module.
- Golden examples: `lib/features/crews/bloc/list_crews_bloc.dart` (+ event/state),
  `lib/features/home/bloc/home_state.dart`, `lib/features/vegapunk_chat/bloc/vegapunk_chat_cubit.dart`.
