import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/errors/app_exceptions.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/crews/data/repository/crew_repository.dart';

class _MockFirestoreService extends Mock implements IFirestoreService {}

Map<String, dynamic> _member(String id, String role) => {
  'characterId': id,
  'name': id,
  'role': role,
  'bounty': '0',
};

final _strawHats = {
  'id': 'c1',
  'name': 'Straw Hats',
  'userId': 'alice',
  'captain': 'luffy',
  'viceCaptain': 'zoro',
  'rolesFilled': ['captain', 'viceCaptain', 'cook'],
  'members': [
    _member('luffy', 'captain'),
    _member('zoro', 'viceCaptain'),
    _member('sanji', 'cook'),
  ],
};

final _heartPirates = {
  'id': 'c2',
  'name': 'Heart Pirates',
  'userId': 'alice',
  'captain': 'law',
  'rolesFilled': ['captain', 'navigator'],
  'members': [_member('law', 'captain'), _member('bepo', 'navigator')],
};

CrewMember _sanjiAs(String? role, {String name = 'sanji'}) =>
    CrewMember(characterId: 'sanji', name: name, role: role, bounty: '0');

void main() {
  late _MockFirestoreService firestore;
  late CrewRepository repository;

  Map<String, Map<String, dynamic>> batchedCrews() {
    final captured = verify(
      () => firestore.updateDocumentsInBatch(
        collection: 'crews',
        updates: captureAny(named: 'updates'),
      ),
    ).captured;
    return captured.single as Map<String, Map<String, dynamic>>;
  }

  List<String?> memberIds(Map<String, dynamic> crew) => [
    for (final member in crew['members'] as List) member['characterId'],
  ];

  setUp(() {
    firestore = _MockFirestoreService();
    repository = CrewRepository(firestoreService: firestore);
    when(
      () => firestore.getUserDocuments(
        collection: 'crews',
        orderBy: any(named: 'orderBy'),
        descending: any(named: 'descending'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => [_strawHats, _heartPirates]);
    when(
      () => firestore.getDocument(collection: 'crews', documentId: 'c2'),
    ).thenAnswer((_) async => _heartPirates);
    when(
      () => firestore.updateDocumentsInBatch(
        collection: any(named: 'collection'),
        updates: any(named: 'updates'),
      ),
    ).thenAnswer((_) async {});
  });

  group('CrewRepository moveMember behaviour', () {
    test('moves a member to another crew in one batch', () async {
      await repository.moveMember(_sanjiAs('doctor'), toCrewId: 'c2');

      final crews = batchedCrews();
      expect(crews.keys, unorderedEquals(['c1', 'c2']));
      expect(memberIds(crews['c1']!), isNot(contains('sanji')));
      expect(crews['c1']!['rolesFilled'], isNot(contains('cook')));
      expect(memberIds(crews['c2']!), contains('sanji'));
      expect(crews['c2']!['rolesFilled'], contains('doctor'));
    });

    test('changes the role inside the same crew', () async {
      await repository.moveMember(_sanjiAs('doctor'), toCrewId: 'c1');

      final crew = batchedCrews()['c1']!;
      expect(memberIds(crew).where((id) => id == 'sanji'), hasLength(1));
      expect(crew['rolesFilled'], containsAll(['doctor', 'captain']));
      expect(crew['rolesFilled'], isNot(contains('cook')));
    });

    test('keeps the role the member already holds in its crew', () async {
      await repository.moveMember(_sanjiAs('cook'), toCrewId: 'c1');

      expect(batchedCrews()['c1']!['rolesFilled'], contains('cook'));
    });

    test('takes the member out of its crew when no crew is given', () async {
      await repository.moveMember(_sanjiAs(null));

      final crews = batchedCrews();
      expect(crews.keys, ['c1']);
      expect(memberIds(crews['c1']!), isNot(contains('sanji')));
    });

    test('writes nothing when the role is taken in the new crew', () async {
      await expectLater(
        repository.moveMember(_sanjiAs('navigator'), toCrewId: 'c2'),
        throwsA(isA<CrewRoleTakenException>()),
      );

      verifyNever(
        () => firestore.updateDocumentsInBatch(
          collection: any(named: 'collection'),
          updates: any(named: 'updates'),
        ),
      );
    });
  });

  group('CrewRepository syncMemberCopies behaviour', () {
    test('renames the member and the title it holds', () async {
      await repository.syncMemberCopies('zoro', name: 'Zoro', bounty: '0');

      final crew = batchedCrews()['c1']!;
      expect(crew['viceCaptain'], 'Zoro');
      final zoro = (crew['members'] as List).firstWhere(
        (member) => member['characterId'] == 'zoro',
      );
      expect(zoro['name'], 'Zoro');
      expect(zoro['role'], 'viceCaptain');
    });

    test('writes nothing when every copy is current', () async {
      await repository.syncMemberCopies('sanji', name: 'sanji', bounty: '0');

      verifyNever(
        () => firestore.updateDocumentsInBatch(
          collection: any(named: 'collection'),
          updates: any(named: 'updates'),
        ),
      );
    });
  });
}
