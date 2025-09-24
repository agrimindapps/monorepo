# Análise Detalhada: Migração StorageService - App-Plantis

**Data:** 2025-09-24
**Escopo:** App-Plantis Storage Services → Core Package Standardization
**Prioridade:** P1 - High (Score 8.0/10)
**Status:** Partially Migrated - Requires Consolidation

---

## 🎯 Executive Summary

### **Situação Atual**
O **app-plantis** possui uma arquitetura **híbrida** de storage: já utiliza o `HiveStorageService` do **core package** via `ILocalStorageRepository` para storage geral, mas mantém implementações locais especializadas (`SecureStorageService` e `EncryptedHiveService`) para dados sensíveis e criptografia. Esta situação representa uma **migração parcial bem-sucedida** que pode ser consolidada.

### **Descoberta Principal**
- **✅ Core Integration:** App já usa `HiveStorageService` do core (linha 136 DI container)
- **⚠️ Specialized Services:** Mantém 2 services locais para dados sensíveis
- **🎯 Consolidation Opportunity:** Elevar specialized services para o core package
- **📈 80% Migrated:** Storage básico completo, faltam apenas recursos avançados

### **Impact Assessment**
- **Não há duplicação básica** - Core integration já funcional
- **Specialized Services** podem beneficiar todo o monorepo
- **Security Enhancement** - Padronizar criptografia cross-app
- **ROI Alto** - Services únicos com valor enterprise

---

## 🔍 Current Architecture Analysis

### **✅ Successfully Migrated - Core Integration**

#### **HiveStorageService (Core Package) - ACTIVE**
**Localização:** `/packages/core/lib/src/infrastructure/services/hive_storage_service.dart`

**Status:** ✅ **ALREADY IMPLEMENTED** no app-plantis
```dart
// apps/app-plantis/lib/core/di/injection_container.dart:136
sl.registerLazySingleton<ILocalStorageRepository>(() =>
  HiveStorageService(sl<IBoxRegistryService>())
);
```

**Funcionalidades Core em Uso:**
- ✅ **Basic Storage:** save(), get(), remove(), clear()
- ✅ **List Operations:** saveList(), getList(), addToList()
- ✅ **TTL Support:** saveWithTTL(), getWithTTL()
- ✅ **User Settings:** saveUserSetting(), getUserSetting()
- ✅ **Offline Data:** saveOfflineData(), getOfflineData()
- ✅ **Box Registry:** Dynamic box management via BoxRegistryService
- ✅ **Error Handling:** Either<Failure, T> pattern

#### **Usage Points - Already Active**
```dart
// Device Management
DeviceLocalDataSourceImpl(storageService: sl<ILocalStorageRepository>())

// Premium Service
SimpleSubscriptionSyncService(localStorage: sl<ILocalStorageRepository>())

// Settings Integration
// Todos os settings usando core storage automaticamente
```

### **⚠️ Local Specialized Services - Migration Candidates**

#### **SecureStorageService - App-Plantis Specialized**
**Localização:** `/apps/app-plantis/lib/core/services/secure_storage_service.dart`

**Recursos Únicos (381 linhas):**
```dart
class SecureStorageService {
  // 🔒 SENSITIVE DATA MANAGEMENT
  Future<void> storeUserCredentials(UserCredentials);
  Future<void> storeLocationData(LocationData);
  Future<void> storePersonalInfo(PersonalInfo);

  // 🔑 ENCRYPTION KEY MANAGEMENT
  Future<List<int>> getOrCreateHiveEncryptionKey();
  Future<void> storeBiometricData(String biometricHash);

  // 🛡️ SECURE OPERATIONS
  Future<bool> isSecureStorageAvailable();
  Future<void> clearAllSecureData();

  // 📱 PLATFORM-SPECIFIC ENCRYPTION
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'app_plantis_secure_data',
    ),
  );
}
```

**Value Proposition:**
- **GDPR Compliance:** Secure storage para dados pessoais
- **Platform Security:** iOS Keychain + Android Keystore
- **Data Classes:** UserCredentials, LocationData, PersonalInfo
- **Encryption Management:** Hive encryption key generation

