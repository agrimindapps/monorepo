# Error Handling - app-gasometer

Sistema robusto de tratamento de erros para o app-gasometer, com foco em operações financeiras e auditoria.

## 📋 Visão Geral

Este módulo fornece uma estrutura completa para:
- ✅ **Mapeamento de exceptions** para Failures tipados
- ✅ **Logging estruturado** com níveis de severidade
- ✅ **Auditoria financeira** detalhada
- ✅ **Sanitização de dados sensíveis**
- ✅ **Integração com Firebase Crashlytics**

## 🏗️ Arquitetura

```
lib/core/errors/
├── failures.dart                           # Hierarchy de Failures
├── exception_mapper.dart                   # Exception → Failure conversion
├── repository_error_handling_example.dart  # Exemplo de uso em repositórios
└── README.md                               # Esta documentação

lib/core/services/
└── financial_logging_service.dart          # Logging service para operações financeiras
```

## 🔧 Componentes Principais

### 1. Failures (failures.dart)

Hierarchy de falhas específicas do app-gasometer:

#### **Core Failures** (reexportados do package:core)
- `Failure` - Base class abstrata
- `ServerFailure` - Erros de servidor/rede
- `CacheFailure` - Erros de storage local
- `ValidationFailure` - Erros de validação
- `AuthFailure` - Erros de autenticação
- `PermissionFailure` - Erros de autorização
- `NetworkFailure` - Erros de conectividade
- `ParseFailure` - Erros de parsing
- `UnknownFailure` - Erros desconhecidos
- `FirebaseFailure` - Erros do Firebase
- `SyncFailure` - Erros de sincronização
- `NotFoundFailure` - Recurso não encontrado

#### **Gasometer-specific Failures**

**FinancialConflictFailure**
- Conflitos em operações financeiras (sincronização)
- Contém: `localData`, `remoteData`, `entityType`, `entityId`

**FinancialIntegrityFailure**
- Violação de regras de negócio financeiras
- Contém: `fieldName`, `invalidValue`, `constraint`

**ConnectivityFailure**
- Wrapper específico para NetworkFailure
- Mensagem padrão user-friendly

**StorageFailure**
- Erros de armazenamento (Hive/Firebase Storage)
- Contém: `storageType`, `operation`

**IdReconciliationFailure**
- Erros ao mapear IDs locais → remotos
- Contém: `localId`, `remoteId`, `entityType`

**ImageOperationFailure**
- Erros em operações de imagem
- Contém: `operation`, `imagePath`

### 2. ExceptionMapper (exception_mapper.dart)

Mapeia exceptions de bibliotecas externas para Failures tipados.

#### **Métodos Principais**

**`mapException(dynamic exception, [StackTrace? stackTrace])`**
- Mapeia qualquer exception para Failure apropriado
- Preserva stack trace quando fornecido
- Retorna Failure específico baseado no tipo de exception

**Mapeamentos Suportados:**

| Exception Type | Failure Type | Exemplos de Códigos |
|----------------|--------------|---------------------|
| `FirebaseException` | Vários | `permission-denied`, `unavailable`, `not-found` |
| `FirebaseAuthException` | `AuthFailure`, `ValidationFailure` | `user-not-found`, `weak-password` |
| `FirebaseException` (Storage) | `ImageOperationFailure`, `NotFoundFailure` | `object-not-found`, `invalid-checksum` |
| Network exceptions | `ConnectivityFailure` | `SocketException`, `TimeoutException` |
| `FormatException` | `ParseFailure` | - |
| `StateError` | `ValidationFailure` | - |
| `ArgumentError` | `ValidationFailure` | - |
| Unknown | `UnknownFailure` | - |

#### **Factory Methods**

```dart
// Criar FinancialIntegrityFailure
ExceptionMapper.createFinancialIntegrityFailure(
  message: 'Cost cannot be negative',
  fieldName: 'cost',
  invalidValue: -10.0,
  constraint: 'cost >= 0',
);

// Criar FinancialConflictFailure
ExceptionMapper.createFinancialConflictFailure(
  message: 'Data conflict detected',
  entityType: 'fuel_supply',
  entityId: 'fuel-123',
  localData: localFuelSupply,
  remoteData: remoteFuelSupply,
);

// Criar IdReconciliationFailure
ExceptionMapper.createIdReconciliationFailure(
  message: 'Failed to reconcile ID',
  localId: 'local-123',
  entityType: 'vehicle',
  remoteId: 'remote-456',
);
```

