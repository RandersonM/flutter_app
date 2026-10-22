import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/shared/utils/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService implements INotificationService {
  /// [navigationService] is required rather than defaulted: notification taps
  /// navigate through the app's single navigatorKey, and a fallback
  /// `NavigationService()` here would mint a second key attached to nothing.
  NotificationService({
    required this._navigationService,
    required this._firestoreService,
    required this._firebaseMessaging,
    required this._firebaseAuth,
  });

  final INavigationService _navigationService;
  final IFirestoreService _firestoreService;
  final FirebaseMessaging _firebaseMessaging;
  final FirebaseAuth _firebaseAuth;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _isInitialized = false;
  Future<void>? _initialization;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  /// Bumped by [clearToken]: a token fetched before it is already deleted.
  int _tokenGeneration = 0;

  @override
  String? get fcmToken => _fcmToken;
  @override
  bool get isInitialized => _isInitialized;

  /// Retried by the next call after a failure: sign-in calls it again, or a
  /// launch that failed here would never save a token for that account.
  @override
  Future<void> initialize() =>
      _initialization ??= _initialize().catchError((Object e, StackTrace st) {
        _initialization = null;
        Error.throwWithStackTrace(e, st);
      });

  Future<void> _initialize() async {
    try {
      await _requestPermissions();

      await _setupLocalNotifications();

      await _setupFirebaseMessaging();

      await _getFCMToken();

      _saveTokenForRestoredSession();

      _isInitialized = true;
      debugPrint('NotificationService: Inicializado com sucesso');
    } catch (e) {
      debugPrint('NotificationService: Erro na inicialização: $e');
      rethrow;
    }
  }

  Future<void> _requestPermissions() async {
    try {
      if (Platform.isIOS) {
        final settings = await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        debugPrint(
          'NotificationService: Permissão iOS: ${settings.authorizationStatus}',
        );
      }

      if (Platform.isAndroid) {
        final settings = await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        debugPrint(
          'NotificationService: Permissão Android: ${settings.authorizationStatus}',
        );
      }
    } catch (e) {
      debugPrint('NotificationService: Erro ao solicitar permissões: $e');
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _setupFirebaseMessaging() async {
    _foregroundSubscription ??= FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    _openedAppSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen(
      _handleMessageOpenedApp,
    );

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  Future<void> _getFCMToken() async {
    _tokenRefreshSubscription ??= _firebaseMessaging.onTokenRefresh.listen(
      _onTokenRefresh,
    );
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('NotificationService: FCM token obtained');
    } catch (e) {
      debugPrint('NotificationService: Erro ao obter FCM token: $e');
    }
  }

  /// Only a Google sign-in saves the token otherwise, so a user who stays
  /// signed in across launches would keep whatever token was saved back then.
  /// Not awaited: the write completes only on the server ack.
  void _saveTokenForRestoredSession() {
    final userId = _firebaseAuth.currentUser?.uid;
    final token = _fcmToken;
    if (userId != null && token != null) {
      unawaited(_writeToken(userId, token));
    }
  }

  Future<void> _onTokenRefresh(String token) async {
    _fcmToken = token;
    debugPrint('NotificationService: FCM token refreshed');
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId != null) await _writeToken(userId, token);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint(
      'NotificationService: foreground message, data keys ${message.data.keys}',
    );

    _showLocalNotification(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint(
      'NotificationService: opened from notification, data keys ${message.data.keys}',
    );

    _handleNotificationNavigation(message.data);
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('NotificationService: Notificação local tocada');
    debugPrint('NotificationService: Payload: ${response.payload}');

    if (response.payload != null) {
      final data = json.decode(response.payload!);
      _handleNotificationNavigation(data);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Canal Padrão',
      channelDescription: 'Canal para notificações do app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: DateTime.now().millisecond,
      title: message.notification?.title ?? 'Nova notificação',
      body: message.notification?.body ?? '',
      notificationDetails: details,
      payload: json.encode(message.data),
    );
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;
    final route = data['route'] as String?;

    Future.delayed(const Duration(milliseconds: 500), () {
      _navigateBasedOnNotificationType(type, id, route, data);
    });
  }

  void _navigateBasedOnNotificationType(
    String? type,
    String? id,
    String? route,
    Map<String, dynamic> data,
  ) {
    final navigationService = _navigationService;

    switch (type?.toLowerCase()) {
      case 'character':
        if (id != null) {
          navigationService.navigateTo(
            AppRoutes.characterDetails,
            arguments: {'id': id},
          );
        }
        break;

      case 'crew':
        if (id != null) {
          navigationService.navigateTo(
            AppRoutes.crewDetails,
            arguments: {'id': id},
          );
        }
        break;

      case 'finances':
        navigationService.navigateTo(AppRoutes.finances);
        break;

      case 'workout':
        navigationService.navigateTo(AppRoutes.workout);
        break;

      case 'cooking':
        navigationService.navigateTo(AppRoutes.cooking);
        break;

      case 'calculator':
        navigationService.navigateTo(AppRoutes.calculator);
        break;

      case 'devil_fruit':
        navigationService.navigateTo(AppRoutes.devilFruit);
        break;

      case 'duels':
        navigationService.navigateTo(AppRoutes.duels);
        break;

      case 'one_piece':
        navigationService.navigateTo(AppRoutes.onePiece);
        break;

      case 'custom':
        if (route != null &&
            AppRoutes.getRoute(RouteSettings(name: route)) != null) {
          navigationService.navigateTo(AppRoutes.home, arguments: data);
        }
        break;

      default:
        if (route != null &&
            AppRoutes.getRoute(RouteSettings(name: route)) != null) {
          navigationService.navigateTo(route, arguments: data);
        } else {
          navigationService.navigateTo(AppRoutes.home);
        }
        break;
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('NotificationService: Inscrito no tópico: $topic');
    } catch (e) {
      debugPrint(
        'NotificationService: Erro ao se inscrever no tópico $topic: $e',
      );
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('NotificationService: Cancelada inscrição no tópico: $topic');
    } catch (e) {
      debugPrint(
        'NotificationService: Erro ao cancelar inscrição no tópico $topic: $e',
      );
    }
  }

  /// Signing out deletes the device token, so the next sign-in fetches a new
  /// one before saving. A sign-out while the token is being fetched drops the
  /// save: written afterwards, the next account's pushes would reach this
  /// device under [userId].
  @override
  Future<void> saveTokenToFirestore(String userId) async {
    try {
      final generation = _tokenGeneration;
      final token = _fcmToken ?? await _firebaseMessaging.getToken();
      if (token == null || generation != _tokenGeneration) return;
      _fcmToken = token;
      if (_firebaseAuth.currentUser?.uid != userId) return;
      await _writeToken(userId, token);
    } catch (e) {
      debugPrint('NotificationService: Erro ao obter FCM token: $e');
    }
  }

  /// Keys and types must match `validToken` in `firestore.rules`.
  Future<void> _writeToken(String userId, String token) async {
    try {
      await _firestoreService.createDocumentWithId(
        collection: 'user_tokens',
        documentId: userId,
        data: {
          'fcmToken': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      debugPrint(
        'NotificationService: Token salvo no Firestore para usuário: $userId',
      );
    } catch (e) {
      debugPrint('NotificationService: Erro ao salvar token no Firestore: $e');
    }
  }

  @override
  Future<void> clearToken() async {
    _tokenGeneration++;
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      debugPrint('NotificationService: Token FCM limpo');
    } catch (e) {
      debugPrint('NotificationService: Erro ao limpar token: $e');
    }
  }
}
