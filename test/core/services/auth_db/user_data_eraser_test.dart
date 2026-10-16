import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/auth_db/i_firestore_service.dart';
import 'package:opfan/core/services/auth_db/user_data_eraser.dart';

class _MockFirestoreService extends Mock implements IFirestoreService {}

void main() {
  late _MockFirestoreService firestore;

  setUp(() {
    firestore = _MockFirestoreService();
    when(
      () => firestore.queryDocuments(
        collection: any(named: 'collection'),
        field: any(named: 'field'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async => []);
    when(
      () => firestore.deleteDocument(
        collection: any(named: 'collection'),
        documentId: any(named: 'documentId'),
      ),
    ).thenAnswer((_) async {});
  });

  void ownerHas(String collection, String field, List<String> ids) {
    when(
      () => firestore.queryDocuments(
        collection: collection,
        field: field,
        value: 'u1',
      ),
    ).thenAnswer(
      (_) async => [
        for (final id in ids) {'id': id},
      ],
    );
  }

  group('UserDataEraser behaviour', () {
    test('deletes every document the user owns in each collection', () async {
      ownerHas('crews', 'userId', ['c1']);
      ownerHas('crews', 'ownerId', ['legacy-crew']);
      ownerHas('custom_characters', 'userId', ['ch1', 'ch2']);
      ownerHas('planner', 'userId', ['g1']);
      ownerHas('workout_assessments', 'user_id', ['w1']);

      await UserDataEraser(firestore: firestore).eraseRemoteData('u1');

      for (final (collection, id) in [
        ('crews', 'c1'),
        ('crews', 'legacy-crew'),
        ('custom_characters', 'ch1'),
        ('custom_characters', 'ch2'),
        ('planner', 'g1'),
        ('workout_assessments', 'w1'),
        ('user_tokens', 'u1'),
        ('users', 'u1'),
      ]) {
        verify(
          () =>
              firestore.deleteDocument(collection: collection, documentId: id),
        ).called(1);
      }
    });

    test('stops at the first failure so the account is not deleted', () async {
      ownerHas('crews', 'userId', ['c1']);
      when(
        () => firestore.deleteDocument(collection: 'crews', documentId: 'c1'),
      ).thenThrow(Exception('permission-denied'));

      await expectLater(
        UserDataEraser(firestore: firestore).eraseRemoteData('u1'),
        throwsException,
      );
      verifyNever(
        () => firestore.deleteDocument(collection: 'users', documentId: 'u1'),
      );
    });
  });
}
