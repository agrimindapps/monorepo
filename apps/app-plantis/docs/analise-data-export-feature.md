# Análise Detalhada: Feature de Exportação de Dados (LGPD)

**Feature:** `apps/app-plantis/lib/features/data_export`  
**Data da Análise:** 30/10/2024  
**Padrão de Referência:** app-plantis (Gold Standard)

---

## 📊 Resumo Executivo

### Status Geral: 🟡 BOM (7/10)

A feature de exportação de dados apresenta uma **estrutura bem organizada** seguindo Clean Architecture, mas possui **inconsistências críticas** no tratamento de erros que impedem conformidade total com os padrões do monorepo.

**Pontos Positivos:**
- ✅ Estrutura em camadas clara (Domain/Data/Presentation)
- ✅ Uso correto de Riverpod com code generation
- ✅ Entidades bem definidas com Equatable
- ✅ Separação de responsabilidades (datasources especializados)
- ✅ Compliance com LGPD (rate limiting, expiração de exports)

**Pontos Críticos Identificados:**
- 🔴 **Ausência de Either<Failure, T>** em repository e use cases
- 🔴 **Exceções não tratadas** propagando para apresentação
- 🟡 Duplicação de código entre notifiers
- 🟡 Estado mutable em repository (static fields)
- 🟡 Arquivo grande em presentation (635 linhas)

---

## 🏗️ Análise Arquitetural

### 1. Estrutura de Camadas ✅ CONFORME

```
data_export/
├── domain/
│   ├── entities/
│   │   └── export_request.dart ✅ (467 linhas - bem modelado)
│   ├── repositories/
│   │   └── data_export_repository.dart ❌ (sem Either<Failure, T>)
│   └── usecases/
│       ├── check_export_availability_usecase.dart ❌
│       ├── request_export_usecase.dart ❌
│       ├── get_export_history_usecase.dart ❌
│       ├── download_export_usecase.dart ❌
│       └── delete_export_usecase.dart ❌
├── data/
│   ├── repositories/
│   │   └── data_export_repository_impl.dart ❌ (323 linhas)
│   └── datasources/
│       └── local/
│           ├── plants_export_datasource.dart ✅ (250 linhas)
│           ├── settings_export_datasource.dart ✅ (40 linhas)
│           └── export_file_generator.dart ✅ (475 linhas)
└── presentation/
    ├── providers/
    │   └── data_export_provider.dart ⚠️ (405 linhas - Freezed State)
    ├── notifiers/
    │   └── data_export_notifier.dart ⚠️ (472 linhas - Duplicado)
    ├── pages/
    │   └── data_export_page.dart ⚠️ (635 linhas - muito grande)
    └── widgets/
        ├── data_type_selector.dart
        ├── export_format_selector.dart
        ├── export_availability_widget.dart
        └── export_progress_dialog.dart
```

**Observações:**
- ✅ Separação clara entre Domain, Data e Presentation
- ⚠️ Dois arquivos de notifiers coexistindo (provider.dart e notifier.dart)
- ❌ Page muito extensa (deveria ser < 500 linhas)

---

## 🔴 ISSUES CRÍTICOS

### #1: Ausência de Either<Failure, T> no Repository [ARQUITETURA]

**Severidade:** 🔴 CRÍTICA  
**Localização:** `domain/repositories/data_export_repository.dart`

**Problema:**
O repository retorna tipos diretos (`Future<ExportRequest>`, `Future<bool>`) ao invés de `Either<Failure, T>`, violando o padrão estabelecido no monorepo.

**Código Atual:**
```dart
abstract class DataExportRepository {
  /// Check availability of data export for the current user
  Future<ExportAvailabilityResult> checkExportAvailability({
    required String userId,
    required Set<DataType> requestedDataTypes,
  });

  /// Request data export
  Future<ExportRequest> requestExport({
    required String userId,
    required Set<DataType> dataTypes,
    required ExportFormat format,
  });

  /// Load export history for user
  Future<List<ExportRequest>> getExportHistory(String userId);

  /// Download export file
  Future<bool> downloadExport(String exportId);

  /// Delete export request and associated file
  Future<bool> deleteExport(String exportId);
}
```

