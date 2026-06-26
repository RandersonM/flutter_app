abstract class IFirestoreService {
  String? get currentUserId;
  bool get isUserAuthenticated;
  String? get currentUserEmail;
  
  Future<String> createDocument({
    required String collection,
    required Map<String, dynamic> data,
  });
  
  Future<void> createDocumentWithId({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  });
  
  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String documentId,
  });
  
  Future<List<Map<String, dynamic>>> getDocuments({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
  });
  
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  });
  
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  });
  
  Future<List<Map<String, dynamic>>> queryDocuments({
    required String collection,
    required String field,
    required dynamic value,
    String? orderBy,
    bool descending = false,
    int? limit,
  });
  
  Future<List<Map<String, dynamic>>> getUserDocuments({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
  });
  
  Future<String> createUserDocument({
    required String collection,
    required Map<String, dynamic> data,
  });
  
  Future<void> updateUserDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  });
  
  Stream<List<Map<String, dynamic>>> streamDocuments({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
  });
  
  Stream<List<Map<String, dynamic>>> streamUserDocuments({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
  });
}
