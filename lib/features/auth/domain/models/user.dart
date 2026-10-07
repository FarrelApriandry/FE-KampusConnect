/// Model user KampusConnect — cocok dengan `PublicUser` backend.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.studentId,
    this.faculty,
    this.major,
    this.academicYear,
    this.avatarUrl,
    this.bio,
    this.role = 'USER',
    this.verificationStatus = 'PENDING',
    this.accountStatus = 'ACTIVE',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String? studentId;
  final String? faculty;
  final String? major;
  final int? academicYear;
  final String? avatarUrl;
  final String? bio;
  final String role;
  final String verificationStatus;
  final String accountStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isVerified => verificationStatus == 'VERIFIED';
  bool get isAdmin => role == 'ADMIN';
  String get displayInitials =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime? date(String? v) => v == null ? null : DateTime.tryParse(v);
    int? year(dynamic v) => v is num ? v.toInt() : null;
    String? str(dynamic v) => v?.toString();

    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      studentId: str(json['student_id']),
      faculty: str(json['faculty']),
      major: str(json['major']),
      academicYear: year(json['academic_year']),
      avatarUrl: str(json['avatar_url']),
      bio: str(json['bio']),
      role: json['role']?.toString() ?? 'USER',
      verificationStatus:
          json['verification_status']?.toString() ?? 'PENDING',
      accountStatus: json['account_status']?.toString() ?? 'ACTIVE',
      createdAt: date(json['created_at']),
      updatedAt: date(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'student_id': studentId,
        'faculty': faculty,
        'major': major,
        'academic_year': academicYear,
        'avatar_url': avatarUrl,
        'bio': bio,
        'role': role,
        'verification_status': verificationStatus,
        'account_status': accountStatus,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}