### 3. FinancialLoggingService (financial_logging_service.dart)

Serviço de logging especializado para operações financeiras.

#### **Níveis de Log**

| Nível | Quando Usar | Enviado para Crashlytics? |
|-------|-------------|---------------------------|
| `debug` | Informações detalhadas (apenas debug mode) | ❌ |
| `info` | Operações normais concluídas | ❌ |
| `warning` | Situações não críticas que precisam atenção | ✅ |
| `error` | Erros que afetam funcionalidade | ✅ |
| `critical` | Erros que podem causar crash/perda de dados | ✅ (fatal) |

#### **Métodos Principais**

**Logging Genérico:**
```dart
logger.debug('Message', {'key': 'value'});
logger.info('Message', {'key': 'value'});
logger.warning('Message', error: exception);
logger.error('Message', error: exception, stackTrace: stackTrace);
logger.critical('Message', error: exception, stackTrace: stackTrace);
```

**Logging Financeiro Especializado:**

```dart
// Operações CRUD
logger.logFinancialOperation(
  operation: 'CREATE',
  entityType: 'fuel_supply',
  entityId: 'fuel-123',
  amount: 100.50,
  vehicleId: 'vehicle-456',
  additionalData: {'liters': 50.0},
);

// Conflitos de sincronização
logger.logFinancialConflict(
  entityType: 'fuel_supply',
  entityId: 'fuel-123',
  localData: localData,
  remoteData: remoteData,
  resolution: 'manual_required',
);

// Erros de validação
logger.logFinancialValidationError(
  entityType: 'fuel_supply',
  fieldName: 'cost',
  invalidValue: -10.0,
  constraint: 'cost >= 0',
);

// Falhas de sincronização
logger.logSyncFailure(
  entityType: 'fuel_supply',
  entityId: 'fuel-123',
  failure: failure,
  retryAttempt: 3,
);

// Operações de imagem
logger.logImageOperation(
  operation: 'upload',
  imagePath: '/path/to/image.jpg',
  success: true,
  fileSizeBytes: 1024000,
);

// Reconciliação de IDs
logger.logIdReconciliation(
  entityType: 'vehicle',
  localId: 'local-123',
  remoteId: 'remote-456',
  success: true,
);
```

#### **Sanitização de Dados Sensíveis**

O logging service automaticamente sanitiza:
- Senhas (`password=[REDACTED]`)
- Tokens (`token=[REDACTED]`)
- API Keys (`key=[REDACTED]`)
- Secrets (`secret=[REDACTED]`)
- Emails (`[EMAIL_REDACTED]`)
- Cartões de crédito (`[CARD_REDACTED]`)
- CPF (`[CPF_REDACTED]`)
- User IDs (parcialmente mascarados: `abc1...xyz9`)

## 📚 Padrões de Uso

### Padrão 1: Repository Create com Validação

```dart
Future<Either<Failure, FuelSupply>> create(FuelSupply fuelSupply) async {
  _logger.debug('Creating fuel supply: ${fuelSupply.id}');

  try {
    // ✅ Validação financeira ANTES de persistir
    if (fuelSupply.cost < 0) {
      _logger.logFinancialValidationError(
        entityType: 'fuel_supply',
        fieldName: 'cost',
        invalidValue: fuelSupply.cost,
        constraint: 'cost >= 0',
      );

      return Left(
        ExceptionMapper.createFinancialIntegrityFailure(
          message: 'Valor não pode ser negativo',
          fieldName: 'cost',
          invalidValue: fuelSupply.cost,
          constraint: 'cost >= 0',
        ),
      );
    }

    // ✅ Persistência
    await _syncManager.create('gasometer', fuelSupply.toEntity());

    // ✅ Logging financeiro para auditoria
    _logger.logFinancialOperation(
      operation: 'CREATE',
      entityType: 'fuel_supply',
      entityId: fuelSupply.id,
      amount: fuelSupply.cost,
      vehicleId: fuelSupply.vehicleId,
      additionalData: {'liters': fuelSupply.liters},
    );

    return Right(fuelSupply);
  } on FirebaseException catch (e, stackTrace) {
    // ✅ Exception específica mapeada
    _logger.error(
      'Failed to create fuel supply (Firebase)',
      error: e,
      stackTrace: stackTrace,
      metadata: {'fuel_id': fuelSupply.id},
    );

    return Left(ExceptionMapper.mapException(e, stackTrace));
  } catch (e, stackTrace) {
    // ✅ Fallback para erros inesperados
    _logger.critical(
      'Unexpected error creating fuel supply',
      error: e,
      stackTrace: stackTrace,
      metadata: {'fuel_id': fuelSupply.id},
    );

    return Left(ExceptionMapper.mapException(e, stackTrace));
  }
}
```

