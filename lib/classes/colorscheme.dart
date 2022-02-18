// Class to generate the color scheme from a color palette

import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

abstract class ColorSchemeGenerator {
  static ColorScheme generate(CorePalette palette, bool dark) {
    final primaryColors = palette.primary;
    final secondaryColors = palette.secondary;
    final tertiaryColors = palette.tertiary;
    final neutralColors = palette.neutral;
    final neutralVariantColors = palette.neutralVariant;
    final errorColors = palette.error;

    // values based on https://m3.material.io/styles/color/the-color-system/tokens

    final ColorScheme result = ColorScheme(
      primary: Color(primaryColors.get(dark ? 80 : 40)),
      primaryContainer: Color(primaryColors.get(dark ? 30 : 90)),
      secondary: Color(secondaryColors.get(dark ? 80 : 40)),
      secondaryContainer: Color(secondaryColors.get(dark ? 30 : 90)),
      tertiary: Color(tertiaryColors.get(dark ? 80 : 40)),
      tertiaryContainer: Color(tertiaryColors.get(dark ? 30 : 90)),
      surface: Color(neutralColors.get(dark ? 10 : 99)),
      surfaceVariant: Color(neutralVariantColors.get(dark ? 30 : 90)),
      background: Color(neutralColors.get(dark ? 10 : 99)),
      error: Color(errorColors.get(dark ? 80 : 40)),
      errorContainer: Color(errorColors.get(dark ? 30 : 90)),
      onPrimary: Color(primaryColors.get(dark ? 20 : 100)),
      onPrimaryContainer: Color(primaryColors.get(dark ? 90 : 10)),
      onSecondary: Color(secondaryColors.get(dark ? 20 : 100)),
      onSecondaryContainer: Color(secondaryColors.get(dark ? 90 : 10)),
      onTertiary: Color(tertiaryColors.get(dark ? 20 : 100)),
      onTertiaryContainer: Color(tertiaryColors.get(dark ? 90 : 10)),
      onSurface: Color(neutralColors.get(dark ? 90 : 10)),
      onSurfaceVariant: Color(neutralVariantColors.get(dark ? 80 : 30)),
      onError: Color(errorColors.get(dark ? 100 : 20)),
      onErrorContainer: Color(errorColors.get(dark ? 80 : 10)),
      onBackground: Color(neutralColors.get(dark ? 90 : 10)),
      outline: Color(neutralVariantColors.get(dark ? 60 : 50)),
      shadow: Color(neutralColors.get(0)),
      inverseSurface: Color(neutralColors.get(dark ? 90 : 20)),
      onInverseSurface: Color(neutralColors.get(dark ? 20 : 95)),
      inversePrimary: Color(primaryColors.get(dark ? 40 : 80)),
      brightness: dark ? Brightness.dark : Brightness.light,
    );

    return result;
  }
}
