import 'package:jellyamp/classes/audio.dart';

enum SortType {
  albumArtist,
  albumArtistDesc,
  albumName,
  albumNameDesc,
}

abstract class APIService {
  SortType sortType = SortType.albumArtist;
  List<AlbumInfo>? albumInfos;
  Map<String, AlbumInfo>? detailedAlbumInfos;

  Future<List<AlbumInfo>> fetchAlbums();
  Future<AlbumInfo> fetchAlbumSongs(String albumId);

  Future<List<AlbumInfo>> fetchAlbumsSorted();
  Future<List<AlbumInfo>> forceFetchAlbums();
  Future<bool> correctServerUrl(String url);
}