### Padrão 2: Repository Update com Detecção de Conflitos

```dart
Future<Either<Failure, FuelSupply>> update(FuelSupply fuelSupply) async {
  _logger.debug('Updating fuel supply: ${fuelSupply.id}');

  try {
    // ✅ Validação
    if (fuelSupply.cost < 0) {
      _logger.logFinancialValidationError(
        entityType: 'fuel_supply',
        fieldName: 'cost',
        invalidValue: fuelSupply.cost,
        constraint: 'cost >= 0',
      );

      return Left(
        ExceptionMapper.createFinancialIntegrityFailure(
          message: 'Valor não pode ser negativo',
          fieldName: 'cost',
          invalidValue: fuelSupply.cost,
          constraint: 'cost >= 0',
        ),
      );
    }

    // ✅ Update com versioning
    final updatedSupply = fuelSupply.markAsDirty().incrementVersion();
    await _syncManager.update('gasometer', fuelSupply.id, updatedSupply);

    // ✅ Logging
    _logger.logFinancialOperation(
      operation: 'UPDATE',
      entityType: 'fuel_supply',
      entityId: fuelSupply.id,
      amount: fuelSupply.cost,
    );

    return Right(updatedSupply);
  } on FirebaseException catch (e, stackTrace) {
    // ✅ Detectar conflitos específicos
    if (e.code == 'failed-precondition' || e.code == 'aborted') {
      _logger.logFinancialConflict(
        entityType: 'fuel_supply',
        entityId: fuelSupply.id,
        localData: fuelSupply.toJson(),
        remoteData: null,
        resolution: 'manual_required',
      );

      return Left(
        ExceptionMapper.createFinancialConflictFailure(
          message: 'Conflito ao atualizar. Dados modificados por outro dispositivo.',
          entityType: 'fuel_supply',
          entityId: fuelSupply.id,
          localData: fuelSupply,
        ),
      );
    }

    _logger.error('Failed to update fuel supply', error: e, stackTrace: stackTrace);
    return Left(ExceptionMapper.mapException(e, stackTrace));
  } catch (e, stackTrace) {
    _logger.critical('Unexpected error', error: e, stackTrace: stackTrace);
    return Left(ExceptionMapper.mapException(e, stackTrace));
  }
}
```

### Padrão 3: Repository Delete com Logging de Auditoria

```dart
Future<Either<Failure, void>> delete(String id) async {
  _logger.debug('Deleting fuel supply: $id');

  try {
    // ✅ Buscar registro ANTES de deletar (auditoria)
    final recordResult = await _syncManager.findById<FuelSupply>(_appName, id);
    final record = recordResult.fold((failure) => null, (supply) => supply);

    if (record == null) {
      _logger.warning('Fuel supply not found for deletion', {'fuel_id': id});
      return Left(NotFoundFailure('Abastecimento não encontrado'));
    }

    // ✅ Delete
    await _syncManager.delete<FuelSupply>(_appName, id);

    // ✅ IMPORTANTE: Logging detalhado para auditoria de deleção
    _logger.logFinancialOperation(
      operation: 'DELETE',
      entityType: 'fuel_supply',
      entityId: id,
      amount: record.cost,
      vehicleId: record.vehicleId,
      additionalData: {
        'deleted_at': DateTime.now().toIso8601String(),
        'liters': record.liters,
        'date': record.date.toIso8601String(),
      },
    );

    return const Right(null);
  } on FirebaseException catch (e, stackTrace) {
    _logger.error('Failed to delete', error: e, stackTrace: stackTrace);
    return Left(ExceptionMapper.mapException(e, stackTrace));
  } catch (e, stackTrace) {
    _logger.critical('Unexpected error', error: e, stackTrace: stackTrace);
    return Left(ExceptionMapper.mapException(e, stackTrace));
  }
}
```

