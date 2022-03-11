import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: LoginScreen(),
      ),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<LoginScreen> {
  final urlController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  TextField urlField() => TextField(
        controller: urlController,
        decoration: const InputDecoration(
          hintText: 'https://jellyfin.example.com',
          label: Text("Your Jellyfin Url"),
        ),
      );
  TextField usernameField() => TextField(
        controller: usernameController,
        decoration: const InputDecoration(
          hintText: 'Username',
          label: Text("Your Jellyfin Username"),
        ),
      );
  TextField passwordField() => TextField(
        controller: passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: '••••••••',
          label: Text("Your Jellyfin Password"),
        ),
      );
  ElevatedButton loginButton() => ElevatedButton(
        child: const Text("Login"),
        onPressed: () {
          ref.read(jellyfinAPIProvider).login(
                usernameController.text,
                passwordController.text,
                urlController.text,
              );
        },
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Welcome to Jellyamp!"),
          const Text("Please enter your Jellyfin details"),
          urlField(),
          usernameField(),
          passwordField(),
          loginButton(),
        ],
      ),
    );
  }
}
