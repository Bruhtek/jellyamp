import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FloatingPlayer extends ConsumerStatefulWidget {
  const FloatingPlayer({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FloatingPlayerState();
}

class _FloatingPlayerState extends ConsumerState<FloatingPlayer> {
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    if (visible) {
      return SizedBox(
        height: 70,
        width: double.infinity,
        child: Container(
          color: Colors.green,
          child: Center(
            child: ElevatedButton(
              child: const Text("Hide"),
              onPressed: () => setState(() {
                visible = false;
              }),
            ),
          ),
        ),
      );
    }

    return Container();
  }
}
