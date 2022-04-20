import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';

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
        child: ElevatedButton(
          child: const Text("Play example song"),
          onPressed: () {
            ref.read(justAudioProvider).playExampleSong();
          },
        ),
      ),
    );
  }
}
