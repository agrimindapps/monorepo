// models/user.dart

// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../../core/models/base_model.dart';

part '73_user.g.dart';

@HiveType(typeId: 73)
class User extends BaseModel {
  @HiveField(10)
  final String name;

  @HiveField(11)
  final String email;

  @HiveField(12)
  final String? avatarUrl;

  @HiveField(13)
  final bool isActive;

  User({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.needsSync,
    super.lastSyncAt,
    super.version,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isActive = true,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      isDeleted: map['isDeleted'] ?? false,
      needsSync: map['needsSync'] ?? true,
      lastSyncAt: map['lastSyncAt'],
      version: map['version'] ?? 1,
      name: map['name'],
      email: map['email'],
      avatarUrl: map['avatarUrl'],
      isActive: map['isActive'] ?? true,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
    });
    return map;
  }

  @override
  User copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? needsSync,
    int? lastSyncAt,
    int? version,
    String? name,
    String? email,
    String? avatarUrl,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      needsSync: needsSync ?? this.needsSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      version: version ?? this.version,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  // Factory methods para compatibilidade
  factory User.fromJson(Map<String, dynamic> json) => User.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
