/// A body measurement typed into the Zoro and Sanji forms, with the bounds a
/// real person falls within. A value outside them would save an infinite or
/// absurd BMI into the month's assessment.
enum BodyMeasure {
  age(min: 10, max: 120, wholeNumber: true),
  heightCm(min: 50, max: 260),
  weightKg(min: 20, max: 400),
  waistCm(min: 30, max: 250);

  const BodyMeasure({
    required this.min,
    required this.max,
    this.wholeNumber = false,
  });

  final int min;
  final int max;
  final bool wholeNumber;

  /// The typed value, or null when it is missing, not a number, or outside
  /// [min]..[max]. Accepts a comma as the decimal separator ("72,5").
  double? parse(String? text) =>
      check(text) == null ? _parseNumber(text!) : null;

  BodyMeasureIssue? check(String? text) {
    final trimmed = text?.trim() ?? '';
    if (trimmed.isEmpty) return BodyMeasureIssue.missing;
    final value = _parseNumber(trimmed);
    if (value == null) return BodyMeasureIssue.notANumber;
    if (value < min || value > max) return BodyMeasureIssue.outOfRange;
    return null;
  }

  double? _parseNumber(String text) {
    final normalized = text.trim().replaceAll(',', '.');
    if (wholeNumber) return int.tryParse(normalized)?.toDouble();
    final value = double.tryParse(normalized);
    return value != null && value.isFinite ? value : null;
  }
}

enum BodyMeasureIssue { missing, notANumber, outOfRange }
