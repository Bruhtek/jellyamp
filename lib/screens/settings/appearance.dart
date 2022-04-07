import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppearanceSettings extends ConsumerStatefulWidget {
  const AppearanceSettings({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppearanceSettingsState();
}

class _AppearanceSettingsState extends ConsumerState<AppearanceSettings> {
  late Map<dynamic, dynamic> _preferences;
  late Box box;

  @override
  void initState() {
    box = Hive.box<Map<dynamic, dynamic>>('preferences');

    if (box.keys.contains("appearance")) {
      _preferences = box.get("appearance")!;
    } else {
      _preferences = <dynamic, dynamic>{};
      box.put("appearance", _preferences);
    }

    super.initState();
  }

  void setValue(String key, String value) {
    setState(() {
      _preferences[key] = value;
      box.put("appearance", _preferences);
    });
  }

  String getValue(String key) {
    return _preferences[key] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Use oval artist images'),
            trailing: Switch(
              value: getValue("useOvalArtistImages") == "true" ? true : false,
              onChanged: (value) => setValue("useOvalArtistImages", value.toString()),
            ),
          ),
        ],
      ),
    );
  }
}
