import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = Provider<Themes>((ref) => Themes());

class Themes {
  static ThemeData createTheme(BuildContext context, {required ColorScheme colorScheme}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      textTheme: Theme.of(context).textTheme,
    );
  }
}
