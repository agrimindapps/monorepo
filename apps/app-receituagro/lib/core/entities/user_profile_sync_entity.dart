import 'package:core/core.dart';

/// Entidade de sincronização para perfil do usuário
/// Extends BaseSyncEntity do core package para compatibilidade
class UserProfileSyncEntity extends BaseSyncEntity {
  final String email;
  final String displayName;
  final String provider;
  final bool isAnonymous;
  final String deviceId;
  final String platform;
  final String appVersion;

  const UserProfileSyncEntity({
    required String id,
    required this.email,
    required this.displayName,
    required this.provider,
    required this.isAnonymous,
    required this.deviceId,
    required this.platform,
    required this.appVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool isDirty = false,
    bool isDeleted = false,
    int version = 1,
    String? userId,
    String? moduleName,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          lastSyncAt: lastSyncAt,
          isDirty: isDirty,
          isDeleted: isDeleted,
          version: version,
          userId: userId,
          moduleName: moduleName,
        );

  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'email': email,
      'displayName': displayName,
      'provider': provider,
      'isAnonymous': isAnonymous,
      'deviceId': deviceId,
      'platform': platform,
      'appVersion': appVersion,
    };
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'provider': provider,
      'isAnonymous': isAnonymous,
      'deviceId': deviceId,
      'platform': platform,
      'appVersion': appVersion,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'isDirty': isDirty,
      'isDeleted': isDeleted,
      'version': version,
      'userId': userId,
      'moduleName': moduleName,
    };
  }

  static UserProfileSyncEntity fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    return UserProfileSyncEntity(
      id: baseFields['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      provider: map['provider'] as String,
      isAnonymous: map['isAnonymous'] as bool,
      deviceId: map['deviceId'] as String,
      platform: map['platform'] as String,
      appVersion: map['appVersion'] as String,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
    );
  }

  factory UserProfileSyncEntity.fromMap(Map<String, dynamic> map) {
    return UserProfileSyncEntity(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      provider: map['provider'] as String,
      isAnonymous: map['isAnonymous'] as bool,
      deviceId: map['deviceId'] as String,
      platform: map['platform'] as String,
      appVersion: map['appVersion'] as String,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
      lastSyncAt: map['lastSyncAt'] != null ? DateTime.parse(map['lastSyncAt'] as String) : null,
      isDirty: map['isDirty'] as bool? ?? false,
      isDeleted: map['isDeleted'] as bool? ?? false,
      version: map['version'] as int? ?? 1,
      userId: map['userId'] as String?,
      moduleName: map['moduleName'] as String?,
    );
  }

  @override
  UserProfileSyncEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? provider,
    bool? isAnonymous,
    String? deviceId,
    String? platform,
    String? appVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  }) {
    return UserProfileSyncEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      provider: provider ?? this.provider,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      deviceId: deviceId ?? this.deviceId,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
    );
  }

  @override
  UserProfileSyncEntity markAsDirty() {
    return copyWith(
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  UserProfileSyncEntity markAsSynced({DateTime? syncTime}) {
    return copyWith(
      isDirty: false,
      lastSyncAt: syncTime ?? DateTime.now(),
    );
  }

  @override
  UserProfileSyncEntity markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  UserProfileSyncEntity incrementVersion() {
    return copyWith(
      version: version + 1,
      updatedAt: DateTime.now(),
    );
  }

  @override
  UserProfileSyncEntity withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  UserProfileSyncEntity withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }

  @override
  List<Object?> get props => [
        ...super.props,
        email,
        displayName,
        provider,
        isAnonymous,
        deviceId,
        platform,
        appVersion,
      ];
}