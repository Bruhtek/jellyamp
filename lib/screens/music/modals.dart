import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utilities/preferences.dart';
import '../../utilities/providers/settings.dart';

// ignore: must_be_immutable
class SelectorModalSheet extends ConsumerStatefulWidget {
  SelectorModalSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SelectorModalSheetState();
}

class _SelectorModalSheetState extends ConsumerState<SelectorModalSheet> {
  void setDisplayMode(int index) {
    ref.watch(settingsProvider).displayMode = DisplayMode.values[index];
  }

  @override
  Widget build(BuildContext context) {
    DisplayMode displayMode = ref.watch(settingsProvider.select((value) => value.displayMode));

    return Wrap(
      children: [
        ListTile(
          minLeadingWidth: 0,
          visualDensity: VisualDensity.compact,
          title: Text(
            "Display mode",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          minLeadingWidth: 0,
          visualDensity: VisualDensity.compact,
          leading: displayMode == DisplayMode.grid
              ? const Icon(Icons.radio_button_on_rounded)
              : const Icon(Icons.radio_button_off_rounded),
          selected: displayMode == DisplayMode.grid,
          title: Text("Compact grid",
              style: TextStyle(
                color: displayMode == DisplayMode.grid
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              )),
          onTap: () => setDisplayMode(0),
        ),
        ListTile(
          minLeadingWidth: 0,
          visualDensity: VisualDensity.compact,
          leading: displayMode == DisplayMode.comfortableGrid
              ? const Icon(Icons.radio_button_on_rounded)
              : const Icon(Icons.radio_button_off_rounded),
          selected: displayMode == DisplayMode.comfortableGrid,
          title: Text("Comfortable grid",
              style: TextStyle(
                color: displayMode == DisplayMode.comfortableGrid
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              )),
          onTap: () => setDisplayMode(1),
        ),
      ],
    );
  }
}
