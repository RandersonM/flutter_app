# Design Details: Design and Contrast Refactor

This document specifies the technical design, including the exact color values, contrast verification, and bottom bar layout.

## 1. Color Palette Redesign

We will redefine the `AppColors.purple` palette in `lib/shared/utils/theme.dart` with modern Tailwind-inspired royal violet/indigo shades:

```dart
static const int _purplePrimaryValue = 0xFF7C3AED; // Violet 600
static const MaterialColor purple = MaterialColor(
  _purplePrimaryValue,
  <int, Color>{
    50: Color(0xFFF5F3FF),   // Violet 50
    100: Color(0xFFEDE9FE),  // Violet 100
    200: Color(0xFFDDD6FE),  // Violet 200
    300: Color(0xFFC4B5FD),  // Violet 300
    350: Color(0xFFA78BFA),  // Violet 400
    400: Color(0xFFA78BFA),  // Violet 400
    500: Color(_purplePrimaryValue),
    600: Color(0xFF7C3AED),  // Violet 600
    700: Color(0xFF6D28D9),  // Violet 700
    800: Color(0xFF5B21B6),  // Violet 800
    900: Color(0xFF4C1D95),  // Violet 900
  },
);
```

## 2. 60-30-10 Theming Architecture

### Light Theme
- **60% (Scaffold Background & Main surfaces)**:
  - `scaffoldBackgroundColor`: `Color(0xFFF8F9FA)` (clean off-white)
  - `surface`: `Color(0xFFF3F4F6)` (light gray container background)
- **30% (Surfaces, Text, Borders, Unselected Items)**:
  - Card & Dialog surface: `Colors.white`
  - Text colors: `Color(0xFF1F2937)` (dark gray for high readability)
  - Border side: `AppColors.purple[100]!` (soft light purple outline)
  - Secondary/unselected text & icons: `Color(0xFF6B7280)`
- **10% (Interactive accents)**:
  - Primary button background / active states: `AppColors.purple[600]` (`0xFF7C3AED`)
  - Accent / Primary text: `AppColors.purple[700]` (`0xFF6D28D9`)
  - Elevated button text: `Colors.white` (fixed contrast!)

### Dark Theme
- **60% (Scaffold Background & Main surfaces)**:
  - `scaffoldBackgroundColor`: `Color(0xFF0F0E13)` (deep matte black with soft purple/gray tone)
  - `surface`: `Color(0xFF151419)`
- **30% (Surfaces, Text, Borders, Unselected Items)**:
  - Card & Dialog surface: `Color(0xFF1E1D24)` (charcoal matte black card surface)
  - Text colors: `Color(0xFFF3F4F6)` (off-white for crisp readability)
  - Border side: `AppColors.purple[900]!.withOpacity(0.3)`
  - Secondary/unselected text & icons: `Color(0xFF9CA3AF)`
- **10% (Interactive accents)**:
  - Primary button background / active states: `AppColors.purple[300]` (`0xFFC4B5FD` / light purple for high contrast on black)
  - Accent / Primary text: `AppColors.purple[300]`
  - Elevated button text: `Color(0xFF1E1B4B)` (dark indigo for high contrast!)

## 3. Elegant Fixed-Color Dark Plum Floating Bottom Navigation Bar

To match the specified screen layout, the bottom navigation bar will use a fixed color palette that does not change between light and dark modes, ensuring a unified visual anchor.

### Visual Styling Specs:
- **Bar Container**:
  - `backgroundColor`: `Color(0xFF1D0B2E)` (deep dark plum/eggplant).
  - `borderRadius`: `BorderRadius.circular(30)` (floating capsule).
  - `border`: `Border.all(color: Colors.white.withOpacity(0.06), width: 1.0)`.
  - `margin`: `EdgeInsets.symmetric(horizontal: 16, vertical: 8)` (elevated slightly above the bottom).
  - `padding`: `EdgeInsets.symmetric(vertical: 8, horizontal: 8)`.
  - `boxShadow`: `BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 16, offset: Offset(0, 8))`.

### Item Layout:
- Every tab consists of a `Column`:
  1. An **Icon Area**:
     - Selected item wraps the icon in an `AnimatedContainer` with background `Color(0xFF7C3AED).withOpacity(0.4)` (translucent violet capsule) and horizontal padding: `22`, vertical padding: `6`.
     - Unselected item has no background color (or `Colors.transparent`) but uses identical dimensions/padding to keep labels perfectly aligned.
     - Icon is `Colors.white` (active) or `Colors.white.withOpacity(0.6)` (inactive).
  2. A **SizedBox** of `6.0` height.
  3. A **Text Label**:
     - Value provided by existing localization.
     - Color: `Colors.white` (active) or `Colors.white.withOpacity(0.6)` (inactive).
     - Style: `FontWeight.w600` (active) or `FontWeight.normal` (inactive).
