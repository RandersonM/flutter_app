## Summary

<!-- One or two sentences: what changes for the user or the codebase, and why now.
     Link the spec / issue / ticket this implements. -->

- Spec / issue:

## Type of change

- [ ] Feature
- [ ] Fix
- [ ] Refactor (no behaviour change)
- [ ] Performance
- [ ] Tests only
- [ ] Docs / harness / tooling
- [ ] Breaking change (data migration, removed route, changed contract)

## Method — what was done

<!-- How you approached it, step by step. Name the layers touched
     (presentation → bloc → repository/service → source) and the key decisions
     inside each. Someone should understand the shape of the change before reading the diff. -->

1.

## Why this way

<!-- The reasoning behind the approach. What alternatives did you consider and why
     were they rejected? Which constraint drove the design (on-device memory,
     offline, Firestore rules, an existing pattern, a spec decision)?
     Call out anything that deviates from CLAUDE.md / .claude/rules and why. -->

- Chosen approach:
- Alternatives considered:
- Trade-offs accepted:

## Impact

<!-- Who and what this affects. Write "none" explicitly where it doesn't apply —
     a blank looks like it wasn't considered. -->

| Area | Impact |
|---|---|
| Users / UX | |
| Data — Firestore collections, `firestore.rules`, Hive boxes / `HiveTypeIds` | |
| On-device AI — model, memory, prompts, tools, RAG store | |
| Platforms — Android / iOS (entitlements, permissions, plugins) | |
| Dependencies — `pubspec.yaml`, Cloud Functions | |
| Performance / offline behaviour | |
| Backward compatibility / migration | |

**Risk:** <!-- low / medium / high, and what would break first -->
**Rollback:** <!-- revert is enough? data to clean up? functions to redeploy? -->

## Changes

<!-- The concrete changes, grouped by area. Point to key files so reviewers know
     where to start. -->

- **Presentation:**
- **BLoC / state:**
- **Data / services:**
- **AI (prompts, tools, RAG):**
- **l10n:**
- **Tests:**
- **Config / CI / harness:**

## Evidence

<!-- Proof it works, not a claim. Attach what applies; delete what doesn't. -->

**Automated**

- [ ] `fvm flutter analyze --no-fatal-infos`: no issues
- [ ] `fvm flutter test`: all passing (paste the count)
- [ ] `fvm dart format --set-exit-if-changed lib test`: clean
- [ ] New or updated tests cover the change: <!-- list test files -->

**Manual**

- [ ] Run on device/simulator: <!-- model + OS version -->
- [ ] Screenshots or video, **before / after**, in **light and dark**, in **EN and PT**:

| Before | After |
|---|---|
| | |

- [ ] Edge cases exercised: <!-- offline, signed out (guest), empty state, error state, model not installed -->
- [ ] AI changes: sample prompts and answers (EN + PT), and memory checked on a real device

## Checklist

- [ ] Every user-facing string is in **both** `intl_en.arb` and `intl_pt.arb`
- [ ] Colours come from `colorScheme` / `semanticColors`. No raw `Colors.*`, hex or semantic `AppColors`
- [ ] BLoCs take dependencies through the constructor (no `getIt`, no other BLoC) and their states carry no UI text
- [ ] New Hive adapters use `HiveTypeIds`. No shipped id was reused
- [ ] New Firestore collections are owner-scoped in `firestore.rules`
- [ ] New private routes are added to `privateRoutes`
- [ ] Comments only where the code cannot speak for itself
- [ ] `.specs/` / `docs/` updated where they described the old behaviour
- [ ] No secrets, `.env` values or generated files (`firebase_options.dart`) committed
- [ ] No AI attribution in commits or in this description
