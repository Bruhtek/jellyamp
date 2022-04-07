import 'package:audio_service/audio_service.dart';

class AlbumArguments {
  final String albumId;
  final String albumName;

  AlbumArguments(this.albumId, this.albumName);
}

class SongInfo {
  final String id;
  final String title;
  final String albumId;
  List<String>? artists;
  //primaryImage from album, since song doesn't have one
  String? primaryImageTag;
  int trackNumber;
  bool isFavorite;

  SongInfo({
    required this.id,
    required this.title,
    required this.albumId,
    required this.trackNumber,
    this.artists,
    this.primaryImageTag,
    this.isFavorite = false,
  });

  factory SongInfo.fromJson(Map<String, dynamic> json) {
    List<String> artists = [];

    for (var artist in json['ArtistItems']) {
      artists.add(artist['Name']);
    }

    return SongInfo(
      id: json['Id'] as String,
      title: json['Name'] as String,
      albumId: json['AlbumId'] as String,
      trackNumber: (json['IndexNumber'] ?? 0) as int,
      artists: artists,
      primaryImageTag: json['AlbumPrimaryImageTag'] as String?,
      isFavorite: json['UserData']['IsFavorite'] as bool,
    );
  }
}

class AlbumInfo {
  final String id;
  final String title;
  List<String>? artists;
  List<SongInfo> songs;
  String? primaryImageTag;
  bool isFavorite;

  AlbumInfo({
    required this.id,
    required this.title,
    this.artists,
    required this.songs,
    this.primaryImageTag,
    this.isFavorite = false,
  });

  factory AlbumInfo.fromJsonNoSongs(Map<String, dynamic> json) {
    List<String> albumArtists = [];

    for (var artist in json['AlbumArtists']) {
      albumArtists.add(artist['Name']);
    }

    return AlbumInfo(
      id: json['Id'] as String,
      title: json['Name'] as String,
      artists: albumArtists,
      songs: [],
      primaryImageTag: json['ImageTags']['Primary'] as String?,
      isFavorite: json['UserData']['IsFavorite'] as bool,
    );
  }
}

/*class AudioMetadata {
  final String id;
  final String albumId;
  final String title;
  final String? primaryImageTag;
  final List<String>? artists;

  AudioMetadata({
    required this.id,
    required this.albumId,
    required this.title,
    this.primaryImageTag,
    this.artists,
  });
}*/