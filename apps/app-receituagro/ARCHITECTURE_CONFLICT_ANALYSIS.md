# Análise de Conflitos Arquiteturais - app-receituagro

## Sumário Executivo

**Status**: CRÍTICO - Violações arquiteturais severas detectadas
**Complexidade**: ALTA - Múltiplas camadas duplicadas com responsabilidades sobrepostas
**Impacto**: Bug funcional (diagnósticos não aparecem) + Technical Debt alto
**Esforço de Refatoração**: 12-16 horas
**Modelo Utilizado**: Sonnet (análise profunda arquitetural)

---

## 1. Mapa de Dependências Atual

```
┌─────────────────────────────────────────────────────────────────────┐
│                     FLUXO DE NAVEGAÇÃO                               │
└─────────────────────────────────────────────────────────────────────┘

Home → Lista Defensivos → DetalheDefensivoPage (4 tabs)
                              └─ Tab "Diagnósticos" → DetalheDiagnosticoPage


┌─────────────────────────────────────────────────────────────────────┐
│                   ARQUITETURA PROBLEMÁTICA                           │
└─────────────────────────────────────────────────────────────────────┘

features/
├── defensivos/                       ✅ OK - Lista de defensivos
│   ├── domain/
│   ├── data/
│   └── presentation/
│
├── DetalheDefensivos/                ❌ PROBLEMA CRÍTICO
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── defensivo_entity.dart       [DUPLICADO]
│   │   │   └── diagnostico_entity.dart     [DUPLICADO - Estrutura Simplificada]
│   │   ├── repositories/
│   │   │   ├── i_defensivo_details_repository.dart
│   │   │   └── diagnostico_repository.dart [DUPLICADO - Interface diferente]
│   │   └── usecases/
│   │       ├── get_diagnosticos_by_defensivo_usecase.dart [DUPLICADO]
│   │       └── get_diagnosticos_usecase.dart              [DUPLICADO]
│   ├── data/
│   │   ├── repositories/
│   │   │   ├── defensivo_details_repository_impl.dart
│   │   │   └── diagnostico_repository_impl.dart     [WRAPPER - Não faz nada real]
│   │   └── mappers/
│   │       └── diagnostico_mapper.dart              [DUPLICADO - Conversão simplificada]
│   └── presentation/
│       ├── providers/
│       │   ├── defensivo_details_notifier.dart
│       │   └── detalhe_defensivo_notifier.dart
│       └── widgets/
│           └── diagnosticos_tab_widget.dart   [USA diagnosticosNotifierProvider]
│
├── diagnosticos/                     ✅ IMPLEMENTAÇÃO REAL
│   ├── domain/
│   │   ├── entities/
│   │   │   └── diagnostico_entity.dart      [COMPLETO - Value Objects]
│   │   ├── repositories/
│   │   │   └── i_diagnosticos_repository.dart [INTERFACE COMPLETA]
│   │   └── usecases/
│   │       └── get_diagnosticos_usecase.dart [8 USE CASES REAIS]
│   ├── data/
│   │   ├── repositories/
│   │   │   └── diagnosticos_repository_impl.dart [ACESSA HIVE - REAL]
│   │   └── mappers/
│   │       └── diagnostico_mapper.dart          [CONVERSÃO COMPLETA]
│   └── presentation/
│       └── providers/
│           └── diagnosticos_notifier.dart       [PROVIDER USADO PELA UI]
│
└── detalhes_diagnostico/             ❌ LOCALIZAÇÃO ERRADA
    └── presentation/
        ├── pages/
        │   └── detalhe_diagnostico_page.dart    [DEVERIA ESTAR EM diagnosticos/]
        ├── providers/
        │   └── detalhe_diagnostico_notifier.dart
        └── widgets/


┌─────────────────────────────────────────────────────────────────────┐
│                  FLUXO DE DADOS (PROBLEMÁTICO)                       │
└─────────────────────────────────────────────────────────────────────┘

1. DetalheDefensivoPage._loadData()
   ↓
2. ref.read(diagnosticosNotifierProvider.notifier)
   .getDiagnosticosByDefensivo(idReg)
   ↓
3. diagnosticosNotifier usa:
   - GetDiagnosticosByDefensivoUseCase (features/diagnosticos)
   - IDiagnosticosRepository (features/diagnosticos)
   ↓
4. DiagnosticosRepositoryImpl.getByDefensivo()
   → DiagnosticoHiveRepository.findByDefensivo()
   → ✅ Retorna 81 diagnósticos
   ↓
5. diagnosticosNotifier atualiza state
   - state.allDiagnosticos = 81 ✅
   - state.contextoDefensivo = idDefensivo ❌ PROBLEMA AQUI
   ↓
6. DiagnosticosTabWidget lê:
   - diagnosticosNotifier.diagnosticos getter
   → ❌ CONTEXTO SE PERDE - retorna []


┌─────────────────────────────────────────────────────────────────────┐
│               INJEÇÃO DE DEPENDÊNCIAS (CONFUSA)                      │
└─────────────────────────────────────────────────────────────────────┘

injection_container.dart:

// CORRETO - Features/diagnosticos registrado
sl.registerLazySingleton<IDiagnosticosRepository>(
  () => DiagnosticosRepositoryImpl(sl<DiagnosticoHiveRepository>()),
);

// PROBLEMA - DetalheDefensivos registra seu próprio repository
// mas usa o de diagnosticos por baixo
initDefensivoDetailsDI() {
  sl.registerLazySingleton<IDefensivoDetailsRepository>(
    () => DefensivoDetailsRepositoryImpl(),  // Recebe IDiagnosticosRepository
  );
}
```

