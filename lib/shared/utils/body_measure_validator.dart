import 'package:flutter/widgets.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/body_measure.dart';

FormFieldValidator<String> bodyMeasureValidator(
  BodyMeasure measure, {
  required AppLocalizations l10n,
  required String missingMessage,
  required String invalidMessage,
}) =>
    (value) => switch (measure.check(value)) {
      null => null,
      BodyMeasureIssue.missing => missingMessage,
      BodyMeasureIssue.notANumber => invalidMessage,
      BodyMeasureIssue.outOfRange => l10n.bodyMeasureOutOfRange(
        measure.min,
        measure.max,
      ),
    };
