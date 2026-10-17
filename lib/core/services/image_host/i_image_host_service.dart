import 'dart:typed_data';

/// Hosts a generated image and returns a URL the app can store and load.
abstract class IImageHostService {
  Future<String> upload(Uint8List png);
}
