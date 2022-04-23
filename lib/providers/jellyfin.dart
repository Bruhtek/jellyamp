import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:transparent_image/transparent_image.dart';

enum AlbumSortType {
  name,
  nameDesc,
  artist,
  artistDesc,
}

enum ArtistSortType {
  name,
  nameDesc,
}

enum SongSortType {
  name,
  nameDesc,
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

  Duration duration;

  bool isFavorite;

  Song({
    required this.id,
    required this.title,
    required this.albumPrimaryImageTag,
    required this.duration,
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
      duration: Duration(microseconds: (json['RunTimeTicks'] as int) ~/ 10),
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
  bool checkingAuth = false;
  bool wrongUrl = false;
  bool checkingUrl = false;

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
    loggedIn = false;
    wrongAuth = false;
    checkingAuth = false;
    wrongUrl = false;

    checkingUrl = true;
    if (_isUrlValid(url)) {
      checkingUrl = false;
      checkingAuth = true;
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
      try {
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

          checkingAuth = false;
          _initialize();
          return true;
        } else {
          checkingAuth = false;
          wrongAuth = true;
          return false;
        }
      } catch (e) {
        checkingAuth = false;
        wrongUrl = true;
        return false;
      }
    }
    checkingUrl = false;
    wrongUrl = true;

    _initialize();
    return false;
  }

