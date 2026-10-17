#!/usr/bin/env bash
# PostToolUse(Edit|Write) hook.
#
# 1. Formats the edited Dart file (CI fails on unformatted code).
# 2. Regenerates localizations when an ARB file changes.
# 3. Marks the tree dirty so the Stop hook knows to run analyze + tests.
# 4. Rejects *newly added* lines that break an objective rule from CLAUDE.md /
#    .claude/rules. Only lines added since HEAD are checked, so legacy debt in
#    a file never blocks an unrelated edit.
#
# Exit 2 feeds stderr back to Claude, which must then fix the lines. A line can
# opt out with a trailing `// harness:allow <reason>` comment — reserved for
# documented exceptions (brand colours, categorical palettes).

set -uo pipefail

input=$(cat)
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
[ -n "$file" ] || exit 0

root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
rel="${file#"$root"/}"
case "$rel" in
  /*) exit 0 ;; # outside the project
  build/* | .dart_tool/* | ios/Pods/* | *.g.dart | lib/l10n/app_localizations*.dart | lib/firebase_options.dart) exit 0 ;;
esac
cd "$root" || exit 0
[ -f "$rel" ] || exit 0

state_dir=".claude/.state"
mkdir -p "$state_dir"

case "$rel" in
  *.arb)
    touch "$state_dir/dart-dirty"
    if ! out=$(fvm flutter gen-l10n 2>&1); then
      printf 'flutter gen-l10n failed after editing %s:\n%s\n' "$rel" "$out" >&2
      exit 2
    fi
    exit 0
    ;;
  pubspec.yaml)
    touch "$state_dir/dart-dirty"
    exit 0
    ;;
  *.dart) ;;
  *) exit 0 ;;
esac

touch "$state_dir/dart-dirty"
fvm dart format "$rel" >/dev/null 2>&1

# Lines added since HEAD; the whole file when it is new.
if git ls-files --error-unmatch "$rel" >/dev/null 2>&1; then
  added=$(git diff -U0 HEAD -- "$rel" | grep '^+' | grep -v '^+++' | sed 's/^+//')
else
  added=$(cat "$rel")
fi
# Comments and explicitly allowed lines are never checked.
added=$(printf '%s\n' "$added" | grep -vE '^\s*//' | grep -v 'harness:allow')
[ -n "$(printf '%s' "$added" | tr -d '[:space:]')" ] || exit 0

violations=""
flag() { # $1 = extended regex, $2 = message
  local hits
  hits=$(printf '%s\n' "$added" | grep -E -- "$1" | head -3)
  if [ -n "$hits" ]; then
    violations+="- $2"$'\n'"$(printf '%s\n' "$hits" | sed 's/^[[:space:]]*/      /')"$'\n'
  fi
}

case "$rel" in
  lib/*/domain/* | lib/*/usecases/* | lib/*/use_cases/*)
    violations+="- No domain/ layer or use-case classes in this app (.claude/rules/architecture.md)."$'\n'
    ;;
esac

# ── BLoC / Cubit ────────────────────────────────────────────────────────────
case "$rel" in
  lib/*/bloc/* | lib/*/cubit/*)
    flag '\bgetIt\b|GetIt\.' \
      'A BLoC/Cubit never resolves dependencies itself. Take it through the constructor as an I* interface and wire it in lib/app/di/ (.claude/rules/bloc.md).'
    flag "import 'package:flutter/(material|widgets|cupertino|painting)\.dart'|BuildContext" \
      'No Flutter UI types in a BLoC/Cubit. Use dart:ui (e.g. Locale) or package:flutter/foundation.dart.'
    flag 'final[[:space:]]+[A-Z][A-Za-z0-9_]*(Bloc|Cubit)[[:space:]]+_?[a-zA-Z0-9_]+[[:space:]]*;' \
      'A BLoC must not depend on another BLoC. Depend on the I*Service/I*Repository underneath, or coordinate in the UI with BlocListener.'
    flag "(Error|Failure)\([^)]*(['\"][A-Za-zÀ-ÿ]|e\.toString\(\)|\\\$e)" \
      'States never carry user-facing text. Emit a failure enum/key and let the widget map it to AppLocalizations (.claude/rules/bloc.md).'
    ;;
esac

# ── Atoms / molecules stay BLoC-free ─────────────────────────────────────────
case "$rel" in
  lib/shared/widgets/atoms/* | lib/shared/widgets/molecules/*)
    flag "package:flutter_bloc|\bgetIt\b|context\.(read|watch|select)|Bloc(Builder|Listener|Consumer|Provider|Selector)" \
      'Atoms and molecules are pure UI: no BLoC, no getIt. Pass data and callbacks in, or move the widget to organisms/.'
    ;;
esac

# ── UI layer ─────────────────────────────────────────────────────────────────
case "$rel" in
  lib/*/presentation/* | lib/shared/widgets/*)
    flag "Text\([[:space:]]*['\"][^'\"\$]*[A-Za-zÀ-ÿ]" \
      'Hardcoded user-facing text. Add the key to lib/l10n/intl_en.arb AND intl_pt.arb and use AppLocalizations.of(context)! (.claude/rules/i18n.md).'
    flag "(hintText|labelText|helperText|errorText|tooltip|semanticLabel|semanticsLabel|title|subtitle|message|content)[[:space:]]*:[[:space:]]*['\"][^'\"\$]*[A-Za-zÀ-ÿ]" \
      'Hardcoded user-facing text in a widget property. Use an ARB key (.claude/rules/i18n.md).'
    # The two patterns above miss ternaries (`Text(a ? 'X' : 'Y')`), literals on
    # their own line and validator returns, so also flag any literal that reads
    # like prose (two words) once interpolations are stripped.
    prose=$(printf '%s\n' "$added" | perl -CSD -e '
      use utf8;
      while (my $line = <STDIN>) {
        next if $line =~ /debugPrint|\bprint\(|\blog\(|assert\(|^\s*(import|export|part)\s|Key\(|RegExp\(|DateFormat|throw\s|Exception\(|Error\(/;
        while ($line =~ /([\x27"])((?:\\.|(?!\1).)*)\1/g) {
          my $text = $2;
          $text =~ s/\$\{(?:[^{}]|\{[^{}]*\})*\}|\$\w+//g;
          next if $text =~ m{https?://|[dMyHhms]{2,}[/:.\-][dMyHhms]};
          if ($text =~ /\p{L}{2,}[\p{L}.\x27]*\s+\p{L}{2,}/) { print $line; last; }
        }
      }' | head -3)
    if [ -n "$prose" ]; then
      violations+="- Hardcoded user-facing text (a string literal that reads like prose). Use an ARB key (.claude/rules/i18n.md). Proper nouns may carry // harness:allow proper noun."$'\n'"$(printf '%s\n' "$prose" | sed 's/^[[:space:]]*/      /')"$'\n'
    fi
    flag 'getIt<I[A-Za-z0-9_]*(Repository|Service)>|getIt\.[a-z][A-Za-z0-9_]*(Repository|Service)\b' \
      'Widgets do not call repositories/services. Go through a BLoC/Cubit (.claude/rules/ui.md).'
    flag 'FirebaseAuth\.instance|FirebaseFirestore\.instance' \
      'The UI never touches Firebase directly. Expose what you need through a BLoC backed by an I*Service.'
    flag '(^|[^<A-Za-z0-9_.])(new[[:space:]]+)?[A-Z][A-Za-z0-9_]*(Bloc|Cubit)\(' \
      'Do not construct a BLoC in a widget. Register it in lib/app/di/features_module.dart and use BlocProvider(create: (_) => getIt<XBloc>()).'
    ;;
