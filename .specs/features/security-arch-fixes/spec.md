# Security & Architecture Fixes

**Branch:** feat/create-cooking-tips-screen  
**Scope:** 7 findings from automated code review (2026-06-23)

---

## Requirements

| ID      | Severity | Requirement |
|---------|----------|-------------|
| SEC-01  | Critical | `testNotification` SHALL verify a valid Firebase ID token (admin claim) before executing |
| SEC-02  | High     | `sendCustomNotification` SHALL reject callers without admin custom claim |
| SEC-03  | High     | `deleteAccount` SHALL delete the Firebase Auth account BEFORE deleting the Firestore profile |
| SEC-04  | Medium   | `saveProfile` SHALL persist only body-profile fields; auth fields (email, providerId, emailVerified, photoUrl) SHALL NOT be written to Firestore |
| ARCH-01 | Medium   | `_onAuthStarted` and `_onAuthCheckStatus` SHALL use `processedUser.isProfileComplete` instead of calling `_authService.hasCompleteProfile(uid)` |
| ARCH-02 | Medium   | `AuthService` SHALL NOT instantiate `UserProfileRepository` directly as a constructor fallback |
| ARCH-03 | Low      | `GlobalErrorBoundary` SHALL restore the previous `ErrorWidget.builder` value inside `dispose()` |

---

## Acceptance Criteria

- SEC-01: POST to `testNotification` without `Authorization: Bearer <token>` returns 401.
- SEC-01: POST with a valid token but no admin claim returns 403.
- SEC-02: Calling `sendCustomNotification` without admin custom claim throws `permission-denied`.
- SEC-03: If `user.delete()` throws `requires-recent-login`, the Firestore document is still intact.
- SEC-04: After `saveProfile`, the Firestore document contains no `email`, `email_verified`, `provider_id`, or `photo_url` keys.
- ARCH-01: No `await _authService.hasCompleteProfile` calls remain in `auth_bloc.dart`.
- ARCH-02: No import of the concrete `UserProfileRepository` in `auth_service.dart`.
- ARCH-03: After `GlobalErrorBoundary` is disposed, `ErrorWidget.builder` equals its pre-mount value.

---

## Constraints

- Do not change any public API surface (BLoC events/states, repository interfaces).
- Do not introduce new dependencies.
- `hasCompleteProfile` on `IUserProfileRepository` and `AuthService` may remain (used by onboarding flow if needed), but must not be called in the BLoC startup path.
