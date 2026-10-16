import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

  group('updateCrewMember', () {
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
        'sanji',
        CrewMember(
          characterId: 'sanji',
          name: 'sanji',
          role: 'viceCaptain',
          bounty: '0',
        ),
      );

      final crew = await savedCrew();
      expect(crew['viceCaptain'], 'sanji');
    });
  });
}
