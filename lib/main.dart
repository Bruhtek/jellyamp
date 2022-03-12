import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/index.dart';
import 'api/jellyfin.dart';

final jellyfinAPIProvider = ChangeNotifierProvider((ref) => JellyfinAPI());

void main() async {
  await Hive.initFlutter();
  // fed up with secure storage, impossible to develop with
  /*final secureStorage = new FlutterSecureStorage();
  WidgetsFlutterBinding.ensureInitialized();
  String? encryptionKey = await secureStorage.read(key: 'key');
  if (encryptionKey == null) {
    final key = Hive.generateSecureKey();
    await secureStorage.write(
      key: 'key',
      value: base64UrlEncode(key),
    );
    encryptionKey = base64UrlEncode(key);
  }
  final encryptKey = base64Url.decode(encryptionKey);
  await Hive.openBox('encrypted', encryptionCipher: HiveAesCipher(encryptKey));*/
  await Hive.openBox('encrypted');
  await Hive.openBox('preferences');
  await Hive.openLazyBox('musicData');

  runApp(const ProviderScope(child: IndexScreen()));
}
