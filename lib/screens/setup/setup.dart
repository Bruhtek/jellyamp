import 'package:flutter/material.dart';

import 'package:jellyamp/screens/setup/welcome.dart';
import 'package:jellyamp/screens/setup/url.dart';
import 'package:jellyamp/screens/setup/login.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen(this.onSubmit, {Key? key}) : super(key: key);

  final Function onSubmit;

  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  PageController pageController = PageController();

  void onLogin() {
    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Welcome(pageController),
        UrlSetup(pageController),
        LoginScreen(pageController, onLogin),
      ],
    );
  }
}
