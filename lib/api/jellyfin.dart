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

class Artist {
  String name;
  String id;
  String? primaryImageTag;

  List<String> albumIds;
  List<String> albumNames;

  List<String> songIds;
  List<String> songNames;

  bool isFavorite;

  Artist({
    required this.name,
    required this.id,
    this.primaryImageTag,
    this.albumIds = const [],
    this.albumNames = const [],
    this.songIds = const [],
    this.songNames = const [],
    required this.isFavorite,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['Id'] as String,
      name: json['Name'] as String,
      primaryImageTag: json['ImageTags']['Primary'] as String?,
      albumIds: [],
      albumNames: [],
      songIds: [],
      songNames: [],
      isFavorite: json['UserData']['IsFavorite'] as bool,
    );
  }
}

class Song {
  String id;
  String title;
  String? albumPrimaryImageTag;

  List<String> artistIds;
  List<String> artistNames;
  String albumId;
  String albumName;

  bool isFavorite;

  Song({
    required this.id,
    required this.title,
    required this.albumPrimaryImageTag,
    this.artistIds = const [],
    this.artistNames = const [],
    required this.albumId,
    required this.albumName,
    this.isFavorite = false,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    List<String> artistIds = [];
    List<String> artistNames = [];

    for (var artist in json['ArtistItems']) {
      artistIds.add(artist['Id']);
      artistNames.add(artist['Name']);
    }

    return Song(
      id: json['Id'] as String,
      title: json['Name'] as String,
      albumPrimaryImageTag: json['AlbumPrimaryImageTag'] as String?,
      artistIds: artistIds,
      artistNames: artistNames,
      albumId: json['AlbumId'] as String,
      albumName: json['Album'] as String,
      isFavorite: json['UserData']['IsFavorite'] as bool,
    );
  }
}

class Album {
  String id;
  String title;
  String? primaryImageTag;

  List<String> artistIds;
  List<String> artistNames;

  List<String> songIds;
  List<String> songTitles;

  bool isFavorite;

