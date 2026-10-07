import 'dart:convert';

import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_store.dart';
import '../domain/models/auth_result.dart';
import '../domain/models/user.dart';
import '../domain/repositories/auth_repository.dart';
import 'auth_remote_datasource.dart';

/// Implementasi [AuthRepository] yang mem-persist token + user (cache).
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._datasource, this._sessionStore);

  final AuthRemoteDatasource _datasource;
  final SessionStore _sessionStore;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
    String? mode,
  }) async {
    final result = await _datasource.login(
      email: email,
      password: password,
      mode: mode,
    );
    await _persistSession(result);
    return result;
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? studentId,
    String? faculty,
    String? major,
    int? academicYear,
  }) async {
    final result = await _datasource.register(
      name: name,
      email: email,
      password: password,
      studentId: studentId,
      faculty: faculty,
      major: major,
      academicYear: academicYear,
    );
    await _persistSession(result);
    return result;
  }

  @override
  Future<User> fetchMe() async {
    final user = await _datasource.fetchMe();
    await writeCachedUserJson(jsonEncode(user.toJson()));
    return user;
  }

  @override
  Future<void> logout() async {
    try {
      await _datasource.logout();
    } on ApiException {
      // Abaikan error server; session tetap dibersihkan lokal.
    }
    await _sessionStore.clearToken();
    await clearCachedUserJson();
  }

  Future<void> _persistSession(AuthResult result) async {
    await _sessionStore.writeToken(result.token);
    await writeCachedUserJson(jsonEncode(result.user.toJson()));
  }
}