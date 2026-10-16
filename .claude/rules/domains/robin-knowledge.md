---
paths:
  - "lib/features/robin_knowledge/**"
---

# Domain — Robin knowledge (goals planner)

No AI. A goals/timeline planner stored in Firestore `planner` (filtered by `userId`
through `IFirestoreService.getUserDocuments`). Blocked offline by
`OfflineBlockerOverlay`. Route `/knowledge`.

## Model (`lib/features/robin_knowledge/data/models/goal_model.dart` — golden model)

`GoalModel{title, description, deadline, createdAt, category, status, progress,
tags, notes}`
- `category`: `study`, `work`, `personal`, `health`, `finance`, `other`.
- `status`: `notStarted`, `inProgress`, `completed`, `overdue`.
- `progress`: 0–100.

## Rules

- `updateGoalProgress` appends a timestamped note and **derives** status from
  progress — don't set status independently of progress.
- Status and progress colours come from `goal_colors.dart` (`goalStatusColor`,
  `goalProgressColor`: ≥75 success, ≥50 warning, else error); category colours are
  the categorical `goalCategoryColor` palette.

## Debt

- `RobinKnowledgeBloc` is a lazy **singleton** (state survives leaving the screen),
  unlike every other feature BLoC. Intended: the timeline, its widgets and the goal
  details route share one goals list. `RobinKnowledgeScreen` provides it with
  `BlocProvider.value(getIt<RobinKnowledgeBloc>())`; pushed routes receive it with
  `BlocProvider.value(value: context.read<RobinKnowledgeBloc>())`.
- `PlannerRepositoryInterface` lacks the `I` prefix; the bloc uses `part`/`part of`.
- `updateGoal` never writes `completed`.
- The Firestore `planner` rule is open to any signed-in user (`firebase.md`).
