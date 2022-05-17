// Developed by Randerson Mayllon
// Copyright © 2022.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:simple_app/core/models/movies/search_movie.dart';
import '../../../shared/errors.dart';

class MovieRepoImpl {
  late final BaseOptions? _options;
  late final Dio _dio;

  MovieRepoImpl({BaseOptions? options}) {
    _buildBaseOptions(options);
    _buildHttpClient();
  }

  void _buildBaseOptions(BaseOptions? options) {
    _options = options ??
        BaseOptions(
          receiveDataWhenStatusError: true,
          responseType: ResponseType.json,
        );
  }

  void _buildHttpClient() {
    _dio = Dio(_options);
  }

  MovieRepoImpl addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);

    return this;
  }

  Future<SearchMovie> findMovie(String name) async {
    try {
      final response = await get(
          url: dotenv.env['BASE_URL']!,
          queryParameters: {'s': name, 'apiKey': dotenv.env['API_KEY']!});

      return SearchMovie.fromJson(response.data['Search'][0]);
    } on DioError catch (error) {
      if (error.error is SocketException) {
        throw NoInternetConnectionException();
      }
      if (error.response?.statusCode != null) {
        switch (error.response?.statusCode) {
          case 400:
            throw BadRequestException(
              jsonDecode(error.response?.data),
            );
          case 401:
            throw UnauthorizedException(
              message: jsonDecode(error.response?.data),
            );
          case 403:
            throw UnauthorizedException(
              message: jsonDecode(error.response?.data),
            );
          case 500:
            throw ServerException();
        }
      }
      throw UnknownException();
    } catch (_) {
      throw UnknownException();
    }
  }

  Future<Response> get({
    required String url,
    Map<String, dynamic>? queryParameters,
  }) {
    return _requestHandler(
      () => _dio.get(url, queryParameters: queryParameters),
    );
  }

  Future<Response> post({required String url, Map<String, dynamic>? data}) {
    return _requestHandler(() => _dio.post(url, data: data));
  }

  Future<Response> patch({required String url, Map<String, dynamic>? data}) {
    return _requestHandler(() => _dio.patch(url, data: data));
  }

  Future<Response> put({required String url, Map<String, dynamic>? data}) {
    return _requestHandler(() => _dio.put(url, data: data));
  }

  Future<Response> _requestHandler(
    ValueGetter<Future<Response>> request,
  ) async {
    try {
      return await request();
    } on DioError catch (error) {
      if (error.error is SocketException) {
        throw NoInternetConnectionException();
      }

      if (error.response?.statusCode != null) {
        switch (error.response?.statusCode) {
          case 400:
            throw BadRequestException(
              jsonDecode(error.response?.data)['description'],
            );
          case 401:
            throw UnauthorizedException(
              message: jsonDecode(error.response?.data)['description'],
            );
          case 403:
            throw UnauthorizedException(
              message: jsonDecode(error.response?.data)['description'],
            );
          case 500:
            throw ServerException();
        }
      }

      throw UnknownException();
    } catch (_) {
      throw UnknownException();
    }
  }
}
