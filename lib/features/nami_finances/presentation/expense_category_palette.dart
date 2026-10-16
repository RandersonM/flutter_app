import 'package:flutter/material.dart';

/// Categorical palette: the colour identifies an expense category, not a
/// status. Keyed by enum name because the setup form still has its own copy of
/// the `ExpenseCategory` enum next to the model's.
abstract final class ExpenseCategoryPalette {
  static Color of(BuildContext context, Enum category) {
    final palette = Theme.of(context).brightness == Brightness.dark
        ? _dark
        : _light;
    return palette[category.name] ?? palette['other']!;
  }

  static const _light = <String, Color>{
    'fixed': Color(0xFFE1140A), // harness:allow categorical
    'food': Color(0xFFFF6D1B), // harness:allow categorical
    'transport': Color(0xFF1976D2), // harness:allow categorical
    'entertainment': Color(0xFF7C3AED), // harness:allow categorical
    'health': Color(0xFF43A047), // harness:allow categorical
    'other': Color(0xFF757575), // harness:allow categorical
  };

  static const _dark = <String, Color>{
    'fixed': Color(0xFFFC8181), // harness:allow categorical
    'food': Color(0xFFF6AD55), // harness:allow categorical
    'transport': Color(0xFF63B3ED), // harness:allow categorical
    'entertainment': Color(0xFFA78BFA), // harness:allow categorical
    'health': Color(0xFF4ADE80), // harness:allow categorical
    'other': Color(0xFF9CA3AF), // harness:allow categorical
  };
}
