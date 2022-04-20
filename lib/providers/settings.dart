import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utilities/preferences.dart';

final settingsProvider = ChangeNotifierProvider((ref) => SettingsProvider());

enum DisplayMode {
  grid,
  comfortableGrid,
  //list,
}

class SettingsProvider extends ChangeNotifier {
  // displayMode
  DisplayMode _displayMode = DisplayMode.grid;
  DisplayMode get displayMode => _displayMode;
  set displayMode(DisplayMode value) {
    _displayMode = value;
    PreferencesStorage.setPreference("display", "displayMode", value.name);
    notifyListeners();
  }

  // useOvalArtistImages
  bool _useOvalArtistImages = true;
  bool get useOvalArtistImages => _useOvalArtistImages;
  set useOvalArtistImages(bool value) {
    _useOvalArtistImages = value;
    PreferencesStorage.setPreference("appearance", "useOvalArtistImages", value.toString());
    notifyListeners();
  }

  SettingsProvider() {
    // displayMode
    final displayModeName = PreferencesStorage.getPreference("display", "displayMode");
    _displayMode = DisplayMode.values
        .firstWhere((e) => e.name == displayModeName, orElse: () => DisplayMode.grid);

    // useOvalArtistImages
    final useOvalArtistImagesName =
        PreferencesStorage.getPreference("appearance", "useOvalArtistImages");
    _useOvalArtistImages = useOvalArtistImagesName == "true";

    notifyListeners();
  }
}
