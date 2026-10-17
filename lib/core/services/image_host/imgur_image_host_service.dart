import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:opfan/core/services/config/i_environment_service.dart';

import 'i_image_host_service.dart';

/// Anonymous Imgur upload. Without `IMGUR_CLIENT_ID`, or when the upload
/// fails, the image is kept inline as a data URI.
class ImgurImageHostService implements IImageHostService {
  ImgurImageHostService({required this._env, required this._dio});

  final IEnvironmentService _env;
  final Dio _dio;

  @override
  Future<String> upload(Uint8List png) async {
    final clientId = _env.imgurClientId;
    if (clientId.isEmpty) return _inline(png);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'https://api.imgur.com/3/image',
        data: FormData.fromMap({'image': base64Encode(png), 'type': 'base64'}),
        options: Options(headers: {'Authorization': 'Client-ID $clientId'}),
      );
      final link = (response.data?['data'] as Map?)?['link'] as String?;
      if (link != null) return link;
    } catch (e) {
      debugPrint('ImgurImageHostService: upload failed - $e');
    }
    return _inline(png);
  }

  String _inline(Uint8List png) => 'data:image/png;base64,${base64Encode(png)}';
}
