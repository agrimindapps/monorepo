import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.photoUrl,
    super.role,
    super.provider,
    super.isEmailVerified,
    super.isPremium,
    super.premiumExpiresAt,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
    super.lastLoginAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString(),
      photoUrl: map['photoUrl']?.toString(),
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${map['role']}',
        orElse: () => UserRole.user,
      ),
      provider: AuthProvider.values.firstWhere(
        (e) => e.toString() == 'AuthProvider.${map['provider']}',
        orElse: () => AuthProvider.email,
      ),
      isEmailVerified: (map['isEmailVerified'] as bool?) ?? false,
      isPremium: (map['isPremium'] as bool?) ?? false,
      premiumExpiresAt: map['premiumExpiresAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['premiumExpiresAt'] as int)
          : null,
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from((map['metadata'] as Map?) ?? {})
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['createdAt'] as int?) ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((map['updatedAt'] as int?) ?? 0),
      lastLoginAt: map['lastLoginAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastLoginAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'role': role.toString().split('.').last,
      'provider': provider.toString().split('.').last,
      'isEmailVerified': isEmailVerified,
      'isPremium': isPremium,
      'premiumExpiresAt': premiumExpiresAt?.millisecondsSinceEpoch,
      'metadata': metadata,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      photoUrl: user.photoUrl,
      role: user.role,
      provider: user.provider,
      isEmailVerified: user.isEmailVerified,
      isPremium: user.isPremium,
      premiumExpiresAt: user.premiumExpiresAt,
      metadata: user.metadata,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      lastLoginAt: user.lastLoginAt,
    );
  }

  @override
  UserModel copyWith({
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
    return UserModel(
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
}