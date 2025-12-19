import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserProfileEntity({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.phoneNumber,
    this.createdAt,
    this.lastLoginAt,
  });

  UserProfileEntity copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserProfileEntity(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        displayName,
        email,
        photoUrl,
        phoneNumber,
        createdAt,
        lastLoginAt,
      ];
}
