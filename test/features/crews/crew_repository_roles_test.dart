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

void main() {
  late _MockFirestoreService firestore;
  late CrewRepository repository;

  Future<Map<String, dynamic>> savedCrew() async {
    final captured = verify(
      () => firestore.updateDocument(
        collection: 'crews',
        documentId: 'c1',
        data: captureAny(named: 'data'),
      ),
    ).captured;
    return captured.single as Map<String, dynamic>;
  }

  setUp(() {
    firestore = _MockFirestoreService();
    repository = CrewRepository(firestoreService: firestore);
    when(
      () => firestore.getDocument(collection: 'crews', documentId: 'c1'),
    ).thenAnswer(
      (_) async => {
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
      },
    );
    when(
      () => firestore.updateDocument(
        collection: any(named: 'collection'),
        documentId: any(named: 'documentId'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async {});
  });

  group('removeMemberFromCrew', () {
    test('frees the removed member role so it can be filled again', () async {
      await repository.removeMemberFromCrew('c1', 'sanji');

      final crew = await savedCrew();
      expect(crew['rolesFilled'], ['captain', 'viceCaptain']);
      expect((crew['members'] as List).length, 2);
    });

    test('clears the captain when the captain leaves', () async {
      await repository.removeMemberFromCrew('c1', 'luffy');

      final crew = await savedCrew();
      expect(crew['captain'], '');
      expect(crew['viceCaptain'], 'zoro');
      expect(crew['rolesFilled'], isNot(contains('captain')));
    });

    test('clears the vice captain stored as viceCaptain', () async {
      await repository.removeMemberFromCrew('c1', 'zoro');

      final crew = await savedCrew();
      expect(crew['viceCaptain'], '');
      expect(crew['captain'], 'luffy');
    });
  });

  group('addMemberToCrew', () {
    CrewMember newcomer(String role) => CrewMember(
      characterId: 'buggy',
      name: 'buggy',
      role: role,
      bounty: '0',
    );

    test('refuses a captain when the crew already has one', () async {
      await expectLater(
        repository.addMemberToCrew('c1', newcomer('captain')),
        throwsA(isA<CrewRoleTakenException>()),
      );

      verifyNever(
        () => firestore.updateDocument(
          collection: any(named: 'collection'),
          documentId: any(named: 'documentId'),
          data: any(named: 'data'),
        ),
      );
    });

    test('refuses a taken role written in another spelling', () async {
      await expectLater(
        repository.addMemberToCrew('c1', newcomer('vicecaptain')),
        throwsA(isA<CrewRoleTakenException>()),
      );
    });

    test('accepts a role a legacy crew lists without a holder', () async {
      when(
        () => firestore.getDocument(collection: 'crews', documentId: 'c1'),
      ).thenAnswer(
        (_) async => {
          'name': 'Straw Hats',
          'userId': 'alice',
          'rolesFilled': ['captain', 'doctor'],
          'members': [_member('luffy', 'captain')],
        },
      );

      await repository.addMemberToCrew('c1', newcomer('doctor'));

      final crew = await savedCrew();
      expect((crew['members'] as List).length, 2);
    });

    test('adds a member to a free role', () async {
      await repository.addMemberToCrew('c1', newcomer('doctor'));

      final crew = await savedCrew();
      expect(crew['rolesFilled'], contains('doctor'));
      expect(crew['captain'], 'luffy');
      expect((crew['members'] as List).length, 4);
    });
  });

  group('removeMemberFromCrew with a role held twice', () {
    setUp(() {
      when(
        () => firestore.getDocument(collection: 'crews', documentId: 'c1'),
      ).thenAnswer(
        (_) async => {
          'name': 'Legacy',
          'userId': 'alice',
          'captain': 'buggy',
          'viceCaptain': 'zoro',
          'rolesFilled': ['captain', 'viceCaptain'],
          'members': [
            _member('luffy', 'captain'),
            _member('buggy', 'captain'),
            _member('zoro', 'viceCaptain'),
          ],
        },
      );
    });

    test('hands the captain title to the captain who stays', () async {
      await repository.removeMemberFromCrew('c1', 'buggy');

      final crew = await savedCrew();
      expect(crew['captain'], 'luffy');
      expect(crew['rolesFilled'], contains('captain'));
    });

    test('keeps the stored captain when the other captain leaves', () async {
      await repository.removeMemberFromCrew('c1', 'luffy');

      final crew = await savedCrew();
      expect(crew['captain'], 'buggy');
      expect(crew['rolesFilled'], contains('captain'));
    });
  });

  group('updateCrewMember', () {
    test('renames the captain along with the member', () async {
      await repository.updateCrewMember(
        'c1',
        'luffy',
        CrewMember(
          characterId: 'luffy',
          name: 'Joy Boy',
          role: 'captain',
          bounty: '0',
        ),
      );

      final crew = await savedCrew();
      expect(crew['captain'], 'Joy Boy');
      expect((crew['members'] as List).first['name'], 'Joy Boy');
      expect(crew['rolesFilled'], contains('captain'));
    });

    test('frees the previous role when a member changes role', () async {
      await repository.updateCrewMember(
        'c1',
        'sanji',
        CrewMember(
          characterId: 'sanji',
          name: 'sanji',
          role: 'doctor',
          bounty: '0',
        ),
      );

      final crew = await savedCrew();
      expect(crew['rolesFilled'], containsAll(['doctor', 'captain']));
      expect(crew['rolesFilled'], isNot(contains('cook')));
    });

    test('recognises the viceCaptain key the UI writes', () async {
      await repository.updateCrewMember(
        'c1',
        'zoro',
        CrewMember(
          characterId: 'zoro',
          name: 'Roronoa',
          role: 'viceCaptain',
          bounty: '0',
        ),
      );

      final crew = await savedCrew();
      expect(crew['viceCaptain'], 'Roronoa');
    });

    test('refuses a role another member already holds', () async {
      await expectLater(
        repository.updateCrewMember(
          'c1',
          'sanji',
          CrewMember(
            characterId: 'sanji',
            name: 'sanji',
            role: 'vice-captain',
            bounty: '0',
          ),
        ),
        throwsA(isA<CrewRoleTakenException>()),
      );

      verifyNever(
        () => firestore.updateDocument(
          collection: any(named: 'collection'),
          documentId: any(named: 'documentId'),
          data: any(named: 'data'),
        ),
      );
    });

    test('lets a member keep the role they hold', () async {
      await repository.updateCrewMember(
        'c1',
        'sanji',
        CrewMember(
          characterId: 'sanji',
          name: 'Sanji',
          role: 'cook',
          bounty: '0',
        ),
      );

      final crew = await savedCrew();
      expect((crew['members'] as List).last['name'], 'Sanji');
    });
  });
}
