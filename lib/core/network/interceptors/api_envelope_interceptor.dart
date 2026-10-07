import 'package:dio/dio.dart';

import '../api_exception.dart';

/// Membuka envelope backend `{ success, data, error?, requestId }`.
///
/// - 2xx → kembalikan payload `data` apa adanya.
/// - non-2xx → lempar [DioException] dengan [ApiException] sebagai error,
///   sehingga [ApiException.from] bisa membaca pesan user-friendly.
class ApiEnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final body = response.data;
    // Selalu bentuk Map untuk read payload.
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      final hasSuccessFlag = body.containsKey('success');
      if (hasSuccessFlag) {
        response.data = data;
      }
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    if (response != null && response.data is Map<String, dynamic>) {
      final body = response.data as Map<String, dynamic>;
      final errorField = body['error'];
      String message = 'Terjadi kesalahan. Coba lagi nanti.';
      String? code;

      if (errorField is Map<String, dynamic>) {
        message = errorField['message'] as String? ?? message;
        code = errorField['code'] as String?;
      } else if (errorField is String) {
        message = errorField;
      } else if (body['message'] is String) {
        message = body['message'] as String;
      }

      final wrapped = DioException(
        requestOptions: err.requestOptions,
        response: Response<dynamic>(
          requestOptions: err.requestOptions,
          statusCode: response.statusCode,
          data: {
            'message': message,
            'code': code,
            'statusCode': response.statusCode,
          },
        ),
        type: DioExceptionType.badResponse,
        error: ApiException(
          message,
          code: code,
          statusCode: response.statusCode,
        ),
      );
      return handler.next(wrapped);
    }

    // Error non-HTTP (timeout, koneksi, dsb) — tetap bungkus agar pesan konsisten.
    final wrapped = DioException(
      requestOptions: err.requestOptions,
      error: ApiException.from(err),
    );
    handler.next(wrapped);
  }
}