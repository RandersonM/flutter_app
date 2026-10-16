import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/shared/utils/devil_fruit_type_palette.dart';

void main() {
  group('DevilFruitTypePalette.of', () {
    test('gives each fruit type its own accent', () {
      final accents = {
        DevilFruitTypePalette.of('Logia').accent,
        DevilFruitTypePalette.of('Paramecia').accent,
        DevilFruitTypePalette.of('Zoan').accent,
      };

      expect(accents, hasLength(3));
    });

    test('matches the type case-insensitively', () {
      expect(
        DevilFruitTypePalette.of('ZOAN').accent,
        DevilFruitTypePalette.of('zoan').accent,
      );
    });

    test('falls back to the Logia palette for an unknown type', () {
      expect(
        DevilFruitTypePalette.of('Smile').accent,
        DevilFruitTypePalette.of('Logia').accent,
      );
    });

    test('starts the gradient with the accent', () {
      final palette = DevilFruitTypePalette.of('Paramecia');

      expect(palette.gradient.colors.first, palette.accent);
    });
  });
}
