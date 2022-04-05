import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppearanceSettings extends ConsumerStatefulWidget {
  AppearanceSettings({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppearanceSettingsState();
}

class _AppearanceSettingsState extends ConsumerState<AppearanceSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appearance'),
      ),
      body: Center(
        child: Text('Appearance'),
      ),
    );
  }
}
