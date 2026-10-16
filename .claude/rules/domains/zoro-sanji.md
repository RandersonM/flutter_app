---
paths:
  - "lib/features/zoro_workout/**"
  - "lib/features/sanji_cooking/**"
  - "lib/core/services/workout/**"
  - "lib/core/services/nutrition/**"
  - "lib/shared/utils/workout_plan_resolver.dart"
  - "lib/core/ai/prompts/personas/sanji_prompt.dart"
---

# Domain — Zoro (workout) and Sanji (nutrition)

Both read the user's body profile (`domains/account.md`) and share Firestore
`workout_assessments`. Both screens are blocked offline by `OfflineBlockerOverlay`.

## workout_assessments

- **One document per user per month**: `user_id`, `month_year` (`"YYYY-MM"`),
  snake_case fields. Accessed directly by `WorkoutAssessmentService`
  (`lib/core/services/workout/workout_assessment_service.dart`).
- `workout_days`: list of **day-of-month ints** for the month.
- `workout_plan`: `{splits: [{name, exercises: [{name, volume}]}]}`
  (`lib/features/zoro_workout/data/models/workout_plan_model.dart`).
- Plan and day updates **fail if the current month has no document** — create the
  month's assessment first.

## Zoro

- Today's split rotates: `doneCount % splits.length`
  (`lib/shared/utils/workout_plan_resolver.dart`).
- Vegapunk's `saveWorkout` tool appends today's day-of-month to `workout_days`;
  `getWorkoutHistory` returns a markdown table — keep payloads lean (no
  `workoutPlan` in history) for the on-device model.
- `ZoroWorkoutBloc` state `Loaded{currentAssessment, history, ...}`. Route `/workout`.
- Debt: `_calculateProgress` / `_calculateRemainingDays` are stubs returning 0;
  hardcoded Portuguese error strings; the bloc injects `AuthBloc`.

## Sanji

- Nutrition calculator from the body profile, results saved into the month's
  `workout_assessments` via `updateNutritionData`.
- Tips and personalized meals come from **Gemini** (`gemini-2.5-flash-lite`,
  `cooking_repository.dart`, `sanji_prompt.dart`) — cloud, rate-limited, fallback
  in `dev_mode`.
- Routes `/cooking`, `/cookingTips`, `/plateGuide`.
- Debt: the screen holds a factory bloc in State and never closes it (leak);
  `_kAlertRed` / `_kAlertOrange` hex constants in `nutrition_results.dart`; the bloc
  injects `AuthBloc`.
