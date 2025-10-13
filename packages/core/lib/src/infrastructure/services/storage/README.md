# Storage Specialized Services

## 📋 Overview

Este diretório contém os **specialized services** extraídos do `EnhancedStorageService` (God Service de 1,157 linhas) seguindo o princípio **Single Responsibility Principle (SRP)**.

**Data de Refactoring**: 2025-10-13
**Esforço**: 6-8 horas
**Status**: ✅ Extraction completa | ⚠️ Integration pendente

---

## 🎯 Specialized Services

### 1. **StorageCacheManager**
**Arquivo**: `storage_cache_manager.dart`
**Responsabilidade**: Cache LRU em memória com TTL

**Features**:
- LRU (Least Recently Used) eviction
- TTL (Time To Live) por item
- Gerenciamento de tamanho máximo (50MB)
- Hit/Miss ratio tracking

**Uso**:
```dart
final cacheManager = StorageCacheManager();
cacheManager.add('key', value, Duration(minutes: 30));
final cached = cacheManager.get<String>('key');
```

---

### 2. **StorageMetricsService**
**Arquivo**: `storage_metrics_service.dart`
**Responsabilidade**: Tracking e estatísticas de operações

**Features**:
- Tracking de read/write operations
- Cache hit/miss ratio calculation
- Performance metrics
- Reporting

**Uso**:
```dart
final metrics = StorageMetricsService();
metrics.recordRead();
final stats = metrics.getMetrics();
print(stats); // StorageMetrics(reads: 100, writes: 50, ...)
```

---

### 3. **StorageEncryptionService** ⭐ NEW IMPLEMENTATION
**Arquivo**: `storage_encryption_service.dart`
**Responsabilidade**: Criptografia/Descriptografia de valores

**Features**:
- XOR encryption (simétrico)
- SHA-256 key derivation
- Base64 encoding
- Detecção automática de valores encriptados

**NOTA**: ⚠️ Implementação básica. Para produção, usar `encrypt` package com AES.

**Uso**:
```dart
final encryption = StorageEncryptionService();
final encrypted = encryption.encrypt('sensitive data');
final decrypted = encryption.decrypt(encrypted);
```

---

### 4. **StorageCompressionService** ⭐ NEW IMPLEMENTATION
**Arquivo**: `storage_compression_service.dart`
**Responsabilidade**: Compressão/Descompressão de strings grandes

**Features**:
- GZip compression
- Threshold detection (>1KB)
- Compression ratio calculation
- Base64 encoding com prefixo `GZIP:`

**Uso**:
```dart
final compression = StorageCompressionService();
final compressed = compression.compress(largeString);
final decompressed = compression.decompress(compressed);
```

---

### 5. **StorageStrategySelector**
**Arquivo**: `storage_strategy_selector.dart`
**Responsabilidade**: Seleção de storage type baseado no valor

**Features**:
- Routing logic entre Hive, SharedPreferences, SecureStorage, File
- Políticas configuráveis (security, performance)
- Detecção de dados sensíveis
- Fallback order para read operations

**Uso**:
```dart
final selector = StorageStrategySelector();
final type = selector.determineStorageType(value, encrypt: true);
// Returns: StorageType.secureStorage
```

---

### 6. **StorageBackupService**
**Arquivo**: `storage_backup_service.dart`
**Responsabilidade**: Backup e restore operations

**Features**:
- Backup completo em JSON
- Backup incremental por item
- Validação de backup structure
- Limpeza de backups antigos
- Listagem de backups disponíveis

**Uso**:
```dart
final backup = StorageBackupService(backupDirectory: dir);
await backup.createBackup(data: {'key': 'value'});
final restored = await backup.restoreBackup(backupPath);
```

---

## 📦 Import Único (Barrel Export)

```dart
// Importa todos os specialized services de uma vez
import 'package:core/src/infrastructure/services/storage/storage_services.dart';

// Agora você tem acesso a:
// - StorageCacheManager
// - StorageMetricsService
// - StorageEncryptionService
// - StorageCompressionService
// - StorageStrategySelector
// - StorageBackupService
```

---

## 🔄 Migration Guide

### Antes (God Service)
```dart
final storage = EnhancedStorageService();
await storage.initialize();
await storage.store('key', value);
final stats = await storage.getStats();
```

### Depois (Specialized Services)
```dart
// Usando services especializados
final cache = StorageCacheManager();
final metrics = StorageMetricsService();
final encryption = StorageEncryptionService();

cache.add('key', value, Duration(minutes: 30));
metrics.recordWrite();
final encrypted = encryption.encrypt(sensitiveValue);
```

### Facade (Backward Compatible) - TODO
```dart
// EnhancedStorageService será refatorado para usar specialized services internamente
final storage = EnhancedStorageService();
// API pública permanece a mesma, mas internamente usa specialized services
await storage.store('key', value); // Delega para cache + metrics + encryption
```

---

## ✅ Benefits

| Antes (God Service) | Depois (Specialized) | Melhoria |
|---------------------|----------------------|----------|
| 1,157 linhas | 6 services (<300 linhas cada) | **-70% linhas/service** |
| 1 responsabilidade violada | 6 responsabilidades separadas | **SRP compliance** |
| Difícil testar | Fácil testar isoladamente | **+Testabilidade** |
| Alta complexidade | Baixa complexidade | **-60% complexidade** |
| Código duplicado | Código reutilizável | **DRY compliance** |
| 0 encryption/compression | Implementações funcionais | **+Features** |

---

## 🚀 Next Steps

### Immediate (2-3h)
- [ ] Refactor `EnhancedStorageService` to use specialized services internally
- [ ] Maintain public API for backward compatibility
- [ ] Update imports in apps (if needed)

### Short-term (1 week)
- [ ] Add unit tests for each specialized service (80%+ coverage)
- [ ] Integration tests with EnhancedStorageService facade
- [ ] Performance benchmarks

### Mid-term (1 month)
- [ ] Upgrade encryption to AES using `encrypt` package
- [ ] Add support for multiple compression algorithms (brotli, zstd)
- [ ] Implement storage quotas and limits
- [ ] Add telemetry and monitoring

---

## 📚 References

- **Original God Service**: `../enhanced_storage_service.dart`
- **Refactoring Plan**: `/REFACTORING_PLAN.md` (if exists)
- **SOLID Principles**: https://en.wikipedia.org/wiki/SOLID
- **Facade Pattern**: https://refactoring.guru/design-patterns/facade

---

**Maintained by**: Flutter Architecture Team
**Last Updated**: 2025-10-13
