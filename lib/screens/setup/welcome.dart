import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              "Welcome to jellyamp!",
              style: Theme.of(context).textTheme.headline3,
            ),
            const Text("Start setting up your jellyamp on the next pages."),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/url'),
              child: const Text("Let's go!"),
            ),
          ],
        ),
      ),
    );
  }
}
