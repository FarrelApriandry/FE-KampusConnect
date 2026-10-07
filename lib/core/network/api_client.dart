import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../storage/session_store.dart';
import 'interceptors/api_envelope_interceptor.dart';
import 'interceptors/auth_interceptor.dart';

/// Dio instance terpusat untuk seluruh request API KampusConnect.
///
/// Semua interceptor global terpasang di sini:
/// - [AuthInterceptor]: sisipkan `Authorization: Bearer <token>`.
/// - [ApiEnvelopeInterceptor]: membuka envelope `{ success, data, requestId }`
///   dan melempar [ApiException] berisi pesan error backend bila gagal.
Dio createApiClient({SessionStore? sessionStore}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: apiConnectTimeout,
      receiveTimeout: apiReceiveTimeout,
      sendTimeout: apiSendTimeout,
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(AuthInterceptor(sessionStore));
  dio.interceptors.add(ApiEnvelopeInterceptor());

  return dio;
}