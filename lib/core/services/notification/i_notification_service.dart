abstract class INotificationService {
  String? get fcmToken;
  
  bool get isInitialized;
  
  Future<void> initialize();
  
  Future<void> subscribeToTopic(String topic);
  
  Future<void> unsubscribeFromTopic(String topic);
  
  Future<void> saveTokenToFirestore(String userId);
  
  Future<void> clearToken();
}
