import 'package:core/core.dart' hide AuthProvider;
import 'package:core/core.dart' as core show AuthProvider;

/// Enum para tipos de usuário específicos do Gasometer
/// Migrado da implementação local UserEntity
enum UserType { anonymous, registered, premium }

/// Extensão para UserEntity do core package, adicionando funcionalidades específicas do Gasometer
/// Esta extensão permite manter compatibilidade com a implementação local anterior
extension UserEntityGasometerExtension on UserEntity {
  
  /// Converte AuthProvider para UserType para compatibilidade com código existente
  UserType get gasometerUserType {
    switch (provider) {
      case core.AuthProvider.anonymous:
        return UserType.anonymous;
      case core.AuthProvider.email:
      case core.AuthProvider.google:
      case core.AuthProvider.apple:
      case core.AuthProvider.facebook:
        if (hasGasometerMetadata('isPremium') && getGasometerMetadata('isPremium') == true) {
          return UserType.premium;
        }
        return UserType.registered;
    }
  }
  
  /// Compatibilidade: isAnonymous
  bool get isAnonymous => gasometerUserType == UserType.anonymous;
  
  /// Compatibilidade: isRegistered
  bool get isRegistered => gasometerUserType == UserType.registered || gasometerUserType == UserType.premium;
  
  /// Compatibilidade: isPremium
  bool get isPremium => gasometerUserType == UserType.premium;
  
  /// Compatibilidade: uid (alias para id)
  String get uid => id;
  
  /// Campos específicos do Gasometer armazenados como metadados no campo phone
  /// Formato: "avatarBase64:metadata_json" ou apenas avatarBase64
  
  /// Extrai avatarBase64 do campo phone (compatibilidade)
  String? get avatarBase64 {
    if (phone == null || phone!.isEmpty) return null;
    final parts = phone!.split('|METADATA|');
    return parts.isNotEmpty && parts[0].isNotEmpty ? parts[0] : null;
  }
  
  /// Extrai metadata do campo phone
  Map<String, dynamic> get metadata {
    if (phone == null || phone!.isEmpty) return {};
    final parts = phone!.split('|METADATA|');
    if (parts.length < 2) return {};
    
    try {
      final metadataStr = parts[1];
      if (metadataStr.isEmpty) return {};
      final metadata = <String, dynamic>{};
      final pairs = metadataStr.split(',');
      for (final pair in pairs) {
        final keyValue = pair.split(':');
        if (keyValue.length == 2) {
          final key = keyValue[0].trim();
          final value = keyValue[1].trim();
          if (value.toLowerCase() == 'true') {
            metadata[key] = true;
          } else if (value.toLowerCase() == 'false') {
            metadata[key] = false;
          } else {
            metadata[key] = value;
          }
        }
      }
      return metadata;
    } catch (e) {
      return {};
    }
  }
  
  /// Verifica se tem metadado específico
  bool hasGasometerMetadata(String key) => metadata.containsKey(key);
  
  /// Obtém metadado específico
  dynamic getGasometerMetadata(String key) => metadata[key];
  
  /// Compatibilidade: effectiveAvatar (prioriza avatarBase64 sobre photoUrl)
  String? get effectiveAvatar => hasLocalAvatar ? avatarBase64 : photoUrl;
  
  /// Compatibilidade: hasLocalAvatar
  bool get hasLocalAvatar => avatarBase64 != null && avatarBase64!.isNotEmpty;
  
  /// Compatibilidade: hasDisplayName
  bool get hasDisplayName => displayName.isNotEmpty;
  
  /// Compatibilidade: hasProfilePhoto  
  bool get hasProfilePhoto => photoUrl != null && photoUrl!.isNotEmpty;
  
  /// Cria um UserEntity com dados específicos do Gasometer
  UserEntity withGasometerData({
    String? avatarBase64,
    Map<String, dynamic>? metadata,
    UserType? userType,
  }) {
    String? newPhone;
    final currentAvatarBase64 = avatarBase64 ?? this.avatarBase64;
    final currentMetadata = metadata ?? this.metadata;
    
    if (currentAvatarBase64 != null || currentMetadata.isNotEmpty) {
      final avatarPart = currentAvatarBase64 ?? '';
      String metadataPart = '';
      
      if (currentMetadata.isNotEmpty) {
        final metadataPairs = currentMetadata.entries
            .map((e) => '${e.key}:${e.value}')
            .join(',');
        metadataPart = metadataPairs;
      }
      
      newPhone = '$avatarPart|METADATA|$metadataPart';
    }
    core.AuthProvider? newProvider;
    if (userType != null) {
      switch (userType) {
        case UserType.anonymous:
          newProvider = core.AuthProvider.anonymous;
          break;
        case UserType.registered:
        case UserType.premium:
          newProvider = provider == core.AuthProvider.anonymous ? core.AuthProvider.email : provider;
          break;
      }
      if (userType == UserType.premium) {
        final updatedMetadata = Map<String, dynamic>.from(currentMetadata);
        updatedMetadata['isPremium'] = true;
        
        final metadataPairs = updatedMetadata.entries
            .map((e) => '${e.key}:${e.value}')
            .join(',');
        newPhone = '${currentAvatarBase64 ?? ''}|METADATA|$metadataPairs';
      }
    }
    
    return copyWith(
      phone: newPhone,
      provider: newProvider,
    );
  }
  
