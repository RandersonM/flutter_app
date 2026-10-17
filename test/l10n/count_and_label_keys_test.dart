import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/l10n/app_localizations_en.dart';
import 'package:opfan/l10n/app_localizations_pt.dart';

void main() {
  final en = AppLocalizationsEn();
  final pt = AppLocalizationsPt();

  group('count and label keys behaviour', () {
    test('joins a label and its value', () {
      expect(en.labelValue(en.captain, 'Luffy'), 'Captain: Luffy');
      expect(pt.labelValue(pt.captain, 'Luffy'), 'Capitão: Luffy');
    });

    test('puts the member count inside the plural phrase', () {
      expect(en.membersCount(0), 'No members');
      expect(en.membersCount(1), '1 member');
      expect(en.membersCount(3), '3 members');
      expect(pt.membersCount(3), '3 membros');
    });

    test('counts haki types and goals in both languages', () {
      expect(en.hakiTypesCount(1), '1 type');
      expect(pt.hakiTypesCount(2), '2 tipos');
      expect(en.goalsTotal(5), '5 total');
      expect(pt.goalsTotal(5), '5 no total');
    });

    test('quotes the query in the empty search message', () {
      expect(en.noResultsFoundFor('Zoro'), 'No results found for "Zoro"');
      expect(
        pt.noResultsFoundFor('Zoro'),
        'Nenhum resultado encontrado para "Zoro"',
      );
    });
  });
}
