import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utilities/preferences.dart';

// ignore: must_be_immutable
class SelectorModalSheet extends ConsumerStatefulWidget {
  SelectorModalSheet(this.setStateContainer, {Key? key}) : super(key: key);

  Function setStateContainer;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SelectorModalSheetState();
}

class _SelectorModalSheetState extends ConsumerState<SelectorModalSheet> {
  int displayMode = 0;

  void setDisplayMode(int index) {
    widget.setStateContainer(index);
    setState(() {
      displayMode = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    displayMode = int.tryParse(PreferencesStorage.getPreference("display", "displayMode")) ?? 1;

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
          leading: displayMode == 0
              ? const Icon(Icons.radio_button_on_rounded)
              : const Icon(Icons.radio_button_off_rounded),
          selected: displayMode == 0,
          title: Text("Compact grid",
              style: TextStyle(
                color: displayMode == 0
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              )),
          onTap: () => setDisplayMode(0),
        ),
        ListTile(
          minLeadingWidth: 0,
          visualDensity: VisualDensity.compact,
          leading: displayMode == 1
              ? const Icon(Icons.radio_button_on_rounded)
              : const Icon(Icons.radio_button_off_rounded),
          selected: displayMode == 1,
          title: Text("Comfortable grid",
              style: TextStyle(
                color: displayMode == 1
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              )),
          onTap: () => setDisplayMode(1),
        ),
      ],
    );
  }
}
