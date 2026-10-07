import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../domain/models/transaction.dart';

/// Datasource HTTP untuk `/api/v1/transactions`.
class TransactionRemoteDatasource {
  TransactionRemoteDatasource(this._dio);

  final Dio _dio;

  /// GET /transactions — transaksi sebagai buyer/seller.
  Future<({List<Transaction> items, int total, bool hasNext})> list({
    int page = 1,
    int limit = 20,
    String? status,
    String? role,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/transactions',
        queryParameters: {
          'page': page,
          'limit': limit,
          'status': ?status,
          'role': ?role,
        },
      );
      final data = res.data ?? {};
      final items = (data['items'] as List? ?? const [])
          .map((e) =>
              Transaction.fromJson((e as Map?)?.cast<String, dynamic>() ?? {}))
          .toList();
      return (
        items: items,
        total: (data['total'] as num?)?.toInt() ?? items.length,
        hasNext: data['hasNext'] == true,
      );
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  /// POST /listings/:id/transactions — ajukan transaksi (negosiasi harga).
  Future<Transaction> create({
    required String listingId,
    required num agreedPrice,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/listings/$listingId/transactions',
        data: {'agreedPrice': agreedPrice},
      );
      return Transaction.fromJson(res.data ?? {});
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  /// PATCH /transactions/:id/status — terima/tolak/selesaikan/batalkan.
  Future<Transaction> updateStatus({
    required String id,
    required String status,
  }) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>(
        '/api/v1/transactions/$id/status',
        data: {'status': status},
      );
      return Transaction.fromJson(res.data ?? {});
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }
}
