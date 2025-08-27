import 'package:equatable/equatable.dart';

enum UserType { anonymous, registered, premium }

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final UserType type;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? lastSignInAt;
  final Map<String, dynamic> metadata;

  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.type,
    required this.isEmailVerified,
    required this.createdAt,
    this.lastSignInAt,
    this.metadata = const {},
  });

  bool get isAnonymous => type == UserType.anonymous;
  bool get isRegistered => type == UserType.registered || type == UserType.premium;
  bool get isPremium => type == UserType.premium;
  
  // Compatibility getter
  String get uid => id;
  bool get hasDisplayName => displayName != null && displayName!.isNotEmpty;
  bool get hasProfilePhoto => photoUrl != null && photoUrl!.isNotEmpty;

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    UserType? type,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      type: type ?? this.type,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        type,
        isEmailVerified,
        createdAt,
        lastSignInAt,
        metadata,
      ];

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, displayName: $displayName, type: $type)';
  }
}