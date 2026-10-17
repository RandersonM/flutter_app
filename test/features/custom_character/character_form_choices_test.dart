import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/custom_character/data/character_form_choices.dart';
import 'package:opfan/features/devil_fruit/data/models/devil_fruit.dart';

void main() {
  final mera = DevilFruit(
    id: 1,
    name: 'Flame-Flame Fruit',
    description: '',
    romanName: 'Mera Mera no Mi',
    type: 'Logia',
  );
  final redHairs = CrewModel(id: 'c1', name: 'Red Hairs', userId: 'u');

  group('character form choices behaviour', () {
    test('finds a devil fruit by its stored roman name', () {
      expect(devilFruitNamed([mera], 'Mera Mera no Mi'), mera);
    });

    test('finds no devil fruit when the options do not list it', () {
      expect(devilFruitNamed([mera], 'Gomu Gomu no Mi'), isNull);
      expect(devilFruitNamed([], 'Gomu Gomu no Mi'), isNull);
      expect(devilFruitNamed([mera], null), isNull);
    });

    test('maps a stored crew name to its id and back', () {
      expect(crewIdNamed([redHairs], 'Red Hairs'), 'c1');
      expect(crewNameWithId([redHairs], 'c1'), 'Red Hairs');
    });

    test('finds no crew when the options do not list it', () {
      expect(crewIdNamed([redHairs], 'Straw Hats'), isNull);
      expect(crewIdNamed([], 'Straw Hats'), isNull);
      expect(crewNameWithId([redHairs], null), isNull);
    });
  });
}