  /// Factory: Cria UserEntity a partir de core UserEntity (para social login)
  static UserEntity fromCoreUserEntity(UserEntity coreUser) {
    return coreUser.copyWith(
      moduleName: 'gasometer',
    );
  }

  /// Factory: Cria UserEntity a partir de Firebase User (migrado do UserModel)
  static UserEntity fromFirebaseUser(User firebaseUser) {
    core.AuthProvider provider = core.AuthProvider.anonymous;
    
    if (firebaseUser.isAnonymous) {
      provider = core.AuthProvider.anonymous;
    } else if (firebaseUser.email != null) {
      provider = core.AuthProvider.email;
      for (final userInfo in firebaseUser.providerData) {
        switch (userInfo.providerId) {
          case 'google.com':
            provider = core.AuthProvider.google;
            break;
          case 'apple.com':
            provider = core.AuthProvider.apple;
            break;
          case 'facebook.com':
            provider = core.AuthProvider.facebook;
            break;
        }
      }
    }
    final metadata = {
      'providerId': firebaseUser.providerData.map((p) => p.providerId).toList().join(','),
      'isAnonymous': firebaseUser.isAnonymous.toString(),
    };
    final metadataPairs = metadata.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');
    final phone = '|METADATA|$metadataPairs';
    
    return UserEntity(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      photoUrl: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
      provider: provider,
      phone: phone,
      isActive: true,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      moduleName: 'gasometer',
    );
  }
  
  /// Factory: Cria UserEntity a partir de documento Firestore (migrado do UserModel)
  static UserEntity fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    core.AuthProvider provider = core.AuthProvider.email;
    final typeIndex = data['type'] as int? ?? 0;
    if (typeIndex == 0) provider = core.AuthProvider.anonymous;
    final oldMetadata = Map<String, dynamic>.from(data['metadata'] as Map? ?? {});
    final metadataPairs = oldMetadata.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');
    
    final phone = '|METADATA|$metadataPairs';
    
    return UserEntity(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      lastLoginAt: (data['lastSignInAt'] as Timestamp?)?.toDate(),
      provider: provider,
      phone: phone,
      isActive: true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: DateTime.now(),
      moduleName: 'gasometer',
    );
  }
  
  /// Factory: Cria UserEntity a partir de JSON local (migrado do UserModel)
  static UserEntity fromGasometerJson(Map<String, dynamic> json) {
    core.AuthProvider provider = core.AuthProvider.email;
    final typeIndex = json['type'] as int? ?? 0;
    if (typeIndex == 0) provider = core.AuthProvider.anonymous;
    final avatarBase64 = json['avatarBase64'] as String?;
    final oldMetadata = Map<String, dynamic>.from(json['metadata'] as Map? ?? {});
    
    String? phone;
    if (avatarBase64 != null || oldMetadata.isNotEmpty) {
      final metadataPairs = oldMetadata.entries
          .map((e) => '${e.key}:${e.value}')
          .join(',');
      phone = '${avatarBase64 ?? ''}|METADATA|$metadataPairs';
    }
    
    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      lastLoginAt: json['lastSignInAt'] != null 
          ? DateTime.parse(json['lastSignInAt'] as String)
          : null,
      provider: provider,
      phone: phone,
      isActive: true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      moduleName: 'gasometer',
    );
  }
  
  /// Converte para formato Firestore (compatibilidade com UserModel.toFirestore)
  Map<String, dynamic> toGasometerFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'type': gasometerUserType.index,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastSignInAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
      'metadata': metadata,
    };
  }
  
  /// Converte para JSON local (compatibilidade com UserModel.toJson)
  Map<String, dynamic> toGasometerJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'avatarBase64': avatarBase64,
      'type': gasometerUserType.index,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'lastSignInAt': lastLoginAt?.toIso8601String(),
      'metadata': metadata,
    };
  }
  
  /// CopyWith específico para Gasometer mantendo compatibilidade com UserModel
  UserEntity copyWithGasometer({
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
    final newAvatarBase64 = avatarBase64 ?? this.avatarBase64;
    final newMetadata = metadata ?? this.metadata;
    String? newPhone;
    if (newAvatarBase64 != null || newMetadata.isNotEmpty) {
      final metadataPairs = newMetadata.entries
          .map((e) => '${e.key}:${e.value}')
          .join(',');
      newPhone = '${newAvatarBase64 ?? ''}|METADATA|$metadataPairs';
    }
    core.AuthProvider? newProvider;
    if (type != null) {
      switch (type) {
        case UserType.anonymous:
          newProvider = core.AuthProvider.anonymous;
          break;
        case UserType.registered:
        case UserType.premium:
          newProvider = provider == core.AuthProvider.anonymous ? core.AuthProvider.email : provider;
          break;
      }
    }
    
    return copyWith(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isEmailVerified: isEmailVerified,
      lastLoginAt: lastSignInAt,
      provider: newProvider,
      phone: newPhone,
      createdAt: createdAt,
    );
  }
}

/// Extensão para facilitar migração de código existente
extension UserEntityGasometerCompatibility on UserEntity {
  
  /// Conversão para "entidade" (compatibilidade com UserModel.toEntity)
  UserEntity toEntity() => this;
  
  /// Factory a partir de entidade (compatibilidade com UserModel.fromEntity) 
  static UserEntity fromEntity(UserEntity entity) => entity;
}
