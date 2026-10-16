# Feature Spec: Sanji Cooking Screen — Visual Redesign

## Objective

Reduce visual noise by trimming the color palette from 6+ competing colors to 3:
**90% neutral + 8% violet + 2% amber/gold**.

## Design Token Reference

### Color Palette (fixed, mode-adaptive)

| Token | Dark | Light |
|---|---|---|
| Background | `#09090B` (scaffold) | `#F7F7FA` |
| Surface | `#16161C` | `#FFFFFF` |
| Card | `#1D1D24` | `#FCFCFD` |
| Violet accent | `#7C3AED` | `#7C3AED` |
| Amber accent | `#FACC15` | `#FACC15` |
| Text primary | `#FAFAFA` | `#09090B` |
| Text muted | `#A1A1AA` | `#71717A` |
| Alert red | `#EF4444` | `#DC2626` |
| Alert orange | `#F97316` | `#EA580C` |

> Violet and amber are used only for interactive/accent elements. Red/orange only for health alert chips.

---

## Requirements

| ID | Requirement |
|---|---|
| COOK-01 | Remove `GomuGomuDivider` (wavy purple wave) — replace with `24px` vertical spacing |
| COOK-02 | `CookingHeader` quote area: remove purple horizontal border; use subtle violet glow shadow instead |
| COOK-03 | Calorie goal cards: neutral dark card (`#1D1D24`), no colored border; only the **user's selected goal** gets solid violet background + white text |
| COOK-04 | Classification chips (BMI / Waist-Height): replace large colored cards with small inline chips; color only the status dot/icon, not the whole card background |
| COOK-05 | "Receita Personalizada" card: dark card (`#1D1D24`), amber border (`#FACC15`), amber icon+title, white body text, violet CTA button |
| COOK-06 | "Plate Guide" card: align to same style as COOK-05 but with violet accent border |
| COOK-07 | Metric cards (BMR / TDEE): neutral layout; no colored text unless it is the TDEE card which uses amber for the value only |

## Acceptance Criteria

- Zero colored borders on non-alert elements
- No more than 2 accent colors visible at the same time on screen
- `GomuGomuDivider` replaced with `SizedBox(height: 24)` spacing
- Classification result shown as small chip inside a neutral card, with colored dot
- Selected goal card uses `#7C3AED` background; others use card neutral
- Receita card border: `#FACC15`; CTA button: `#7C3AED`
- All text on dark surfaces: white or `#A1A1AA` (muted)
- `flutter analyze` reports zero new issues after changes
