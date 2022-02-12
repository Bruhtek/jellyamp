import 'package:jellyamp/classes/audio.dart';

enum SortType {
  albumArtist,
  albumArtistDesc,
  albumName,
  albumNameDesc,
}

abstract class APIService {
  SortType sortType = SortType.albumArtist;
  Map<String, AlbumInfo>? detailedAlbumInfos;

  Future<Map<String, AlbumInfo>> fetchAlbums();
  Future<AlbumInfo> fetchAlbumSongs(String albumId);

  Future<List<AlbumInfo>> fetchAlbumsSorted();
  Future<Map<String, AlbumInfo>> forceFetchAlbums();
  Future<bool> correctServerUrl(String url);
}
