# Tasks: Sanji Cooking Screen Redesign

## T1 — Remove GomuGomuDivider, replace with spacing
- **Goal**: Replace all `GomuGomuDivider` usages in `nutrition_results.dart` with `SizedBox(height: 24)`
- **Files**: `nutrition_results.dart`
- **Req**: COOK-01
- **Status**: [ ] Pending

## T2 — Redesign CookingHeader quote section
- **Goal**: Remove `Border.symmetric(horizontal: purple)` from quote container. Add subtle violet glow shadow. Keep quote text amber.
- **Files**: `cooking_header.dart`
- **Req**: COOK-02
- **Status**: [ ] Pending

## T3 — Redesign calorie goal cards (neutral + selected-violet)
- **Goal**: Refactor `_buildCalorieCard` — neutral dark card for all; solid violet bg + white text for selected goal
- **Files**: `nutrition_results.dart`
- **Req**: COOK-03
- **Status**: [ ] Pending

## T4 — Classification chips
- **Goal**: Refactor `_buildClassificationCard` — single neutral card, small colored dot + label text, no colored background
- **Files**: `nutrition_results.dart`
- **Req**: COOK-04
- **Status**: [ ] Pending

## T5 — Receita Personalizada card
- **Goal**: Refactor the ElevatedButton "recipe" card — dark bg, amber border, amber icon/title, white body, violet ElevatedButton CTA
- **Files**: `nutrition_results.dart`
- **Req**: COOK-05
- **Status**: [ ] Pending

## T6 — Plate Guide card
- **Goal**: Refactor `_buildPlateGuideButton` — dark bg, violet border, violet icon/title, violet button
- **Files**: `nutrition_results.dart`
- **Req**: COOK-06
- **Status**: [ ] Pending

## T7 — Metric cards (BMR / TDEE)
- **Goal**: Refactor `_buildMetricCard` — no colored text; TDEE value uses amber; BMR uses text primary
- **Files**: `nutrition_results.dart`
- **Req**: COOK-07
- **Status**: [ ] Pending

## T8 — Verify
- **Goal**: `flutter analyze` zero new issues; hot-reload visual verification
- **Files**: All changed files
- **Req**: All
- **Status**: [ ] Pending
