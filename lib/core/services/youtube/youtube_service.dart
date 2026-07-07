import 'package:get_it/get_it.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:opfan/features/youtube/data/models/youtube_video_model.dart';
import 'package:opfan/core/services/index.dart';

class YouTubeService implements IYouTubeService {
  late final Dio _dio;
  final IEnvironmentService _env = GetIt.I.get<IEnvironmentService>();

  final Map<String, YouTubeVideo> _videoCache = {};
  final Map<String, List<YouTubeVideo>> _multipleVideoCache = {};

  final List<DateTime> _requestTimestamps = [];
  static const int _maxRequestsPerHour = 50;

  bool _quotaExceeded = false;
  DateTime? _quotaExceededTime;
  static const Duration _quotaResetDuration = Duration(hours: 24);

  YouTubeService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _env.youtubeBaseUrl,
        connectTimeout: Duration(milliseconds: _env.networkTimeout),
        receiveTimeout: Duration(milliseconds: _env.networkTimeout),
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  @override
  Future<YouTubeVideo?> searchCharacterAMV(String characterName) async {
    final cacheKey = _getCacheKey(characterName);
    if (_videoCache.containsKey(cacheKey)) {
      return _videoCache[cacheKey];
    }

    if (_isQuotaExceeded()) {
      debugPrint('YouTube Service: Quota exceeded, using fallback');
      return await _getMockVideo(characterName);
    }

    if (!_canMakeRequest()) {
      debugPrint('YouTube Service: Rate limit exceeded, using fallback');
      return await _getMockVideo(characterName);
    }

    try {
      final query = '$characterName AMV One Piece';
      debugPrint('YouTube Service: Searching for "$query"');

      _recordRequest();

      final response = await _dio.get(
        '/search',
        queryParameters: {
          'part': 'snippet',
          'q': query,
          'type': 'video',
          'maxResults': 5,
          'order': 'relevance',
          'key': _env.youtubeApiKey,
          'safeSearch': 'none',
          'videoEmbeddable': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final items = data['items'] as List;

        if (items.isNotEmpty) {
          final random = Random();
          final randomIndex = random.nextInt(items.length);
          final video = YouTubeVideo.fromJson(items[randomIndex]);

          _videoCache[cacheKey] = video;

          return video;
        } else {
          return await _getMockVideo(characterName);
        }
      } else {
        debugPrint('YouTube Service: Error - Status ${response.statusCode}');
        return await _getMockVideo(characterName);
      }
    } on DioException catch (e) {
      debugPrint('YouTube Service: DioException - ${e.message}');
      debugPrint('YouTube Service: Response data - ${e.response?.data}');

      if (e.response?.statusCode == 403) {
        _handleQuotaExceeded(e.response?.data);
      }

      return await _getMockVideo(characterName);
    } catch (e) {
      debugPrint('YouTube Service: Unexpected error - $e');
      return await _getMockVideo(characterName);
    }
  }

  @override
  Future<List<YouTubeVideo>> searchMultipleCharacterAMVs(
    String characterName, {
    int maxResults = 3,
  }) async {
    final cacheKey = _getCacheKey(characterName, maxResults);
    if (_multipleVideoCache.containsKey(cacheKey)) {
      return _multipleVideoCache[cacheKey]!;
    }

    if (_isQuotaExceeded()) {
      debugPrint('YouTube Service: Quota exceeded, using fallback');
      return await _getMockVideos(characterName, maxResults);
    }

    if (!_canMakeRequest()) {
      debugPrint('YouTube Service: Rate limit exceeded, using fallback');
      return await _getMockVideos(characterName, maxResults);
    }

    try {
      final query = '$characterName AMV One Piece';

      _recordRequest();

      final response = await _dio.get(
        '/search',
        queryParameters: {
          'part': 'snippet',
          'q': query,
          'type': 'video',
          'maxResults': maxResults,
          'order': 'relevance',
          'key': _env.youtubeApiKey,
          'safeSearch': 'none',
          'videoEmbeddable': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final items = data['items'] as List;

        final videos = items
            .map((item) => YouTubeVideo.fromJson(item))
            .toList();

        _multipleVideoCache[cacheKey] = videos;

        return videos;
      } else {
        debugPrint('YouTube Service: Error - Status ${response.statusCode}');
        return await _getMockVideos(characterName, maxResults);
      }
    } on DioException catch (e) {
      debugPrint('YouTube Service: DioException - ${e.message}');

      if (e.response?.statusCode == 403) {
        _handleQuotaExceeded(e.response?.data);
      }

      return await _getMockVideos(characterName, maxResults);
    } catch (e) {
      debugPrint('YouTube Service: Unexpected error - $e');
      return await _getMockVideos(characterName, maxResults);
    }
  }

  Future<YouTubeVideo?> _getMockVideo(String characterName) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final mockVideos = [
      YouTubeVideo(
        videoId: 'dQw4w9WgXcQ',
        title: '$characterName AMV - Epic Moments',
        thumbnailUrl:
            'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
        channelTitle: 'One Piece AMV Channel',
        description: 'Epic $characterName moments compilation',
      ),
      YouTubeVideo(
        videoId: 'oVgEhDlmjbE',
        title: '$characterName - Best Scenes',
        thumbnailUrl:
            'https://img.youtube.com/vi/oVgEhDlmjbE/maxresdefault.jpg',
        channelTitle: 'Anime AMV Hub',
        description: 'Best $characterName scenes from One Piece',
      ),
    ];

    return mockVideos[Random().nextInt(mockVideos.length)];
  }

  Future<List<YouTubeVideo>> _getMockVideos(
    String characterName,
    int count,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final mockVideos = [
      YouTubeVideo(
        videoId: 'dQw4w9WgXcQ',
        title: '$characterName AMV - Epic Moments',
        thumbnailUrl:
            'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
        channelTitle: 'One Piece AMV Channel',
        description: 'Epic $characterName moments compilation',
      ),
      YouTubeVideo(
        videoId: 'oVgEhDlmjbE',
        title: '$characterName - Best Scenes',
        thumbnailUrl:
            'https://img.youtube.com/vi/oVgEhDlmjbE/maxresdefault.jpg',
        channelTitle: 'Anime AMV Hub',
        description: 'Best $characterName scenes from One Piece',
      ),
      YouTubeVideo(
        videoId: 'fJ9rUzIMcZQ',
        title: '$characterName - Ultimate Power',
        thumbnailUrl:
            'https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg',
        channelTitle: 'One Piece Clips',
        description: 'Ultimate $characterName power moments',
      ),
    ];

    return mockVideos.take(count).toList();
  }

  @override
  bool get hasApiKey =>
      _env.youtubeApiKey != 'your_youtube_api_key_here' &&
      _env.youtubeApiKey.isNotEmpty;

  @override
  Future<YouTubeVideo?> searchCharacterAMVWithFallback(
    String characterName,
  ) async {
    if (hasApiKey) {
      return await searchCharacterAMV(characterName);
    } else {
      return await _getMockVideo(characterName);
    }
  }

  String _getCacheKey(String characterName, [int? maxResults]) {
    return maxResults != null
        ? '${characterName.toLowerCase()}_$maxResults'
        : characterName.toLowerCase();
  }

  bool _canMakeRequest() {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));