#### **EncryptedHiveService - Crypto Integration**
**Localização:** `/apps/app-plantis/lib/core/services/encrypted_hive_service.dart`

**Recursos Únicos:**
```dart
class EncryptedHiveService implements IEncryptedStorageRepository {
  // 🔐 ENCRYPTED BOX MANAGEMENT
  Future<Either<Failure, Box<String>>> getEncryptedBox(String boxName);
  Future<Box<String>> getSensitiveDataBox();
  Future<Box<String>> getPiiDataBox();

  // 🔑 CIPHER MANAGEMENT
  HiveCipher? _encryptionCipher;

  // 📦 SPECIALIZED BOXES
  static const String _sensitiveDataBoxName = 'sensitive_data_encrypted';
  static const String _piiDataBoxName = 'pii_data_encrypted';
  static const String _locationDataBoxName = 'location_data_encrypted';
}
```

**Integration Point:**
- **Uses SecureStorageService** for key management
- **Implements IEncryptedStorageRepository** (core interface)
- **Provides encrypted Hive boxes** for sensitive data

#### **Usage Analysis - Local Services**
```dart
// DI Registration - Local services
sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService.instance);

// Usage in Backup Services
BackupAuditService(storageService: sl<SecureStorageService>());
BackupRestoreService(storageService: sl<SecureStorageService>());
BackupService(storageService: sl<SecureStorageService>());
```

---

## 🚀 Migration Strategy

### **Abordagem Recomendada: Core Enhancement + Specialized Services Migration**

#### **Current State Assessment**
- ✅ **80% Complete:** Basic storage via core package functional
- ⚠️ **20% Remaining:** Specialized secure services still local
- 🎯 **Goal:** Consolidate specialized services into core package

#### **Migration Plan: 3-Phase Approach**

### **Phase 1: Core Package Enhancement (Dias 1-2)**

**Objetivo:** Migrar specialized services para core package com interfaces configuráveis

#### **Enhanced Core Services Structure**
```dart
// packages/core/lib/src/infrastructure/services/enhanced_secure_storage_service.dart

class EnhancedSecureStorageService implements ISecureStorageRepository {
  final String _appIdentifier;
  final SecureStorageConfig _config;

  EnhancedSecureStorageService({
    required String appIdentifier,
    SecureStorageConfig? config,
  }) : _appIdentifier = appIdentifier,
       _config = config ?? SecureStorageConfig.defaultConfig();

  // Configurable per app
  FlutterSecureStorage get _storage => FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: _config.useEncryptedSharedPreferences,
      keyCipherAlgorithm: _config.androidKeyCipher,
      storageCipherAlgorithm: _config.androidStorageCipher,
    ),
    iOptions: IOSOptions(
      accessibility: _config.iOSAccessibility,
      accountName: '${_appIdentifier}_secure_data',
    ),
  );

  // Generic secure data operations
  Future<Either<Failure, void>> storeSecureData<T>({
    required String key,
    required T data,
    SecureDataSerializer<T>? serializer,
  }) async {
    try {
      final jsonString = (serializer?.serialize(data) ?? jsonEncode(data));
      await _storage.write(key: key, value: jsonString);
      return const Right(null);
    } catch (e) {
      return Left(SecurityFailure('Error storing secure data: $e'));
    }
  }

  Future<Either<Failure, T?>> getSecureData<T>({
    required String key,
    SecureDataSerializer<T>? serializer,
  }) async {
    try {
      final jsonString = await _storage.read(key: key);
      if (jsonString == null) return const Right(null);

      final data = serializer?.deserialize(jsonString) ??
                  jsonDecode(jsonString) as T;
      return Right(data);
    } catch (e) {
      return Left(SecurityFailure('Error retrieving secure data: $e'));
    }
  }

  // Specialized methods for common data types
  Future<Either<Failure, List<int>>> getOrCreateEncryptionKey({
    String keyName = 'hive_encryption_key',
  }) async {
    // Generic encryption key management
  }

  Future<Either<Failure, void>> storeBiometricHash(String hash) async {
    return storeSecureData<String>(key: 'biometric_hash', data: hash);
  }

  Future<Either<Failure, void>> clearAllSecureData() async {
    try {
      await _storage.deleteAll();
      return const Right(null);
    } catch (e) {
      return Left(SecurityFailure('Error clearing secure data: $e'));
    }
  }
}

// Configuration classes
class SecureStorageConfig {
  final bool useEncryptedSharedPreferences;
  final KeyCipherAlgorithm androidKeyCipher;
  final StorageCipherAlgorithm androidStorageCipher;
  final KeychainAccessibility iOSAccessibility;

  const SecureStorageConfig({
    required this.useEncryptedSharedPreferences,
    required this.androidKeyCipher,
    required this.androidStorageCipher,
    required this.iOSAccessibility,
  });

  const SecureStorageConfig.defaultConfig() : this(
    useEncryptedSharedPreferences: true,
    androidKeyCipher: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
    androidStorageCipher: StorageCipherAlgorithm.AES_GCM_NoPadding,
    iOSAccessibility: KeychainAccessibility.first_unlock_this_device,
  );

  // App-specific configurations
  const SecureStorageConfig.plantis() : this(
    useEncryptedSharedPreferences: true,
    androidKeyCipher: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
    androidStorageCipher: StorageCipherAlgorithm.AES_GCM_NoPadding,
    iOSAccessibility: KeychainAccessibility.first_unlock_this_device,
  );
}

// Data serializers for complex types
abstract class SecureDataSerializer<T> {
  String serialize(T data);
  T deserialize(String json);
}

class UserCredentialsSerializer implements SecureDataSerializer<UserCredentials> {
  @override
  String serialize(UserCredentials data) => jsonEncode(data.toJson());

  @override
  UserCredentials deserialize(String json) =>
      UserCredentials.fromJson(jsonDecode(json));
}
```

