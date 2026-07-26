# Workout Plans — Specification

## Overview

Allow the user to create custom workout routines composed of multiple workout "splits" (A, B, C…), save them to Firestore inside the existing `workout_assessments` collection, and display the correct workout for today based on a rotation algorithm aligned with the user's weekly workout goal.

---

## Requirements

| ID | Requirement |
|----|-------------|
| WP-01 | User SHALL be able to create a named workout plan containing 1–N named splits (A, B, C…) |
| WP-02 | Each split SHALL contain a list of exercises with name and volume (e.g. "Supino Reto: 3x15", "Corrida: 45 min") |
| WP-03 | The plan SHALL be stored as a new field `workout_plan` in the existing `workout_assessments` Firestore document |
| WP-04 | The system SHALL determine which split to display today using a rotation algorithm based on `workout_days_goal` and `workout_days` |
| WP-05 | The "Next Workout" card SHALL display the real split for today/tomorrow derived from WP-04 |
| WP-06 | The system SHALL show each exercise as ✅ done or ⬜ pending based on whether today is already marked in `workout_days` (calendar) |
| WP-07 | If no plan exists, the UI SHALL show a CTA to create one |
| WP-08 | The user SHALL be able to edit/replace the plan at any time |

---

## Data Contract

### Firestore field — `workout_plan` (inside `workout_assessments`)

```json
{
  "workout_plan": {
    "splits": [
      {
        "name": "Treino A",
        "exercises": [
          { "name": "Supino Reto", "volume": "3x15" },
          { "name": "Crucifixo", "volume": "3x12" }
        ]
      },
      {
        "name": "Treino B",
        "exercises": [
          { "name": "Agachamento", "volume": "4x10" },
          { "name": "Leg Press", "volume": "3x15" }
        ]
      }
    ]
  }
}
```

---

## Rotation Algorithm

```
Given:
  workout_days = [1, 3, 5, 8, 10]   // days of month with workouts done
  splits = [A, B, C]
  goal = 4 days/week

To find today's split:
  1. Count how many workout_days have occurred up to (and including) today → N
  2. split_index = N % splits.length
  3. today_split = splits[split_index]

To find tomorrow's split:
  - Use N+1 (next scheduled workout)
```

---

## UI Changes

### WorkoutResults — `_buildNextWorkout`
- Show real split name and exercises from `workout_plan`
- Show "Criar plano" CTA if no plan exists

### _NextWorkoutModal (Bottom Sheet)
- List real exercises from the resolved split
- Each exercise row shows ✅ if today is marked in `workout_days`, ⬜ otherwise

### New Screen: `WorkoutPlanEditorScreen`
- Form to create/edit splits
- Add split button
- Per-split: editable name + exercise list (name + volume)
- Save button → calls BLoC event

---

## Constraints

- No new Firestore collection — reuse `workout_assessments`
- No new BLoC — add events/state to `ZoroWorkoutBloc`
- No external packages needed — pure Dart + Flutter + existing Firestore service
- The `WorkoutAssessmentModel` needs `workout_plan` field added (nullable)
- Must run `dart run build_runner build` after model change (uses `json_serializable`)
