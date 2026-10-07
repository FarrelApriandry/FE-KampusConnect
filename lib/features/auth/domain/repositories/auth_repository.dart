import '../models/auth_result.dart';
import '../models/user.dart';

/// Kontrak repository autentikasi KampusConnect.
abstract interface class AuthRepository {
  Future<AuthResult> login({
    required String email,
    required String password,
    String? mode,
  });

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? studentId,
    String? faculty,
    String? major,
    int? academicYear,
  });

  Future<User> fetchMe();

  Future<void> logout();
}