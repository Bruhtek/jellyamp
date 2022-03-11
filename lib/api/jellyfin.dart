import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

enum SortType {
  albumName,
  albumNameDesc,
  albumArtist,
  albumArtistDesc,
}

class JellyfinAPI extends ChangeNotifier {
  //    ______ _   ___      __
  //   |  ____| \ | \ \    / /
  //   | |__  |  \| |\ \  / /
  //   |  __| | . ` | \ \/ /
  //   | |____| |\  |  \  /
  //   |______|_| \_|   \/
  //

  void notify() {
    notifyListeners();
  }

  late String _mediaBrowserToken;
  late String _jellyfinUrl;
  late String _userId;

  JellyfinAPI() {
    _mediaBrowserToken = '';
    _jellyfinUrl = '';
    _userId = '';

    _initialize();
  }

  bool loggedIn = false;
  bool wrongAuth = false;
  bool initialized = false;

  void _initialize() async {
    bool settingsReadCorrectly = _readEnvFromDisk();
    if (settingsReadCorrectly) {
      bool authenticated = await _checkAuthenticated();
      if (authenticated) {
        loggedIn = true;
      } else {
        wrongAuth = true;
      }
    }

    initialized = true;
    notify();
  }

  Future<bool> _checkAuthenticated() async {
    final uri = Uri.parse("$_jellyfinUrl/Users/Me");

    final response = await http.get(
      uri,
      headers: reqHeaders,
    );

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<bool> checkServerUrl(String url) async {
    if (_isUrlValid(url)) {
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

  bool _isUrlValid(String? url) {
    if (url?.endsWith('/') ?? true) {
      return false;
    }
    final uri = Uri.tryParse((url ?? '') + '/');
    return uri != null && uri.hasAbsolutePath && uri.scheme.startsWith('http');
  }

  Future<bool> login(String username, String password, String url) async {
    if (_isUrlValid(url)) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final uri = Uri.parse("$url/Users/AuthenticateByName");

      final headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "X-Emby-Authorization":
            'MediaBrowser Client="Android", Device="${androidInfo.model}", DeviceId="${androidInfo.androidId}", Version="${packageInfo.version}"',
      };

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          "Username": username,
          "Pw": password,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _userId = json['User']['Id'];
        _mediaBrowserToken = json['AccessToken'];
        _jellyfinUrl = url;

        _saveEnvToDisk();

        _initialize();
        return true;
      }
    }

    _initialize();
    return false;
  }

  void _saveEnvToDisk() {
    var envBox = Hive.box('encrypted');

    envBox.put("mediaBrowserToken", _mediaBrowserToken);
    envBox.put("userId", _userId);
    envBox.put("jellyfinUrl", _jellyfinUrl);
  }

  /// Reads the environment variables from disk.
  /// Returns true if all the environment variables were read successfully.
  bool _readEnvFromDisk() {
    var envBox = Hive.box('encrypted');

    if (envBox.keys.contains('mediaBrowserToken')) {
      _mediaBrowserToken = envBox.get('mediaBrowserToken');
    } else {
      return false;
    }

    if (envBox.keys.contains('userId')) {
      _userId = envBox.get('userId');
    } else {
      return false;
    }

    if (envBox.keys.contains('jellyfinUrl')) {
      _jellyfinUrl = envBox.get('jellyfinUrl');
    } else {
      return false;
    }

    return true;
  }

  String get reqBaseUrl => _jellyfinUrl;
  Map<String, String> get reqHeaders =>
      {'X-MediaBrowser-Token': _mediaBrowserToken};

  //                      _ _
  //       /\            | (_)
  //      /  \  _   _  __| |_  ___
  //     / /\ \| | | |/ _` | |/ _ \
  //    / ____ \ |_| | (_| | | (_) |
  //   /_/    \_\__,_|\__,_|_|\___/
  //

  //    _____
  //   |_   _|
  //     | |  _ __ ___   __ _  __ _  ___  ___
  //     | | | '_ ` _ \ / _` |/ _` |/ _ \/ __|
  //    _| |_| | | | | | (_| | (_| |  __/\__ \
  //   |_____|_| |_| |_|\__,_|\__, |\___||___/
  //                           __/ |
  //                          |___/

}