## ✅ Checklist de Error Handling

Para cada repositório, verificar:

- ✅ Try-catch em todos os métodos públicos
- ✅ Exceptions específicas capturadas (FirebaseException, etc)
- ✅ Logging apropriado (debug para start, info para success, error para failures)
- ✅ Metadata relevante nos logs (IDs, valores financeiros, timestamps)
- ✅ Failures tipados (não generic Exception)
- ✅ Stack traces sempre preservados
- ✅ Validação financeira ANTES de persistência
- ✅ Logging de auditoria em operações financeiras
- ✅ Detecção de conflitos em updates
- ✅ Logging de deleções (importante para auditoria)

## 🧪 Testing

### Testes do ExceptionMapper

```bash
flutter test test/core/errors/exception_mapper_test.dart
```

**Cobertura esperada:**
- ✅ Firebase Firestore exceptions (10+ casos)
- ✅ Firebase Auth exceptions (8+ casos)
- ✅ Firebase Storage exceptions (5+ casos)
- ✅ Network exceptions (3+ casos)
- ✅ Parsing exceptions
- ✅ State/Argument exceptions
- ✅ Unknown exceptions
- ✅ Factory methods
- ✅ Stack trace preservation

Total: **30+ testes**

## 📊 Métricas de Qualidade

### Objetivos
- ✅ 0 analyzer errors
- ✅ 0 critical warnings
- ✅ ≥80% test coverage para ExceptionMapper
- ✅ Todos os repositórios usando ExceptionMapper
- ✅ Logging estruturado em 100% das operações financeiras

## 🔄 Migração Gradual

### Fase 1: Setup ✅ COMPLETO
- ✅ Criar failures.dart
- ✅ Criar exception_mapper.dart
- ✅ Criar financial_logging_service.dart
- ✅ Criar testes do exception_mapper
- ✅ Criar documentação (este README)

### Fase 2: Migração de Repositórios (Próximo)
- ⏳ VehicleRepository
- ⏳ FuelRepository
- ⏳ MaintenanceRepository
- ⏳ ExpenseRepository

### Fase 3: Validação
- ⏳ Revisar logs em debug mode
- ⏳ Validar Crashlytics integration
- ⏳ Performance testing
- ⏳ Auditoria de segurança (dados sensíveis sanitizados)

## 📝 Notas Importantes

### Dados Sensíveis
- **NUNCA** logar senhas, tokens, API keys em texto plano
- User IDs devem ser parcialmente mascarados
- Valores financeiros SÃO SEGUROS para log (são dados de negócio, não credenciais)

### Performance
- Logging em `debug` level só executa em debug mode
- Crashlytics logging é assíncrono (não bloqueia)
- Sanitização de dados tem overhead mínimo

### Auditoria Financeira
- Operações CREATE/UPDATE/DELETE DEVEM ser logadas
- Incluir valores ANTES e DEPOIS em updates
- Incluir todos os dados relevantes em deletes
- Timestamps são adicionados automaticamente

## 🔗 Referências

- **Exemplo Completo**: `repository_error_handling_example.dart`
- **Core Failures**: `packages/core/lib/src/shared/utils/failure.dart`
- **Testes**: `test/core/errors/exception_mapper_test.dart`

## 🚀 Quick Start

```dart
// 1. Importar
import 'package:gasometer/core/errors/failures.dart';
import 'package:gasometer/core/errors/exception_mapper.dart';
import 'package:gasometer/core/services/financial_logging_service.dart';

// 2. Injetar FinancialLoggingService no repository
class MyRepository {
  final FinancialLoggingService _logger;

  MyRepository({required FinancialLoggingService logger}) : _logger = logger;

  // 3. Usar padrões de error handling
  Future<Either<Failure, MyEntity>> create(MyEntity entity) async {
    try {
      // validação + persistência
    } on FirebaseException catch (e, stackTrace) {
      return Left(ExceptionMapper.mapException(e, stackTrace));
    } catch (e, stackTrace) {
      _logger.critical('Unexpected error', error: e, stackTrace: stackTrace);
      return Left(ExceptionMapper.mapException(e, stackTrace));
    }
  }
}
```

---

**Última atualização**: 2025-10-23
**Status**: ✅ Fase 1 Completa - Pronto para migração de repositórios
