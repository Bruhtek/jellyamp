import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArtistsScreen extends ConsumerWidget {
  ArtistsScreen(this.toggleSelecting, {Key? key}) : super(key: key);

  Function toggleSelecting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Text("artists"),
    );
  }
}
