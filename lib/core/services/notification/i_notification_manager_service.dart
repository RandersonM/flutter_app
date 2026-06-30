abstract class INotificationManagerService {
  Future<Map<String, dynamic>> sendCustomNotificationToAll({
    required String title,
    required String body,
    String? type,
    String? screen,
  });

  Future<Map<String, dynamic>> sendCustomNotificationToUsers({
    required String title,
    required String body,
    required List<String> userIds,
    String? type,
    String? screen,
  });

  Future<Map<String, dynamic>> testNotification({
    String title = 'Teste',
    String body = 'Esta é uma notificação de teste',
  });

  Future<Map<String, dynamic>> sendNamiMonthlyReportNotification();
  
  Future<Map<String, dynamic>> sendZoroWorkoutNotification();
  
  Future<Map<String, dynamic>> sendSanjiCookingNotification();
  
  Future<Map<String, dynamic>> sendFeaturedCharacterNotification();
  
  Future<Map<String, dynamic>> sendFinanceTipNotification();
  
  Future<Map<String, dynamic>> sendDuelNotification();

  bool get isUserAuthenticated;

  String? get currentUserId;
}
