import 'dart:typed_data';

/// Tipos de storage disponíveis
enum StorageType {
  /// Hive - estruturado, rápido, persistente
  hive,

  /// SharedPreferences - para primitivos e strings pequenas
  sharedPreferences,

  /// Secure Storage - para dados sensíveis (criptografado)
  secureStorage,

  /// File System - para arquivos e dados grandes
  file,
}

/// Seletor de estratégia de storage
///
/// Responsabilidades:
/// - Determinar melhor storage type baseado no valor
/// - Routing logic entre Hive, SharedPreferences, SecureStorage, File
/// - Configuração de preferências
class StorageStrategySelector {
  /// Determina o tipo de storage adequado baseado no valor e configurações
  ///
  /// Lógica:
  /// - encrypt=true → SecureStorage
  /// - String pequena (<1000 chars) → SharedPreferences
  /// - Primitivos (int/double/bool) → SharedPreferences
  /// - Arquivos grandes (>10KB) ou Uint8List → File
  /// - Default → Hive
  StorageType determineStorageType<T>(T value, bool encrypt) {
    // Criptografia força SecureStorage
    if (encrypt) return StorageType.secureStorage;

    // Strings pequenas em SharedPreferences
    if (value is String && value.length < 1000) {
      return StorageType.sharedPreferences;
    }

    // Primitivos em SharedPreferences
    if (value is int || value is double || value is bool) {
      return StorageType.sharedPreferences;
    }

    // Arquivos grandes ou binários em File
    if (value is Uint8List || (value is String && value.length > 10000)) {
      return StorageType.file;
    }

    // Default: Hive (estruturado, rápido, persistente)
    return StorageType.hive;
  }

  /// Determina storage type baseado em políticas customizadas
  StorageType determineWithPolicy(
    dynamic value,
    StoragePolicy policy,
  ) {
    // Política override
    if (policy.forceType != null) {
      return policy.forceType!;
    }

    // Aplicar encrypt policy
    final shouldEncrypt = policy.encryptSensitiveData && _isSensitive(value);

    return determineStorageType(value, shouldEncrypt);
  }

  /// Verifica se valor é sensível (heurística)
  bool _isSensitive(dynamic value) {
    if (value is! String) return false;

    final lowerValue = value.toLowerCase();

    // Keywords sensíveis
    const sensitiveKeywords = [
      'password',
      'token',
      'secret',
      'key',
      'auth',
      'credential',
      'session',
    ];

    for (final keyword in sensitiveKeywords) {
      if (lowerValue.contains(keyword)) {
        return true;
      }
    }

    return false;
  }

  /// Obtém ordem de fallback para read operations
  List<StorageType> getFallbackOrder(StorageType preferredType) {
    // Remove o preferred da lista e coloca no início
    final fallbackList = [
      StorageType.hive,
      StorageType.sharedPreferences,
      StorageType.secureStorage,
      StorageType.file,
    ];

    fallbackList.remove(preferredType);
    return [preferredType, ...fallbackList];
  }
}

/// Política de seleção de storage
class StoragePolicy {
  final StorageType? forceType;
  final bool encryptSensitiveData;
  final bool preferFastStorage;
  final int largeFileSizeThreshold;

  const StoragePolicy({
    this.forceType,
    this.encryptSensitiveData = true,
    this.preferFastStorage = false,
    this.largeFileSizeThreshold = 10000,
  });

  static const StoragePolicy defaultPolicy = StoragePolicy();

  static const StoragePolicy securePolicy = StoragePolicy(
    encryptSensitiveData: true,
    preferFastStorage: false,
  );

  static const StoragePolicy performancePolicy = StoragePolicy(
    encryptSensitiveData: false,
    preferFastStorage: true,
  );
}
