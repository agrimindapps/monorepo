# Sistema de Error Handling dos Repositories

Este documento descreve o sistema completo de tratamento de erros implementado para os repositories do módulo plantas.

## 📋 Visão Geral

O sistema de error handling foi desenvolvido para resolver problemas críticos identificados na issue #12:
- Exceptions silenciosas engolidas por try-catch inadequados
- Falta de logging estruturado para debugging
- Operações batch sem tratamento de erro robusto
- Ausência de retry mechanism para falhas temporárias

## 🏗️ Arquitetura

### 1. **RepositoryException Hierarchy**
```dart
RepositoryException (abstract base class)
├── RepositoryInitializationException
├── DataAccessException
├── NetworkException (with retry support)
├── TimeoutException
├── DataConflictException
├── EntityNotFoundException
├── BatchOperationException
├── ValidationException
├── InvalidStateException
└── SyncException
```

**Características:**
- ✅ Contexto estruturado (repository, operation, timestamp)
- ✅ Exception chaining (causa original preservada)
- ✅ Serialização para logging
- ✅ Metadata adicional específica por tipo

### 2. **Sistema de Logging Estruturado**
```dart
RepositoryLogger logger = RepositoryLogManager.instance.getLogger('MyRepository');

// Diferentes níveis
logger.debug('Debug info', data: {...});
logger.info('Operation started', data: {...});
logger.warning('Recoverable issue', data: {...});
logger.error('Operation failed', exception: e);
logger.critical('System failure', exception: e);

// Log com timing automático
await logger.logOperation('complexOperation', () async {
  // operação custosa
});
```

**Features:**
- ✅ Múltiplos outputs (console, arquivo, remoto)
- ✅ Integração com Flutter DevTools
- ✅ Context estruturado automático
- ✅ Timing de operações
- ✅ Gerenciamento global de configurações

### 3. **Retry Mechanism Inteligente**
```dart
// Configurações predefinidas
RetryConfig.network   // Para operações de network (4 tentativas)
RetryConfig.fast      // Para operações rápidas (2 tentativas)
RetryConfig.critical  // Para operações críticas (5 tentativas)

// Uso via manager
final result = await RetryManager.retry<String>(
  operation: () => _syncService.create(data),
  repositoryName: 'MyRepository',
  operationName: 'createEntity',
  configName: 'network',
);
```

**Características:**
- ✅ Exponential backoff com jitter
- ✅ Predicados inteligentes para retry
- ✅ Timeout integration
- ✅ Callbacks para monitoramento
- ✅ Configurações flexíveis por tipo

### 4. **RepositoryErrorHandlingMixin**
Mixin que facilita integração do sistema em repositories existentes:

```dart
class MyRepository with RepositoryErrorHandlingMixin {
  @override
  String get repositoryName => 'MyRepository';
  
  Future<T> myOperation<T>() async {
    return await executeCrudOperation<T>(
      operation: () => _actualOperation(),
      operationType: 'create',
      entityType: 'MyEntity',
    );
  }
}
```

## 🚀 Como Usar

### 1. **Em um Repository Novo**
```dart
import 'error_handling/repository_error_handling_mixin.dart';

class NewRepository with RepositoryErrorHandlingMixin {
  @override
  String get repositoryName => 'NewRepository';
  
  Future<EntityModel> createEntity(EntityModel entity) async {
    return await executeCrudOperation<EntityModel>(
      operation: () => _syncService.create(entity),
      operationType: 'create',
      entityType: 'Entity',
      additionalContext: {'entity_name': entity.name},
    );
  }
  
  Future<List<String>> createBatch(List<EntityModel> entities) async {
    return await executeBatchOperation<String, EntityModel>(
      items: entities,
      itemOperation: (entity) => _syncService.create(entity),
      operationType: 'createBatch',
      continueOnError: false,
    );
  }
}
```

### 2. **Operações com Retry Automático**
```dart
Future<T> networkOperation<T>() async {
  return await executeWithErrorHandling<T>(
    operation: () => _externalApiCall(),
    operationName: 'fetchFromAPI',
    enableRetry: true,        // Ativa retry
    retryConfigName: 'network',
  );
}
```

### 3. **Operações com Timeout**
```dart
Future<T> timeoutOperation<T>() async {
  return await executeWithTimeoutAndRetry<T>(
    operation: () => _longRunningOperation(),
    operationName: 'processLargeData',
    timeout: Duration(seconds: 30),
  );
}
```

### 4. **Busca Segura (sem engolir exceptions)**
```dart
Future<EntityModel?> findEntitySafely(String id) async {
  return await executeCrudOperation<EntityModel?>(
    operation: () async {
      final entities = await findAll();
      
      // Não engole exceptions inesperadas
      return findInListSafely(
        entities,
        (entity) => entity.id == id,
        'findById',
        context: {'entityId': id},
      );
    },
    operationType: 'findById',
    entityId: id,
  );
}
```