    _requestTimestamps.removeWhere(
      (timestamp) => timestamp.isBefore(oneHourAgo),
    );

    return _requestTimestamps.length < _maxRequestsPerHour;
  }

  void _recordRequest() {
    _requestTimestamps.add(DateTime.now());
  }

  bool _isQuotaExceeded() {
    if (!_quotaExceeded) return false;

    if (_quotaExceededTime != null) {
      final timeSinceQuotaExceeded = DateTime.now().difference(
        _quotaExceededTime!,
      );
      if (timeSinceQuotaExceeded > _quotaResetDuration) {
        _quotaExceeded = false;
        _quotaExceededTime = null;
        return false;
      }
    }

    return true;
  }

  void _handleQuotaExceeded(dynamic responseData) {
    _quotaExceeded = true;
    _quotaExceededTime = DateTime.now();

    if (responseData != null) {
      final error = responseData['error'];
      if (error != null && error['errors'] != null) {
        final errors = error['errors'] as List;
        for (final err in errors) {
          if (err['reason'] == 'quotaExceeded') {
            debugPrint(
              'YouTube Service: Quota exceeded - switching to offline mode',
            );
            break;
          }
        }
      }
    }
  }

  @override
  void clearCache() {
    _videoCache.clear();
    _multipleVideoCache.clear();
    debugPrint('YouTube Service: Cache cleared');
  }

  @override
  void resetQuotaState() {
    _quotaExceeded = false;
    _quotaExceededTime = null;
    debugPrint('YouTube Service: Quota state reset');
  }

  @override
  Map<String, dynamic> getServiceStatus() {
    return {
      'hasApiKey': hasApiKey,
      'quotaExceeded': _quotaExceeded,
      'quotaExceededTime': _quotaExceededTime?.toIso8601String(),
      'cachedVideos': _videoCache.length,
      'cachedMultipleVideos': _multipleVideoCache.length,
      'recentRequests': _requestTimestamps.length,
      'canMakeRequest': _canMakeRequest(),
    };
  }
}
