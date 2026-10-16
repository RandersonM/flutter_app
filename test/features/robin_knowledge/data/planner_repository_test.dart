import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/errors/app_exceptions.dart';
import 'package:opfan/core/services/auth_db/i_firestore_service.dart';
import 'package:opfan/features/robin_knowledge/data/repository/planner_repository.dart';

class _MockFirestoreService extends Mock implements IFirestoreService {}

void main() {
  late _MockFirestoreService firestore;
  late PlannerRepository repository;

  setUp(() {
    firestore = _MockFirestoreService();
    repository = PlannerRepository(firestoreService: firestore);
  });

  group('PlannerRepository behaviour', () {
    test('throws NotFoundException when updating a missing goal', () async {
      when(
        () => firestore.getDocument(collection: 'planner', documentId: 'g1'),
      ).thenAnswer((_) async => null);

      await expectLater(
        repository.updateGoalProgress('g1', 40),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('rethrows the original error instead of wrapping it', () async {
      when(
        () => firestore.getUserDocuments(collection: 'planner'),
      ).thenThrow(const NotSignedInException());

      await expectLater(
        repository.getGoals(),
        throwsA(isA<NotSignedInException>()),
      );
    });

    test('rejects a goal whose date has an unknown format', () async {
      when(() => firestore.getUserDocuments(collection: 'planner')).thenAnswer(
        (_) async => [
          {
            'id': 'g1',
            'title': 'Poneglyph',
            'description': '',
            'deadline': 42,
            'createdAt': '2026-01-01T00:00:00.000',
          },
        ],
      );

      await expectLater(repository.getGoals(), throwsA(isA<FormatException>()));
    });
  });
}
