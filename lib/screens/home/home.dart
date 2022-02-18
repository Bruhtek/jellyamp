import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: const Text('Home'),
        ),
        body: const Center(
          child: Text('Home'),
        ),
      ),
      theme: ThemeData.from(colorScheme: Provider.of<ColorScheme>(context)),
    );
  }
}
