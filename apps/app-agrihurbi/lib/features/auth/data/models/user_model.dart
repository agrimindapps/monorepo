import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:core/core.dart';

part 'user_model.g.dart';

/// Model de dados para usuários com suporte ao Hive
/// 
/// Implementa serialização local (Hive) e conversões para entidades do domínio
/// TypeId: 1 - Reservado para usuários no sistema Hive
@HiveType(typeId: 1)
class UserModel extends UserEntity {
  @HiveField(0)
  final String userModelId;
  
  @HiveField(1)
  final String userModelEmail;
  
  @HiveField(2)
  final String userModelDisplayName;
  
  @HiveField(3)
  final String? userModelPhotoUrl;
  
  @HiveField(4)
  final bool userModelIsEmailVerified;
  
  @HiveField(5)
  final DateTime? userModelLastLoginAt;
  
  @HiveField(6)
  final AuthProvider userModelProvider;
  
  @HiveField(7)
  final DateTime? userModelCreatedAt;
  
  @HiveField(8)
  final DateTime? userModelUpdatedAt;

  const UserModel({
    required this.userModelId,
    required this.userModelEmail,
    required this.userModelDisplayName,
    this.userModelPhotoUrl,
    this.userModelIsEmailVerified = false,
    this.userModelLastLoginAt,
    this.userModelProvider = AuthProvider.email,
    this.userModelCreatedAt,
    this.userModelUpdatedAt,
  }) : super(
    id: userModelId,
    email: userModelEmail,
    displayName: userModelDisplayName,
    photoUrl: userModelPhotoUrl,
    isEmailVerified: userModelIsEmailVerified,
    lastLoginAt: userModelLastLoginAt,
    provider: userModelProvider,
    phone: null, // Valor padrão para compatibilidade
    isActive: true, // Valor padrão para compatibilidade
    createdAt: userModelCreatedAt,
    updatedAt: userModelUpdatedAt,
    // Novos parâmetros do BaseSyncEntity
    lastSyncAt: null,
    isDirty: false,
    isDeleted: false,
    version: 1,
    userId: null,
    moduleName: 'agrihurbi',
  );

  /// Converte o UserModel para UserEntity do domínio
  UserEntity toEntity() {
    return UserEntity(
      id: userModelId,
      displayName: userModelDisplayName,
      email: userModelEmail,
      photoUrl: userModelPhotoUrl,
      isEmailVerified: userModelIsEmailVerified,
      lastLoginAt: userModelLastLoginAt,
      provider: userModelProvider,
      phone: null, // Valor padrão para compatibilidade
      isActive: true, // Valor padrão para compatibilidade
      createdAt: userModelCreatedAt,
      updatedAt: userModelUpdatedAt,
      // Campos de sincronização
      lastSyncAt: null,
      isDirty: false,
      isDeleted: false,
      version: 1,
      userId: null,
      moduleName: 'agrihurbi',
    );
  }

  /// Cria um UserModel a partir de uma UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      userModelId: entity.id,
      userModelDisplayName: entity.displayName,
      userModelEmail: entity.email,
      userModelPhotoUrl: entity.photoUrl,
      userModelIsEmailVerified: entity.isEmailVerified,
      userModelLastLoginAt: entity.lastLoginAt,
      userModelProvider: entity.provider,
      userModelCreatedAt: entity.createdAt,
      userModelUpdatedAt: entity.updatedAt,
    );
  }

  /// Cria um UserModel a partir de um JSON Map (Supabase/API)
  factory UserModel.fromJson(DataMap json) {
    return UserModel(
      userModelId: json['id'] as String,
      userModelDisplayName: json['displayName'] as String,
      userModelEmail: json['email'] as String,
      userModelPhotoUrl: json['photoUrl'] as String?,
      userModelIsEmailVerified: json['isEmailVerified'] as bool? ?? false,
      userModelLastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      userModelProvider: AuthProvider.values.firstWhere(
        (p) => p.name == (json['provider'] as String? ?? 'email'),
        orElse: () => AuthProvider.email,
      ),
      userModelCreatedAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      userModelUpdatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Converte o UserModel para um JSON Map (Supabase/API)
  @override
  DataMap toJson() {
    return {
      'id': userModelId,
      'displayName': userModelDisplayName,
      'email': userModelEmail,
      'photoUrl': userModelPhotoUrl,
      'isEmailVerified': userModelIsEmailVerified,
      'lastLoginAt': userModelLastLoginAt?.toIso8601String(),
      'provider': userModelProvider.name,
      'createdAt': userModelCreatedAt?.toIso8601String(),
      'updatedAt': userModelUpdatedAt?.toIso8601String(),
    };
  }

  /// Cria uma cópia do UserModel com campos opcionalmente modificados
  @override
  UserModel copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoUrl,
    bool? isEmailVerified,
    DateTime? lastLoginAt,
    AuthProvider? provider,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  }) {
    // UserModel mapeia apenas os campos que tem implementação local
    // Os demais parâmetros são aceitos para compatibilidade mas serão valores padrão
    return UserModel(
      userModelId: id ?? userModelId,
      userModelDisplayName: displayName ?? userModelDisplayName,
      userModelEmail: email ?? userModelEmail,
      userModelPhotoUrl: photoUrl ?? userModelPhotoUrl,
      userModelIsEmailVerified: isEmailVerified ?? userModelIsEmailVerified,
      userModelLastLoginAt: lastLoginAt ?? userModelLastLoginAt,
      userModelProvider: provider ?? userModelProvider,
      userModelCreatedAt: createdAt ?? userModelCreatedAt,
      userModelUpdatedAt: updatedAt ?? userModelUpdatedAt,
    );
  }

  /// Factory para criar instância vazia para formulários
  factory UserModel.empty() {
    return const UserModel(
      userModelId: '',
      userModelDisplayName: '',
      userModelEmail: '',
    );
  }
}