import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:jellyamp/api/jellyfin.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen(this.pageController, this.onLogin, {Key? key})
      : super(key: key);

  final Function onLogin;
  final PageController pageController;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loggedIn = false;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  TextField username() => TextField(
        controller: usernameController,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          hintText: "username",
          label: Center(
            child: Text("Your Jellyfin Username"),
          ),
        ),
      );
  TextField password() => TextField(
        controller: passwordController,
        textAlign: TextAlign.center,
        obscureText: true,
        enableSuggestions: false,
        autocorrect: false,
        decoration: const InputDecoration(
          hintText: "••••••••",
          label: Center(
            child: Text("Your Jellyfin Password"),
          ),
        ),
      );

  Future<void> login(String username, String password) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final uri = Uri.parse(
        "${Provider.of<JellyfinAPI>(context, listen: false).reqBaseUrl}/Users/AuthenticateByName");

    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "X-Emby-Authorization":
          'MediaBrowser Client="Android", Device="${androidInfo.model}", DeviceId="${androidInfo.androidId}", Version="${packageInfo.version}"',
    };

    final response = await http.post(uri,
        headers: headers,
        body: jsonEncode({
          "Username": username,
          "Pw": password,
        }));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      JellyfinAPI jellyfinAPI =
          Provider.of<JellyfinAPI>(context, listen: false);

      jellyfinAPI.setUserId(json['User']['Id']);
      jellyfinAPI.setToken(json['AccessToken']);

      jellyfinAPI.saveEnvToDisk();

      widget.onLogin();
    } else {
      throw Exception("Failed to login!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.65,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Write your jellyfin login details here",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36.0),
              ),
              Column(
                children: [
                  username(),
                  password(),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  login(usernameController.text, passwordController.text);
                },
                child: const Text("Login"),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => widget.pageController.previousPage(
            duration: const Duration(milliseconds: 500), curve: Curves.ease),
        child: const Icon(Icons.arrow_back_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
    );
  }
}
