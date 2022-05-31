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

  static void setPreference(String category, String key, String value) {
    Box box = Hive.box<Map<dynamic, dynamic>>("preferences");

    if (box.containsKey(category)) {
      Map<dynamic, dynamic> map = box.get(category);
      map[key] = value;
      box.put(category, map);
    } else {
      Map<dynamic, dynamic> map = <dynamic, dynamic>{};
      map[key] = value;
      box.put(category, map);
    }
  }
}
