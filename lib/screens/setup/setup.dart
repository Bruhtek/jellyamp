import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';

// ignore: must_be_immutable
class SetupScreen extends StatelessWidget {
  SetupScreen(this.themeData, {Key? key}) : super(key: key);

  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeData,
      home: const Scaffold(
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
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        keyboardType: TextInputType.url,
        decoration: const InputDecoration(
          hintText: 'https://jellyfin.example.com',
          label: Text("Your Jellyfin Url"),
        ),
      );
  TextField usernameField() => TextField(
        controller: usernameController,
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: 'Username',
          label: Text("Your Jellyfin Username"),
        ),
      );
  TextField passwordField() => TextField(
        controller: passwordController,
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        obscureText: true,
        decoration: const InputDecoration(
          hintText: '. . . . . . . . . . . .',
          label: Text("Your Jellyfin Password"),
        ),
      );
  ElevatedButton loginButton(bool enabled) => ElevatedButton(
        child: const Text("Login"),
        onPressed: enabled
            ? () => ref.read(jellyfinAPIProvider).login(
                  usernameController.text,
                  passwordController.text,
                  urlController.text,
                )
            : null,
      );

  Widget loginStatus() => StreamBuilder<int>(
        stream: ref.watch(jellyfinAPIProvider.select((value) => value.loginStatusStream())),
        initialData: 0,
        builder: (context, snapshot) {
          String statusText;
          bool error = false;

          switch (snapshot.data) {
            case 1:
              statusText = "Checking url...";
              break;
            case 2:
              statusText = "Wrong url!";
              error = true;
              break;
            case 3:
              statusText = "Checking credentials...";
              break;
            case 4:
              statusText = "Wrong credentials!";
              error = true;
              break;
            case 5:
              statusText = "Fetching data...";
              break;
            default:
              statusText = "";
              break;
          }
          List<Widget> columnChildren = <Widget>[
            loginButton(snapshot.data == 0 || error),
          ];

          columnChildren.add(Text(statusText,
              style:
                  TextStyle(color: error ? Colors.red : Theme.of(context).colorScheme.secondary)));

          columnChildren.add(const SizedBox(height: 8.0));

          if (snapshot.data != 0 && !error) {
            columnChildren.add(const CircularProgressIndicator());
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: columnChildren,
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
          Text(
            "Welcome to Jellyamp!",
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 24),
          ),
          Text(
            "Please enter your Jellyfin instance details",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          urlField(),
          usernameField(),
          passwordField(),
          loginStatus(),
        ],
      ),
    );
  }
}
