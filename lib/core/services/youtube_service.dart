// Developed by Randerson Mayllon
// Copyright © 2022.

import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../home/models/youtube_video_model.dart';

class YouTubeService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  static const String _apiKey = 'xxx';

  late final Dio _dio;

  YouTubeService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }

  /// Busca vídeos AMV do personagem especificado
  Future<YouTubeVideo?> searchCharacterAMV(String characterName) async {
    try {
      final query = '$characterName AMV One Piece';
      debugPrint('YouTube Service: Searching for "$query"');

      final response = await _dio.get('/search', queryParameters: {
        'part': 'snippet',
        'q': query,
        'type': 'video',
        'maxResults': 5,
        'order': 'relevance',
        'key': _apiKey,
        'safeSearch': 'none',
        'videoEmbeddable': 'true',
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final items = data['items'] as List;

        if (items.isNotEmpty) {
          final random = Random();
          final randomIndex = random.nextInt(items.length);
          final video = YouTubeVideo.fromJson(items[randomIndex]);
          return video;
        } else {
          return null;
        }
      } else {
        debugPrint('YouTube Service: Error - Status ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      debugPrint('YouTube Service: DioException - ${e.message}');
      debugPrint('YouTube Service: Response data - ${e.response?.data}');
      return null;
    } catch (e) {
      debugPrint('YouTube Service: Unexpected error - $e');
      return null;
    }
  }

  Future<List<YouTubeVideo>> searchMultipleCharacterAMVs(String characterName,
      {int maxResults = 3}) async {
    try {
      final query = '$characterName AMV One Piece';

      final response = await _dio.get('/search', queryParameters: {
        'part': 'snippet',
        'q': query,
        'type': 'video',
        'maxResults': maxResults,
        'order': 'relevance',
        'key': _apiKey,
        'safeSearch': 'none',
        'videoEmbeddable': 'true',
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final items = data['items'] as List;

        final videos =
            items.map((item) => YouTubeVideo.fromJson(item)).toList();
        return videos;
      } else {
        debugPrint('YouTube Service: Error - Status ${response.statusCode}');
        return [];
      }
    } on DioException catch (e) {
      debugPrint('YouTube Service: DioException - ${e.message}');
      return [];
    } catch (e) {
      debugPrint('YouTube Service: Unexpected error - $e');
      return [];
    }
  }

  Future<YouTubeVideo?> _getMockVideo(String characterName) async {
    await Future.delayed(const Duration(seconds: 1));

    return YouTubeVideo(
      videoId: 'dQw4w9WgXcQ',
      title: '$characterName AMV - Epic Moments',
      thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
      channelTitle: 'One Piece AMV Channel',
      description: 'Epic $characterName moments compilation',
    );
  }

  bool get hasApiKey => _apiKey != 'YOUR_YOUTUBE_API_KEY' && _apiKey.isNotEmpty;

  Future<YouTubeVideo?> searchCharacterAMVWithFallback(
      String characterName) async {
    if (hasApiKey) {
      return await searchCharacterAMV(characterName);
    } else {
      return await _getMockVideo(characterName);
    }
  }
}
