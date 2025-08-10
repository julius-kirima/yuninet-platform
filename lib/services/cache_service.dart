import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('cacheBox');
  }

  Future<void> putData(String key, dynamic value) async {
    final box = Hive.box('cacheBox');
    await box.put(key, value);
  }

  dynamic getData(String key) {
    final box = Hive.box('cacheBox');
    return box.get(key);
  }
}
