import 'package:opfan/features/youtube/data/models/youtube_video_model.dart';

abstract class IYouTubeService {
  Future<YouTubeVideo?> searchCharacterAMV(String characterName);

  Future<List<YouTubeVideo>> searchMultipleCharacterAMVs(
    String characterName, {
    int maxResults = 3,
  });

  bool get hasApiKey;

  Future<YouTubeVideo?> searchCharacterAMVWithFallback(String characterName);

  void clearCache();

  void resetQuotaState();

  Map<String, dynamic> getServiceStatus();
}