  /// 0 - nothing,
  /// 1 - cheking url,
  /// 2 - wrong url,
  /// 3 - checking auth,
  /// 4 - wrong auth,
  /// 5 - success,
  Stream<int> loginStatusStream() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (checkingUrl) {
        yield 1;
      } else if (wrongUrl) {
        yield 2;
      } else if (checkingAuth) {
        yield 3;
      } else if (wrongAuth) {
        yield 4;
      } else if (loggedIn) {
        yield 5;
      } else {
        yield 0;
      }
    }
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
  Map<String, String> get reqHeaders => {'X-MediaBrowser-Token': _mediaBrowserToken};

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

  int get artistsCount => _artists.length;
  int get songsCount => _songs.length;
  int get albumsCount => _albums.length;

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

  /// all 3 return null in case of an error
  Future<Map<String, Album>?> _fetchAlbums() async {
    var response = await http.get(
      Uri.parse('$_jellyfinUrl/Users/$_userId/Items?includeItemTypes=MusicAlbum&recursive=true'),
      headers: reqHeaders,
    );

    if (response.statusCode == 200) {
      return compute(_sortAlbums, response);
    }

    return null;
  }
  Future<Map<String, Song>?> _fetchSongs() async {
    var response = await http.get(
      Uri.parse('$_jellyfinUrl/Users/$_userId/Items?includeItemTypes=Audio&recursive=true'),
      headers: reqHeaders,
    );

    if (response.statusCode == 200) {
      return compute(_sortSongs, response);
    }

    return null;
  }
  Future<Map<String, Artist>?> _fetchArtists() async {
    var response = await http.get(
      Uri.parse('$_jellyfinUrl/Users/$_userId/Items?includeItemTypes=MusicArtist&recursive=true'),
      headers: reqHeaders,
    );

    if (response.statusCode == 200) {
      return compute(_sortArtists, response);
    }

    return null;
  }

  Album? getAlbum(String id) => _albums[id];
  Artist? getArtist(String id) => _artists[id];
  Song? getSong(String id) => _songs[id];

  List<Album> getAlbums({AlbumSortType sortType = AlbumSortType.artist}) {
    List<Album> albums = [];

    _albums.forEach((key, value) {
      albums.add(value);
    });

    switch (sortType) {
      case AlbumSortType.name:
        albums = _sortByTitle(albums, false);
        break;
      case AlbumSortType.nameDesc:
        albums = _sortByTitle(albums, true);
        break;
      case AlbumSortType.artist:
        albums = _sortByArtist(albums, false);
        break;
      case AlbumSortType.artistDesc:
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
          a.artistNames.sort((c, d) => c.toLowerCase().compareTo(d.toLowerCase()));
          b.artistNames.sort((c, d) => c.toLowerCase().compareTo(d.toLowerCase()));

          if (a.artistNames.first.toLowerCase() == b.artistNames.first.toLowerCase()) {
            return a.title.toLowerCase().compareTo(b.title.toLowerCase()) * multiplier;
          } else {
            return a.artistNames.first.toLowerCase().compareTo(b.artistNames.first.toLowerCase()) *
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
        return a.title.toLowerCase().compareTo(b.title.toLowerCase()) * multiplier;
      }
    });

    return albums;
  }
  List<Artist> getArtists({ArtistSortType sortType = ArtistSortType.name}) {
    List<Artist> artists = [];

    _artists.forEach((key, value) {
      artists.add(value);
    });

    switch (sortType) {
      case ArtistSortType.name:
        artists.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case ArtistSortType.nameDesc:
        artists.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
    }

    return artists;
  }
  List<Song> getSongs({SongSortType sortType = SongSortType.name}) {
    List<Song> songs = [];

    _songs.forEach((key, value) {
      songs.add(value);
    });

    switch (sortType) {
      case SongSortType.name:
        songs.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SongSortType.nameDesc:
        songs.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }

    return songs;
  }

  List<Album> getRandomAlbums({int count = 20}) {
    List<Album> albums = [];

    _albums.forEach((key, value) {
      albums.add(value);
    });

    albums.shuffle();

    return albums.sublist(0, count);
  }
  List<Artist> getRandomArtists({int count = 20}) {
    List<Artist> artists = [];

    _artists.forEach((key, value) {
      artists.add(value);
    });

    artists.shuffle();

    return artists.sublist(0, count);
  }
  List<Song> getRandomSongs({int count = 20}) {
    List<Song> songs = [];

    _songs.forEach((key, value) {
      songs.add(value);
    });

    songs.shuffle();

    return songs.sublist(0, count);
  }

  List<Album> recomendedAlbums = [];
  List<Artist> recomendedArtists = [];
  List<Song> recomendedSongs = [];

  List<Album> getRecommendedAlbums() {
    if (recomendedAlbums.isEmpty) {
      recomendedAlbums = getRandomAlbums(count: 20);
    }

    return recomendedAlbums;
  }
  List<Artist> getRecommendedArtists() {
    if (recomendedArtists.isEmpty) {
      recomendedArtists = getRandomArtists(count: 20);
    }

    return recomendedArtists;
  }
  List<Song> getRecommendedSongs() {
    if (recomendedSongs.isEmpty) {
      recomendedSongs = getRandomSongs(count: 20);
    }

    return recomendedSongs;
  }

  /// returns a [MediaItem] with the data of a song
  /// returns `null` if the song with specified id doesnt exist
  Future<MediaItem?> mediaItemFromSongId(String songId) async {
    Song? song = _songs[songId];

    if (song == null) return null;

    Uri? artUri;

    if (song.albumPrimaryImageTag != null) {
      artUri = await getItemImageUri(song.id, song.albumPrimaryImageTag!);
    }

    return MediaItem(
      id: songId,
      title: song.title,
      duration: song.duration,
      artist: song.artistNames.join(', '),
      album: song.albumId,
      artUri: artUri,
    );
  }

  String getSongDownloadUrl(String songId) {
    return '$_jellyfinUrl/Items/$songId/Download';
  }

  //    _____
  //   |_   _|
  //     | |  _ __ ___   __ _  __ _  ___  ___
  //     | | | '_ ` _ \ / _` |/ _` |/ _ \/ __|
  //    _| |_| | | | | | (_| | (_| |  __/\__ \
  //   |_____|_| |_| |_|\__,_|\__, |\___||___/
  //                           __/ |
  //                          |___/

  Future<Uri> getItemImageUri(String itemId, String primaryImageTag) async {
    final File imageFile = await _fileImage(primaryImageTag + '.img');
    if (imageFile.existsSync()) {
      return imageFile.uri;
    }

    return Uri.parse(_imageTagUrl(primaryImageTag: primaryImageTag, itemId: itemId)!);
  }

  // the key is the image Url, to avoid any potential duplicates
  Map<String, ImageProvider> cachedImages = {};

  Future<File> _fileImage(String filename) async {
    Directory dir = await getApplicationDocumentsDirectory();
    Directory subDir = await Directory('${dir.path}/cachedImages').create(recursive: true);
    String pathName = '${subDir.path}/$filename';
    return File(pathName);
  }

  Future<ImageProvider> _imageWithCache({
    required String imageFilename,
    required String imageUrl,
  }) async {
    final image = NetworkToFileImage(
      url: imageUrl,
      file: await _fileImage(imageFilename),
      headers: reqHeaders,
      processError: (error) => MemoryImage(kTransparentImage),
    );

    cachedImages[imageUrl] = image;

    return image;
  }

  String? _imageTagUrl({
    required String primaryImageTag,
    required String itemId,
    int maxWidth = 256,
    int maxHeight = 256,
  }) {
    final String url =
        '$_jellyfinUrl/Items/$itemId/Images/Primary?maxWidth=$maxWidth&maxHeight=$maxHeight';

    return url;
  }

  Widget futureItemImage({
    required dynamic item,
    BoxFit fit = BoxFit.cover,
    int maxWidth = 256,
    int maxHeight = 256,
    Widget alternative = const SizedBox(),
  }) {
    String? imageTag;
    String itemId;

    if (item is Album) {
      imageTag = item.primaryImageTag;
      itemId = item.id;
    } else if (item is Artist) {
      imageTag = item.primaryImageTag;
      itemId = item.id;
    } else if (item is Song) {
      imageTag = item.albumPrimaryImageTag;
      itemId = item.albumId;
    } else if (item is MediaItem) {
      final file = File(item.artUri?.path ?? '');
      if (file.existsSync()) {
        return Image.file(file, fit: fit);
      }
      if (item.artUri != null) {
        return FadeInImage(
          image: NetworkImage(item.artUri!.path),
          placeholder: MemoryImage(kTransparentImage),
        );
      }

      return alternative;
    } else {
      return alternative;
    }

    if (imageTag == null) {
      return alternative;
    }

    final String url = _imageTagUrl(
      primaryImageTag: imageTag,
      itemId: itemId,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
    )!;

    if (cachedImages.containsKey(url)) {
      return Image(image: cachedImages[url]!, fit: fit);
    }

    return FutureBuilder<Widget>(
      future: itemImage(
        item: item,
        alternative: alternative,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        fit: fit,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        }

        return Container();
      },
    );
  }

  Future<Widget> itemImage({
    required dynamic item,
    BoxFit fit = BoxFit.cover,
    int maxWidth = 256,
    int maxHeight = 256,
    Widget alternative = const SizedBox(),
  }) async {
    String? imageTag;
    String itemId;

    if (item is Album) {
      imageTag = item.primaryImageTag;
      itemId = item.id;
    } else if (item is Artist) {
      imageTag = item.primaryImageTag;
      itemId = item.id;
    } else if (item is Song) {
      imageTag = item.albumPrimaryImageTag;
      itemId = item.albumId;
    } else {
      return alternative;
    }

    if (imageTag == null) {
      return alternative;
    }

    final String url = _imageTagUrl(
      primaryImageTag: imageTag,
      itemId: itemId,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
    )!;

    return FadeInImage(
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: MemoryImage(kTransparentImage),
      image: await _imageWithCache(
        imageFilename: imageTag + ".img",
        imageUrl: url,
      ),
      fit: fit,
    );
  }
}

Map<String, Album> _sortAlbums(dynamic response) {
  Map<String, Album> albums = {};

  final int albumCount = jsonDecode(response.body)['TotalRecordCount'];

  for (int i = 0; i < albumCount; i++) {
    Album temp = Album.fromJson(jsonDecode(response.body)['Items'][i]);

    albums[temp.id] = temp;
  }

  return albums;
}
Map<String, Song> _sortSongs(dynamic response) {
  Map<String, Song> songs = {};

  final int albumCount = jsonDecode(response.body)['TotalRecordCount'];

  for (int i = 0; i < albumCount; i++) {
    Song temp = Song.fromJson(jsonDecode(response.body)['Items'][i]);

    songs[temp.id] = temp;
  }

  return songs;
}
Map<String, Artist> _sortArtists(dynamic response) {
  Map<String, Artist> artists = {};

  final int albumCount = jsonDecode(response.body)['TotalRecordCount'];

  for (int i = 0; i < albumCount; i++) {
    Artist temp = Artist.fromJson(jsonDecode(response.body)['Items'][i]);

    artists[temp.id] = temp;
  }

  return artists;
}
