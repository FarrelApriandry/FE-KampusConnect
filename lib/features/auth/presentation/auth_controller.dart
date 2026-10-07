import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/providers.dart';
import '../../../core/storage/session_store.dart';
import '../domain/models/auth_result.dart';
import '../domain/models/user.dart';

/// State sesi aplikasi.
sealed class AuthState {
  const AuthState();

  const factory AuthState.initializing() = _Initializing;
  const factory AuthState.guest() = _Guest;
  const factory AuthState.authenticated({required User user}) = _Authenticated;

  bool get isInitializing => this is _Initializing;
  bool get isAuthenticated => this is _Authenticated;

  User? get user => switch (this) {
        _Authenticated(:final user) => user,
        _ => null,
      };
}

final class _Initializing extends AuthState {
  const _Initializing();
}

final class _Guest extends AuthState {
  const _Guest();
}

final class _Authenticated extends AuthState {
  const _Authenticated({required this.user});

  @override
  final User user;
}

/// Controller sesi: restore token saat startup, login, register, logout.
class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final token = await ref.read(sessionStoreProvider).readToken();
    if (token == null || token.isEmpty) return const AuthState.guest();

    // Restore user dari cache dulu agar splash tidak menunggu jaringan.
    User? cached;
    final cachedJson = await readCachedUserJson();
    if (cachedJson != null && cachedJson.isNotEmpty) {
      try {
        cached = User.fromJson(
          (jsonDecode(cachedJson) as Map).cast<String, dynamic>(),
        );
      } catch (_) {
        cached = null;
      }
    }

    // Refresh profil dari server (sekaligus validasi token).
    try {
      final user = await ref.read(authRepositoryProvider).fetchMe();
      return AuthState.authenticated(user: user);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await ref.read(authRepositoryProvider).logout();
        return const AuthState.guest();
      }
      // Token valid tapi offline → pakai cache.
      if (cached != null) return AuthState.authenticated(user: cached);
      await ref.read(authRepositoryProvider).logout();
      return const AuthState.guest();
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
    String? mode,
  }) async {
    final result = await ref.read(authRepositoryProvider).login(
          email: email,
          password: password,
          mode: mode,
        );
    state = AsyncData(AuthState.authenticated(user: result.user));
    return result;
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? studentId,
    String? faculty,
    String? major,
    int? academicYear,
  }) async {
    final result = await ref.read(authRepositoryProvider).register(
          name: name,
          email: email,
          password: password,
          studentId: studentId,
          faculty: faculty,
          major: major,
          academicYear: academicYear,
        );
    state = AsyncData(AuthState.authenticated(user: result.user));
    return result;
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(AuthState.guest());
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);