import 'package:flutter/material.dart';

/// Categorical palette for the plate guide: each colour only names a food
/// group, it carries no status, so it has no theme role. Mid-tones stay
/// readable as pie fills and legend text on both light and dark cards.
abstract final class PlateSectionPalette {
  static const vegetables = Color(0xFF6AC346); // harness:allow categorical
  static const proteins = Color(0xFFE1140A); // harness:allow categorical
  static const carbohydrates = Color(0xFF8D6E63); // harness:allow categorical

  /// Pie labels sit on the fixed fills above, never on a theme surface.
  static const label = Colors.white; // harness:allow on fixed fill
  static const labelShadow = Colors.black; // harness:allow on fixed fill
}
