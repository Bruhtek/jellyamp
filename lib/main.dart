import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';

import 'screens/index.dart';
import 'providers/jellyfin.dart';
import 'providers/audio_handler.dart';

late JellyfinAPI _jellyfinAPI;
late ChangeNotifierProvider<JellyfinAPI> jellyfinAPIProvider;
late JustAudioHandler _justAudioHandler;
late Provider<JustAudioHandler> justAudioProvider;
late StreamProvider<SequenceState?> sequenceStateProvider;

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  await Hive.initFlutter();
  await Hive.openBox('encrypted');
  await Hive.openBox<Map<dynamic, dynamic>>('preferences');
  await Hive.openLazyBox('musicData');

  _jellyfinAPI = JellyfinAPI();
  jellyfinAPIProvider = ChangeNotifierProvider((ref) => _jellyfinAPI);

  _justAudioHandler = await AudioService.init<JustAudioHandler>(
    builder: () => JustAudioHandler(_jellyfinAPI),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.bruhtek.jellyamp.channel.audio',
      androidNotificationChannelName: 'Jellyamp playback',
      androidShowNotificationBadge: true,
    ),
  );
  justAudioProvider = Provider((ref) => _justAudioHandler);
  sequenceStateProvider =
      StreamProvider<SequenceState?>((ref) => _justAudioHandler.sequenceStateStream);

  // fed up with secure storage, impossible to develop with
  // final secureStorage = new FlutterSecureStorage();
  // WidgetsFlutterBinding.ensureInitialized();
  // String? encryptionKey = await secureStorage.read(key: 'key');
  // if (encryptionKey == null) {
  //   final key = Hive.generateSecureKey();
  //   await secureStorage.write(
  //     key: 'key',
  //     value: base64UrlEncode(key),
  //   );
  //   encryptionKey = base64UrlEncode(key);
  // }
  // final encryptKey = base64Url.decode(encryptionKey);
  // await Hive.openBox('encrypted', encryptionCipher: HiveAesCipher(encryptKey));

  runApp(const ProviderScope(child: IndexScreen()));
}
