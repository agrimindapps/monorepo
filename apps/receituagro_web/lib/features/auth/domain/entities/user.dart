import 'package:equatable/equatable.dart';

import 'user_role.dart';

/// User entity (business model)
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// Check if user has write permissions
  bool get canWrite => role.canWrite;

  /// Check if user has delete permissions
  bool get canDelete => role.canDelete;

  /// Check if user is admin
  bool get isAdmin => role.isAdmin;

  @override
  List<Object?> get props => [id, email, name, role, createdAt, lastLoginAt];

  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
