import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/features/crews/data/repository/crew_repository_interface.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/custom_character/data/repository/custom_character_repository.dart';

class _MockFirestoreService extends Mock implements IFirestoreService {}

class _MockCrewRepository extends Mock implements ICrewRepository {}

Map<String, dynamic> _character(String id, String bounty) => {
  'id': id,
  'userId': 'alice',
  'name': id,
  'bounty': bounty,
};

void main() {
  group('CustomCharacterModel.parseBounty', () {
    test('reads display-formatted bounties as numbers', () {
      expect(CustomCharacterModel.parseBounty('3,000,000,000'), 3000000000);
      expect(CustomCharacterModel.parseBounty('900.000'), 900000);
      expect(CustomCharacterModel.parseBounty('฿ 1,500'), 1500);
    });

    test('treats empty or non-numeric bounties as zero', () {
      expect(CustomCharacterModel.parseBounty(''), 0);
      expect(CustomCharacterModel.parseBounty('unknown'), 0);
    });
  });

  group('CustomCharacterRepository bounty ordering', () {
    late _MockFirestoreService firestore;
    late CustomCharacterRepository repository;

    setUp(() {
      firestore = _MockFirestoreService();
      repository = CustomCharacterRepository(
        _MockCrewRepository(),
        firestoreService: firestore,
      );
      when(
        () => firestore.getUserDocuments(
          collection: any(named: 'collection'),
          orderBy: any(named: 'orderBy'),
          descending: any(named: 'descending'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => [
          _character('luffy', '3,000,000,000'),
          _character('usopp', '500,000,000'),
          _character('chopper', '1,000'),
          _character('buggy', '900,000'),
        ],
      );
    });

    test('sorts by numeric value, not by text', () async {
      final sorted = await repository.getUserCustomCharacters(
        orderBy: 'bounty',
      );

      expect(sorted.map((c) => c.id), ['chopper', 'buggy', 'usopp', 'luffy']);
    });

    test('sorts descending by numeric value', () async {
      final sorted = await repository.getUserCustomCharacters(
        orderBy: 'bounty',
        descending: true,
      );

      expect(sorted.first.id, 'luffy');
      expect(sorted.last.id, 'chopper');
    });

    test('filters a bounty range numerically', () async {
      final inRange = await repository.getCustomCharactersByBountyRange(
        minBounty: '1,000,000',
        maxBounty: '1,000,000,000',
      );

      expect(inRange.map((c) => c.id), ['usopp']);
    });
  });
}