---

## 2. Conflitos Críticos Identificados

### 2.1. Duplicação de Entidades (CRÍTICO)

**DetalheDefensivos/domain/entities/diagnostico_entity.dart** (113 linhas):
```dart
class DiagnosticoEntity extends Equatable {
  final String id;
  final String idDefensivo;
  final String? nomeDefensivo;
  final String? nomeCultura;
  final String? nomePraga;
  final String dosagem;                    // ❌ String simples
  final String? unidadeDosagem;
  final String? modoAplicacao;
  final int? intervaloDias;
  final String ingredienteAtivo;
  final String cultura;
  final String grupo;
  // ... getters simples
}
```

**diagnosticos/domain/entities/diagnostico_entity.dart** (583 linhas):
```dart
class DiagnosticoEntity {
  final String id;
  final String idDefensivo;
  final String idCultura;               // ✅ ID obrigatório
  final String idPraga;                 // ✅ ID obrigatório
  final DosagemEntity dosagem;          // ✅ Value Object
  final AplicacaoEntity aplicacao;      // ✅ Value Object
  // + Value Objects:
  // - DosagemEntity (dosagem mínima/máxima, validação)
  // - AplicacaoEntity (terrestre + aérea)
  // - DiagnosticoCompletude (enum)
  // - DiagnosticosStats
  // - DiagnosticoSearchFilters
}
```

**Impacto**:
- Estruturas de dados incompatíveis
- Conversão lossy (perde informações de aplicação, dosagem mínima)
- Dois modelos mentais diferentes para o mesmo conceito

---

### 2.2. Duplicação de Repositories (CRÍTICO)

**DetalheDefensivos/data/repositories/diagnostico_repository_impl.dart** (50 linhas):
```dart
class DiagnosticoRepositoryImpl implements DiagnosticoRepository {
  final IDiagnosticosRepository _repository;

  @override
  ResultFuture<List<DiagnosticoEntity>> getDiagnosticosByDefensivo(String idDefensivo) async {
    return await _repository.getByDefensivo(idDefensivo);  // ❌ WRAPPER INÚTIL
  }
}
```

**diagnosticos/data/repositories/diagnosticos_repository_impl.dart** (573 linhas):
```dart
class DiagnosticosRepositoryImpl implements IDiagnosticosRepository {
  final DiagnosticoHiveRepository _hiveRepository;  // ✅ ACESSO REAL AO HIVE

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByDefensivo(String idDefensivo) async {
    final diagnosticosHive = await _hiveRepository.findByDefensivo(idDefensivo);
    final entities = diagnosticosHive.map((hive) => DiagnosticoMapper.fromHive(hive)).toList();
    return Right(entities);
  }

  // + 15 métodos especializados:
  // - getByTriplaCombinacao
  // - searchWithFilters
  // - getStatistics
  // - validarCompatibilidade
  // - getSimilarDiagnosticos
  // ...
}
```

**Problema**: `DetalheDefensivos` criou um wrapper que apenas delega para `diagnosticos`, mas usa tipos incompatíveis.

---

### 2.3. Duplicação de Mappers (ALTO IMPACTO)

**DetalheDefensivos/data/mappers/diagnostico_mapper.dart**:
```dart
class DiagnosticoMapper {
  static DiagnosticoEntity fromDiagnosticosEntity(diag_entity.DiagnosticoEntity entity) {
    return DiagnosticoEntity(
      dosagem: entity.dosagem.displayDosagem,     // ❌ Perde informação estruturada
      ingredienteAtivo: entity.idDefensivo,       // ❌ Mapeia errado
      cultura: entity.nomeCultura ?? 'Não especificado',  // ❌ Fallback hardcoded
      grupo: entity.nomePraga ?? 'Praga não identificada',
    );
  }

  // ✅ Método correto (mas não é usado):
  static Future<DiagnosticoEntity> fromDiagnosticosEntityWithResolution(...)
}
```

