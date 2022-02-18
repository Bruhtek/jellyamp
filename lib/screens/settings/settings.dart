import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: const Text('Settings'),
        ),
        body: const Center(
          child: Text('Settings'),
        ),
      ),
      theme: ThemeData.from(colorScheme: Provider.of<ColorScheme>(context)),
    );
  }
}
