import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'panel_player.dart';
import 'panel_queue.dart';
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
        child: PageView(
          scrollDirection: Axis.horizontal,
          children: const [
            PanelPlayer(),
            PanelQueue(),
          ],
          controller: PageController(
            initialPage: 0,
            keepPage: false,
            viewportFraction: 1.0,
          ),
        ));
  }
}