### 5. **Logging Manual Detalhado**
```dart
void complexOperation() async {
  logger.info(
    'Starting complex operation',
    data: RepositoryLogUtils.crudContext(
      entityType: 'ComplexEntity',
      additionalData: {'batch_size': 100},
    ),
  );
  
  try {
    // operação complexa
    
    logger.info('Operation completed successfully');
  } catch (exception, stackTrace) {
    final repoException = RepositoryExceptions.networkError(
      repository: repositoryName,
      operation: 'complexOperation',
      cause: exception,
    );
    
    logger.logException(repoException, stackTrace: stackTrace);
    throw repoException;
  }
}
```

## 🔧 Configuração

### 1. **Configuração Global de Log**
```dart
// No main() ou inicialização da app
RepositoryLogManager.instance.setGlobalLogLevel(LogLevel.info);

// Adicionar outputs customizados
RepositoryLogManager.instance.addGlobalOutput(
  FileLogOutput('/path/to/log/file'),
);
```

### 2. **Configuração de Retry Customizada**
```dart
// Registrar configuração específica
RetryManager.instance.registerConfig('custom', RetryConfig(
  maxAttempts: 5,
  initialDelay: Duration(seconds: 1),
  backoffMultiplier: 2.5,
  maxDelay: Duration(minutes: 2),
  shouldRetry: (e) => e.toString().contains('specific_error'),
));

// Usar configuração customizada
await RetryManager.retry<T>(
  operation: () => _operation(),
  repositoryName: 'MyRepo',
  operationName: 'customOp',
  configName: 'custom',
);
```

## 📊 Monitoramento e Debug

### 1. **Estatísticas de Cache**
```dart
// Obter estatísticas de loggers
final stats = RepositoryLogManager.instance.getStatistics();
print('Total loggers: ${stats['total_loggers']}');

// Obter estatísticas de retry
final retryStats = RetryManager.instance.getStatistics();
print('Configurações: ${retryStats['registered_configs']}');
```

### 2. **Debug de Exceptions**
```dart
// Exceptions têm contexto rico para debugging
try {
  await operation();
} on BatchOperationException catch (e) {
  print('Batch falhou: ${e.successfulItems}/${e.totalItems} sucessos');
  for (final error in e.individualErrors) {
    print('Item error: ${error.toLogMap()}');
  }
} on NetworkException catch (e) {
  print('Network error: retryable=${e.isRetryable}, attempts=${e.retryCount}');
}
```

### 3. **Logging Context Automático**
Todos os logs incluem contexto automático:
- Timestamp preciso
- Repository de origem
- Operação sendo executada
- Context específico da operação
- Stack trace quando relevante
- Metadata adicional por tipo de exception

## ✅ Benefícios

### **Para Debugging:**
- ✅ Logs estruturados facilitam identificação de problemas
- ✅ Context rico em cada exception
- ✅ Stack traces preservados
- ✅ Timing de operações automático

### **Para Reliability:**
- ✅ Retry automático para falhas temporárias
- ✅ Timeout protection
- ✅ Operações batch robustas
- ✅ Graceful degradation

### **Para Maintainability:**
- ✅ Error handling consistente
- ✅ Separation of concerns
- ✅ Type-safe exceptions
- ✅ Mixin pattern reutilizável

### **Para Operations:**
- ✅ Observabilidade completa
- ✅ Métricas automáticas
- ✅ Configuração centralizada
- ✅ Multiple output formats

## 🔄 Migração de Repositories Existentes

### 1. **Adicionar Mixin**
```dart
class ExistingRepository 
    with ExistingMixins, RepositoryErrorHandlingMixin {
  
  @override
  String get repositoryName => 'ExistingRepository';
}
```

### 2. **Refatorar Try-Catch Problemáticos**
```dart
// ❌ Antes: engole exceptions
try {
  return list.firstWhere(predicate);
} catch (e) {
  return null;
}

// ✅ Depois: tratamento correto
return findInListSafely(list, predicate, 'operationName');
```

### 3. **Upgrade Operações Batch**
```dart
// ❌ Antes: sem error handling
for (final item in items) {
  await processItem(item); // Pode falhar silenciosamente
}

// ✅ Depois: batch operation robusta
await executeBatchOperation<Result, Item>(
  items: items,
  itemOperation: (item) => processItem(item),
  operationType: 'processBatch',
  continueOnError: true,
);
```

## 📚 Exemplos de Uso Real

Veja os repositories já refatorados:
- `PlantaConfigRepository`: findByPlantaId() corrigido
- `TarefaRepository`: createBatch() e removerPorPlanta() refatorados
- `EspacoRepository`: Mixin integrado
- `PlantaRepository`: Mixin integrado

## 🔗 Files de Referência

- `exceptions/repository_exceptions.dart` - Exception hierarchy
- `logging/repository_logger.dart` - Sistema de logging
- `retry/retry_mechanism.dart` - Retry mechanism
- `repository_error_handling_mixin.dart` - Mixin principal

---

**Issue #12 - Resolvida em 07/08/2025** 🎉