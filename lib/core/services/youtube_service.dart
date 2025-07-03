// Developed by Randerson Mayllon
// Copyright © 2022.

import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../home/models/youtube_video_model.dart';
import 'environment_service.dart';

class YouTubeService {
  late final Dio _dio;
  final EnvironmentService _env = EnvironmentService.instance;

  YouTubeService() {
    _dio = Dio(BaseOptions(
      baseUrl: _env.youtubeBaseUrl,
      connectTimeout: Duration(milliseconds: _env.networkTimeout),
      receiveTimeout: Duration(milliseconds: _env.networkTimeout),
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }

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
        'key': _env.youtubeApiKey,
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
        'key': _env.youtubeApiKey,
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

  bool get hasApiKey =>
      _env.youtubeApiKey != 'your_youtube_api_key_here' &&
      _env.youtubeApiKey.isNotEmpty;

  Future<YouTubeVideo?> searchCharacterAMVWithFallback(
      String characterName) async {
    if (hasApiKey) {
      return await searchCharacterAMV(characterName);
    } else {
      return await _getMockVideo(characterName);
    }
  }
}