  Album({
    required this.id,
    required this.title,
    this.primaryImageTag,
    this.artistIds = const [],
    this.artistNames = const [],
    this.songIds = const [],
    this.songTitles = const [],
    this.isFavorite = false,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    List<String> artistIds = [];
    List<String> artistNames = [];

    for (var artist in json['AlbumArtists']) {
      artistIds.add(artist['Id']);
      artistNames.add(artist['Name']);
    }

    return Album(
      id: json['Id'] as String,
      title: json['Name'] as String,
      primaryImageTag: json['ImageTags']['Primary'] as String?,
      artistIds: artistIds,
      artistNames: artistNames,
      songIds: [],
      songTitles: [],
      isFavorite: json['UserData']['IsFavorite'] as bool,
    );
  }
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

  /// Declares whether the user has finished logging in.
  /// If [loggedIn] is true, also declares whether data has finished loading.
  bool initialized = false;

  void _initialize() async {
    bool settingsReadCorrectly = _readEnvFromDisk();
    if (settingsReadCorrectly) {
      bool authenticated = await _checkAuthenticated();
      if (authenticated) {
        loggedIn = true;
        await fetchData();
      } else {
        wrongAuth = true;
      }
    }

    initialized = true;
    notify();
  }

  Future<bool> _checkAuthenticated() async {
    try {
      final uri = Uri.parse("$_jellyfinUrl/Users/Me");

      final response = await http.get(
        uri,
        headers: reqHeaders,
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
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

  Map<String, Artist> _artists = {};
  Map<String, Song> _songs = {};
  Map<String, Album> _albums = {};

  /// Fetches and sorts out all the data.
  /// Returns true if the data was fetched properly, false otherwise.
  Future<bool> fetchData() async {
    Map<String, Album>? albums = await _fetchAlbums();
    Map<String, Song>? songs = await _fetchSongs();
    Map<String, Artist>? artists = await _fetchArtists();

    if (albums != null && songs != null && artists != null) {
      songs.forEach((key, value) {
        albums[value.albumId]?.songIds.add(value.id);
        albums[value.albumId]?.songTitles.add(value.title);
        for (String artistId in value.artistIds) {
          artists[artistId]?.songIds.add(value.id);
          artists[artistId]?.songNames.add(value.title);
        }
      });

      albums.forEach((key, value) {
        for (String artistId in value.artistIds) {
          artists[artistId]?.albumIds.add(value.id);
          artists[artistId]?.albumNames.add(value.title);
        }
      });

      _albums = albums;
      _songs = songs;
      _artists = artists;

      notify();
      return true;
    }

    return false;
  }

  /// returns null in case of an error
  Future<Map<String, Album>?> _fetchAlbums() async {
    Map<String, Album> albums = {};

    var response = await http.get(
      Uri.parse(
          '$_jellyfinUrl/Users/$_userId/Items?includeItemTypes=MusicAlbum&recursive=true'),
      headers: reqHeaders,
    );

    if (response.statusCode == 200) {
      final int albumCount = jsonDecode(response.body)['TotalRecordCount'];

      for (int i = 0; i < albumCount; i++) {
        Album temp = Album.fromJson(jsonDecode(response.body)['Items'][i]);

        albums[temp.id] = temp;
      }

      return albums;
    }

    return null;
  }

  /// returns null in case of an error
  Future<Map<String, Song>?> _fetchSongs() async {
    Map<String, Song> songs = {};

    var response = await http.get(
      Uri.parse(
          '$_jellyfinUrl/Users/$_userId/Items?includeItemTypes=Audio&recursive=true'),
      headers: reqHeaders,
    );

    if (response.statusCode == 200) {
      final int albumCount = jsonDecode(response.body)['TotalRecordCount'];

      for (int i = 0; i < albumCount; i++) {
        Song temp = Song.fromJson(jsonDecode(response.body)['Items'][i]);

        songs[temp.id] = temp;
      }

      return songs;
    }

    return null;
  }

  /// returns null in case of an error
  Future<Map<String, Artist>?> _fetchArtists() async {
    Map<String, Artist> artists = {};

    var response = await http.get(
      Uri.parse(
          '$_jellyfinUrl/Users/$_userId/Items?includeItemTypes=MusicArtist&recursive=true'),
      headers: reqHeaders,
    );

    if (response.statusCode == 200) {
      final int albumCount = jsonDecode(response.body)['TotalRecordCount'];

      for (int i = 0; i < albumCount; i++) {
        Artist temp = Artist.fromJson(jsonDecode(response.body)['Items'][i]);

        artists[temp.id] = temp;
      }

      return artists;
    }

    return null;
  }

  List<Album> getAlbums({SortType sortType = SortType.albumArtist}) {
    List<Album> albums = [];

    _albums.forEach((key, value) {
      albums.add(value);
    });

    switch (sortType) {
      case SortType.albumName:
        break;
      case SortType.albumNameDesc:
        break;
      case SortType.albumArtist:
        albums = _sortByArtist(albums, false);
        break;
      case SortType.albumArtistDesc:
        albums = _sortByArtist(albums, true);
        break;
    }

    return albums;
  }

  List<Album> _sortByArtist(List<Album> albums, bool desc) {
    int multiplier = desc ? -1 : 1;

    albums.sort((a, b) {
      if (a.artistNames.isNotEmpty && b.artistNames.isNotEmpty) {
        if (a.artistNames.isEmpty) {
          return 1 * multiplier;
        } else if (b.artistNames.isEmpty) {
          return -1 * multiplier;
        } else {
          a.artistNames
              .sort((c, d) => c.toLowerCase().compareTo(d.toLowerCase()));
          b.artistNames
              .sort((c, d) => c.toLowerCase().compareTo(d.toLowerCase()));

          if (a.artistNames.first.toLowerCase() ==
              b.artistNames.first.toLowerCase()) {
            return a.title.toLowerCase().compareTo(b.title.toLowerCase()) *
                multiplier;
          } else {
            return a.artistNames.first
                    .toLowerCase()
                    .compareTo(b.artistNames.first.toLowerCase()) *
                multiplier;
          }
        }
      } else {
        return 0;
      }
    });

    return albums;
  }

  List<Album> _sortByTitle(List<Album> albums, bool desc) {
    int multiplier = desc ? -1 : 1;

    albums.sort((a, b) {
      if (a.title.toLowerCase() == b.title.toLowerCase()) {
        return 0;
      } else {
        return a.title.toLowerCase().compareTo(b.title.toLowerCase()) *
            multiplier;
      }
    });

    return albums;
  }

  //    _____
  //   |_   _|
  //     | |  _ __ ___   __ _  __ _  ___  ___
  //     | | | '_ ` _ \ / _` |/ _` |/ _ \/ __|
  //    _| |_| | | | | | (_| | (_| |  __/\__ \
  //   |_____|_| |_| |_|\__,_|\__, |\___||___/
  //                           __/ |
  //                          |___/

}
