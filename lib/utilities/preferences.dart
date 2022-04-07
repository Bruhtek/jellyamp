import 'package:hive_flutter/hive_flutter.dart';

class PreferencesStorage {
  static String getPreference(String category, String key) {
    Box box = Hive.box<Map<dynamic, dynamic>>("preferences");

    if (box.containsKey(category)) {
      Map<dynamic, dynamic> map = box.get(category);

      if (map.containsKey(key)) {
        return map[key];
      }

      return "";
    }

    return "";
  }
}
