import 'package:dio/dio.dart';

/// Exception domain mapping dari error API backend (ElysiaJS).
class ApiException implements Exception {
  const ApiException(this.message, {this.code, this.statusCode});

  const ApiException.unknown()
      : message = 'Terjadi kesalahan. Coba lagi nanti.',
        code = null,
        statusCode = null;

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => message;

  /// Konversi [DioException] (atau exception lain) ke [ApiException] ramah-user.
  static ApiException from(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      String serverMessage = 'Terjadi kesalahan. Coba lagi nanti.';
      String? serverCode;
      if (data is Map<String, dynamic>) {
        // Envelope backend: { success, data, error?, requestId }
        final err = data['error'];
        if (err is Map<String, dynamic>) {
          serverMessage = err['message'] as String? ?? data['message'] as String? ?? serverMessage;
          serverCode = err['code'] as String?;
        } else if (err is String) {
          serverMessage = err;
        }
      }
      return switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.transformTimeout =>
          const ApiException(
            'Koneksi ke server lambat. Periksa jaringanmu.',
          ),
        DioExceptionType.connectionError => const ApiException(
            'Tidak dapat terhubung ke server. Pastikan backend berjalan.',
          ),
        DioExceptionType.badResponse => ApiException(
            serverMessage,
            code: serverCode,
            statusCode: error.response?.statusCode,
          ),
        DioExceptionType.cancel => const ApiException('Request dibatalkan.'),
        DioExceptionType.badCertificate => const ApiException(
            'Sertifikat server tidak valid.',
          ),
        DioExceptionType.unknown => ApiException(
            error.message ?? 'Terjadi kesalahan tak dikenal.',
          ),
      };
    }
    if (error is ApiException) return error;
    return const ApiException.unknown();
  }
}