**diagnosticos/data/mappers/diagnostico_mapper.dart**:
```dart
class DiagnosticoMapper {
  static DiagnosticoEntity fromHive(DiagnosticoHive hive) {
    return DiagnosticoEntity(
      dosagem: DosagemEntity(                     // ✅ Value Object preservado
        dosagemMinima: double.tryParse(hive.dsMin ?? '0'),
        dosagemMaxima: double.tryParse(hive.dsMax) ?? 0.0,
        unidadeMedida: hive.um,
      ),
      aplicacao: AplicacaoEntity(                 // ✅ Informação completa
        terrestre: ...,
        aerea: ...,
      ),
    );
  }
}
```

**Impacto**: Dados empobrecidos na conversão, perdendo informações críticas de aplicação.

---

### 2.4. Duplicação de Use Cases (MÉDIO)

**DetalheDefensivos tem 2 use cases duplicados**:

1. `GetDiagnosticosByDefensivoUseCase` (120 linhas com logs verbosos)
2. `GetDiagnosticosUsecase` (22 linhas wrapper simples)

**diagnosticos tem 8 use cases especializados**:

1. `GetDiagnosticosUseCase`
2. `GetDiagnosticoByIdUseCase`
3. `GetRecomendacoesUseCase`
4. `GetDiagnosticosByDefensivoUseCase`
5. `GetDiagnosticosByCulturaUseCase`
6. `GetDiagnosticosByPragaUseCase`
7. `SearchDiagnosticosWithFiltersUseCase`
8. `GetDiagnosticoStatsUseCase`
9. `ValidateCompatibilidadeUseCase`
10. `SearchDiagnosticosByPatternUseCase`
11. `GetDiagnosticoFiltersDataUseCase`

**Problema**: Use cases duplicados com lógica ligeiramente diferente causam confusão.

---

### 2.5. Feature Mal Localizada

