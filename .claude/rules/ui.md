---
paths:
  - "lib/**/presentation/**/*.dart"
  - "lib/shared/widgets/**/*.dart"
  - "lib/shared/utils/theme.dart"
  - "lib/shared/utils/app_semantic_colors.dart"
  - "lib/shared/utils/constants.dart"
  - "lib/core/auth/app_wrapper.dart"
  - "lib/main.dart"
---

# UI

## Screen shape

```dart
class CrewsScreen extends StatelessWidget {
  const CrewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ListCrewsBloc>()..add(const LoadCrews()),
      child: const _CrewsView(),
    );
  }
}

class _CrewsView extends StatelessWidget {
  const _CrewsView();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: DefaultAppBar(title: Text(l10n.crewsTitle)),
      body: BlocBuilder<ListCrewsBloc, ListCrewsState>(
        builder: (context, state) => switch (state) { ... },
      ),
    );
  }
}
```

- The public screen only provides the BLoC; a private `_XView` builds the UI.
- Get BLoCs from DI (`getIt<XBloc>()`), never `XBloc(...)` in a widget. Global
  cubits: `BlocProvider.value(value: getIt<ConnectivityCubit>())`.
- `BlocBuilder` for rendering, `BlocListener` for side effects (navigation,
  snackbars), `BlocConsumer` for both. Use `context.select` when a widget needs one
  field of a big state.
- **No business logic, repositories, services or Firebase in widgets** (hook-
  enforced). Ownership checks, deletes and "add member" belong in a BLoC (golden:
  `CrewDetailsBloc`).
- Prefer small private widget classes over `Widget _buildX()` methods for anything
  with its own state or more than a few lines.
- Golden: `lib/features/crews/presentation/list_crews_screen.dart`,
  `lib/features/calculator/presentation/calculator_screen.dart`.

## Atomic design (`lib/shared/widgets/`)

| Level | Rule |
|---|---|
| `atoms/` | Pure UI, no BLoC, no `getIt`, no l10n lookups that depend on feature state |
| `molecules/` | Compose atoms; still no BLoC / `getIt` — take data + callbacks |
| `organisms/` | May read BLoCs via context |

Feature-specific widgets stay in `lib/features/<f>/presentation/widgets/`; promote
to `shared/` only when a second feature needs them.

## Colours

The theme is the source of truth, so light and dark are decided in one place.

| Need | Use |
|---|---|
| Brand, surfaces, text | `Theme.of(context).colorScheme.*` |
| Secondary / muted text | `colorScheme.onSurfaceVariant` |
| Dividers, outlines | `colorScheme.outlineVariant` / `outline` |
| Text on a coloured fill | the matching `on*` colour (`onPrimary`, `onError`, ...) |
| Error / destructive | `colorScheme.error` |
| Success, warning, info | `Theme.of(context).semanticColors.*` (`import 'package:opfan/shared/utils/app_semantic_colors.dart'`) |

Hook-enforced on new lines: no raw `Colors.*` (except `Colors.transparent`), no
`Color(0x...)` literals, no `AppColors.red/green/orange/yellow` for meaning.
Allowed exceptions: third-party brand colours (YouTube red in
`youtube_player_screen.dart`), categorical palettes (`RoleIconMapper`), decorative
art (`futuristic_background.dart`). Anything else that is genuinely not semantic:
add it to `theme.dart`, or mark the line `// harness:allow <reason>`.
Categorical palettes live in one file each: `ExpenseCategoryPalette` (Nami),
`goal_colors.dart` (Robin), `PlateSectionPalette` (Sanji),
`shared/utils/devil_fruit_type_palette.dart`. Media overlays (white/black on video,
photos, GIFs) are `// harness:allow decorative`. `test/shared/utils/theme_roles_test.dart`
guards contrast for `onSurfaceVariant`, `outline*` and `error` in both themes.

## Typography, icons, spacing

- Text styles from `Theme.of(context).textTheme.*` with `copyWith`; no ad-hoc
  `TextStyle(fontSize: ...)` families.
- Icons: Phosphor through `AppIcon(PhosphorIconsRegular.x)`
  (`lib/shared/widgets/atoms/app_icon.dart`). No Material `Icons.*` in new code.
- Spacing: `Constants.margin` multiples and `Constants.sizeNN`
  (`lib/shared/utils/constants.dart`), or `Row/Column(spacing:)`. Avoid new literal
  `EdgeInsets.all(13)` values.
- App bar: `DefaultAppBar` (`lib/shared/widgets/molecules/default_app_bar.dart`).

## Text

All visible text comes from `AppLocalizations` — see `i18n.md`. That includes
`Semantics` labels, tooltips, snackbars, dialogs and validator messages.
