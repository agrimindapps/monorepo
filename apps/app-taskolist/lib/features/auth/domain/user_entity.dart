import 'package:core/core.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool _emailVerified;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    bool emailVerified = false,
  }) : _emailVerified = emailVerified;

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? emailVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? _emailVerified,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    avatarUrl,
    createdAt,
    updatedAt,
    isActive,
    _emailVerified,
  ];

  bool get isAnonymous => id == 'anonymous';
  bool get emailVerified => _emailVerified;
  bool get isEmailVerified => _emailVerified;
}
