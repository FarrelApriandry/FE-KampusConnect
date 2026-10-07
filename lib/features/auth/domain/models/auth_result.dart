import '../models/user.dart';

/// Hasil autentikasi dari backend: user + JWT.
class AuthResult {
  const AuthResult({required this.user, required this.token});

  final User user;
  final String token;

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        user: User.fromJson((json['user'] as Map?)?.cast<String, dynamic>() ?? {}),
        token: json['token']?.toString() ?? '',
      );
}