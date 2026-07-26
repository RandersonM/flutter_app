# Feature Spec: Design and Contrast Refactor

This specification outlines the visual redesign and color contrast improvements for the application, following the 60-30-10 design rule, establishing a modern purple-themed palette, and replacing the outdated bottom navigation bar with an elegant floating design.

## Requirements Traceability

| ID | Requirement | Description |
|---|---|---|
| **DSGN-01** | Color Contrast Improvement | Standardize text and button color contrast to meet WCAG AA (at least 4.5:1 ratio) for readability, fixing dark-on-dark button text. |
| **DSGN-02** | Light Theme Refactor | Refactor light theme: off-white/light-gray background (60%), slate/indigo-tinted gray details (30%), vibrant violet/purple accents (10%). |
| **DSGN-03** | Dark Theme Refactor | Refactor dark theme: matte black background (60%), deep charcoal/dark gray surfaces (30%), vibrant purple/lavender accents (10%). |
| **DSGN-04** | Primary Button Redesign | Primary buttons must use the purple accent with high-contrast text (white for light/dark theme depending on the background contrast). |
| **DSGN-05** | Bottom Bar Redesign | Replace the bottom bar with an elegant, modern, floating navigation bar with a fixed dark-plum/eggplant background and a top-capsule active indicator. |
| **DSGN-06** | Bottom Bar Docked to Screen Edge | The bottom bar MUST be flush with the bottom of the screen (no floating gap, no outer padding-bottom, no surrounding border). Color is fixed at `Color(0xFF2D1648)` in both themes. Only top corners are rounded. Safe area is respected via internal padding. Active capsule uses solid `Color(0xFF7C3AED)`. |

## Acceptance Criteria

### 1. Theming & Colors (DSGN-01, DSGN-02, DSGN-03, DSGN-04)
- **Light Theme**:
  - Scaffold background is off-white (`Color(0xFFF8F9FA)` or `Color(0xFFF3F4F6)`).
  - Primary color is a vibrant violet (`Color(0xFF7C3AED)`).
  - Cards and dialogs have a clean white background, a very subtle lavender-tinted border, and soft shadows.
  - Buttons with solid primary color have white text, ensuring high contrast.
- **Dark Theme**:
  - Scaffold background is matte black (`Color(0xFF0F0E13)`).
  - Surface cards use a slightly lighter matte black/charcoal (`Color(0xFF18171C)`).
  - Primary color is a lighter lavender/violet (`Color(0xFFC084FC)` or `Color(0xFFD8B4FE)`).
  - Text on primary buttons is high-contrast dark.
- **60-30-10 Rule**:
  - **60%**: Dominant backgrounds (off-white for light, matte black for dark).
  - **30%**: Secondary structures (cards, secondary text, border outlines, disabled states).
  - **10%**: Interactive/accent elements (buttons, active tabs, select indicators, main brand icons).

### 2. Floating Bottom Bar (DSGN-05)
- **Fixed Dark Plum Background**: Same color in both light and dark mode (`Color(0xFF1D0B2E)`).
- **Floating design**: elevated off the bottom edge, rounded corners (`BorderRadius.circular(30)`), soft shadow.
- **Unified Items Layout**:
  - Every navigation item displays an icon and a text label underneath it.
  - Labels and icons align perfectly horizontally to avoid layout shifts.
- **Active State (Pill Icon Indicator)**:
  - The selected tab wraps the *icon only* in a translucent violet capsule (`Color(0xFF7C3AED).withOpacity(0.4)` or similar).
  - The text label under the active tab is white (`Colors.white`), while unselected tabs are light silver/lavender with opacity (`Colors.white.withOpacity(0.6)`).
- **Session Continuity**:
  - Maintain compatibility with the existing pages (`BottomNavigationPages`).
  - Proper safe area handling.
