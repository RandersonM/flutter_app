import 'i_firestore_service.dart';
import 'i_user_data_eraser.dart';

class UserDataEraser implements IUserDataEraser {
  UserDataEraser({required this._firestore});

  /// Collections whose documents carry the owner's uid in a field. Crews
  /// created before `userId` existed only have `ownerId`.
  static const _ownerFields = {
    'crews': ['userId', 'ownerId'],
    'custom_characters': ['userId'],
    'planner': ['userId'],
    'workout_assessments': ['user_id'],
  };

  /// Collections keyed by the uid itself.
  static const _uidKeyedCollections = ['user_tokens', 'users'];

  final IFirestoreService _firestore;

  @override
  Future<void> eraseRemoteData(String uid) async {
    for (final MapEntry(key: collection, value: fields)
        in _ownerFields.entries) {
      for (final field in fields) {
        final documents = await _firestore.queryDocuments(
          collection: collection,
          field: field,
          value: uid,
        );
        for (final document in documents) {
          await _firestore.deleteDocument(
            collection: collection,
            documentId: document['id'] as String,
          );
        }
      }
    }
    for (final collection in _uidKeyedCollections) {
      await _firestore.deleteDocument(collection: collection, documentId: uid);
    }
  }
}
