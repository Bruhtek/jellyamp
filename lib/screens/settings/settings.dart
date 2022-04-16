import 'package:flutter/material.dart';

import 'appearance.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Widget index(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 16.0),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 130,
              child: Center(
                child: Icon(
                  Icons.settings_rounded,
                  size: 128,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            SizedBox(
              height: 30,
              child: Center(
                child: Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            cardBuilder(
                context, "Appearance", Icons.palette_rounded, "Change the app's appearance"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return index(context);
  }
}

Widget cardBuilder(BuildContext context, String title, IconData leading, String? subtitle) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16.0),
      color: Theme.of(context).colorScheme.onSecondary,
    ),
    margin: const EdgeInsets.all(8.0),
    child: Stack(
      children: [
        ListTile(
          leading: SizedBox(
            height: double.infinity,
            child: Icon(leading, size: 32, color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          title: Text(
            title,
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                )
              : null,
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pushNamed('/settings/appearance'),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
