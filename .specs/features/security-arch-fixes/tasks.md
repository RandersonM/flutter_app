# Tasks — Security & Architecture Fixes

## T1 [SEC-01] — testNotification: Firebase ID token verification
- **File:** `functions/src/index.ts` (line ~459)
- **Change:** Verify `Authorization: Bearer <token>` header via `admin.auth().verifyIdToken()`; require `admin` custom claim.
- **Done when:** Returns 401 on missing/invalid token; 403 on non-admin token.

## T2 [SEC-02] — sendCustomNotification: admin claim guard
- **File:** `functions/src/index.ts` (line ~338)
- **Depends on:** `HttpsError` imported from `firebase-functions/v2/https`
- **Change:** Check `request.auth?.token.admin`; throw `HttpsError("permission-denied", ...)` if falsy.
- **Done when:** Non-admin authenticated caller receives `permission-denied`.

## T3 [SEC-03] — deleteAccount: correct operation order
- **File:** `lib/core/services/auth_service.dart` (lines 300–301)
- **Change:** Move `await user.delete()` to line 300; move `await _userProfileRepository.deleteProfile(user.uid)` to line 301.
- **Done when:** `deleteProfile` is only reached if `user.delete()` succeeds.

## T4 [SEC-04] — saveProfile: write only body-profile fields
- **File:** `lib/core/user_profile/repository/user_profile_repository.dart` (line ~48)
- **Change:** Replace `profile.toJson()` with an explicit map containing only body-profile keys.
- **Done when:** Auth fields absent from Firestore write payload.

## T5 [ARCH-01] — auth_bloc: remove redundant Firestore call
- **File:** `lib/core/auth/blocs/auth_bloc.dart` (lines 47–54 and 202–209)
- **Change:** Replace `await _authService.hasCompleteProfile(user.uid)` with `processedUser.isProfileComplete`.
- **Done when:** Zero `hasCompleteProfile` calls remain in `auth_bloc.dart`.

## T6 [ARCH-02] — AuthService: remove concrete DI fallback
- **File:** `lib/core/services/auth_service.dart` (lines 11, 27, 30)
- **Change:** Remove concrete `UserProfileRepository` import and the `?? UserProfileRepository()` fallback; make parameter required.
- **Done when:** `auth_service.dart` has no import of the concrete repository class.

## T7 [ARCH-03] — GlobalErrorBoundary: restore builder on dispose
- **File:** `lib/shared/widgets/global_error_boundary.dart` (line ~17)
- **Change:** Capture `ErrorWidget.builder` before overwriting in `initState`; restore it in `dispose()`.
- **Done when:** `dispose()` exists and restores previous builder.
