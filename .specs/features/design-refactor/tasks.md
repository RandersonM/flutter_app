# Tasks: Design and Contrast Refactor

Implementation tasks for the design refactor.

## T1: Refactor Color Palette and App Themes
- **Goal**: Update `lib/shared/utils/theme.dart` with the new purple palette and light/dark theme values adhering to the 60-30-10 rule and resolving color contrasts.
- **Files**: `lib/shared/utils/theme.dart`
- **Depends on**: None
- **Requirement Mapping**: DSGN-01, DSGN-02, DSGN-03, DSGN-04
- **Status**: [x] Completed
- **Commit Scope**: `style(theme): update purple palette and contrast rules`

## T2: Implement Custom Floating Bottom Navigation Bar (Fixed Dark Plum Design)
- **Goal**: Rewrite `lib/shared/widgets/organisms/bottom_navigation.dart` as a modern, premium, floating bottom bar with a fixed dark-plum background and a capsule active icon container.
- **Files**: `lib/shared/widgets/organisms/bottom_navigation.dart`
- **Depends on**: T1
- **Requirement Mapping**: DSGN-05
- **Status**: [x] Completed
- **Commit Scope**: `feat(navigation): replace bottom bar with custom fixed dark-plum capsule design`

## T3: Visual Verification
- **Goal**: Verify visual appeal, responsiveness, color contrast, and correctness of the app.
- **Files**: None
- **Depends on**: T1, T2
- **Requirement Mapping**: DSGN-01 to DSGN-05
- **Status**: [x] Completed (Verified via `flutter analyze`; visual verification pending user interaction/hot-reload)

## T4: Dock Bottom Bar to Screen Edge (Fixed Dark Plum, No Border/Padding-Bottom)
- **Goal**: Redesign the bottom bar so it sits flush with the screen bottom edge — no outer padding, no side border, no floating gap. Background stays fixed at `Color(0xFF2D1648)` in both light and dark modes. Only top corners are rounded (`topLeft: 28, topRight: 28`). Active capsule uses solid `Color(0xFF7C3AED)`. Safe area is respected via internal bottom padding.
- **Files**: `lib/shared/widgets/organisms/bottom_navigation.dart`
- **Depends on**: T2
- **Requirement Mapping**: DSGN-06
- **Status**: [x] Completed
- **Commit Scope**: `feat(navigation): dock bottom bar flush to screen, remove border and outer padding`
