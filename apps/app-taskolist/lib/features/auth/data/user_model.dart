import 'package:core/core.dart' show HiveType, JsonSerializable, HiveField;

import '../domain/user_entity.dart';

part 'user_model.g.dart';

@HiveType(typeId: 5)
@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl,
    required super.createdAt,
    required super.updatedAt,
    super.isActive,
    super.emailVerified = false,
  });

  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get name => super.name;

  @HiveField(2)
  @override
  String get email => super.email;

  @HiveField(3)
  @override
  String? get avatarUrl => super.avatarUrl;

  @HiveField(4)
  @override
  DateTime get createdAt => super.createdAt;

  @HiveField(5)
  @override
  DateTime get updatedAt => super.updatedAt;

  @HiveField(6)
  @override
  bool get isActive => super.isActive;

  @HiveField(7)
  @override
  bool get emailVerified => super.emailVerified;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      avatarUrl: entity.avatarUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
    );
  }

  @override
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? emailVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}
