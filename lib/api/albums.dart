import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:jellyamp/classes/audio.dart';
import 'package:jellyamp/env.dart';

enum SortType {
  albumArtist,
  albumArtistDesc,
  albumName,
  albumNameDesc,
}

class Albums {
  SortType sortType = SortType.albumArtist;

  //TODO: this is redundant, we should replace all use with detailedAlbumInfos
  List<AlbumInfo>? albumInfos;

  /// Id to AlbumInfo
  Map<String, AlbumInfo>? detailedAlbumInfos;

  Future<List<AlbumInfo>> fetchAlbums() async {
    if (albumInfos == null) {
      List<AlbumInfo> albums = [];

      var response = await http.get(
          Uri.parse(
              '$reqBaseUrl/Users/$envUserId/Items?parentId=$envLibraryId&includeItemTypes=MusicAlbum&recursive=true'),
          headers: reqHeaders);

      if (response.statusCode == 200) {
        final int albumCount = jsonDecode(response.body)['TotalRecordCount'];

        for (int i = 0; i < albumCount; i++) {
          albums.add(
              AlbumInfo.fromJsonNoSongs(jsonDecode(response.body)['Items'][i]));
        }

        // ignore: prefer_for_elements_to_map_fromiterable
        detailedAlbumInfos = Map.fromIterable(
          albums,
          key: (e) => e.id,
          value: (e) => e,
        );
        albumInfos = albums;
      } else {
        throw Exception("Failed to fetch albums!");
      }

      return albums;
    } else {
      return albumInfos!;
    }
  }

  Future<AlbumInfo> fetchAlbumSongs(String albumId) async {
    AlbumInfo? albumInfo = detailedAlbumInfos?[albumId];

    if (albumInfo != null && albumInfo.songs != null) {
      if (albumInfo.songs!.isNotEmpty) {
        return albumInfo;
      }
    }

    // a little on the paranoid side, since we already have the album info in 99% of the cases
    if (albumInfo == null) {
      final albumInfoUrl = '$reqBaseUrl/Users/$envUserId/Items?ids=$albumId';

      final response = await http.get(
        Uri.parse(albumInfoUrl),
        headers: reqHeaders,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        albumInfo = AlbumInfo.fromJsonNoSongs(json['Items'][0]);
      } else {
        throw Exception("Failed to fetch album info!");
      }
    }

    List<SongInfo> songs = [];
    final String songsInfoUrl =
        '$reqBaseUrl/Users/$envUserId/Items?parentId=$albumId&includeItemTypes=Audio&recursive=true';

    final response = await http.get(
      Uri.parse(songsInfoUrl),
      headers: reqHeaders,
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      for (var song in json['Items']) {
        songs.add(SongInfo.fromJson(song));
      }

      albumInfo.songs = songs;
      detailedAlbumInfos![albumId] = albumInfo;
    } else {
      throw Exception("Failed to fetch songs info!");
    }

    return albumInfo;
  }

  List<AlbumInfo> _sortByArtist(List<AlbumInfo> albums, bool desc) {
    int multiplier = desc ? -1 : 1;
    albums.sort((a, b) {
      if (a.artists != null && b.artists != null) {
        if (a.artists == null) {
          return 1 * multiplier;
        } else if (b.artists == null) {
          return -1 * multiplier;
        } else {
          a.artists!.sort((c, d) => c.toLowerCase().compareTo(d.toLowerCase()));
          b.artists!.sort((c, d) => c.toLowerCase().compareTo(d.toLowerCase()));

          if (a.artists!.first.toLowerCase() ==
              b.artists!.first.toLowerCase()) {
            return a.title.toLowerCase().compareTo(b.title.toLowerCase()) *
                multiplier;
          } else {
            return a.artists!.first
                    .toLowerCase()
                    .compareTo(b.artists!.first.toLowerCase()) *
                multiplier;
          }
        }
      } else {
        return 0;
      }
    });

    return albums;
  }

  Future<List<AlbumInfo>> fetchAlbumsSorted() async {
    List<AlbumInfo> albums = await fetchAlbums();

    //sort by album artist name, and if equal, by album name
    switch (sortType) {
      case SortType.albumArtist:
        return _sortByArtist(albums, false);
      case SortType.albumArtistDesc:
        return _sortByArtist(albums, true);
      case SortType.albumName:
        albums.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        return albums;
      case SortType.albumNameDesc:
        albums.sort(
            (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        return albums;
      default:
        return _sortByArtist(albums, false);
    }
  }

  //TODO: change this, it shouldn't just delete cached data, since we could have no connection
  Future<List<AlbumInfo>> forceFetchAlbums() async {
    albumInfos = null;
    return await fetchAlbums();
  }
}
