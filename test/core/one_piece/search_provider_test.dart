// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_app/core/one_piece/models/character.dart';
import 'package:simple_app/core/one_piece/search_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('One piece search characters', () {
    SearchProvider provider = SearchProvider();

    test('Should get empty list if there is no match', () async {
      provider.query = 'batata';

      await provider.filter();

      List<Character> filtered = provider.queryResults;

      expect(filtered, isEmpty);
    });

    test('Should get by nickname', () async {
      provider.query = 'Black leg';

      await provider.filter();

      List<Character> filtered = provider.queryResults;

      expect(filtered.first.nickname, provider.query);
    });

    test('Should not be case sensitive', () async {
      provider.query = 'luffy';

      await provider.filter();

      List<Character> filtered = provider.queryResults;

      provider.query = 'LUFFY';

      await provider.filter();

      List<Character> upperFiltered = provider.queryResults;

      expect(filtered.first.name, upperFiltered.first.name);
    });
  });
}
