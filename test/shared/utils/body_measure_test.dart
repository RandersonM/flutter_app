import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/shared/utils/body_measure.dart';

void main() {
  group('BodyMeasure behaviour', () {
    test('accepts a comma as the decimal separator', () {
      expect(BodyMeasure.weightKg.parse('72,5'), 72.5);
      expect(BodyMeasure.weightKg.parse(' 72.5 '), 72.5);
      expect(BodyMeasure.heightCm.parse('175'), 175);
    });

    test('rejects zero and negative values as out of range', () {
      expect(BodyMeasure.heightCm.check('0'), BodyMeasureIssue.outOfRange);
      expect(BodyMeasure.weightKg.check('-3'), BodyMeasureIssue.outOfRange);
      expect(BodyMeasure.heightCm.parse('0'), isNull);
      expect(BodyMeasure.weightKg.parse('-3'), isNull);
    });

    test('rejects values beyond a human range', () {
      expect(BodyMeasure.heightCm.check('49'), BodyMeasureIssue.outOfRange);
      expect(BodyMeasure.heightCm.check('261'), BodyMeasureIssue.outOfRange);
      expect(BodyMeasure.weightKg.check('401'), BodyMeasureIssue.outOfRange);
      expect(BodyMeasure.age.check('121'), BodyMeasureIssue.outOfRange);
    });

    test('accepts the range bounds', () {
      expect(BodyMeasure.heightCm.check('50'), isNull);
      expect(BodyMeasure.heightCm.check('260'), isNull);
      expect(BodyMeasure.weightKg.check('20'), isNull);
      expect(BodyMeasure.weightKg.check('400'), isNull);
    });

    test('reports text that is not a number', () {
      expect(BodyMeasure.weightKg.check('abc'), BodyMeasureIssue.notANumber);
      expect(BodyMeasure.weightKg.check('NaN'), BodyMeasureIssue.notANumber);
      expect(
        BodyMeasure.weightKg.check('Infinity'),
        BodyMeasureIssue.notANumber,
      );
      expect(BodyMeasure.weightKg.parse('abc'), isNull);
    });

    test('reports a missing value', () {
      expect(BodyMeasure.weightKg.check(null), BodyMeasureIssue.missing);
      expect(BodyMeasure.weightKg.check('  '), BodyMeasureIssue.missing);
    });

    test('takes age as a whole number only', () {
      expect(BodyMeasure.age.parse('30'), 30);
      expect(BodyMeasure.age.check('30,5'), BodyMeasureIssue.notANumber);
    });
  });
}
