// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:opfan/core/models/one_piece/devil_fruit.dart';
import 'package:opfan/core/services/environment_service.dart';

class DevilFruitService {
  late final Dio _dio;
  final EnvironmentService _env = EnvironmentService.instance;
  List<DevilFruit> _cachedFruits = [];
  bool _isLoaded = false;

  DevilFruitService() {
    _dio = Dio(BaseOptions(
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

  Future<List<DevilFruit>> fetchAll() async {
    if (_isLoaded && _cachedFruits.isNotEmpty) {
      return _cachedFruits;
    }

    try {
      final url = _env.devilFruitApiUrl;

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data;
        _cachedFruits =
            jsonData.map((json) => DevilFruit.fromJson(json)).toList();
        _isLoaded = true;

        
        return _cachedFruits;
      } else {
        throw Exception('Failed to load devil fruits: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DevilFruitService: DioException - ${e.message}');
      debugPrint('DevilFruitService: Response data - ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('DevilFruitService: Unexpected error - $e');
      rethrow;
    }
  }

  Future<DevilFruit?> fetchById(int id) async {
    if (!_isLoaded) {
      await fetchAll();
    }

    try {
      return _cachedFruits.firstWhere((fruit) => fruit.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<DevilFruit>> fetchByType(String type) async {
    if (!_isLoaded) {
      await fetchAll();
    }

    return _cachedFruits
        .where((fruit) => fruit.type.toLowerCase() == type.toLowerCase())
        .toList();
  }

  Future<List<DevilFruit>> searchByName(String name) async {
    if (!_isLoaded) {
      await fetchAll();
    }

    return _cachedFruits
        .where((fruit) =>
            fruit.name.toLowerCase().contains(name.toLowerCase()) ||
            fruit.romanName.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  List<String> get availableTypes {
    if (!_isLoaded) return [];

    return _cachedFruits.map((fruit) => fruit.type).toSet().toList();
  }

  void clearCache() {
    _cachedFruits.clear();
    _isLoaded = false;
  }
}
