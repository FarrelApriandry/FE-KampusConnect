import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../domain/models/auth_result.dart';
import '../domain/models/user.dart';

/// Datasource HTTP untuk endpoint `/api/v1/auth/*` dan `/api/v1/me`.
class AuthRemoteDatasource {
  AuthRemoteDatasource(this._dio);

  final Dio _dio;

  Future<AuthResult> login({
    required String email,
    required String password,
    String? mode,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/login',
        data: {
          'email': email,
          'password': password,
          'mode': ?mode,
        },
      );
      return AuthResult.fromJson(res.data ?? {});
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
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
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'student_id': studentId,
          'faculty': faculty,
          'major': major,
          'academic_year': academicYear,
        },
        options: Options(
          // Register tidak butuh auth header.
          extra: {'skipAuth': true},
        ),
      );
      return AuthResult.fromJson(res.data ?? {});
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<User> fetchMe() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/me');
      return User.fromJson(res.data ?? {});
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post<void>('/api/v1/auth/logout');
    } on DioException catch (e) {
      // Logout tetap dianggap sukses (token dihapus lokal).
      throw ApiException.from(e);
    }
  }
}
