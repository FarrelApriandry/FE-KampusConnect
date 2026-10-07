import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Penyimpanan token JWT (secure) + data sesi ringan (SharedPreferences).
class SessionStore {
  SessionStore({FlutterSecureStorage? secureStorage})
      : _secure = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secure;

  Future<String?> readToken() => _secure.read(key: kTokenKey);

  Future<void> writeToken(String token) =>
      _secure.write(key: kTokenKey, value: token);

  Future<void> clearToken() => _secure.delete(key: kTokenKey);
}

Future<String?> readCachedUserJson() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(kUserKey);
}

Future<void> writeCachedUserJson(String json) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(kUserKey, json);
}

Future<void> clearCachedUserJson() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(kUserKey);
}