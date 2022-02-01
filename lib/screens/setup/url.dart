import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UrlSetup extends StatefulWidget {
  const UrlSetup({Key? key}) : super(key: key);

  @override
  State<UrlSetup> createState() => _UrlSetupState();
}

class _UrlSetupState extends State<UrlSetup> {
  bool valid = false;
  String jellyfinUrl = '';
  String message = '';

  Future<bool> correctServerUrl(String url) async {
    if (isUrlValid(url)) {
      try {
        final response = await http.get(Uri.parse('$url/System/Info/Public'));
        if (response.statusCode == 200) {
          if (response.body.contains('"ProductName":"Jellyfin Server"')) {
            return true;
          }

          return false;
        }

        return false;
      } catch (e) {
        return false;
      }
    }

    return false;
  }

  void checkUrl(String? url) {
    setState(() {
      jellyfinUrl = url ?? '';
    });
  }

  bool isUrlValid(String? url) {
    if (url?.endsWith('/') ?? true) {
      return false;
    }
    final uri = Uri.tryParse((url ?? '') + '/');
    return uri != null && uri.hasAbsolutePath && uri.scheme.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.65,
          padding: const EdgeInsets.all(24.0),
          child: FutureBuilder<bool>(
            future: correctServerUrl(jellyfinUrl),
            builder: (context, snapshot) {
              Widget dynamicText = Container();
              Widget dynamicButton = Container();

              if (snapshot.hasData) {
                final messageText;
                final Function()? onPressed;

                if (snapshot.data!) {
                  messageText = "Your Jellyfin instance is valid";
                  onPressed = () => Navigator.pushNamed(context, '/token');
                } else {
                  if (jellyfinUrl.isEmpty) {
                    messageText = "";
                  } else {
                    messageText =
                        "Your Jellyfin instance is not valid. Check if you entered the correct URL";
                  }

                  onPressed = null;
                }

                dynamicText = Text(
                  messageText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: snapshot.data! ? Colors.green : Colors.red,
                  ),
                );
                dynamicButton = ElevatedButton(
                  onPressed: onPressed,
                  child: const Text("Next"),
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Write your jellyfin instance url here",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 36.0),
                  ),
                  TextField(
                    textAlign: TextAlign.center,
                    onChanged: checkUrl,
                    decoration: const InputDecoration(
                      hintText: "https://jellyfin.example.com",
                      label: Center(
                        child: Text("Your Jellyfin instance URL"),
                      ),
                    ),
                  ),
                  dynamicText,
                  dynamicButton,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
