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
  The session is validated by forcing a token refresh. Only a revoked session
  (`FirebaseAuthException` `user-token-expired`, `user-disabled`, `user-not-found`,
  `invalid-user-token`) or Google answering `sign_in_required` signs the user out;
  any other failure (offline, timeout) keeps the session. The signed-in user is
  cached in the encrypted device box `auth_cache_encrypted` (key `current_user`,
  `IUserStorageService.openDeviceBox`); when that cache is lost (reinstall,
  reset keychain) but Firebase still has the user, `checkAuthStatus` rebuilds
  it from the Firebase user and the stored body profile. Sign-in and
  `checkAuthStatus` return `null` (and cache nothing) when Firebase no longer
  has that uid after their slow reads, so a sign-out mid-check stays signed
  out; and they keep a complete cached profile of the same uid over an
  incomplete read, so onboarding saved meanwhile is not overwritten.
- Local data is per user (`IUserStorageService`): signing out keeps it on the
  device under the uid, and the next account sees only its own.
- `deleteAccount` signs in with Google again, erases the user's Firestore
  documents (`IUserDataEraser`), deletes the Auth user, then the local boxes and
  RAG databases. Firestore goes first because the rules deny deletes once the
  Auth user is gone. No screen dispatches `AuthDeleteAccount` yet.
- `AuthBloc` (`lib/core/auth/blocs/`) is a global lazy singleton. States: `Initial`,
  `Loading`, `Authenticated(user, isFirstLogin)`, `NeedsOnboarding`,
  `Unauthenticated`, `Error`, `ProfileUpdating/Updated/UpdateFailed`,
  `DeletingAccount`, `AccountDeleted`. Every path that signs a user in (start, sign-in, Firebase
  status change) picks `Authenticated` or `NeedsOnboarding` from
  `isProfileComplete`; a status change — or a sign-in call that returns late —
  for the uid already in the state is ignored, because Firebase replays the
  current user on subscribe and reports a sign-in before `signInWithGoogle`
  returns. It listens to `IAuthService.profileChanges`, so a body profile saved
  by another feature replaces the user in `Authenticated` (display name trimmed
  by `UserNameMiddleware`, like every other signed-in state). `AuthStarted` (also the error screen's
  "Try again") replaces the `authStatusStream` subscription, never adds one.
- A failed profile save never reaches `AuthError`: the bloc emits
  `ProfileUpdateFailed`, then the signed-in state rebuilt from
  `IAuthService.currentUser` (the last stored profile). Onboarding in create mode
  shows `profileUpdateFailed`; in edit mode it has already popped, so the screen
  that opened it (profile, Sanji) shows it through `ProfileUpdateFailureListener`
  (`lib/shared/widgets/organisms/`).
- `AppWrapper` (`lib/core/auth/app_wrapper.dart`) is the root switch on `AuthState`:
  Splash → Home / Onboarding / Login / Error. Splash never navigates. Its
  `buildWhen` skips `ProfileUpdating/Updated/UpdateFailed`, so a profile save
  keeps the current root instead of falling to Splash.
- **Guest mode exists:** login offers "skip for now"; public routes must work signed out.
- Leaving a session (sign-out, account deletion, revoked session) always lands
  on Login with an empty stack: `SignedOutRedirect` (in `MaterialApp.builder`)
  does it, because login and onboarding replace the whole stack and remove
  `AppWrapper`. A cancelled sign-in by a guest does not move them.
- Login honours `returnRoute` / `returnArguments` from the route guard (`routing.md`).
- FCM token (`INotificationService`): saved to `user_tokens/{uid}` on Google
  sign-in (fetching a new one, since sign-out deletes the device token; not
  awaited, so a slow write never holds the signed-in state), once per launch
  when `initialize` finds a restored Firebase session, and on every
  `onTokenRefresh` while a Firebase user is signed in. A save is dropped when
  that uid is no longer signed in or `clearToken` ran while the token was
  fetched, so a fast sign-out never leaves this device under the old account.
  Sign-in retries an `initialize` that failed at launch.

## User profile

- `UserModel` (`lib/core/auth/models/user_model.dart`): `@JsonSerializable`
  (snake_case keys) + hand-written Hive adapter. Body fields: `gender`, `age`,
  `heightCm`, `weightKg`, `activityLevel`, `goal`, optional circumferences.
- **`isProfileComplete`** requires gender, age, height, weight (> 0), activity level
  and goal — that is what routes a user to onboarding.
- Persisted at Firestore `users/{uid}` by `IUserProfileRepository` with
  `set(merge: true)` + `updated_at`. The document holds only the body fields
  (`BodyProfile`, `lib/core/user_profile/models/body_profile.dart`, matching
  `profileKeys()` in the rules); identity comes from Firebase Auth.
  `fetchBodyProfile` reads only those fields, so legacy documents with identity
  fields still parse. A read that fails (offline with nothing cached, App Check)
  keeps the body already cached for that uid instead of sending the user to
  onboarding. A save writes only the fields it has: a field it lacks is
  deleted only when the cached profile had it (the user cleared it), so a
  profile filled on a device that never loaded the measures keeps them.
- A user sent to onboarding because the profile could not be read offline is
  signed straight in once it can: `AuthBloc` runs `AuthCheckStatus` when the
  network comes back while the state is `NeedsOnboarding`, and a status change
  or sign-in for the same uid is applied when it completes that profile.
- `IAuthService.updateBodyProfile` stores the profile in the Hive cache, emits
  it on `profileChanges` and returns; the Firestore write is not awaited (it
  completes only on the server ack, so awaiting it hung offline saves). If the
  server refuses it, the cache is put back to the stored profile (no stored
document: the body is cleared, so onboarding asks again), emitted on
  `profileChanges`, and `profileSyncFailures` makes `AuthBloc` emit
  `ProfileUpdateFailed` (shown by `ProfileUpdateFailureListener`).
- `UserNameMiddleware` (`lib/core/middleware/user_name_middleware.dart`) trims the
  display name to two words.

## Onboarding

Two steps: (1) biological sex, age, height, weight; (2) activity level, goal,
optional measurements. Every number is parsed and bounded by `BodyMeasure`
(`lib/shared/utils/body_measure.dart`, see `domains/zoro-sanji.md`): a comma
decimal is accepted, and an empty optional measurement is skipped but one out of
range is refused; emptying a prefilled one clears it (the form replaces the
body fields with `BodyProfile.replaceIn`). The form is prefilled once. Create mode on
`AuthNeedsOnboarding`; edit mode when it receives a `UserModel`. The login
screen replaces the stack with `/onboarding` on `NeedsOnboarding`; only that
pushed route replaces the stack with `/home` once the state turns
`Authenticated` (login removed `AppWrapper`). As the `AppWrapper` child it does
not navigate — the root switch shows Home. Finish turns into a spinner until the save fails or the
screen goes. Dispatches `AuthProfileBodyUpdated` — no bloc of its own.
`/onboarding` is public by design.

## Profile

`/profile` (private): sign-out, theme and language switches (`ThemeCubit`,
`LocaleCubit`), and "edit body profile" (pushes `/onboarding` with the user).

The body profile feeds Zoro, Sanji and Vegapunk's `getUserProfile` tool — changing
its fields affects all three.