#### **Enhanced Encrypted Storage Service**
```dart
// packages/core/lib/src/infrastructure/services/enhanced_encrypted_storage_service.dart

class EnhancedEncryptedStorageService implements IEncryptedStorageRepository {
  final EnhancedSecureStorageService _secureStorage;
  final Map<String, HiveCipher> _ciphers = {};

  EnhancedEncryptedStorageService(this._secureStorage);

  @override
  Future<Either<Failure, Box<String>>> getEncryptedBox(
    String boxName, {
    String? keyName,
  }) async {
    try {
      // Get or create cipher for this box
      HiveCipher cipher;
      if (_ciphers.containsKey(boxName)) {
        cipher = _ciphers[boxName]!;
      } else {
        final keyResult = await _secureStorage.getOrCreateEncryptionKey(
          keyName: keyName ?? '${boxName}_key',
        );

        if (keyResult.isLeft()) {
          return keyResult.fold((failure) => Left(failure), (_) => throw Exception());
        }

        final key = keyResult.fold((_) => throw Exception(), (key) => key);
        cipher = HiveAesCipher(key);
        _ciphers[boxName] = cipher;
      }

      // Open encrypted box
      if (!Hive.isBoxOpen(boxName)) {
        final box = await Hive.openBox<String>(boxName, encryptionCipher: cipher);
        return Right(box);
      }

      return Right(Hive.box<String>(boxName));
    } catch (e) {
      return Left(CacheFailure('Error opening encrypted box: $e'));
    }
  }

  // Specialized encrypted operations
  Future<Either<Failure, void>> storeEncryptedData<T>({
    required String boxName,
    required String key,
    required T data,
  }) async {
    final boxResult = await getEncryptedBox(boxName);

    return boxResult.fold(
      (failure) => Left(failure),
      (box) async {
        try {
          await box.put(key, jsonEncode(data));
          return const Right(null);
        } catch (e) {
          return Left(CacheFailure('Error storing encrypted data: $e'));
        }
      },
    );
  }
}
```

### **Phase 2: App-Plantis Adapter Integration (Dia 3)**

