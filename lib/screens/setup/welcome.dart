import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Welcome to jellyamp!",
                style: Theme.of(context).textTheme.headline3,
                textAlign: TextAlign.center,
              ),
              const Text(
                "Start setting up your jellyamp on the next pages.",
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/url'),
                child: const Text("Let's go!"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
