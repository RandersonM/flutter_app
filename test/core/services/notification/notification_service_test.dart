import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/auth_db/i_firestore_service.dart';
import 'package:opfan/core/services/config/i_navigation_service.dart';
import 'package:opfan/core/services/notification/notification_service.dart';

class _MockMessaging extends Mock implements FirebaseMessaging {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockFirestore extends Mock implements IFirestoreService {}

class _MockNavigation extends Mock implements INavigationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // flutter test registers no plugins: give local notifications the Android
  // implementation over a mocked channel so initialize() can run.
  setUpAll(() {
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dexterous.com/flutter/local_notifications'),
          (_) async => true,
        );
  });

  late _MockMessaging messaging;
  late _MockFirebaseAuth firebaseAuth;
  late _MockFirestore firestore;
  late StreamController<String> tokenRefresh;
  late NotificationService service;

  setUp(() {
    messaging = _MockMessaging();
    firebaseAuth = _MockFirebaseAuth();
    firestore = _MockFirestore();
    tokenRefresh = StreamController<String>.broadcast();

    when(() => messaging.onTokenRefresh).thenAnswer((_) => tokenRefresh.stream);
    when(() => messaging.getToken()).thenAnswer((_) async => 'token-1');
    when(() => messaging.getInitialMessage()).thenAnswer((_) async => null);
    when(() => messaging.deleteToken()).thenAnswer((_) async {});
    when(() => firebaseAuth.currentUser).thenReturn(null);
    when(
      () => firestore.createDocumentWithId(
        collection: any(named: 'collection'),
        documentId: any(named: 'documentId'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async {});

    service = NotificationService(
      navigationService: _MockNavigation(),
      firestoreService: firestore,
      firebaseMessaging: messaging,
      firebaseAuth: firebaseAuth,
    );
  });

  tearDown(() => tokenRefresh.close());

  List<(Object?, Object?)> savedTokens() {
    final captured = verify(
      () => firestore.createDocumentWithId(
        collection: 'user_tokens',
        documentId: captureAny(named: 'documentId'),
        data: captureAny(named: 'data'),
      ),
    ).captured;
    return [
      for (var i = 0; i < captured.length; i += 2)
        (captured[i], (captured[i + 1] as Map)['fcmToken']),
    ];
  }

  group('NotificationService token behaviour', () {
    test('saves a fresh token when another account signs in', () async {
      await service.initialize();
      await service.saveTokenToFirestore('alice');
      await service.clearToken();
      when(() => messaging.getToken()).thenAnswer((_) async => 'token-2');

      await service.saveTokenToFirestore('bob');

      expect(savedTokens(), [('alice', 'token-1'), ('bob', 'token-2')]);
    });

    test('saves a refreshed token for the signed-in user', () async {
      final user = _MockUser();
      when(() => user.uid).thenReturn('alice');
      when(() => firebaseAuth.currentUser).thenReturn(user);
      await service.initialize();

      tokenRefresh.add('token-3');
      await pumpEventQueue();

      expect(savedTokens(), [('alice', 'token-3')]);
      expect(service.fcmToken, 'token-3');
    });

    test('keeps a refreshed token local while signed out', () async {
      await service.initialize();

      tokenRefresh.add('token-3');
      await pumpEventQueue();

      verifyNever(
        () => firestore.createDocumentWithId(
          collection: any(named: 'collection'),
          documentId: any(named: 'documentId'),
          data: any(named: 'data'),
        ),
      );
      expect(service.fcmToken, 'token-3');
    });
  });
}