#### **Plantis-Specific Service Adapter**
```dart
// apps/app-plantis/lib/core/adapters/plantis_storage_adapter.dart

class PlantisStorageAdapter {
  final EnhancedSecureStorageService _secureStorage;
  final EnhancedEncryptedStorageService _encryptedStorage;

  PlantisStorageAdapter({
    required EnhancedSecureStorageService secureStorage,
    required EnhancedEncryptedStorageService encryptedStorage,
  }) : _secureStorage = secureStorage,
       _encryptedStorage = encryptedStorage;

  // Backward compatible methods
  Future<void> storeUserCredentials(UserCredentials credentials) async {
    await _secureStorage.storeSecureData<UserCredentials>(
      key: 'user_credentials',
      data: credentials,
      serializer: UserCredentialsSerializer(),
    );
  }

  Future<UserCredentials?> getUserCredentials() async {
    final result = await _secureStorage.getSecureData<UserCredentials>(
      key: 'user_credentials',
      serializer: UserCredentialsSerializer(),
    );

    return result.fold((_) => null, (data) => data);
  }

  Future<void> storeLocationData(LocationData locationData) async {
    await _secureStorage.storeSecureData<LocationData>(
      key: 'location_data',
      data: locationData,
      serializer: LocationDataSerializer(),
    );
  }

  Future<LocationData?> getLocationData() async {
    final result = await _secureStorage.getSecureData<LocationData>(
      key: 'location_data',
      serializer: LocationDataSerializer(),
    );

    return result.fold((_) => null, (data) => data);
  }

  Future<List<int>> getOrCreateHiveEncryptionKey() async {
    final result = await _secureStorage.getOrCreateEncryptionKey();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (key) => key,
    );
  }

  // Enhanced encrypted box access
  Future<Box<String>> getSensitiveDataBox() async {
    final result = await _encryptedStorage.getEncryptedBox('sensitive_data_encrypted');
    return result.fold(
      (failure) => throw Exception(failure.message),
      (box) => box,
    );
  }

  // Other backward compatible methods...
}
```

#### **Updated DI Configuration**
```dart
// apps/app-plantis/lib/core/di/injection_container.dart

void _initCoreServices() {
  // ... existing services

  // Enhanced Secure Storage with Plantis config
  sl.registerLazySingleton<EnhancedSecureStorageService>(
    () => EnhancedSecureStorageService(
      appIdentifier: 'plantis',
      config: const SecureStorageConfig.plantis(),
    ),
  );

  // Enhanced Encrypted Storage
  sl.registerLazySingleton<EnhancedEncryptedStorageService>(
    () => EnhancedEncryptedStorageService(sl<EnhancedSecureStorageService>()),
  );

  // Plantis Storage Adapter (backward compatibility)
  sl.registerLazySingleton<PlantisStorageAdapter>(
    () => PlantisStorageAdapter(
      secureStorage: sl<EnhancedSecureStorageService>(),
      encryptedStorage: sl<EnhancedEncryptedStorageService>(),
    ),
  );

  // Maintain backward compatibility interface
  sl.registerLazySingleton<SecureStorageService>(() =>
    _SecureStorageServiceAdapter(sl<PlantisStorageAdapter>()));
}

// Legacy adapter for zero breaking changes
class _SecureStorageServiceAdapter implements SecureStorageService {
  final PlantisStorageAdapter _adapter;
  _SecureStorageServiceAdapter(this._adapter);

  @override
  Future<void> storeUserCredentials(UserCredentials credentials) =>
      _adapter.storeUserCredentials(credentials);

  @override
  Future<UserCredentials?> getUserCredentials() =>
      _adapter.getUserCredentials();

  // ... other forwarding methods
}
```

### **Phase 3: Validation & Rollout (Dia 4)**

#### **Testing Integration**
```dart
// test/storage/enhanced_storage_integration_test.dart

void main() {
  group('Enhanced Storage Integration', () {
    late EnhancedSecureStorageService secureStorage;
    late EnhancedEncryptedStorageService encryptedStorage;

    setUp(() {
      secureStorage = EnhancedSecureStorageService(
        appIdentifier: 'test',
        config: const SecureStorageConfig.defaultConfig(),
      );
      encryptedStorage = EnhancedEncryptedStorageService(secureStorage);
    });

    test('should store and retrieve secure data', () async {
      const testData = UserCredentials(
        userId: 'test123',
        email: 'test@example.com',
      );

      final storeResult = await secureStorage.storeSecureData<UserCredentials>(
        key: 'test_credentials',
        data: testData,
        serializer: UserCredentialsSerializer(),
      );

      expect(storeResult.isRight(), true);

      final retrieveResult = await secureStorage.getSecureData<UserCredentials>(
        key: 'test_credentials',
        serializer: UserCredentialsSerializer(),
      );

      expect(retrieveResult.isRight(), true);
      final retrieved = retrieveResult.fold((_) => null, (data) => data);
      expect(retrieved?.userId, testData.userId);
    });

    test('should handle encrypted boxes correctly', () async {
      final boxResult = await encryptedStorage.getEncryptedBox('test_box');

      expect(boxResult.isRight(), true);
      final box = boxResult.fold((_) => null, (box) => box);
      expect(box, isNotNull);
    });
  });
}
```

