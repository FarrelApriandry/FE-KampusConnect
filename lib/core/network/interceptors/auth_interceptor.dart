import 'package:dio/dio.dart';

import '../../storage/session_store.dart';

/// Menyisipkan token JWT dari [SessionStore] sebagai Bearer header.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._sessionStore);

  final SessionStore? _sessionStore;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] == true) return handler.next(options);
    if (_sessionStore == null) return handler.next(options);
    final token = await _sessionStore.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}