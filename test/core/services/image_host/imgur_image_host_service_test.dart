import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/config/environment_service.dart';
import 'package:opfan/core/services/image_host/imgur_image_host_service.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  final png = Uint8List.fromList([137, 80, 78, 71]);

  group('ImgurImageHostService behaviour', () {
    test('keeps the image inline without a client id', () async {
      final dio = _MockDio();
      final host = ImgurImageHostService(
        env: EnvironmentService(values: const {}),
        dio: dio,
      );

      expect(await host.upload(png), 'data:image/png;base64,iVBORw==');
      verifyZeroInteractions(dio);
    });

    test('falls back to inline when the upload fails', () async {
      final dio = _MockDio();
      when(
        () => dio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(DioException(requestOptions: RequestOptions()));
      final host = ImgurImageHostService(
        env: EnvironmentService(values: const {'IMGUR_CLIENT_ID': 'abc'}),
        dio: dio,
      );

      expect(await host.upload(png), startsWith('data:image/png;base64,'));
    });
  });
}
