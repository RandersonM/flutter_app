/// Removes everything a user stored in Firestore.
abstract class IUserDataEraser {
  /// Must run while [uid] is still signed in: the security rules only let the
  /// owner delete their documents.
  Future<void> eraseRemoteData(String uid);
}
