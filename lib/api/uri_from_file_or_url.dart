import 'dart:io';

import 'package:jellyamp/api/jellyfin.dart';
import 'package:jellyamp/classes/audio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

Future<File> fileSong(String filename) async {
  Directory dir = await getApplicationDocumentsDirectory();
  Directory subDir =
      await Directory('${dir.path}/songs').create(recursive: true);
  String pathName = '${subDir.path}/$filename';
  return File(pathName);
}

// Add back the null check for the file
Future<AudioSource?> urlOrFileSave(
    AudioMetadata metadata, JellyfinAPI jellyfinAPI) async {
  String url = "${jellyfinAPI.reqBaseUrl}/Items/${metadata.id}/Download";
  await fileSong(metadata.id);

  //TODO: enable handling the file download

  return null;
}
