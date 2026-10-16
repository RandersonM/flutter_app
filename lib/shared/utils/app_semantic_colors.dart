import 'package:flutter/material.dart';

import 'theme.dart';

/// Status colors that Material's [ColorScheme] has no slot for.
///
/// `ColorScheme` already covers brand and surface roles (primary, secondary,
/// tertiary, error, surface…) — use those. What it lacks is *semantic status*:
/// success, warning and info. Those were previously written as raw
/// `Colors.green` / `Colors.orange` / `Colors.blue` in widgets, which meant
/// every widget independently guessed a value and none of them adapted to the
/// active theme. Dark mode needs lighter, less saturated variants to keep
/// contrast against a dark surface, and that decision belongs here, once.
///
/// Usage:
/// ```dart
/// final semantic = Theme.of(context).semanticColors;
/// Icon(Icons.check, color: semantic.success);
/// ```
///
/// For error/danger use `Theme.of(context).colorScheme.error` — do not add a
/// duplicate slot for it here.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
  });

  /// Completed / achieved / positive delta.
  final Color success;
  final Color onSuccess;

  /// Tinted background for a success badge or chip.
  final Color successContainer;

  /// Caution, pending, over-budget — not yet an error.
  final Color warning;
  final Color onWarning;
  final Color warningContainer;

  /// Neutral informational accent.
  final Color info;
  final Color onInfo;
  final Color infoContainer;

  static const AppSemanticColors light = AppSemanticColors(
    success: Color(0xFF2E7D32),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFDCEFD9),
    warning: Color(0xFFB25000),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFFE6D1),
    info: Color(0xFF1565C0),
    onInfo: Color(0xFFFFFFFF),
    infoContainer: Color(0xFFD7E7FA),
  );

  /// Lighter, less saturated than [light] — saturated mid-tones fail contrast
  /// against the dark surface (#151419).
  static const AppSemanticColors dark = AppSemanticColors(
    success: Color(0xFF7BD87F),
    onSuccess: Color(0xFF10240F),
    successContainer: Color(0xFF23401F),
    warning: Color(0xFFFFB176),
    onWarning: Color(0xFF2B1400),
    warningContainer: Color(0xFF4A2A10),
    info: Color(0xFF8FC3F5),
    onInfo: Color(0xFF0A1B2E),
    infoContainer: Color(0xFF1C3550),
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
    );
  }

  @override
  AppSemanticColors lerp(covariant AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
    );
  }
}

extension AppSemanticColorsX on ThemeData {
  /// Status colors for the active theme.
  ///
  /// Falls back to [AppSemanticColors.light] only if the extension was not
  /// registered — which would mean a `ThemeData` built outside
  /// [getLightTheme] / [getDarkTheme].
  AppSemanticColors get semanticColors =>
      extension<AppSemanticColors>() ?? AppSemanticColors.light;
}
