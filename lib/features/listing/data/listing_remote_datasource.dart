import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../domain/models/category.dart';
import '../domain/models/listing.dart';

/// Datasource HTTP untuk `/api/v1/listings` dan `/api/v1/categories`.
class ListingRemoteDatasource {
  ListingRemoteDatasource(this._dio);

  final Dio _dio;

  /// GET /listings — feed publik dengan filter & sort.
  Future<({List<Listing> items, int total, bool hasNext})> list({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? type,
    String? condition,
    String? status = 'ACTIVE',
    num? minPrice,
    num? maxPrice,
    String? sort,
    String? sellerId,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/listings',
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': ?search,
          'category': ?category,
          'type': ?type,
          'condition': ?condition,
          'status': ?status,
          'minPrice': ?minPrice,
          'maxPrice': ?maxPrice,
          'sort': ?sort,
          'sellerId': ?sellerId,
        },
      );
      final data = res.data ?? {};
      final items = (data['items'] as List? ?? const [])
          .map((e) => Listing.fromJson((e as Map?)?.cast<String, dynamic>() ?? {}))
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

  /// GET /listings/:id — detail + seller + images.
  Future<Listing> getById(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/listings/$id');
      return Listing.fromJson(res.data ?? {});
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  /// POST /listings — buat listing baru (wajib login).
  Future<Listing> create({
    required String title,
    required num price,
    String? description,
    String? categoryId,
    String type = 'PRODUCT',
    String? condition,
    String? meetupLocation,
    List<String> images = const [],
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/listings',
        data: {
          'title': title,
          'price': price,
          'description': ?description,
          'categoryId': ?categoryId,
          'type': type,
          'condition': ?condition,
          'meetupLocation': ?meetupLocation,
          'images': images.isEmpty ? null : images,
        },
      );
      return Listing.fromJson(res.data ?? {});
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  /// PATCH /listings/:id — update sebagian field (wajib login, pemilik).
  Future<Listing> update(
    String id, {
    String? title,
    String? description,
    String? categoryId,
    String? type,
    num? price,
    String? condition,
    String? meetupLocation,
    String? status,
  }) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>(
        '/api/v1/listings/$id',
        data: {
          'title': ?title,
          'description': ?description,
          'categoryId': ?categoryId,
          'type': ?type,
          'price': ?price,
          'condition': ?condition,
          'meetupLocation': ?meetupLocation,
          'status': ?status,
        },
      );
      return Listing.fromJson(res.data ?? {});
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  /// DELETE /listings/:id — arsipkan (soft delete).
  Future<void> archive(String id) async {
    try {
      await _dio.delete<void>('/api/v1/listings/$id');
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  /// GET /categories — kategori produk/jasa.
  Future<List<Category>> categories() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/categories');
      final items = (res.data?['items'] as List? ?? const []);
      return items
          .map((e) =>
              Category.fromJson((e as Map?)?.cast<String, dynamic>() ?? {}))
          .toList();
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }
}