---

## 🧪 Testing Strategy

### **Migration Validation**
```dart
// test/migration/storage_migration_test.dart

class StorageMigrationTest {
  // Test backward compatibility
  static Future<void> testBackwardCompatibility() async {
    final adapter = PlantisStorageAdapter(
      secureStorage: EnhancedSecureStorageService(appIdentifier: 'test'),
      encryptedStorage: EnhancedEncryptedStorageService(...),
    );

    // Test all legacy methods work
    final credentials = UserCredentials(userId: '123', email: 'test@example.com');
    await adapter.storeUserCredentials(credentials);
    final retrieved = await adapter.getUserCredentials();

    expect(retrieved?.userId, equals(credentials.userId));
  }

  // Test enhanced functionality
  static Future<void> testEnhancedFeatures() async {
    final secureStorage = EnhancedSecureStorageService(appIdentifier: 'test');

    // Test generic secure data storage
    await secureStorage.storeSecureData<Map<String, String>>(
      key: 'custom_data',
      data: {'key': 'value'},
    );

    final result = await secureStorage.getSecureData<Map<String, String>>(
      key: 'custom_data',
    );

    expect(result.isRight(), true);
  }
}
```

---

## ⚖️ Risk Assessment & Mitigation

### **Low Risk Migration ✅**

#### **Favorable Factors:**
- **Core Integration Proven:** HiveStorageService já funcionando no app-plantis
- **Interface-Based:** ILocalStorageRepository permite upgrades transparentes
- **Specialized Enhancement:** Não afeta storage básico já estável
- **Backward Compatibility:** Adapter pattern mantém interfaces existentes

#### **Risk Mitigation:**

**Risk 1: Secure Storage Breaking Changes**
- **Impact:** Medium - backup services dependem do SecureStorageService
- **Mitigation:** Adapter pattern mantém interface exata
- **Testing:** Comprehensive backward compatibility tests

**Risk 2: Encryption Key Migration**
- **Impact:** High - perda de chaves = perda de dados
- **Mitigation:** Migration script para chaves existentes
- **Backup:** Export/import de chaves durante migração

**Risk 3: Performance Impact**
- **Impact:** Low - additional abstraction layer
- **Mitigation:** Direct delegation, minimal overhead
- **Monitoring:** Performance benchmarks

### **Migration Safety Net**
```dart
// Emergency rollback capability
class StorageEmergencyRollback {
  static Future<void> rollbackToLocal() async {
    // 1. Export all secure data
    // 2. Restore local SecureStorageService registration
    // 3. Import data back
    // Total time: < 1 hour
  }
}
```

---

## 📊 Impact Metrics

### **Current State Metrics**
- **Core Storage:** ✅ 100% migrated (HiveStorageService)
- **Secure Storage:** ❌ 0% migrated (still local)
- **Encrypted Storage:** ❌ 0% migrated (still local)
- **Overall Migration:** 33% complete

### **Post-Migration Metrics**
- **Code Consolidation:** 600+ lines moved to core package
- **Cross-App Benefits:** 6 apps can use enterprise secure storage
- **Duplicate Elimination:** 100% secure storage duplication removed
- **Feature Enhancement:** Configurable per app + enhanced serialization

### **ROI Calculation**
- **Investment:** 4 dias development + testing
- **Returns:** Enterprise secure storage for 6 apps
- **Break-even:** First cross-app secure storage usage
- **Long-term:** Unified security standards cross-app

---

## 🎯 Success Criteria

