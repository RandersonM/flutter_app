import 'package:flutter/material.dart';

/// Colours that identify a devil fruit type (Logia, Paramecia, Zoan). They
/// encode a category, not a status, so they stay the same in light and dark.
class DevilFruitTypePalette {
  const DevilFruitTypePalette._(this.accent, this._gradientEnd);

  /// Type label, filter chip and icon colour; also the gradient start.
  final Color accent;
  final Color _gradientEnd;

  /// Text and overlays drawn on top of [gradient].
  static const Color onGradient = Colors.white; // harness:allow decorative

  static const _logia = DevilFruitTypePalette._(
    Color(0xFF667EEA), // harness:allow categorical
    Color(0xFF764BA2), // harness:allow categorical
  );
  static const _paramecia = DevilFruitTypePalette._(
    Color(0xFF11998E), // harness:allow categorical
    Color(0xFF38EF7D), // harness:allow categorical
  );
  static const _zoan = DevilFruitTypePalette._(
    Color(0xFFF093FB), // harness:allow categorical
    Color(0xFFF5576C), // harness:allow categorical
  );

  static DevilFruitTypePalette of(String type) => switch (type.toLowerCase()) {
    'paramecia' => _paramecia,
    'zoan' => _zoan,
    _ => _logia,
  };

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, _gradientEnd],
  );
}