**Código Esperado (Padrão Gold Standard):**
```dart
abstract class DataExportRepository {
  /// Check availability of data export for the current user
  Future<Either<Failure, ExportAvailabilityResult>> checkExportAvailability({
    required String userId,
    required Set<DataType> requestedDataTypes,
  });

  /// Request data export
  Future<Either<Failure, ExportRequest>> requestExport({
    required String userId,
    required Set<DataType> dataTypes,
    required ExportFormat format,
  });

  /// Load export history for user
  Future<Either<Failure, List<ExportRequest>>> getExportHistory(String userId);

  /// Download export file
  Future<Either<Failure, bool>> downloadExport(String exportId);

  /// Delete export request and associated file
  Future<Either<Failure, bool>> deleteExport(String exportId);
}
```

**Referência Gold Standard:**
```dart
// apps/app-plantis/lib/features/device_management/domain/repositories/device_repository.dart
abstract class DeviceRepository {
  Future<Either<Failure, List<DeviceModel>>> getUserDevices(String userId);
  Future<Either<Failure, DeviceModel?>> getDeviceByUuid(String deviceUuid);
  Future<Either<Failure, DeviceModel>> validateDevice({
    required String userId,
    required DeviceModel device,
  });
}
```

**Impacto:**
- Erro handling inconsistente com o resto do app
- Exceções não controladas propagando até a UI
- Testes mais difíceis (sem mockear falhas específicas)
- Violação do princípio de programação funcional adotado no monorepo

---

### #2: Repository Implementation com Exceções [DATA INTEGRITY]

**Severidade:** 🔴 CRÍTICA  
**Localização:** `data/repositories/data_export_repository_impl.dart`

**Problema:**
A implementação do repository lança exceções ao invés de retornar `Left(Failure)`.

**Exemplos de Código Problemático:**

```dart
// Linha 114-118
} catch (e) {
  return ExportAvailabilityResult.unavailable(
    reason: 'Erro ao verificar disponibilidade: ${e.toString()}',
  );
}

// Linha 147-149
} catch (e) {
  throw Exception('Erro ao solicitar exportação: ${e.toString()}');
}

// Linha 161-163
} catch (e) {
  throw Exception('Erro ao carregar histórico: ${e.toString()}');
}

// Linha 172-173
if (request == null) {
  throw Exception('Export não encontrado');
}

// Linha 185-187
} catch (e) {
  throw Exception('Erro ao baixar arquivo: ${e.toString()}');
}
```

**Código Esperado:**
```dart
@override
Future<Either<Failure, ExportAvailabilityResult>> checkExportAvailability({
  required String userId,
  required Set<DataType> requestedDataTypes,
}) async {
  try {
    // ... lógica ...
    return Right(ExportAvailabilityResult.available(
      availableDataTypes: availableTypes,
      estimatedSizeInBytes: totalSize,
    ));
  } on FirebaseException catch (e) {
    return Left(FirebaseFailure(
      'Erro ao verificar disponibilidade',
      code: e.code,
      details: e,
    ));
  } catch (e) {
    return Left(UnknownFailure(
      'Erro inesperado ao verificar disponibilidade',
      details: e,
    ));
  }
}

@override
Future<Either<Failure, ExportRequest>> requestExport({
  required String userId,
  required Set<DataType> dataTypes,
  required ExportFormat format,
}) async {
  try {
    _lastExportTime = DateTime.now();

    final request = ExportRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      dataTypes: dataTypes,
      format: format,
      requestDate: DateTime.now(),
      status: ExportRequestStatus.pending,
      metadata: const {
        'app_version': '1.0.0',
        'platform': 'Flutter',
        'compliance': 'LGPD',
      },
    );
    
    await _saveExportRequest(request);
    _processExportRequest(request);

    return Right(request);
  } on CacheException catch (e) {
    return Left(CacheFailure(
      'Erro ao salvar solicitação de exportação',
      code: 'CACHE_ERROR',
      details: e,
    ));
  } catch (e) {
    return Left(UnknownFailure(
      'Erro ao solicitar exportação',
      details: e,
    ));
  }
}
```

