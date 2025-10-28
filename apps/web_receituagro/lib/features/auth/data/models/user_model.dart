import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';

/// User data model (DTO)
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    required super.createdAt,
    super.lastLoginAt,
  });

  /// Create model from JSON (Supabase format)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['user_metadata']?['name']?.toString() ??
          json['email']?.toString().split('@').first ??
          '',
      role: UserRole.fromString(
        json['user_metadata']?['role']?.toString() ?? 'viewer',
      ),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastLoginAt: json['last_sign_in_at'] != null
          ? DateTime.tryParse(json['last_sign_in_at'].toString())
          : null,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_metadata': {
        'name': name,
        'role': role.value,
      },
      'created_at': createdAt.toIso8601String(),
      'last_sign_in_at': lastLoginAt?.toIso8601String(),
    };
  }

  /// Create model from domain entity
  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      role: entity.role,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
    );
  }

  /// Convert model to domain entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      role: role,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
