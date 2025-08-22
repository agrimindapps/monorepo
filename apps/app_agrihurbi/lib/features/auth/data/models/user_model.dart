import 'package:hive/hive.dart';
import 'package:app_agrihurbi/features/auth/domain/entities/user_entity.dart';
import 'package:app_agrihurbi/core/utils/typedef.dart';

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
  final String userModelName;
  
  @HiveField(2)
  final String userModelEmail;
  
  @HiveField(3)
  final String? userModelPhone;
  
  @HiveField(4)
  final String? userModelProfileImageUrl;
  
  @HiveField(5)
  final DateTime userModelCreatedAt;
  
  @HiveField(6)
  final DateTime? userModelLastLoginAt;
  
  @HiveField(7)
  final bool userModelIsActive;

  const UserModel({
    required this.userModelId,
    required this.userModelName,
    required this.userModelEmail,
    this.userModelPhone,
    this.userModelProfileImageUrl,
    required this.userModelCreatedAt,
    this.userModelLastLoginAt,
    this.userModelIsActive = true,
  }) : super(
    id: userModelId,
    name: userModelName,
    email: userModelEmail,
    phone: userModelPhone,
    profileImageUrl: userModelProfileImageUrl,
    createdAt: userModelCreatedAt,
    lastLoginAt: userModelLastLoginAt,
    isActive: userModelIsActive,
  );

  /// Converte o UserModel para UserEntity do domínio
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      profileImageUrl: profileImageUrl,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      isActive: isActive,
    );
  }

  /// Cria um UserModel a partir de uma UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      userModelId: entity.id,
      userModelName: entity.name,
      userModelEmail: entity.email,
      userModelPhone: entity.phone,
      userModelProfileImageUrl: entity.profileImageUrl,
      userModelCreatedAt: entity.createdAt,
      userModelLastLoginAt: entity.lastLoginAt,
      userModelIsActive: entity.isActive,
    );
  }

  /// Cria um UserModel a partir de um JSON Map (Supabase/API)
  factory UserModel.fromJson(DataMap json) {
    return UserModel(
      userModelId: json['id'] as String,
      userModelName: json['name'] as String,
      userModelEmail: json['email'] as String,
      userModelPhone: json['phone'] as String?,
      userModelProfileImageUrl: json['profile_image_url'] as String?,
      userModelCreatedAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      userModelLastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      userModelIsActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Converte o UserModel para um JSON Map (Supabase/API)
  DataMap toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Cria uma cópia do UserModel com campos opcionalmente modificados
  @override
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return UserModel(
      userModelId: id ?? this.id,
      userModelName: name ?? this.name,
      userModelEmail: email ?? this.email,
      userModelPhone: phone ?? this.phone,
      userModelProfileImageUrl: profileImageUrl ?? this.profileImageUrl,
      userModelCreatedAt: createdAt ?? this.createdAt,
      userModelLastLoginAt: lastLoginAt ?? this.lastLoginAt,
      userModelIsActive: isActive ?? this.isActive,
    );
  }

  /// Factory para criar instância vazia para formulários
  factory UserModel.empty() {
    return UserModel(
      userModelId: '',
      userModelName: '',
      userModelEmail: '',
      userModelCreatedAt: DateTime.now(),
      userModelIsActive: true,
    );
  }
}