**Impacto:**
- Crashes não tratados na aplicação
- Mensagens de erro genéricas para o usuário
- Dificulta testes unitários e de integração
- Não segue convenções do monorepo

---

### #3: Use Cases sem Either<Failure, T> [ARQUITETURA]

**Severidade:** 🔴 CRÍTICA  
**Localização:** Todos os use cases em `domain/usecases/`

**Problema:**
Use cases apenas delegam para repository sem aplicar Either pattern.

**Código Atual:**
```dart
// check_export_availability_usecase.dart
class CheckExportAvailabilityUseCase {
  final DataExportRepository _repository;

  CheckExportAvailabilityUseCase(this._repository);

  Future<ExportAvailabilityResult> call({
    required String userId,
    required Set<DataType> requestedDataTypes,
  }) async {
    return await _repository.checkExportAvailability(
      userId: userId,
      requestedDataTypes: requestedDataTypes,
    );
  }
}

// request_export_usecase.dart
class RequestExportUseCase {
  final DataExportRepository _repository;

  RequestExportUseCase(this._repository);

  Future<ExportRequest> call({
    required String userId,
    required Set<DataType> dataTypes,
    required ExportFormat format,
  }) async {
    return await _repository.requestExport(
      userId: userId,
      dataTypes: dataTypes,
      format: format,
    );
  }
}
```

**Código Esperado:**
```dart
// check_export_availability_usecase.dart
class CheckExportAvailabilityUseCase {
  final DataExportRepository _repository;

  CheckExportAvailabilityUseCase(this._repository);

  Future<Either<Failure, ExportAvailabilityResult>> call({
    required String userId,
    required Set<DataType> requestedDataTypes,
  }) async {
    return await _repository.checkExportAvailability(
      userId: userId,
      requestedDataTypes: requestedDataTypes,
    );
  }
}

// request_export_usecase.dart
class RequestExportUseCase {
  final DataExportRepository _repository;

  RequestExportUseCase(this._repository);

  Future<Either<Failure, ExportRequest>> call({
    required String userId,
    required Set<DataType> dataTypes,
    required ExportFormat format,
  }) async {
    // Pode adicionar validações antes de chamar o repository
    if (dataTypes.isEmpty) {
      return const Left(ValidationFailure(
        'Selecione ao menos um tipo de dado para exportar',
        code: 'EMPTY_DATA_TYPES',
      ));
    }

    return await _repository.requestExport(
      userId: userId,
      dataTypes: dataTypes,
      format: format,
    );
  }
}
```

---

### #4: Estado Mutable em Repository [THREAD SAFETY]

**Severidade:** 🟡 IMPORTANTE  
**Localização:** `data/repositories/data_export_repository_impl.dart` (linhas 11-13)

**Problema:**
Uso de campos estáticos mutáveis para controle de estado.

**Código Problemático:**
```dart
class DataExportRepositoryImpl implements DataExportRepository {
  final PlantsExportDataSource _plantsDataSource;
  final SettingsExportDataSource _settingsDataSource;
  final ExportFileGenerator _fileGenerator;
  static const Duration _exportCooldown = Duration(hours: 1);
  static DateTime? _lastExportTime; // ❌ Static mutable
  static final Map<String, ExportRequest> _exportRequests = {}; // ❌ Static mutable
```

