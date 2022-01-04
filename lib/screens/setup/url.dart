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
      body: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Write your jellyfin instance url here",
              style: TextStyle(fontSize: 36.0),
            ),
            TextField(
              onChanged: checkUrl,
              decoration: const InputDecoration(
                hintText: "https://jellyfin.example.com",
                labelText: "Your Jellyfin instance URL",
              ),
            ),
            FutureBuilder<bool>(
              future: correctServerUrl(jellyfinUrl),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!) {
                    return Column(
                      children: [
                        const Text(
                          "Success!",
                          style: TextStyle(color: Colors.green),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/token'),
                          child: const Text("Next"),
                        ),
                      ],
                    );
                  } else {
                    return const Text(
                      "Invalid Url!",
                      style: TextStyle(color: Colors.red),
                    );
                  }
                }

                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
