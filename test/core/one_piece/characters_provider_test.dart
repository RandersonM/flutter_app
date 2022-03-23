// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter_test/flutter_test.dart';

import 'package:simple_app/core/one_piece/characters_provider.dart';
import 'package:simple_app/core/one_piece/models/character.dart';
import 'package:simple_app/core/one_piece/services/characters_backend_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('One piece characters', () {
    CharactersProvider provider = CharactersProvider();
    CharactersBackendService service = CharactersBackendService();
    provider.backend = service;

    test('Should get the fist 10 in the characters list', () async {
      await provider.fetchData();

      expect(provider.characters.length, 10);
    });

    test('Should get the characters list size', () async {
      int totalCount = service.totalCount;
      expect(totalCount > 0, true);
    });

    test('Should get until max length of characters list', () async {
      List<Character> charactersFuture = await service.fetch(500);
      expect(charactersFuture.length, service.totalCount);
    });
  });
}