**Problemas:**
1. **Thread-unsafe:** Múltiplas instâncias compartilham o mesmo estado
2. **Testes difíceis:** Estado persiste entre testes
3. **Memory leak potencial:** Map crescendo indefinidamente
4. **Violação de DI:** Estado deveria ser injetado (Hive, SharedPreferences)

**Solução Recomendada:**
```dart
class DataExportRepositoryImpl implements DataExportRepository {
  final PlantsExportDataSource _plantsDataSource;
  final SettingsExportDataSource _settingsDataSource;
  final ExportFileGenerator _fileGenerator;
  final IHiveRepository _hiveRepository; // ✅ Injetado
  static const Duration _exportCooldown = Duration(hours: 1);

  DataExportRepositoryImpl({
    required PlantsExportDataSource plantsDataSource,
    required SettingsExportDataSource settingsDataSource,
    required ExportFileGenerator fileGenerator,
    required IHiveRepository hiveRepository, // ✅ Dependency Injection
  }) : _plantsDataSource = plantsDataSource,
       _settingsDataSource = settingsDataSource,
       _fileGenerator = fileGenerator,
       _hiveRepository = hiveRepository;

  Future<DateTime?> _getLastExportTime() async {
    return await _hiveRepository.get<DateTime?>('last_export_time');
  }

  Future<void> _setLastExportTime(DateTime time) async {
    await _hiveRepository.put('last_export_time', time);
  }

  Future<Map<String, ExportRequest>> _getExportRequests() async {
    final stored = await _hiveRepository.get<Map<dynamic, dynamic>>(
      'export_requests',
    );
    if (stored == null) return {};
    
    return stored.map((key, value) => 
      MapEntry(key.toString(), ExportRequest.fromJson(value))
    );
  }

  Future<void> _saveExportRequest(ExportRequest request) async {
    final requests = await _getExportRequests();
    requests[request.id] = request;
    await _hiveRepository.put('export_requests', requests);
  }
}
```

---

## 🟡 ISSUES IMPORTANTES

### #5: Duplicação de Notifiers [CODE QUALITY]

**Severidade:** 🟡 IMPORTANTE  
**Localização:** `presentation/providers/` e `presentation/notifiers/`

**Problema:**
Existem DOIS arquivos implementando o mesmo notifier:
1. `data_export_provider.dart` (405 linhas) - com Freezed State
2. `data_export_notifier.dart` (472 linhas) - com classe manual

**Análise:**

**data_export_provider.dart:**
```dart
@freezed
class DataExportState with _$DataExportState {
  const factory DataExportState({
    @Default([]) List<ExportRequest> exportHistory,
    @Default(ExportProgress.initial()) ExportProgress currentProgress,
    ExportAvailabilityResult? availabilityResult,
    @Default(false) bool isLoading,
    String? error,
  }) = _DataExportState;
}

@riverpod
class DataExportNotifier extends _$DataExportNotifier {
  @override
  DataExportState build() {
    // ... implementação síncrona
    initialize();
    return const DataExportState();
  }
}
```

**data_export_notifier.dart:**
```dart
class DataExportState {
  final ExportProgress currentProgress;
  final ExportAvailabilityResult? availabilityResult;
  final List<ExportRequest> exportHistory;
  final bool isLoading;
  final String? error;

  const DataExportState({/* ... */});
  
  DataExportState copyWith({/* ... */}) {
    return DataExportState(/* ... */);
  }
}

@riverpod
class DataExportNotifier extends _$DataExportNotifier {
  @override
  Future<DataExportState> build() async {
    // ... implementação assíncrona
    try {
      final history = await _getHistoryUseCase(_currentUserId);
      return DataExportState(exportHistory: history);
    } catch (e) {
      return DataExportState(error: 'Erro ao inicializar: ${e.toString()}');
    }
  }
}
```

**Diferenças Críticas:**
- Provider: build **síncrono**, state com Freezed
- Notifier: build **assíncrono**, state manual
- Provider: usa `state = state.copyWith()`
- Notifier: usa `state = AsyncValue.data(currentState.copyWith())`

