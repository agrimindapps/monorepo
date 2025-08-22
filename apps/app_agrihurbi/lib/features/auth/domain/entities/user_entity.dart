import 'package:equatable/equatable.dart';

/// User entity for the domain layer
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        profileImageUrl,
        createdAt,
        lastLoginAt,
        isActive,
      ];
}