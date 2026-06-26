import 'package:opfan/core/models/one_piece/devil_fruit.dart';

abstract class IDevilFruitService {
  Future<List<DevilFruit>> fetchAll();
  Future<DevilFruit?> fetchById(int id);
  Future<List<DevilFruit>> fetchByType(String type);
  Future<List<DevilFruit>> searchByName(String name);
  List<String> get availableTypes;
  void clearCache();
}
