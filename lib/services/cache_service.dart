import 'package:hive/hive.dart';

class CacheService {
  Future<void> saveData(String key, dynamic data) async {
    var box = await Hive.openBox('yuninetCache');
    await box.put(key, data);
  }

  Future<dynamic> loadData(String key) async {
    var box = await Hive.openBox('yuninetCache');
    return box.get(key);
  }
}