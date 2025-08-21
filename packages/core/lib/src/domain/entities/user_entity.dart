import 'base_entity.dart';

/// Entidade do usuário compartilhada entre os apps
/// Representa dados básicos de um usuário logado no sistema
class UserEntity extends BaseEntity {
  const UserEntity({
    required super.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
    this.lastLoginAt,
    this.provider = AuthProvider.email,
    super.createdAt,
    super.updatedAt,
  });

  /// Email do usuário
  final String email;

  /// Nome de exibição do usuário
  final String displayName;

  /// URL da foto do perfil (opcional)
  final String? photoUrl;

  /// Se o email foi verificado
  final bool isEmailVerified;

  /// Data do último login
  final DateTime? lastLoginAt;

  /// Provedor de autenticação usado
  final AuthProvider provider;

  /// Retorna true se o usuário tem foto de perfil
  bool get hasProfilePhoto => photoUrl != null && photoUrl!.isNotEmpty;

  /// Retorna as iniciais do nome para avatar
  String get initials {
    final names = displayName.trim().split(' ');
    if (names.isEmpty) return 'U';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  @override
  BaseEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isEmailVerified,
    DateTime? lastLoginAt,
    AuthProvider? provider,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'provider': provider.name,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Cria instância do JSON
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      lastLoginAt: json['lastLoginAt'] != null 
        ? DateTime.parse(json['lastLoginAt'] as String) 
        : null,
      provider: AuthProvider.values.firstWhere(
        (p) => p.name == (json['provider'] as String),
        orElse: () => AuthProvider.email,
      ),
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String) 
        : null,
      updatedAt: json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt'] as String) 
        : null,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        email,
        displayName,
        photoUrl,
        isEmailVerified,
        lastLoginAt,
        provider,
      ];
}

/// Provedores de autenticação suportados
enum AuthProvider {
  email,
  google,
  apple,
  facebook,
  anonymous,
}

extension AuthProviderExtension on AuthProvider {
  String get displayName {
    switch (this) {
      case AuthProvider.email:
        return 'Email';
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
      case AuthProvider.facebook:
        return 'Facebook';
      case AuthProvider.anonymous:
        return 'Anônimo';
    }
  }

  String get providerId {
    switch (this) {
      case AuthProvider.email:
        return 'password';
      case AuthProvider.google:
        return 'google.com';
      case AuthProvider.apple:
        return 'apple.com';
      case AuthProvider.facebook:
        return 'facebook.com';
      case AuthProvider.anonymous:
        return 'anonymous';
    }
  }
}