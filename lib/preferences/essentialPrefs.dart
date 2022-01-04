import 'package:shared_preferences/shared_preferences.dart';
import 'package:jellyamp/classes/prefs.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<EssentialInfo> getEssentialInfo() async {
  SharedPreferences prefs = await _prefs;
  String jellyfinUrl = prefs.getString("env/JellyfinUrl") ?? '';
  String mediaBrowserToken = prefs.getString("env/MediaBrowserToken") ?? '';
  String userId = prefs.getString("env/UserId") ?? '';
  String libraryId = prefs.getString("env/LibraryId") ?? '';

  return EssentialInfo(
    jellyfinUrl,
    mediaBrowserToken,
    userId,
    libraryId,
  );
}

Future<void> setEssentialInfo(String key, String value) async {
  SharedPreferences prefs = await _prefs;

  prefs.setString('env/$key', value);
}
