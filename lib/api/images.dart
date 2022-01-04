import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:jellyamp/env.dart';

const bool useCache = true;

Future<File> fileImage(String filename) async {
  Directory dir = await getApplicationDocumentsDirectory();
  Directory subDir =
      await Directory('${dir.path}/cachedImages').create(recursive: true);
  String pathName = '${subDir.path}/$filename';
  return File(pathName);
}

Future<ImageProvider> _imageWithCache({
  required String imageFilename,
  required String url,
}) async {
  return NetworkToFileImage(
    url: url,
    file: await fileImage(imageFilename),
    headers: reqHeaders,
  );
}

Widget imageIfTagExists({
  required String? primaryImageTag,
  required String itemId,
  Widget? alternative,
  BoxFit? fit,
}) {
  if (primaryImageTag != null) {
    final String url =
        '$reqBaseUrl/Items/$itemId/Images/Primary?tag=$primaryImageTag';

    return FutureBuilder<ImageProvider>(
      future: _imageWithCache(
        imageFilename: primaryImageTag + ".img",
        url: url,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return FadeInImage(
            fadeInDuration: const Duration(milliseconds: 200),
            placeholder: MemoryImage(kTransparentImage),
            image: snapshot.data!,
            fit: fit,
          );
        } else {
          return alternative ?? Container();
        }
      },
    );
  } else {
    return alternative ?? Container();
  }
}
