---
paths:
  - "lib/features/auth/**"
  - "lib/features/onboarding/**"
  - "lib/features/profile/**"
  - "lib/features/splash/**"
  - "lib/core/auth/**"
  - "lib/core/user_profile/**"
  - "lib/core/middleware/**"
  - "lib/core/services/auth_db/auth_service.dart"
---

# Domain — account, auth, onboarding, profile

## Auth

- Google Sign-In through `IAuthService` (`lib/core/services/auth_db/auth_service.dart`).
  The session is validated by forcing a token refresh; on `SocketException` it falls
  back to the cached user in Hive box `auth_cache` (key `current_user`).
- `AuthBloc` (`lib/core/auth/blocs/`) is a global lazy singleton. States: `Initial`,
  `Loading`, `Authenticated(user, isFirstLogin)`, `NeedsOnboarding`,
  `Unauthenticated`, `Error`, `ProfileUpdating/Updated`, `DeletingAccount`,
  `AccountDeleted`.
- `AppWrapper` (`lib/core/auth/app_wrapper.dart`) is the root switch on `AuthState`:
  Splash → Home / Onboarding / Login / Error. Splash never navigates.
- **Guest mode exists:** login offers "skip for now"; public routes must work signed out.
- Login honours `returnRoute` / `returnArguments` from the route guard (`routing.md`).
- Debt: `AuthStarted` is dispatched twice (in `core_module.dart` and
  `AppWrapper.initState`).

## User profile

- `UserModel` (`lib/core/auth/models/user_model.dart`): `@JsonSerializable`
  (snake_case keys) + hand-written Hive adapter. Body fields: `gender`, `age`,
  `heightCm`, `weightKg`, `activityLevel`, `goal`, optional circumferences.
- **`isProfileComplete`** requires gender, age, height, weight (> 0), activity level
  and goal — that is what routes a user to onboarding.
- Persisted at Firestore `users/{uid}` by `IUserProfileRepository` with
  `set(merge: true)` + `updated_at`.
- `UserNameMiddleware` (`lib/core/middleware/user_name_middleware.dart`) trims the
  display name to two words.

## Onboarding

Two steps: (1) biological sex, age, height, weight; (2) activity level, goal,
optional measurements. Create mode on `AuthNeedsOnboarding`; edit mode when it
receives a `UserModel`. Dispatches `AuthProfileBodyUpdated` — no bloc of its own.
`/onboarding` is public by design.
Debt: hardcoded Portuguese app bar titles.

## Profile

`/profile` (private): sign-out, theme and language switches (`ThemeCubit`,
`LocaleCubit`), and "edit body profile" (pushes `/onboarding` with the user).

The body profile feeds Zoro, Sanji and Vegapunk's `getUserProfile` tool — changing
its fields affects all three.
