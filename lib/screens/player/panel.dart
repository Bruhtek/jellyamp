import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Panel extends ConsumerStatefulWidget {
  const Panel({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PanelState();
}

class _PanelState extends ConsumerState<Panel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Center(
        child: Text("Panel", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      ),
    );
  }
}
