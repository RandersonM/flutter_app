import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/duels/bloc/duel_scoring.dart';
import 'package:opfan/features/duels/data/models/fighting_style_model.dart';

CustomCharacterModel _fighter(
  String id, {
  List<String>? haki,
  String? devilFruit,
  List<String> affiliations = const [],
  String? style,
}) => CustomCharacterModel(
  id: id,
  name: id,
  haki: haki,
  devilFruit: devilFruit,
  affiliations: affiliations,
  fightingStyle: style == null ? null : FightingStyleModel(type: style),
  image: '',
  occupation: const [],
  bounty: '0',
);

void main() {
  final plain = _fighter('plain');

  group('DuelScoring.baseScore behaviour', () {
    test('scores zero for a fighter with nothing', () {
      expect(DuelScoring.baseScore(plain), 0);
    });

    test('adds 50 for king\'s haki under either name', () {
      expect(DuelScoring.baseScore(_fighter('a', haki: ['Haoshoku'])), 50);
      expect(DuelScoring.baseScore(_fighter('b', haki: ["King's Haki"])), 50);
    });

    test('adds 40 for armament haki under either name', () {
      expect(DuelScoring.baseScore(_fighter('a', haki: ['Busoshoku'])), 40);
      expect(DuelScoring.baseScore(_fighter('b', haki: ['Armament'])), 40);
    });

    test('adds 30 for observation haki under either name', () {
      expect(DuelScoring.baseScore(_fighter('a', haki: ['Kenbunshoku'])), 30);
      expect(DuelScoring.baseScore(_fighter('b', haki: ['Observation'])), 30);
    });

    test('adds up all three haki types', () {
      final all = _fighter(
        'all',
        haki: ['Haoshoku Haki', 'Busoshoku Haki', 'Kenbunshoku Haki'],
      );
      expect(DuelScoring.baseScore(all), 120);
    });

    test('adds 25 for a devil fruit and nothing for an empty one', () {
      expect(DuelScoring.baseScore(_fighter('a', devilFruit: 'Gomu Gomu')), 25);
      expect(DuelScoring.baseScore(_fighter('b', devilFruit: '')), 0);
    });

    test('adds 30 for each important affiliation, case-insensitively', () {
      for (final affiliation in [
        'Yonkou',
        'admiral',
        'Shichibukai',
        'Four Emperors',
      ]) {
        expect(
          DuelScoring.baseScore(_fighter('a', affiliations: [affiliation])),
          30,
          reason: affiliation,
        );
      }
      expect(
        DuelScoring.baseScore(
          _fighter('b', affiliations: ['Yonkou', 'Admiral']),
        ),
        60,
      );
    });

    test('ignores ordinary affiliations', () {
      expect(
        DuelScoring.baseScore(
          _fighter('a', affiliations: ['Marines', 'Pirates']),
        ),
        0,
      );
    });

    test(
      'adds 20 for swordsman, 15 for martial arts and 10 for any other style',
      () {
        expect(DuelScoring.baseScore(_fighter('a', style: 'swordsman')), 20);
        expect(DuelScoring.baseScore(_fighter('b', style: 'Swordsman')), 20);
        expect(DuelScoring.baseScore(_fighter('c', style: 'martial_arts')), 15);
        expect(DuelScoring.baseScore(_fighter('d', style: 'sniper')), 10);
      },
    );
  });

  group('DuelScoring.matchupBonus behaviour', () {
    test('gives nothing when neither side has a matchup', () {
      expect(DuelScoring.matchupBonus(plain, plain), 0);
    });

    test('gives armament +20 against a devil fruit user', () {
      final armament = _fighter('a', haki: ['Busoshoku']);
      final fruitUser = _fighter('f', devilFruit: 'Mera Mera');

      expect(DuelScoring.matchupBonus(armament, fruitUser), 20);
      expect(DuelScoring.matchupBonus(armament, plain), 0);
    });

    test('gives observation +10 against swordsmen and martial artists', () {
      final observation = _fighter('o', haki: ['Kenbunshoku']);

      expect(
        DuelScoring.matchupBonus(
          observation,
          _fighter('s', style: 'swordsman'),
        ),
        10,
      );
      expect(
        DuelScoring.matchupBonus(
          observation,
          _fighter('m', style: 'martial_arts'),
        ),
        10,
      );
      expect(
        DuelScoring.matchupBonus(observation, _fighter('n', style: 'sniper')),
        0,
      );
    });

    test('gives king\'s haki +20 only against a defender without it', () {
      final king = _fighter('k', haki: ['Haoshoku']);

      expect(DuelScoring.matchupBonus(king, plain), 20);
      expect(
        DuelScoring.matchupBonus(king, _fighter('k2', haki: ['Haoshoku'])),
        0,
      );
    });

    test('takes 20 from a devil fruit user facing armament haki', () {
      final fruitUser = _fighter('f', devilFruit: 'Mera Mera');
      final armament = _fighter('a', haki: ['Armament']);

      expect(DuelScoring.matchupBonus(fruitUser, armament), -20);
      expect(DuelScoring.matchupBonus(fruitUser, plain), 0);
    });

    test('combines every matchup that applies', () {
      final attacker = _fighter(
        'att',
        haki: ['Haoshoku', 'Busoshoku', 'Kenbunshoku'],
        devilFruit: 'Gomu Gomu',
      );
      final defender = _fighter(
        'def',
        haki: ['Busoshoku'],
        devilFruit: 'Mera Mera',
        style: 'swordsman',
      );

      expect(DuelScoring.matchupBonus(attacker, defender), 20 + 10 + 20 - 20);
    });
  });

  group('DuelScoring.winner behaviour', () {
    final first = _fighter('first');
    final second = _fighter('second');

    test('gives a tie to the first character', () {
      expect(DuelScoring.winner(first, second, roll1: 40, roll2: 40), first);
    });

    test('picks the higher roll between otherwise equal fighters', () {
      expect(DuelScoring.winner(first, second, roll1: 0, roll2: 1), second);
      expect(DuelScoring.winner(first, second, roll1: 79, roll2: 0), first);
    });

    test('adds base score, matchups and roll for each side', () {
      // King's haki: base 50 + matchup 20 against a fighter without it = 70.
      final king = _fighter('king', haki: ['Haoshoku']);

      expect(DuelScoring.winner(plain, king, roll1: 70, roll2: 0), plain);
      expect(DuelScoring.winner(plain, king, roll1: 69, roll2: 0), king);
    });

    test('lets the matchup penalty swing the fight', () {
      // Fruit user: 25 - 20 = 5. Armament user: 40 + 20 = 60.
      final fruitUser = _fighter('fruit', devilFruit: 'Mera Mera');
      final armament = _fighter('armament', haki: ['Busoshoku']);

      expect(
        DuelScoring.winner(fruitUser, armament, roll1: 55, roll2: 0),
        fruitUser,
      );
      expect(
        DuelScoring.winner(fruitUser, armament, roll1: 54, roll2: 0),
        armament,
      );
    });

    test('keeps rolls within 0 to 79', () {
      expect(DuelScoring.rollRange, 80);
    });
  });
}
