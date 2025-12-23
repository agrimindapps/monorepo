/// Device Identity Service - Re-export from core
///
/// Este arquivo agora re-exporta DeviceIdentityService do core package.
/// DeviceInfo é mantido como alias para DeviceEntity para compatibilidade.
library;

// Re-export from core
export 'package:core/core.dart' show DeviceIdentityService, DeviceEntity;

import 'package:core/core.dart' show DeviceEntity;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;

/// Tipo alias para compatibilidade com código existente
/// DeviceInfo agora é um alias para DeviceEntity do core
typedef DeviceInfo = DeviceEntity;

/// Extension para adicionar métodos de compatibilidade ao DeviceEntity
extension DeviceInfoCompatibility on DeviceEntity {
  /// Nome para exibição (compatibilidade com DeviceInfo antigo)
  String get displayNameCompat => '$name • $platform $systemVersion';

  /// Versão completa da aplicação
  String get fullAppVersion => '$appVersion ($buildNumber)';

  /// Indica se é dispositivo de desenvolvimento
  bool get isDevelopmentDevice => !isPhysicalDevice;

  /// Identifier (usa uuid para compatibilidade)
  String get identifier => uuid;
}

/// Helper para criar DeviceEntity com valores de fallback
DeviceEntity createFallbackDevice() {
  final now = DateTime.now();
  final platformStr = kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase();
  
  return DeviceEntity(
    id: 'unknown-device',
    uuid: 'unknown-device',
    name: 'Unknown Device',
    model: 'Unknown',
    platform: platformStr,
    systemVersion: 'Unknown',
    appVersion: '1.0.0',
    buildNumber: '1',
    isPhysicalDevice: true,
    manufacturer: 'Unknown',
    firstLoginAt: now,
    lastActiveAt: now,
    isActive: true,
    createdAt: now,
  );
}

