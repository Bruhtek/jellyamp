import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Collapsed extends ConsumerStatefulWidget {
  const Collapsed({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CollapsedState();
}

class _CollapsedState extends ConsumerState<Collapsed> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: const Center(child: Text("Collapsed")),
    );
  }
}
