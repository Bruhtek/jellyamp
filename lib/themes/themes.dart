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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.background,
      ),
      switchTheme: SwitchThemeData(
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurface.withOpacity(0.38);
          }

          return colorScheme.primary.withOpacity(0.7);
        }),
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurface.withOpacity(0.7);
          }

          return colorScheme.primary;
        }),
      ),
    );
  }
}
