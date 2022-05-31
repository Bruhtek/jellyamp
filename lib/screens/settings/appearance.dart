import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings.dart';

class AppearanceSettings extends ConsumerStatefulWidget {
  const AppearanceSettings({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppearanceSettingsState();
}

class _AppearanceSettingsState extends ConsumerState<AppearanceSettings> {
  @override
  Widget build(BuildContext context) {
    final useOvalArtistImages =
        ref.watch(settingsProvider.select((value) => value.useOvalArtistImages));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              'Use oval artist images',
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
            trailing: Switch(
              value: useOvalArtistImages,
              onChanged: (value) => ref.read(settingsProvider).useOvalArtistImages = value,
            ),
          ),
        ],
      ),
    );
  }
}