**Recomendação:**
Manter APENAS `data_export_notifier.dart` (versão assíncrona) e remover `data_export_provider.dart`. A versão assíncrona é mais robusta pois:
1. Carrega histórico inicial corretamente
2. Trata erros de inicialização
3. Usa AsyncValue<T> (padrão Riverpod)

---

### #6: DataExportPage muito extenso [MAINTAINABILITY]

**Severidade:** 🟡 IMPORTANTE  
**Localização:** `presentation/pages/data_export_page.dart` (635 linhas)

**Problema:**
Arquivo ultrapassa o limite de 500 linhas estabelecido no monorepo.

**Recomendação:**
Extrair para widgets especializados:
```
presentation/
└── widgets/
    ├── export_history_section.dart (histórico de exports)
    ├── export_request_form.dart (formulário de solicitação)
    ├── export_availability_banner.dart (banner de disponibilidade)
    └── export_statistics_card.dart (estatísticas de dados)
```

---

### #7: Datasources lançam Exceptions [ERROR HANDLING]

**Severidade:** 🟡 IMPORTANTE  
**Localização:** `data/datasources/local/plants_export_datasource.dart`

**Problema:**
Datasources retornam `Either<Failure, T>` dos repositories mas convertem para `Exception`.

**Código Atual:**
```dart
@override
Future<List<PlantExportData>> getUserPlantsData(String userId) async {
  try {
    final plantsResult = await _plantsRepository.getPlants();

    return plantsResult.fold(
      (failure) =>
          throw Exception('Erro ao buscar plantas: ${failure.message}'), // ❌
      (plants) =>
          plants.map((plant) => PlantExportData(/* ... */)).toList(),
    );
  } catch (e) {
    throw Exception('Erro ao buscar dados de plantas: ${e.toString()}'); // ❌
  }
}
```

**Problema:**
1. Perde informação do tipo específico de Failure
2. Mensagens de erro menos precisas
3. Não permite tratamento diferenciado por tipo de erro

**Solução Recomendada:**
```dart
abstract class PlantsExportDataSource {
  Future<Either<Failure, List<PlantExportData>>> getUserPlantsData(String userId);
  Future<Either<Failure, List<TaskExportData>>> getUserTasksData(String userId);
  // ...
}

class PlantsExportLocalDataSource implements PlantsExportDataSource {
  @override
  Future<Either<Failure, List<PlantExportData>>> getUserPlantsData(
    String userId,
  ) async {
    try {
      final plantsResult = await _plantsRepository.getPlants();

      return plantsResult.fold(
        (failure) => Left(failure), // ✅ Preserva o tipo de falha
        (plants) {
          final exportData = plants
            .map((plant) => PlantExportData(/* ... */))
            .toList();
          return Right(exportData);
        },
      );
    } catch (e) {
      return Left(UnknownFailure(
        'Erro ao buscar dados de plantas',
        details: e,
      ));
    }
  }
}
```

---

## 🟢 PONTOS POSITIVOS

### ✅ Entities Bem Modeladas

**Localização:** `domain/entities/export_request.dart`

A modelagem das entidades está excelente:
- ✅ Uso correto de `Equatable`
- ✅ Enums com `displayName`
- ✅ Factory constructors para casos comuns
- ✅ Métodos utilitários (`isExpired`, `expirationDate`)
- ✅ Documentação clara

**Exemplo:**
```dart
enum ExportFormat {
  json('JSON'),
  csv('CSV'),
  xml('XML'),
  pdf('PDF');

  const ExportFormat(this.displayName);
  final String displayName;
}

class ExportRequest extends Equatable {
  // ... campos ...
  
  bool get isExpired {
    if (completionDate == null) return false;
    return DateTime.now().difference(completionDate!).inDays > 30;
  }

  DateTime? get expirationDate {
    if (completionDate == null) return null;
    return completionDate!.add(const Duration(days: 30));
  }
}
```