esac

# ── Whole lib/ ───────────────────────────────────────────────────────────────
case "$rel" in
  lib/*)
    case "$rel" in
      lib/core/storage/hive_type_ids.dart) ;;
      *) flag 'typeId[[:space:]]*(=>|=)[[:space:]]*[0-9]' \
        'Literal Hive typeId. Add the id to lib/core/storage/hive_type_ids.dart and reference HiveTypeIds.x — never reuse a shipped id.' ;;
    esac
    flag 'ChangeNotifier|package:provider/|riverpod' \
      'No ChangeNotifier, Provider or Riverpod. State lives in a BLoC/Cubit.'
    case "$rel" in
      lib/core/services/config/environment_service.dart) ;;
      *) flag 'dotenv\.|String\.fromEnvironment' 'Read configuration through IEnvironmentService, never dotenv or String.fromEnvironment directly.' ;;
    esac
    flag 'generativelanguage\.googleapis\.com|google_generative_ai' \
      'Gemini is called only through Firebase AI Logic (IGeminiClient / firebase_ai) — the app must never hold a Gemini API key.'
    case "$rel" in
      lib/app/di/*) ;;
      *) flag '(^|[^A-Za-z0-9_])NavigationService\(' \
        'Never instantiate NavigationService — a second instance detaches the navigatorKey. Use getIt<INavigationService>().' ;;
    esac
    case "$rel" in
      lib/core/services/config/locale_service.dart) ;;
      *) flag 'Platform\.localeName|PlatformDispatcher\.instance\.locale|window\.locale' \
        'Do not read the device locale. UI uses LocaleCubit; non-UI code uses ILocaleService.' ;;
    esac
    case "$rel" in
      lib/shared/utils/theme.dart | lib/shared/utils/app_semantic_colors.dart | lib/shared/utils/role_icon_mapper.dart | \
        lib/shared/widgets/atoms/futuristic_background.dart | lib/features/youtube/presentation/youtube_player_screen.dart) ;;
      *)
        flag 'Colors\.(red|green|orange|amber|yellow|deepOrange|lightGreen|lime|white|black|grey|blueGrey)[A-Za-z0-9]*' \
          'Raw Colors.*. Use Theme.of(context).colorScheme (text: onSurface/onSurfaceVariant, dividers: outlineVariant, errors: error) or .semanticColors for success/warning/info (.claude/rules/ui.md).'
        flag 'AppColors\.(red|green|orange|yellow|amber)\b|Color\(0x[0-9A-Fa-f]{8}\)' \
          'Semantic or ad-hoc colour outside the theme. Use colorScheme / semanticColors; new palette colours belong in lib/shared/utils/theme.dart.'
        ;;
    esac
    ;;
esac

# ── Tests ────────────────────────────────────────────────────────────────────
case "$rel" in
  test/*)
    flag 'package:mockito|@GenerateMocks|@GenerateNiceMocks' \
      'Tests use mocktail (class _MockX extends Mock implements IX) and bloc_test, not mockito (.claude/rules/testing.md).'
    ;;
esac

if [ -n "$violations" ]; then
  {
    printf 'Harness rule check failed for %s (only lines added since HEAD are checked):\n' "$rel"
    printf '%s' "$violations"
    printf 'Fix these lines. If one is a deliberate, documented exception, append `// harness:allow <reason>` to it and mention it to the user.\n'
  } >&2
  exit 2
fi
exit 0
