import 'package:core/core.dart';

/// Extensão para UserEntity do core package, adicionando funcionalidades específicas do ReceitaAgro
/// Esta extensão permite trabalhar com campos específicos que eram do UserProfileSyncEntity
extension UserEntityReceitaAgroExtension on UserEntity {
  
  /// Verifica se o usuário é anônimo baseado no provider (compatibilidade)
  bool get isReceitaAgroAnonymous => provider == AuthProvider.anonymous;
  
  /// Converte o AuthProvider enum para string (compatibilidade com UserProfileSyncEntity)
  String get providerString => provider.name;
  
  /// Campos específicos do ReceitaAgro que podem ser armazenados no phone ou como metadata
  /// Para compatibilidade, usamos convenções de armazenamento
  
  /// Extrai deviceId do campo phone (convenção temporária)
  /// Formato: "deviceId:platform:appVersion" ou apenas deviceId
  String? get deviceId {
    if (phone == null || phone!.isEmpty) return null;
    final parts = phone!.split(':');
    return parts.isNotEmpty ? parts[0] : null;
  }
  
  /// Extrai platform do campo phone
  String? get platform {
    if (phone == null || phone!.isEmpty) return null;
    final parts = phone!.split(':');
    return parts.length >= 2 ? parts[1] : null;
  }
  
  /// Extrai appVersion do campo phone
  String? get appVersion {
    if (phone == null || phone!.isEmpty) return null;
    final parts = phone!.split(':');
    return parts.length >= 3 ? parts[2] : null;
  }
  
  /// Cria um UserEntity com informações específicas do ReceitaAgro
  /// Armazena deviceId, platform e appVersion no campo phone usando formato especial
  UserEntity withReceitaAgroData({
    String? deviceId,
    String? platform,
    String? appVersion,
  }) {
    String? newPhone;
    if (deviceId != null || platform != null || appVersion != null) {
      newPhone = [
        deviceId ?? '',
        platform ?? '',
        appVersion ?? '',
      ].join(':');
    }
    
    return copyWith(phone: newPhone);
  }
  
  /// Cria um UserEntity a partir dos dados do UserProfileSyncEntity (para migração)
  static UserEntity fromUserProfileSyncEntity({
    required String id,
    required String email,
    required String displayName,
    required String provider,
    required bool isAnonymous,
    required String deviceId,
    required String platform,
    required String appVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool isDirty = false,
    bool isDeleted = false,
    int version = 1,
    String? userId,
    String? moduleName,
  }) {
    // Converte string provider para AuthProvider enum
    AuthProvider authProvider;
    switch (provider.toLowerCase()) {
      case 'google':
        authProvider = AuthProvider.google;
        break;
      case 'apple':
        authProvider = AuthProvider.apple;
        break;
      case 'facebook':
        authProvider = AuthProvider.facebook;
        break;
      case 'anonymous':
        authProvider = AuthProvider.anonymous;
        break;
      default:
        authProvider = AuthProvider.email;
    }
    
    // Armazena informações específicas no campo phone
    final phone = '$deviceId:$platform:$appVersion';
    
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      provider: authProvider,
      phone: phone,
      isActive: true,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSyncAt: lastSyncAt,
      isDirty: isDirty,
      isDeleted: isDeleted,
      version: version,
      userId: userId,
      moduleName: moduleName,
    );
  }
  
  /// Converte para formato compatível com UserProfileSyncEntity (para compatibilidade temporária)
  Map<String, dynamic> toUserProfileSyncMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'provider': providerString,
      'isAnonymous': isReceitaAgroAnonymous,
      'deviceId': deviceId ?? '',
      'platform': platform ?? '',
      'appVersion': appVersion ?? '',
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
  
  /// Implementação específica do toFirebaseMap para manter compatibilidade
  Map<String, dynamic> toReceitaAgroFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'email': email,
      'displayName': displayName,
      'provider': providerString,
      'isAnonymous': isReceitaAgroAnonymous,
      'deviceId': deviceId ?? '',
      'platform': platform ?? '',
      'appVersion': appVersion ?? '',
    };
  }
  
  /// Cria UserEntity a partir de Firebase map no formato UserProfileSyncEntity
  static UserEntity fromReceitaAgroFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    
    // Converte string provider para AuthProvider enum
    AuthProvider authProvider;
    final providerStr = map['provider'] as String? ?? 'email';
    switch (providerStr.toLowerCase()) {
      case 'google':
        authProvider = AuthProvider.google;
        break;
      case 'apple':
        authProvider = AuthProvider.apple;
        break;
      case 'facebook':
        authProvider = AuthProvider.facebook;
        break;
      case 'anonymous':
        authProvider = AuthProvider.anonymous;
        break;
      default:
        authProvider = AuthProvider.email;
    }
    
    // Monta dados específicos no campo phone
    final deviceId = map['deviceId'] as String? ?? '';
    final platform = map['platform'] as String? ?? '';
    final appVersion = map['appVersion'] as String? ?? '';
    final phone = '$deviceId:$platform:$appVersion';
    
    return UserEntity(
      id: baseFields['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      provider: authProvider,
      phone: phone,
      isActive: true,
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
}

/// Extensão para facilitar a migração em massa de UserProfileSyncEntity para UserEntity
extension UserProfileSyncEntityMigration on UserEntity {
  
  /// Verifica se tem dados específicos do ReceitaAgro armazenados
  bool get hasReceitaAgroData => 
      phone != null && 
      phone!.isNotEmpty && 
      phone!.contains(':');
  
  /// Limpa dados específicos do ReceitaAgro (remove do campo phone)
  UserEntity clearReceitaAgroData() {
    return copyWith(phone: null);
  }
  
  /// Atualiza apenas os dados específicos do ReceitaAgro
  UserEntity updateReceitaAgroData({
    String? deviceId,
    String? platform,
    String? appVersion,
  }) {
    final currentDeviceId = this.deviceId;
    final currentPlatform = this.platform;
    final currentAppVersion = this.appVersion;
    
    final newDeviceId = deviceId ?? currentDeviceId ?? '';
    final newPlatform = platform ?? currentPlatform ?? '';
    final newAppVersion = appVersion ?? currentAppVersion ?? '';
    
    return withReceitaAgroData(
      deviceId: newDeviceId,
      platform: newPlatform,
      appVersion: newAppVersion,
    );
  }
}