---

### ✅ Separação de Datasources

**Localização:** `data/datasources/local/`

Excelente separação de responsabilidades:
- `plants_export_datasource.dart` - Dados de plantas, tarefas, espaços
- `settings_export_datasource.dart` - Configurações do usuário
- `export_file_generator.dart` - Geração de arquivos (JSON, CSV, XML, PDF)

Cada datasource tem responsabilidade única e clara.

---

### ✅ Riverpod com Code Generation

**Localização:** `presentation/notifiers/data_export_notifier.dart`

Uso correto de Riverpod:
```dart
@riverpod
class DataExportNotifier extends _$DataExportNotifier {
  @override
  Future<DataExportState> build() async {
    // ... inicialização
  }
}

@riverpod
CheckExportAvailabilityUseCase checkExportAvailabilityUseCase(Ref ref) {
  return GetIt.instance<CheckExportAvailabilityUseCase>();
}
```

---

### ✅ Compliance LGPD

**Localização:** Repository implementation

Implementação de requisitos LGPD:
- ✅ Rate limiting (1 export por hora)
- ✅ Expiração automática (30 dias)
- ✅ Controle de disponibilidade
- ✅ Histórico de exportações
- ✅ Metadata de compliance

```dart
static const Duration _exportCooldown = Duration(hours: 1);

bool get isExpired {
  if (completionDate == null) return false;
  return DateTime.now().difference(completionDate!).inDays > 30;
}

metadata: const {
  'app_version': '1.0.0',
  'platform': 'Flutter',
  'compliance': 'LGPD',
},
```

---

## 📋 Plano de Ação Recomendado

### Prioridade 1 - CRÍTICO (Implementar Imediatamente)

#### ✅ Task 1.1: Adicionar Either<Failure, T> no Repository Interface
**Arquivo:** `domain/repositories/data_export_repository.dart`  
**Estimativa:** 30 minutos  
**Impacto:** Alto - Base para todo error handling

#### ✅ Task 1.2: Implementar Either<Failure, T> no Repository Implementation
**Arquivo:** `data/repositories/data_export_repository_impl.dart`  
**Estimativa:** 2 horas  
**Impacto:** Alto - Corrige error handling principal

#### ✅ Task 1.3: Atualizar Use Cases para Either<Failure, T>
**Arquivos:** Todos em `domain/usecases/`  
**Estimativa:** 1 hora  
**Impacto:** Alto - Consistência arquitetural

#### ✅ Task 1.4: Atualizar Notifier para consumir Either
**Arquivo:** `presentation/notifiers/data_export_notifier.dart`  
**Estimativa:** 1.5 horas  
**Impacto:** Alto - UI error handling correto

### Prioridade 2 - IMPORTANTE (Próximo Sprint)

#### ✅ Task 2.1: Remover estado estático do Repository
**Arquivo:** `data/repositories/data_export_repository_impl.dart`  
**Estimativa:** 3 horas  
**Impacto:** Médio - Thread safety e testabilidade

#### ✅ Task 2.2: Consolidar Notifiers (remover duplicação)
**Arquivos:** `presentation/providers/data_export_provider.dart` (remover)  
**Estimativa:** 30 minutos  
**Impacto:** Médio - Code quality

#### ✅ Task 2.3: Refatorar DataExportPage (< 500 linhas)
**Arquivo:** `presentation/pages/data_export_page.dart`  
**Estimativa:** 2 horas  
**Impacto:** Médio - Maintainability

#### ✅ Task 2.4: Atualizar Datasources para Either
**Arquivo:** `data/datasources/local/plants_export_datasource.dart`  
**Estimativa:** 1.5 horas  
**Impacto:** Médio - Consistency

### Prioridade 3 - DESEJÁVEL (Backlog)

