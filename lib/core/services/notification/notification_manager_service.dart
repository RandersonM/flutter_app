import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'i_notification_manager_service.dart';

class NotificationManagerService implements INotificationManagerService {
  static final NotificationManagerService _instance =
      NotificationManagerService._internal();
  factory NotificationManagerService() => _instance;
  NotificationManagerService._internal();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Enviar notificação personalizada para todos os usuários
  @override
  Future<Map<String, dynamic>> sendCustomNotificationToAll({
    required String title,
    required String body,
    String? type,
    String? screen,
  }) async {
    try {
      final callable = _functions.httpsCallable('sendCustomNotification');

      final result = await callable.call({
        'title': title,
        'body': body,
        'type': type ?? 'custom',
        'screen': screen ?? 'home',
      });

      debugPrint('NotificationManagerService: Notificação enviada com sucesso');
      return result.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('NotificationManagerService: Erro ao enviar notificação: $e');
      rethrow;
    }
  }

  // Enviar notificação personalizada para usuários específicos
  @override
  Future<Map<String, dynamic>> sendCustomNotificationToUsers({
    required String title,
    required String body,
    required List<String> userIds,
    String? type,
    String? screen,
  }) async {
    try {
      final callable = _functions.httpsCallable('sendCustomNotification');

      final result = await callable.call({
        'title': title,
        'body': body,
        'type': type ?? 'custom',
        'screen': screen ?? 'home',
        'userIds': userIds,
      });

      debugPrint(
          'NotificationManagerService: Notificação enviada para usuários específicos');
      return result.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('NotificationManagerService: Erro ao enviar notificação: $e');
      rethrow;
    }
  }

  // Testar notificação (para desenvolvimento)
  @override
  Future<Map<String, dynamic>> testNotification({
    String title = 'Teste',
    String body = 'Esta é uma notificação de teste',
  }) async {
    try {
      final callable = _functions.httpsCallable('testNotification');

      final result = await callable.call({
        'title': title,
        'body': body,
      });

      debugPrint('NotificationManagerService: Teste de notificação enviado');
      return result.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint(
          'NotificationManagerService: Erro no teste de notificação: $e');
      rethrow;
    }
  }

  // Enviar notificação de relatório mensal da Nami
  @override
  Future<Map<String, dynamic>> sendNamiMonthlyReportNotification() async {
    return await sendCustomNotificationToAll(
      title: '💰 Relatório Mensal - Nami Finances',
      body:
          'Chegou a hora de revisar suas finanças do mês! Acesse o app para ver seu relatório completo.',
      type: 'nami_monthly_report',
      screen: 'nami_finances',
    );
  }

  // Enviar notificação de treino do Zoro
  @override
  Future<Map<String, dynamic>> sendZoroWorkoutNotification() async {
    return await sendCustomNotificationToAll(
      title: '⚔️ Treino do Zoro',
      body: 'Hora do treino! Que tal praticar algumas técnicas de espada hoje?',
      type: 'zoro_workout',
      screen: 'zoro_workout',
    );
  }

  // Enviar notificação de culinária do Sanji
  @override
  Future<Map<String, dynamic>> sendSanjiCookingNotification() async {
    return await sendCustomNotificationToAll(
      title: '👨‍🍳 Dica do Sanji',
      body:
          'Hora do almoço! Que tal preparar uma refeição nutritiva e deliciosa?',
      type: 'sanji_cooking',
      screen: 'sanji_cooking',
    );
  }

  // Enviar notificação de personagem em destaque
  @override
  Future<Map<String, dynamic>> sendFeaturedCharacterNotification() async {
    return await sendCustomNotificationToAll(
      title: '🏴‍☠️ Personagem em Destaque',
      body: 'Conheça um novo personagem de One Piece hoje!',
      type: 'featured_character',
      screen: 'one_piece',
    );
  }

  // Enviar notificação de dica financeira
  @override
  Future<Map<String, dynamic>> sendFinanceTipNotification() async {
    return await sendCustomNotificationToAll(
      title: '💰 Dica Financeira',
      body: 'Lembre-se de registrar seus gastos de hoje no Nami Finances!',
      type: 'finance_tip',
      screen: 'nami_finances',
    );
  }

  // Enviar notificação de duelo
  @override
  Future<Map<String, dynamic>> sendDuelNotification() async {
    return await sendCustomNotificationToAll(
      title: '🎯 Duelo de Personagens',
      body: 'Que tal um duelo épico entre seus personagens favoritos?',
      type: 'duel',
      screen: 'duels',
    );
  }

  // Verificar se o usuário está autenticado
  @override
  bool get isUserAuthenticated => _auth.currentUser != null;

  // Obter ID do usuário atual
  @override
  String? get currentUserId => _auth.currentUser?.uid;
}
