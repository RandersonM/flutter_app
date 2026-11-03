import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:opfan/core/errors/app_exceptions.dart';

import 'i_firestore_service.dart';

class FirestoreService implements IFirestoreService {
  FirestoreService({required this._firestore, required this._auth});

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  bool get isUserAuthenticated => _auth.currentUser != null;

  @override
  String? get currentUserEmail => _auth.currentUser?.email;

  @override
  Future<String> createDocument({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      final docRef = await _firestore.collection(collection).add(data);
      return docRef.id;
    } catch (e) {
      debugPrint(
        'FirestoreService: creating a document in $collection failed: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> createDocumentWithId({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).set(data);
    } catch (e) {
      debugPrint(
        'FirestoreService: creating document $documentId in $collection failed: $e',
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint(
        'FirestoreService: reading document $documentId in $collection failed: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDocuments({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      final result = querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      return result;
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        debugPrint(
          'FirestoreService: Error permission detected. Check the Firestore rules.',
        );
      }
      debugPrint(
        'FirestoreService: reading documents in $collection failed: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      debugPrint(
        'FirestoreService: updating document $documentId in $collection failed: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> updateDocumentsInBatch({
    required String collection,
    required Map<String, Map<String, dynamic>> updates,
  }) async {
    try {
      final batch = _firestore.batch();
      for (final MapEntry(key: documentId, value: data) in updates.entries) {
        batch.update(_firestore.collection(collection).doc(documentId), data);
      }
      await batch.commit();
    } catch (e) {
      debugPrint(
        'FirestoreService: batch update of ${updates.length} documents in $collection failed: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      debugPrint(
        'FirestoreService: deleting document $documentId in $collection failed: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> queryDocuments({
    required String collection,
    required String field,
    required dynamic value,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection(collection)
          .where(field, isEqualTo: value);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      final result = querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      return result;
    } catch (e) {
      debugPrint(
        'FirestoreService: querying documents in $collection failed: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserDocuments({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      throw const NotSignedInException();
    }

    return queryDocuments(
      collection: collection,
      field: 'userId',
      value: userId,
      orderBy: orderBy,
      descending: descending,
      limit: limit,
    );
  }

  @override
  Future<String> createUserDocument({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw const NotSignedInException();
    }

    final userData = {
      ...data,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    return createDocument(collection: collection, data: userData);
  }

  @override
  Future<void> updateUserDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw const NotSignedInException();
    }

    final updateData = {...data, 'updatedAt': FieldValue.serverTimestamp()};

    await updateDocument(
      collection: collection,
      documentId: documentId,
      data: updateData,
    );
  }

  @override
  Stream<List<Map<String, dynamic>>> streamDocuments({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query query = _firestore.collection(collection);

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList(),
    );
  }

  @override
  Stream<List<Map<String, dynamic>>> streamUserDocuments({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    Query query = _firestore
        .collection(collection)
        .where('userId', isEqualTo: userId);

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList(),
    );
  }
}