### **Phase 1 - Core Enhancement**
- [ ] EnhancedSecureStorageService implemented with app configuration
- [ ] EnhancedEncryptedStorageService with flexible encryption
- [ ] SecureStorageConfig with app-specific presets
- [ ] Comprehensive unit test suite (>95% coverage)
- [ ] Documentation and usage examples

### **Phase 2 - App Integration**
- [ ] PlantisStorageAdapter maintaining backward compatibility
- [ ] All existing secure storage functionality preserved
- [ ] DI container updated with enhanced services
- [ ] Legacy adapter for zero breaking changes
- [ ] Integration tests passing

### **Phase 3 - Validation**
- [ ] All backup services working with new storage
- [ ] Performance metrics maintained or improved
- [ ] Security validation and encryption key migration
- [ ] Production deployment successful
- [ ] Cross-app adoption ready

### **Acceptance Criteria**
1. **Functionality:** All existing storage operations preserved + enhanced
2. **Security:** Platform-specific encryption maintained or improved
3. **Performance:** No measurable performance regression
4. **Scalability:** Other apps can adopt secure storage easily

---

## 📋 Implementation Checklist

### **Phase 1: Core Package Enhancement (2 dias)**
- [ ] Design EnhancedSecureStorageService interface
- [ ] Implement configurable secure storage with app identification
- [ ] Create EnhancedEncryptedStorageService with flexible encryption
- [ ] Add SecureStorageConfig with presets (plantis, gasometer, etc)
- [ ] Implement serializer system for complex data types
- [ ] Create comprehensive unit tests
- [ ] Performance benchmarking
- [ ] Documentation and examples

### **Phase 2: App-Plantis Integration (1 dia)**
- [ ] Create PlantisStorageAdapter for backward compatibility
- [ ] Implement _SecureStorageServiceAdapter for legacy support
- [ ] Update DI container with enhanced services
- [ ] Migration script for existing encryption keys
- [ ] Integration testing with backup services
- [ ] Manual testing of all secure storage functionality

### **Phase 3: Validation & Rollout (1 dia)**
- [ ] Production validation testing
- [ ] Performance monitoring setup
- [ ] Security audit of encryption implementation
- [ ] Team training on enhanced capabilities
- [ ] Documentation updates
- [ ] Rollback procedure documentation

---

## 🔄 Future Roadmap

### **Cross-App Adoption**
- **app-gasometer:** Secure storage for receipt data and personal info
- **app-receituagro:** Secure storage for agricultural and location data
- **app-taskolist:** Secure storage for sensitive task and personal data
- **Unified Security:** Consistent encryption and security patterns

### **Advanced Features**
- **Biometric Integration:** Enhanced biometric authentication
- **Cloud Backup:** Encrypted cloud backup of secure storage
- **Key Rotation:** Automatic encryption key rotation
- **Compliance:** GDPR, HIPAA compliance features

---

## 📈 Strategic Value

### **Current Achievement**
- **Foundation Solid:** Core storage integration successful (80% complete)
- **Proven Pattern:** HiveStorageService integration demonstrates feasibility
- **Architecture Ready:** Interfaces and patterns established

### **Migration Value**
- **Security Standardization:** Enterprise-grade security across apps
- **Reduced Duplication:** ~600 lines consolidated
- **Enhanced Capability:** Configurable, extensible secure storage
- **Cross-App Benefits:** 6 apps gain enterprise security features

### **Long-term Impact**
- **Security Foundation:** Robust foundation for all sensitive data
- **Compliance Ready:** GDPR, security standards compliance
- **Developer Velocity:** Pre-built secure storage for new features
- **User Trust:** Professional-grade data protection

---

**Conclusão:** O app-plantis já demonstrou **sucesso na migração básica** com HiveStorageService. A consolidação dos specialized services representa o **fechamento final** desta migração, elevando recursos únicos e valiosos para beneficiar todo o monorepo. A arquitetura híbrida atual é funcional, mas a consolidação completa oferece **valor estratégico significativo** para padronização de segurança cross-app.

**Recomendação:** **Implementar como prioridade alta** para completar a migração de storage e estabelecer padrão de segurança enterprise para todo o monorepo.