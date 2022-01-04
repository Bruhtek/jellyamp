import 'package:flutter/material.dart';
import 'package:jellyamp/screens/setup/url.dart';

import 'package:jellyamp/screens/setup/welcome.dart';
import 'package:jellyamp/screens/setup/url.dart';

class Setup extends StatelessWidget {
  const Setup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Setup jellyamp!",
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const Welcome(),
        '/url': (context) => const UrlSetup(),
      },
    );
  }
}
