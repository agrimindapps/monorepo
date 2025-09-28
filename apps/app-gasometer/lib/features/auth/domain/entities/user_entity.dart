import 'package:equatable/equatable.dart';

enum UserType { anonymous, registered, premium }

class UserEntity extends Equatable {

  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.avatarBase64,
    required this.type,
    required this.isEmailVerified,
    required this.createdAt,
    this.lastSignInAt,
    this.metadata = const {},
  });
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? avatarBase64; // Local avatar as base64 string
  final UserType type;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? lastSignInAt;
  final Map<String, dynamic> metadata;

  bool get isAnonymous => type == UserType.anonymous;
  bool get isRegistered => type == UserType.registered || type == UserType.premium;
  bool get isPremium => type == UserType.premium;
  
  // Compatibility getter
  String get uid => id;
  bool get hasDisplayName => displayName != null && displayName!.isNotEmpty;
  bool get hasProfilePhoto => photoUrl != null && photoUrl!.isNotEmpty;
  bool get hasLocalAvatar => avatarBase64 != null && avatarBase64!.isNotEmpty;
  
  // Priority: local avatar over remote photoUrl
  String? get effectiveAvatar => hasLocalAvatar ? avatarBase64 : photoUrl;

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? avatarBase64,
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
      avatarBase64: avatarBase64 ?? this.avatarBase64,
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
        avatarBase64,
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