#### ⭐ Task 3.1: Adicionar testes unitários de repository
**Estimativa:** 4 horas  
**Cobertura:** 80%+

#### ⭐ Task 3.2: Adicionar testes de integração
**Estimativa:** 3 horas

#### ⭐ Task 3.3: Melhorar documentação inline
**Estimativa:** 1 hora

---

## 📊 Métricas de Qualidade

### Antes das Melhorias
```
✅ Estrutura em Camadas: 10/10
❌ Error Handling: 3/10
✅ Riverpod Usage: 9/10
⚠️ SOLID Compliance: 6/10
⚠️ Code Size: 7/10
⚠️ Thread Safety: 5/10

SCORE TOTAL: 7.0/10
```

### Após Implementação do Plano
```
✅ Estrutura em Camadas: 10/10
✅ Error Handling: 10/10
✅ Riverpod Usage: 10/10
✅ SOLID Compliance: 9/10
✅ Code Size: 9/10
✅ Thread Safety: 9/10

SCORE ESPERADO: 9.5/10 (Gold Standard)
```

---

## 🎯 Comparação com Gold Standard

### Feature Device Management (Referência)
```dart
// ✅ Repository com Either
abstract class DeviceRepository {
  Future<Either<Failure, List<DeviceModel>>> getUserDevices(String userId);
  Future<Either<Failure, DeviceModel>> validateDevice({
    required String userId,
    required DeviceModel device,
  });
}

// ✅ Use Case com Either e validação
class GetUserDevicesUseCase {
  Future<Either<Failure, List<DeviceModel>>> call([
    GetUserDevicesParams? params,
  ]) async {
    try {
      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final result = await _deviceRepository.getUserDevices(userId);
      return result.fold(
        (failure) => Left(failure),
        (devices) {
          // Lógica de filtro/ordenação
          return Right(sortedDevices);
        }
      );
    } catch (e) {
      return Left(ServerFailure(
        'Erro ao buscar dispositivos',
        code: 'GET_USER_DEVICES_ERROR',
        details: e,
      ));
    }
  }
}
```

### Data Export (Atual)
```dart
// ❌ Repository sem Either
abstract class DataExportRepository {
  Future<ExportRequest> requestExport({
    required String userId,
    required Set<DataType> dataTypes,
    required ExportFormat format,
  });
}

// ❌ Use Case sem validação ou error handling
class RequestExportUseCase {
  Future<ExportRequest> call({
    required String userId,
    required Set<DataType> dataTypes,
    required ExportFormat format,
  }) async {
    return await _repository.requestExport(
      userId: userId,
      dataTypes: dataTypes,
      format: format,
    );
  }
}
```

---

## 🔗 Referências

### Documentação Interna
- `.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md`
- `packages/core/lib/src/shared/utils/failure.dart`

### Features de Referência (Gold Standard)
- `apps/app-plantis/lib/features/device_management/` - Error handling exemplar
- `apps/app-plantis/lib/features/plants/` - Repository pattern correto
- `apps/app-plantis/lib/features/tasks/` - Use cases com validação

---

## ✅ Conclusão

A feature de exportação de dados está **bem estruturada** mas requer **correções críticas** no error handling para atingir o padrão gold standard do app-plantis.

**Próximos Passos:**
1. ✅ Implementar Either<Failure, T> em toda a camada de domínio e dados
2. ✅ Remover estado estático do repository
3. ✅ Consolidar notifiers (manter apenas versão assíncrona)
4. ⭐ Adicionar cobertura de testes adequada

**Impacto Esperado:**
- 🔒 Maior robustez e confiabilidade
- 🧪 Maior testabilidade
- 📝 Código mais manutenível
- ✅ Conformidade com padrões do monorepo

---

**Gerado em:** 30/10/2024  
**Versão do Relatório:** 1.0  
**Próxima Revisão:** Após implementação das Tasks de Prioridade 1