**detalhes_diagnostico/** deveria estar **dentro de diagnosticos/**:

```
❌ ATUAL:
features/
├── DetalheDefensivos/
├── diagnosticos/
└── detalhes_diagnostico/   # ← DESLOCADO

✅ CORRETO:
features/
├── defensivos/
│   └── presentation/pages/detalhe_defensivo_page.dart
└── diagnosticos/
    ├── domain/
    ├── data/
    └── presentation/
        ├── pages/
        │   ├── diagnosticos_list_page.dart
        │   └── detalhe_diagnostico_page.dart    # ← AQUI
        └── providers/
```

---

## 3. Análise de Responsabilidades (SRP Violations)

### 3.1. DetalheDefensivos - Violação Massiva

**Responsabilidades Misturadas**:
1. ✅ **Legítima**: Exibir detalhes de um defensivo específico
2. ❌ **Invasiva**: Gerenciar diagnósticos (deveria usar `diagnosticos/` como serviço)
3. ❌ **Invasiva**: Comentários (já tem feature separada)
4. ❌ **Invasiva**: Favoritos (já tem feature separada)
5. ❌ **Invasiva**: Tecnologia (deveria estar em `defensivos/`)

**Arquitetura Correta**:

```dart
// DetalheDefensivos deveria SER APENAS PRESENTATION LAYER:
features/
└── defensivos/
    ├── domain/          # ✅ Manter entidades e lógica de defensivos
    ├── data/            # ✅ Manter repositories de defensivos
    └── presentation/
        ├── pages/
        │   ├── home_defensivos_page.dart
        │   └── detalhe_defensivo_page.dart      # ✅ MOVER AQUI
        ├── providers/
        │   └── detalhe_defensivo_notifier.dart  # ✅ MOVER AQUI
        └── widgets/
            ├── diagnosticos_tab_widget.dart     # ✅ USA diagnosticos como serviço
            ├── comentarios_tab_widget.dart      # ✅ USA comentarios como serviço
            └── tecnologia_tab_widget.dart
```

---

### 3.2. Violação DRY (Don't Repeat Yourself)

**Código Duplicado Detectado**:

| Arquivo | Localização 1 | Localização 2 | Linhas |
|---------|---------------|---------------|--------|
| `diagnostico_entity.dart` | DetalheDefensivos | diagnosticos | ~113 vs 583 |
| `diagnostico_repository.dart` | DetalheDefensivos | diagnosticos | Interface diferente |
| `diagnostico_mapper.dart` | DetalheDefensivos | diagnosticos | ~118 vs 83 |
| `get_diagnosticos_by_defensivo_usecase.dart` | DetalheDefensivos | diagnosticos | ~120 vs 90 |

**Estimativa**: ~400 linhas de código duplicado/obsoleto

---

### 3.3. Violação OCP (Open/Closed Principle)

**Problema**: `DetalheDefensivos` não está aberto para extensão, está **reescrevendo** funcionalidade existente.

Cada vez que `diagnosticos/` adiciona uma feature (ex: filtros avançados, estatísticas), `DetalheDefensivos` precisa:
1. Duplicar a lógica
2. Atualizar seus próprios mappers
3. Atualizar suas próprias entidades
4. Riscar bugs de inconsistência

---

## 4. Causa Raiz do Bug Atual

### 4.1. Fluxo de Contexto Quebrado

**diagnosticos_notifier.dart (linhas 63-100)**:

```dart
class DiagnosticosNotifier {
  DiagnosticosState _state = DiagnosticosState.initial();

  Future<void> getDiagnosticosByDefensivo(String idDefensivo, ...) async {
    // 1. Busca diagnósticos
    final result = await _getDiagnosticosByDefensivoUseCase(params);

    result.fold(
      (failure) => ...,
      (diagnosticos) {
        // 2. Atualiza state
        _state = _state.copyWith(
          allDiagnosticos: diagnosticos,           // ✅ 81 diagnósticos
          contextoDefensivo: idDefensivo,         // ❌ STRING (não objeto)
          contextoConsulta: DiagnosticoContextoConsulta.defensivo,
        );
      },
    );
  }

  // 3. Getter que QUEBRA o contexto
  List<dynamic> get diagnosticos {
    // ❌ PROBLEMA: Comparação falha silenciosamente
    if (_state.contextoDefensivo != null && _state.currentFilters.cultura == null) {
      // Esta branch não retorna diagnósticos porque `cultura` está nula
      return [];
    }

    return _state.filteredDiagnosticos.isEmpty
        ? _state.allDiagnosticos     // ✅ Deveria entrar aqui mas não entra
        : _state.filteredDiagnosticos;
  }
}
```

**Root Cause**: Lógica condicional complexa no getter mistura conceitos de:
- Contexto de consulta (defensivo/cultura/praga)
- Filtros aplicados
- Estado de busca

---

### 4.2. Estado Complexo Demais

**diagnosticos_notifier.dart - State Class**:

```dart
class DiagnosticosState {
  final List<dynamic> allDiagnosticos;          // ❌ dynamic - Type unsafe
  final List<dynamic> filteredDiagnosticos;
  final List<dynamic> searchResults;

  final String? contextoDefensivo;              // ❌ String, deveria ser objeto
  final String? contextoCultura;
  final String? contextoPraga;
  final DiagnosticoContextoConsulta contextoConsulta;  // ❌ Enum separado

  final DiagnosticoSearchFilters currentFilters;
  final String? lastSearchQuery;
  final bool isSearchMode;
  final bool hasActiveFilters;

  // ... 8 propriedades de estado
}
```

**Problemas**:
1. **Type Safety**: `List<dynamic>` ao invés de `List<DiagnosticoEntity>`
2. **Contexto Fragmentado**: 3 strings + 1 enum para representar contexto
3. **Estado Derivado**: `hasActiveFilters` deveria ser computed property
4. **Responsabilidade Múltipla**: Mistura dados + estado de UI

---

## 5. Proposta de Refatoração

### 5.1. Estrutura Alvo

```
features/
├── defensivos/                          # ✅ Feature única de defensivos
│   ├── domain/
│   │   ├── entities/
│   │   │   └── defensivo_entity.dart
│   │   ├── repositories/
│   │   │   └── i_defensivos_repository.dart
│   │   └── usecases/
│   │       └── get_defensivo_details_usecase.dart
│   ├── data/
│   │   ├── repositories/
│   │   │   └── defensivos_repository_impl.dart
│   │   └── mappers/
│   │       └── defensivo_mapper.dart
│   └── presentation/
│       ├── pages/
│       │   ├── home_defensivos_page.dart
│       │   └── detalhe_defensivo_page.dart       # ✅ MOVIDO
│       ├── providers/
│       │   ├── defensivos_notifier.dart
│       │   └── detalhe_defensivo_notifier.dart   # ✅ MOVIDO
│       └── widgets/
│           ├── detalhe/                          # ✅ NOVO - Tabs organizadas
│           │   ├── info_tab_widget.dart
│           │   ├── diagnosticos_tab_widget.dart  # ✅ USA diagnosticos/
│           │   ├── tecnologia_tab_widget.dart
│           │   └── comentarios_tab_widget.dart   # ✅ USA comentarios/
│           └── lista/
│               └── defensivo_item_widget.dart
│
├── diagnosticos/                        # ✅ Feature única de diagnósticos
│   ├── domain/
│   │   ├── entities/
│   │   │   └── diagnostico_entity.dart           # ✅ ÚNICA VERDADE
│   │   ├── repositories/
│   │   │   └── i_diagnosticos_repository.dart    # ✅ ÚNICA INTERFACE
│   │   └── usecases/                             # ✅ 11 use cases
│   │       ├── get_diagnosticos_usecase.dart
│   │       ├── get_diagnostico_by_id_usecase.dart
│   │       ├── get_by_defensivo_usecase.dart     # ✅ ÚNICA IMPLEMENTAÇÃO
│   │       └── ...
│   ├── data/
│   │   ├── repositories/
│   │   │   └── diagnosticos_repository_impl.dart # ✅ ÚNICA IMPLEMENTAÇÃO
│   │   └── mappers/
│   │       └── diagnostico_mapper.dart           # ✅ ÚNICO MAPPER
│   └── presentation/
│       ├── pages/
│       │   ├── diagnosticos_list_page.dart
│       │   └── detalhe_diagnostico_page.dart     # ✅ MOVIDO
│       ├── providers/
│       │   ├── diagnosticos_notifier.dart        # ✅ SIMPLIFICADO
│       │   └── detalhe_diagnostico_notifier.dart
│       └── widgets/
│           ├── diagnostico_card_widget.dart
│           └── diagnostico_filter_widget.dart
│
└── comentarios/                         # ✅ Feature separada (OK)
    └── ...

❌ DELETAR COMPLETAMENTE:
- features/DetalheDefensivos/           # Tudo movido para defensivos/
- features/detalhes_diagnostico/        # Movido para diagnosticos/presentation/pages/
```

---

### 5.2. Refatoração do DiagnosticosNotifier

**ANTES (Complexo - 8 propriedades de estado)**:
```dart
class DiagnosticosState {
  final List<dynamic> allDiagnosticos;
  final List<dynamic> filteredDiagnosticos;
  final List<dynamic> searchResults;
  final String? contextoDefensivo;
  final String? contextoCultura;
  final String? contextoPraga;
  final DiagnosticoContextoConsulta contextoConsulta;
  final DiagnosticoSearchFilters currentFilters;
  // ...

  List<dynamic> get diagnosticos {
    // ❌ Lógica complexa com múltiplas condições
  }
}
```

**DEPOIS (Simples - 3 propriedades + computed)**:
```dart
class DiagnosticosState {
  final List<DiagnosticoEntity> diagnosticos;        // ✅ Type-safe
  final DiagnosticoSearchFilters? activeFilters;     // ✅ Opcional e claro
  final String? searchQuery;                         // ✅ Simples

  // ✅ Computed properties (sem estado duplicado)
  bool get hasFilters => activeFilters != null && activeFilters!.hasFilters;
  bool get isSearchMode => searchQuery != null && searchQuery!.isNotEmpty;
  List<DiagnosticoEntity> get displayDiagnosticos {
    var result = diagnosticos;

    // Aplicar filtros se existirem
    if (hasFilters) {
      result = _applyFilters(result, activeFilters!);
    }

    // Aplicar busca se existir
    if (isSearchMode) {
      result = _applySearch(result, searchQuery!);
    }

    return result;
  }

  // ✅ Métodos privados para cada transformação
  List<DiagnosticoEntity> _applyFilters(...) { ... }
  List<DiagnosticoEntity> _applySearch(...) { ... }
}
```

**Benefícios**:
- ✅ Type-safe (`List<DiagnosticoEntity>` ao invés de `List<dynamic>`)
- ✅ Single Source of Truth (sem `contextoDefensivo` + `contextoConsulta` separados)
- ✅ Computed properties ao invés de estado duplicado
- ✅ Lógica isolada em métodos privados (testável)
- ✅ Imutabilidade mantida

---

### 5.3. Injeção de Dependências Simplificada

**ANTES**:
```dart
// injection_container.dart (linhas 245-296)

// Registra diagnosticos (correto)
sl.registerLazySingleton<IDiagnosticosRepository>(...);
sl.registerLazySingleton<GetDiagnosticosUseCase>(...);
// ... 10 use cases

// ❌ Registra DetalheDefensivos separadamente
initDefensivoDetailsDI();  // Cria wrapper desnecessário
```

**DEPOIS**:
```dart
// injection_container.dart

// ✅ Apenas diagnosticos (feature completa)
sl.registerLazySingleton<IDiagnosticosRepository>(
  () => DiagnosticosRepositoryImpl(sl<DiagnosticoHiveRepository>()),
);

// ✅ Use cases específicos
sl.registerLazySingleton<GetDiagnosticosByDefensivoUseCase>(
  () => GetDiagnosticosByDefensivoUseCase(sl<IDiagnosticosRepository>()),
);

// ✅ Defensivos usa diagnosticos como SERVIÇO (sem duplicação)
// Nenhum registro especial necessário - apenas injeta via provider
```

---

## 6. Plano de Execução Passo-a-Passo

### Fase 1: Preparação (1-2h)

1. **Criar branch de refatoração**
   ```bash
   git checkout -b refactor/consolidate-diagnosticos-architecture
   ```

2. **Backup de testes existentes**
   ```bash
   # Copiar testes para referência
   cp -r test/features/DetalheDefensivos test/features/_backup_detalhes_defensivos
   cp -r test/features/detalhes_diagnostico test/features/_backup_detalhes_diagnostico
   ```

3. **Análise de impacto**
   ```bash
   # Buscar todas as importações de DetalheDefensivos
   grep -r "features/DetalheDefensivos" lib/ --include="*.dart"
   grep -r "features/detalhes_diagnostico" lib/ --include="*.dart"
   ```

---

### Fase 2: Consolidação de Entidades (2-3h)

1. **Deletar entidade duplicada**
   ```bash
   rm lib/features/DetalheDefensivos/domain/entities/diagnostico_entity.dart
   rm lib/features/DetalheDefensivos/data/mappers/diagnostico_mapper.dart
   ```

2. **Atualizar imports**
   - Substituir todas as referências para usar `diagnosticos/domain/entities/diagnostico_entity.dart`
   - Arquivos afetados: ~15 arquivos

3. **Atualizar UI widgets para usar entidade completa**
   - `DiagnosticosTabWidget`: Usar `DiagnosticoEntity` com Value Objects
   - `diagnosticos_defensivos_components.dart`: Adaptar para novos campos

---

### Fase 3: Consolidação de Repositories (2-3h)

1. **Deletar repositories duplicados**
   ```bash
   rm lib/features/DetalheDefensivos/data/repositories/diagnostico_repository_impl.dart
   rm lib/features/DetalheDefensivos/domain/repositories/diagnostico_repository.dart
   ```

2. **Atualizar `IDefensivoDetailsRepository`**
   ```dart
   abstract class IDefensivoDetailsRepository {
     Future<Either<Failure, DefensivoDetailsEntity?>> getDefensivoByName(String name);
     // ❌ REMOVER: Future<Either<Failure, List<DiagnosticoEntity>>> getDiagnosticosByDefensivo(...);
     Future<Either<Failure, bool>> isFavorited(String defensivoId);
     Future<Either<Failure, bool>> toggleFavorite(...);
   }
   ```

3. **Atualizar `DefensivoDetailsRepositoryImpl`**
   ```dart
   class DefensivoDetailsRepositoryImpl implements IDefensivoDetailsRepository {
     final FitossanitarioHiveRepository _fitossanitarioRepository;
     final FavoritosHiveRepository _favoritosRepository;
     // ❌ REMOVER: final IDiagnosticosRepository _diagnosticosRepository;

     // Métodos de diagnósticos REMOVIDOS
   }
   ```

---

### Fase 4: Consolidação de Use Cases (1-2h)

1. **Deletar use cases duplicados**
   ```bash
   rm lib/features/DetalheDefensivos/domain/usecases/get_diagnosticos_by_defensivo_usecase.dart
   rm lib/features/DetalheDefensivos/domain/usecases/get_diagnosticos_usecase.dart
   ```

2. **Usar diretamente os use cases de `diagnosticos/`**
   - Providers devem injetar `GetDiagnosticosByDefensivoUseCase` de `diagnosticos/`

---

### Fase 5: Refatoração do DiagnosticosNotifier (3-4h)

1. **Simplificar state class**
   ```dart
   // diagnosticos/presentation/providers/diagnosticos_notifier.dart

   class DiagnosticosState {
     final List<DiagnosticoEntity> diagnosticos;
     final DiagnosticoSearchFilters? activeFilters;
     final String? searchQuery;
     final bool isLoading;
     final String? errorMessage;

     const DiagnosticosState({
       this.diagnosticos = const [],
       this.activeFilters,
       this.searchQuery,
       this.isLoading = false,
       this.errorMessage,
     });

     // Computed properties
     bool get hasFilters => activeFilters?.hasFilters == true;
     bool get isSearchMode => searchQuery?.isNotEmpty == true;

     List<DiagnosticoEntity> get displayDiagnosticos {
       var result = diagnosticos;
       if (hasFilters) result = _applyFilters(result);
       if (isSearchMode) result = _applySearch(result);
       return result;
     }
   }
   ```

2. **Refatorar método `getDiagnosticosByDefensivo`**
   ```dart
   Future<void> getDiagnosticosByDefensivo(String idDefensivo) async {
     state = AsyncValue.loading();

     final result = await _getDiagnosticosByDefensivoUseCase(
       GetDiagnosticosByDefensivoParams(idDefensivo: idDefensivo),
     );

     state = result.fold(
       (failure) => AsyncValue.error(failure, StackTrace.current),
       (diagnosticos) => AsyncValue.data(
         DiagnosticosState(diagnosticos: diagnosticos),
       ),
     );
   }
   ```

3. **Escrever testes unitários**
   ```dart
   // test/features/diagnosticos/presentation/providers/diagnosticos_notifier_test.dart

   test('getDiagnosticosByDefensivo retorna diagnósticos corretamente', () async {
     // Arrange
     when(() => mockUseCase(any())).thenAnswer((_) async => Right(mockDiagnosticos));

     // Act
     await container.read(diagnosticosNotifierProvider.notifier)
       .getDiagnosticosByDefensivo('defensivo-id');

     // Assert
     final state = container.read(diagnosticosNotifierProvider);
     expect(state.value!.diagnosticos, equals(mockDiagnosticos));
   });
   ```

---

### Fase 6: Reorganização de Pastas (2-3h)

1. **Mover DetalheDefensivoPage**
   ```bash
   mkdir -p lib/features/defensivos/presentation/pages
   mv lib/features/DetalheDefensivos/detalhe_defensivo_page.dart \
      lib/features/defensivos/presentation/pages/
   ```

2. **Mover widgets de tabs**
   ```bash
   mkdir -p lib/features/defensivos/presentation/widgets/detalhe
   mv lib/features/DetalheDefensivos/presentation/widgets/diagnosticos_tab_widget.dart \
      lib/features/defensivos/presentation/widgets/detalhe/
   # Repetir para outros widgets
   ```

3. **Mover DetalheDiagnosticoPage**
   ```bash
   mv lib/features/detalhes_diagnostico/presentation/pages/detalhe_diagnostico_page.dart \
      lib/features/diagnosticos/presentation/pages/
   ```

4. **Atualizar imports em todos os arquivos**
   - Buscar e substituir paths antigos

---

### Fase 7: Limpeza e Validação (1-2h)

1. **Deletar pastas obsoletas**
   ```bash
   rm -rf lib/features/DetalheDefensivos
   rm -rf lib/features/detalhes_diagnostico
   ```

2. **Atualizar DI**
   ```dart
   // lib/core/di/injection_container.dart

   // ❌ REMOVER:
   // initDefensivoDetailsDI();

   // ✅ Apenas diagnosticos registrado (já existe)
   ```

3. **Executar análise estática**
   ```bash
   flutter analyze
   # Resolver todos os erros de import
   ```

4. **Executar testes**
   ```bash
   flutter test
   # Atualizar testes que dependiam da estrutura antiga
   ```

5. **Testar fluxo completo manualmente**
   - Home → Defensivos → Detalhe → Tab Diagnósticos
   - Verificar que diagnósticos aparecem
   - Verificar filtros funcionam
   - Verificar navegação para DetalheDiagnostico

---

## 7. Estimativa de Esforço

| Fase | Atividade | Tempo | Risco |
|------|-----------|-------|-------|
| 1 | Preparação | 1-2h | Baixo |
| 2 | Consolidação de Entidades | 2-3h | Médio |
| 3 | Consolidação de Repositories | 2-3h | Alto |
| 4 | Consolidação de Use Cases | 1-2h | Baixo |
| 5 | Refatoração DiagnosticosNotifier | 3-4h | Alto |
| 6 | Reorganização de Pastas | 2-3h | Médio |
| 7 | Limpeza e Validação | 1-2h | Médio |
| **TOTAL** | | **12-19h** | |

**Estimativa conservadora**: 16 horas (2 dias úteis)

---

## 8. Riscos e Mitigações

### 8.1. Risco Alto: Quebrar UI Existente

**Impacto**: Telas param de funcionar durante refatoração
**Probabilidade**: Alta (muitos arquivos afetados)

**Mitigações**:
1. ✅ Refatorar em fases incrementais (commits pequenos)
2. ✅ Manter testes rodando em cada fase
3. ✅ Usar feature flags se necessário
4. ✅ Fazer merge apenas quando tudo estiver 100% funcional

---

### 8.2. Risco Médio: Perda de Features

**Impacto**: Funcionalidades específicas param de funcionar
**Probabilidade**: Média (pode perder features obscuras)

**Mitigações**:
1. ✅ Documentar todas as features antes de refatorar
2. ✅ Criar checklist de funcionalidades
3. ✅ Testes de aceitação manuais

---

### 8.3. Risco Médio: Conflitos com Outras Branches

**Impacto**: Merge complexo e propenso a erros
**Probabilidade**: Média (refatoração grande)

**Mitigações**:
1. ✅ Comunicar equipe sobre refatoração
2. ✅ Fazer merge de main frequentemente
3. ✅ Considerar feature freeze temporário

---

## 9. Benefícios Pós-Refatoração

### 9.1. Arquitetura

- ✅ **Single Source of Truth**: 1 entidade, 1 repository, 1 mapper
- ✅ **Separation of Concerns**: Cada feature com responsabilidade clara
- ✅ **DRY**: Zero duplicação de código
- ✅ **Testabilidade**: Componentes isolados e mockáveis
- ✅ **Manutenibilidade**: Mudanças localizadas em 1 lugar

### 9.2. Performance

- ✅ **Menos Conversões**: Sem mapper duplicado empobrecendo dados
- ✅ **Type Safety**: Compile-time checks ao invés de runtime crashes
- ✅ **Menos Código**: ~400 linhas deletadas

### 9.3. Developer Experience

- ✅ **Onboarding**: Estrutura clara e previsível
- ✅ **Debugging**: Fluxo de dados linear e rastreável
- ✅ **Features**: Adicionar features em 1 lugar apenas

---

## 10. Métricas de Qualidade

### Antes da Refatoração

| Métrica | Valor | Status |
|---------|--------|--------|
| Entidades Duplicadas | 2 | 🔴 |
| Repositories Duplicados | 2 | 🔴 |
| Mappers Duplicados | 2 | 🔴 |
| Use Cases Duplicados | 2 | 🔴 |
| Linhas de Código Duplicado | ~400 | 🔴 |
| Complexidade Cyclomatic (DiagnosticosNotifier) | 15+ | 🔴 |
| Type Safety | 60% (dynamic) | 🔴 |
| SRP Violations | 3 features | 🔴 |
| Health Score | 3/10 | 🔴 |

### Após a Refatoração (Esperado)

| Métrica | Valor | Status |
|---------|--------|--------|
| Entidades Duplicadas | 0 | ✅ |
| Repositories Duplicados | 0 | ✅ |
| Mappers Duplicados | 0 | ✅ |
| Use Cases Duplicados | 0 | ✅ |
| Linhas de Código Duplicado | 0 | ✅ |
| Complexidade Cyclomatic (DiagnosticosNotifier) | 5 | ✅ |
| Type Safety | 100% | ✅ |
| SRP Violations | 0 | ✅ |
| Health Score | 9/10 | ✅ |

---

## 11. Comandos Rápidos

### Para Iniciar Refatoração

```bash
# 1. Criar branch
git checkout -b refactor/consolidate-diagnosticos-architecture

# 2. Backup de testes
cp -r test/features/DetalheDefensivos test/features/_backup_detalhes_defensivos

# 3. Análise de impacto
grep -r "DetalheDefensivos/domain/entities/diagnostico_entity" lib/ --include="*.dart"
```

### Para Validar Cada Fase

```bash
# Após cada fase, executar:
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
```

### Para Reverter Se Necessário

```bash
# Se algo der errado, reverter último commit
git reset --hard HEAD~1

# Ou reverter branch inteira
git checkout main
git branch -D refactor/consolidate-diagnosticos-architecture
```

---

## 12. Conclusão

### Sumário de Problemas

1. **Duplicação Massiva**: 3 camadas completas duplicadas (domain/data/presentation)
2. **Violação SRP**: `DetalheDefensivos` tem responsabilidades de 4 features diferentes
3. **Bug Funcional**: Diagnósticos não aparecem devido a state complexo e conversões lossy
4. **Technical Debt Alto**: ~400 linhas de código duplicado/obsoleto
5. **Manutenibilidade Baixa**: Mudanças precisam ser feitas em 3 lugares diferentes

### Arquitetura Alvo

```
✅ defensivos/       → Feature de listagem e detalhes de defensivos
✅ diagnosticos/     → Feature completa de diagnósticos (única verdade)
✅ comentarios/      → Feature separada de comentários
✅ favoritos/        → Feature separada de favoritos
```

### Impacto Esperado

- ✅ **Bug Resolvido**: Diagnósticos aparecerão corretamente
- ✅ **Código Limpo**: -400 linhas de duplicação
- ✅ **Arquitetura Sólida**: Single Responsibility + DRY + Type Safety
- ✅ **Manutenibilidade**: Features isoladas e testáveis
- ✅ **Performance**: Menos conversões e validações redundantes

### Próximos Passos

1. **Aprovação**: Revisar e aprovar este plano
2. **Execução**: Seguir fases 1-7 (12-16 horas)
3. **Validação**: Testes completos + Code review
4. **Merge**: Integrar na branch principal

---

**Preparado por**: Claude Code Intelligence (Sonnet 4.5)
**Data**: 2025-10-11
**Status**: Aguardando aprovação para execução
