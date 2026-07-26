# Workout Plans — Design

## Architecture

```
WorkoutPlanModel (new)
  └── WorkoutSplitModel (new)
        └── WorkoutExerciseModel (new)

WorkoutAssessmentModel (modify)
  └── + workoutPlan: WorkoutPlanModel?

WorkoutAssessmentService (modify)
  └── + updateWorkoutPlan(plan)

ZoroWorkoutBloc (modify)
  ├── + SaveWorkoutPlan event
  └── uses WorkoutPlanResolver (new utility)

WorkoutPlanResolver (new utility)
  └── resolveTodaySplit(assessment) → WorkoutSplitModel?

UI
  ├── workout_results.dart — _buildNextWorkout uses real data
  ├── _NextWorkoutModal — uses real exercises + done status
  └── WorkoutPlanEditorScreen (new)
```

## Component Sequence

```
User opens Workout screen
  → ZoroWorkoutBloc.InitializeWorkoutAssessment
  → loads assessment (includes workout_plan if exists)
  → WorkoutResults shows "Next Workout" card with real split
  → User taps card → _NextWorkoutModal opens with real exercises

User taps "Criar Plano" (no plan exists)
  → WorkoutPlanEditorScreen opens
  → User adds splits + exercises
  → Saves → ZoroWorkoutBloc.SaveWorkoutPlan
  → WorkoutAssessmentService.updateWorkoutPlan
  → BLoC reloads → UI updates
```

## Files Changed

| File | Change |
|------|--------|
| `lib/core/models/workout_plan_model.dart` | **NEW** — WorkoutPlanModel, WorkoutSplitModel, WorkoutExerciseModel |
| `lib/core/models/workout_assessment_model.dart` | **MODIFY** — add `workoutPlan` field |
| `lib/core/models/workout_assessment_model.g.dart` | **REGENERATE** |
| `lib/core/services/workout_assessment_service.dart` | **MODIFY** — add `updateWorkoutPlan()` |
| `lib/features/zoro_workout/bloc/zoro_workout_event.dart` | **MODIFY** — add `SaveWorkoutPlan` event |
| `lib/features/zoro_workout/bloc/zoro_workout_bloc.dart` | **MODIFY** — handle `SaveWorkoutPlan` |
| `lib/shared/utils/workout_plan_resolver.dart` | **NEW** — rotation algorithm |
| `lib/features/zoro_workout/presentation/widgets/workout_results.dart` | **MODIFY** — use real plan |
| `lib/features/zoro_workout/presentation/workout_plan_editor_screen.dart` | **NEW** — plan editor UI |
