import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';

/// Duel scoring rules — see `.claude/rules/domains/crews-characters-duels.md`.
///
/// Pure and deterministic: the random part of a duel comes in as [roll1] /
/// [roll2] so callers own the randomness and tests can fix it.
class DuelScoring {
  const DuelScoring._();

  /// Exclusive upper bound of each fighter's random roll (0–79).
  static const rollRange = 80;

  static const _importantAffiliations = [
    'yonkou',
    'admiral',
    'shichibukai',
    'four emperors',
  ];

  /// Returns the winner; a tie goes to [character1].
  static CustomCharacterModel winner(
    CustomCharacterModel character1,
    CustomCharacterModel character2, {
    required int roll1,
    required int roll2,
  }) {
    final score1 =
        baseScore(character1) + matchupBonus(character1, character2) + roll1;
    final score2 =
        baseScore(character2) + matchupBonus(character2, character1) + roll2;
    return score1 >= score2 ? character1 : character2;
  }

  /// Haki, devil fruit, affiliations and fighting style, before matchups.
  static int baseScore(CustomCharacterModel character) {
    var score = 0;

    for (final hakiType in character.haki ?? const <String>[]) {
      if (_isKings(hakiType)) score += 50;
      if (_isArmament(hakiType)) score += 40;
      if (_isObservation(hakiType)) score += 30;
    }

    if (_hasDevilFruit(character)) score += 25;

    for (final affiliation in character.affiliations) {
      final normalized = affiliation.toLowerCase();
      if (_importantAffiliations.any(normalized.contains)) score += 30;
    }

    final fightingStyle = character.fightingStyle;
    if (fightingStyle != null) {
      score += switch (fightingStyle.type.toLowerCase()) {
        'swordsman' => 20,
        'martial_arts' => 15,
        _ => 10,
      };
    }

    return score;
  }

  /// What [attacker] gains (or loses) against this particular [defender].
  static int matchupBonus(
    CustomCharacterModel attacker,
    CustomCharacterModel defender,
  ) {
    final attackerHaki = attacker.haki;
    final defenderHaki = defender.haki;
    var bonus = 0;

    if (attackerHaki != null &&
        _hasDevilFruit(defender) &&
        attackerHaki.any(_isArmament)) {
      bonus += 20;
    }

    final defenderType = defender.fightingStyle?.type;
    if (attackerHaki != null &&
        (defenderType == 'martial_arts' || defenderType == 'swordsman') &&
        attackerHaki.any(_isObservation)) {
      bonus += 10;
    }

    final attackerHasKings = attackerHaki?.any(_isKings) ?? false;
    final defenderHasKings = defenderHaki?.any(_isKings) ?? false;
    if (attackerHasKings && !defenderHasKings) bonus += 20;

    if (_hasDevilFruit(attacker) &&
        defenderHaki != null &&
        defenderHaki.any(_isArmament)) {
      bonus -= 20;
    }

    return bonus;
  }

  static bool _hasDevilFruit(CustomCharacterModel character) =>
      character.devilFruit?.isNotEmpty ?? false;

  static bool _isKings(String haki) {
    final normalized = haki.toLowerCase();
    return normalized.contains('haoshoku') || normalized.contains('king');
  }

  static bool _isArmament(String haki) {
    final normalized = haki.toLowerCase();
    return normalized.contains('busoshoku') || normalized.contains('armament');
  }

  static bool _isObservation(String haki) {
    final normalized = haki.toLowerCase();
    return normalized.contains('kenbunshoku') ||
        normalized.contains('observation');
  }
}
