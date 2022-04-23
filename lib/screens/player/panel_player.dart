import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';

class PanelPlayer extends ConsumerStatefulWidget {
  const PanelPlayer({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PanelPlayerState();
}

class _PanelPlayerState extends ConsumerState<PanelPlayer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber,
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
