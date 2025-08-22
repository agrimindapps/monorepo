import 'package:equatable/equatable.dart';

enum UserRole {
  user,
  premium,
  admin,
}

enum AuthProvider {
  email,
  google,
  apple,
  facebook,
}

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final UserRole role;
  final AuthProvider provider;
  final bool isEmailVerified;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.role = UserRole.user,
    this.provider = AuthProvider.email,
    this.isEmailVerified = false,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    UserRole? role,
    AuthProvider? provider,
    bool? isEmailVerified,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      provider: provider ?? this.provider,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  bool get hasValidPremium {
    if (!isPremium) return false;
    if (premiumExpiresAt == null) return true; // Lifetime premium
    return DateTime.now().isBefore(premiumExpiresAt!);
  }

  bool get needsEmailVerification => !isEmailVerified && provider == AuthProvider.email;

  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    return email.split('@').first;
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        photoUrl,
        role,
        provider,
        isEmailVerified,
        isPremium,
        premiumExpiresAt,
        metadata,
        createdAt,
        updatedAt,
        lastLoginAt,
      ];
}