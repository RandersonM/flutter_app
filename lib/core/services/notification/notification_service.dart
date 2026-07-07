import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/shared/utils/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService implements INotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _isInitialized = false;

  @override
  String? get fcmToken => _fcmToken;
  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _requestPermissions();

      await _setupLocalNotifications();

      await _setupFirebaseMessaging();

      await _getFCMToken();

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
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('NotificationService: FCM Token: $_fcmToken');

      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('NotificationService: Novo FCM Token: $newToken');
      });
    } catch (e) {
      debugPrint('NotificationService: Erro ao obter FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('NotificationService: Mensagem recebida em primeiro plano');
    debugPrint('NotificationService: Título: ${message.notification?.title}');
    debugPrint('NotificationService: Corpo: ${message.notification?.body}');
    debugPrint('NotificationService: Dados: ${message.data}');

    _showLocalNotification(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('NotificationService: App aberto através da notificação');
    debugPrint('NotificationService: Dados: ${message.data}');

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
    final navigationService = NavigationService();

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

  @override
  Future<void> saveTokenToFirestore(String userId) async {
    if (_fcmToken == null) return;

    try {
      await FirestoreService().createDocumentWithId(
        collection: 'user_tokens',
        documentId: userId,
        data: {
          'fcmToken': _fcmToken,
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
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      debugPrint('NotificationService: Token FCM limpo');
    } catch (e) {
      debugPrint('NotificationService: Erro ao limpar token: $e');
    }
  }
}
