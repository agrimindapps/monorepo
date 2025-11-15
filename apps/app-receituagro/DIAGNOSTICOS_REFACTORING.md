# Diagnosticos Notifier Refactoring - God Object Split

## 📋 Overview

O god object `DiagnosticosNotifier` (748 linhas) foi refatorado em **5 notifiers especializados** (~110 linhas cada), aplicando rigorosamente o **Single Responsibility Principle** e **Clean Architecture**.

**Status**: ✅ COMPLETO - Código compila, gera sem erros, pronto para uso

---

## 🎯 Objetivos Alcançados

### Antes (God Object)
```
DiagnosticosNotifier (748 linhas)
├── Load/List management
├── Filtering (defensivo, cultura, praga)
├── Search operations
├── Recommendations
├── Statistics
├── Error handling
└── Cache management
```

**Problemas**:
- ❌ 12+ métodos públicos
- ❌ 7 responsabilidades misturadas
- ❌ Difícil testar
- ❌ Difícil manter
- ❌ Violação do SRP

### Depois (5 Specialized Notifiers)
```
DiagnosticosListNotifier (116 linhas) ✅ SRP
├── loadAll()
├── loadById()
├── refresh()
└── clear()

DiagnosticosFilterNotifier (138 linhas) ✅ SRP
├── filterByDefensivo()
├── filterByCultura()
├── filterByPraga()
└── clearFilters()

DiagnosticosSearchNotifier (119 linhas) ✅ SRP
├── search()
├── searchWithFilters()
└── clearSearch()

DiagnosticosRecommendationsNotifier (98 linhas) ✅ SRP
├── getRecommendations()
├── getRecommendationsByDefensivo()
└── clearRecommendations()

DiagnosticosStatsNotifier (93 linhas) ✅ SRP
├── loadStatistics()
├── loadFiltersData()
└── refresh()
```

**Benefícios**:
- ✅ 3-4 métodos públicos por notifier
- ✅ 1 responsabilidade por notifier
- ✅ Fácil testar (cada notifier isolado)
- ✅ Fácil manter (concerns separados)
- ✅ SRP rigorosamente aplicado

---

## 📁 Estrutura de Arquivos

### State Classes (5 files, 242 linhas)
```
presentation/state/
├── diagnosticos_list_state.dart (40 linhas)
│   └── DiagnosticosListState @freezed
├── diagnosticos_filter_state.dart (55 linhas)
│   └── DiagnosticosFilterState @freezed
├── diagnosticos_search_state.dart (47 linhas)
│   └── DiagnosticosSearchState @freezed
├── diagnosticos_recommendations_state.dart (63 linhas)
│   └── DiagnosticosRecommendationsState @freezed
└── diagnosticos_stats_state.dart (37 linhas)
    └── DiagnosticosStatsState @freezed
```

**Características**:
- ✅ Immutável (@freezed)
- ✅ Type-safe
- ✅ Métodos auxiliares (hasError, hasData, clearError)
- ✅ Factory methods para estado inicial

### Notifiers (5 files, 564 linhas)
```
presentation/notifiers/
├── diagnosticos_list_notifier.dart (116 linhas)
│   └── DiagnosticosListNotifier extends StateNotifier
├── diagnosticos_filter_notifier.dart (138 linhas)
│   └── DiagnosticosFilterNotifier extends StateNotifier
├── diagnosticos_search_notifier.dart (119 linhas)
│   └── DiagnosticosSearchNotifier extends StateNotifier
├── diagnosticos_recommendations_notifier.dart (98 linhas)
│   └── DiagnosticosRecommendationsNotifier extends StateNotifier
└── diagnosticos_stats_notifier.dart (93 linhas)
    └── DiagnosticosStatsNotifier extends StateNotifier
```

**Características**:
- ✅ Dependency injection via `di.sl<T>()`
- ✅ Error handling com Either<Failure, T>
- ✅ Métodos públicos max 4 por notifier
- ✅ Código <150 linhas

### Providers (5 files, 221 linhas)
```
presentation/providers/
├── diagnosticos_list_provider.dart (39 linhas)
│   └── @riverpod class DiagnosticosList
├── diagnosticos_filter_provider.dart (57 linhas)
│   └── @riverpod class DiagnosticosFilter
├── diagnosticos_search_provider.dart (39 linhas)
│   └── @riverpod class DiagnosticosSearch
├── diagnosticos_recommendations_provider.dart (53 linhas)
│   └── @riverpod class DiagnosticosRecommendations
└── diagnosticos_stats_provider.dart (33 linhas)
    └── @riverpod class DiagnosticosStats
```

**Características**:
- ✅ Riverpod code generation (@riverpod)
- ✅ Auto-dispose (libera memória)
- ✅ Métodos auxiliares para cada operation

### Auto-Generated Files (10 files)
```
presentation/state/
├── diagnosticos_*_state.freezed.dart (5 files)

presentation/providers/
└── diagnosticos_*_provider.g.dart (5 files)
```

---

## 🔧 Como Usar

### 1. **DiagnosticosListProvider** - List Management

```dart
// Watch para atualizações em tempo real
final listState = ref.watch(diagnosticosListProvider);

// Acessar dados
if (listState.hasData) {
  print('Diagnósticos: ${listState.diagnosticos.length}');
}

// Carregar tudo
await ref.read(diagnosticosListProvider.notifier).loadAll();

// Carregar um específico
await ref.read(diagnosticosListProvider.notifier).loadById('123');

// Recarregar
await ref.read(diagnosticosListProvider.notifier).refresh();

// Limpar
ref.read(diagnosticosListProvider.notifier).clear();
```

### 2. **DiagnosticosFilterProvider** - Filtering

```dart
// Watch para filtros
final filterState = ref.watch(diagnosticosFilterProvider);

// Filtrar por praga
await ref.read(diagnosticosFilterProvider.notifier).filterByPraga(
  'praga_id',
  nomePraga: 'Lagarta do Milho',
);

// Filtrar por cultura
await ref.read(diagnosticosFilterProvider.notifier).filterByCultura(
  'cultura_id',
  nomeCultura: 'Milho',
);

// Filtrar por defensivo
await ref.read(diagnosticosFilterProvider.notifier).filterByDefensivo(
  'defensivo_id',
  nomeDefensivo: 'Inseticida X',
);

// Limpar filtros
ref.read(diagnosticosFilterProvider.notifier).clearFilters();
```

### 3. **DiagnosticosSearchProvider** - Search

```dart
// Watch para busca
final searchState = ref.watch(diagnosticosSearchProvider);

// Buscar por padrão
await ref.read(diagnosticosSearchProvider.notifier).search(
  'pulgão',
  contexto: diagnosticosList, // opcional
);

// Buscar com filtros estruturados
await ref.read(diagnosticosSearchProvider.notifier).searchWithFilters(
  DiagnosticoSearchFilters(
    defensivo: 'inseticida',
    cultura: 'milho',
  ),
);

// Limpar busca
ref.read(diagnosticosSearchProvider.notifier).clearSearch();
```

### 4. **DiagnosticosRecommendationsProvider** - Recommendations

```dart
// Watch para recomendações
final recsState = ref.watch(diagnosticosRecommendationsProvider);

// Obter recomendações por cultura e praga
await ref.read(diagnosticosRecommendationsProvider.notifier)
    .getRecommendations(
  idCultura: 'milho_id',
  idPraga: 'praga_id',
  nomeCultura: 'Milho',
  nomePraga: 'Pulgão',
  limit: 20,
);

// Limpar
ref.read(diagnosticosRecommendationsProvider.notifier)
    .clearRecommendations();
```

### 5. **DiagnosticosStatsProvider** - Statistics

```dart
// Watch para stats
final statsState = ref.watch(diagnosticosStatsProvider);

// Carregar estatísticas
await ref.read(diagnosticosStatsProvider.notifier).loadStatistics();

// Carregar dados de filtros
await ref.read(diagnosticosStatsProvider.notifier).loadFiltersData();

// Atualizar tudo
await ref.read(diagnosticosStatsProvider.notifier).refresh();
```

---

## 🧪 Testing

### Unit Test Example (DiagnosticosListNotifier)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_receituagro/features/diagnosticos/presentation/notifiers/diagnosticos_list_notifier.dart';
import 'package:app_receituagro/features/diagnosticos/presentation/state/diagnosticos_list_state.dart';

void main() {
  group('DiagnosticosListNotifier', () {
    late DiagnosticosListNotifier notifier;
    late MockGetDiagnosticosUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockGetDiagnosticosUseCase();
      notifier = DiagnosticosListNotifier();
    });

    test('should load diagnosticos', () async {
      // Arrange
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right([mockDiagnostico]));

      // Act
      await notifier.loadAll();

      // Assert
      expect(notifier.state.hasData, true);
      expect(notifier.state.diagnosticos.length, 1);
    });

    test('should handle error', () async {
      // Arrange
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Left(mockFailure));

      // Act
      await notifier.loadAll();

      // Assert
      expect(notifier.state.hasError, true);
    });
  });
}
```

---

## 📊 Métricas de Qualidade

| Métrica | Antes | Depois |
|---------|-------|--------|
| **Linhas** | 748 | 564 (5 notifiers) |
| **Métodos Públicos** | 12+ | 3-4 (cada) |
| **Responsabilidades** | 7 | 1 (cada notifier) |
| **Cyclomatic Complexity** | ⛔ Alta | ✅ Baixa |
| **Testabilidade** | ❌ Difícil | ✅ Fácil |
| **Manutenibilidade** | ❌ Baixa | ✅ Alta |

---

## 🔄 Integração com Existing Code

### Old Notifier (DEPRECATED)

O `DiagnosticosNotifier` original continua disponível mas marcado como `@deprecated`. Use os novos notifiers especializados ao invés:

```dart
// ❌ EVITAR (deprecated)
final diagnosticos = ref.watch(diagnosticosProvider);

// ✅ PREFERIR (novo)
final list = ref.watch(diagnosticosListProvider);
final filter = ref.watch(diagnosticosFilterProvider);
final search = ref.watch(diagnosticosSearchProvider);
```

### Migration Path

1. **Identificar** onde `diagnosticosProvider` é usado
2. **Refatorar** para usar o provider específico (list/filter/search/recommendations/stats)
3. **Testar** a nova implementação
4. **Remover** do código (após migração completa)
5. **Deletar** o arquivo antigo quando não mais necessário

---

## ✅ Validações Realizadas

- ✅ **Code Generation**: Freezed e Riverpod gerando corretamente
- ✅ **Type Safety**: Nenhum erro de tipo
- ✅ **Compilation**: Sem erros no `flutter analyze`
- ✅ **File Size**: Cada arquivo <500 linhas
- ✅ **SRP**: Cada notifier com responsabilidade única
- ✅ **Dependency Injection**: DI container injetando corretamente
- ✅ **Error Handling**: Either<Failure, T> implementado

---

## 🚀 Próximos Passos

1. **Phase 1**: UI screens começam a usar novos providers
2. **Phase 2**: Migração completa de `diagnosticosProvider` → novos providers
3. **Phase 3**: Add unit tests para cada notifier
4. **Phase 4**: Remove old `DiagnosticosNotifier`

---

## 📚 Referências

### Padrões Aplicados
- **Single Responsibility Principle (SRP)**: Cada notifier tem UMA responsabilidade
- **Clean Architecture**: Domain/Data/Presentation layers
- **Immutability**: @freezed para type-safe state
- **Dependency Injection**: Injeção de dependências via DI container
- **Error Handling**: Either<Failure, T> em toda camada domain

### Arquivos Relacionados
- Domain layer: `lib/features/diagnosticos/domain/`
- Data layer: `lib/features/diagnosticos/data/`
- UI screens: `lib/features/diagnosticos/presentation/pages/`

---

## 🎊 Conclusão

A refatoração resultou em código **mais mantível, testável e escalável**, aplicando rigorosamente os princípios SOLID e Clean Architecture. Cada notifier agora tem uma única responsabilidade clara, facilitando testes unitários, manutenção e futuras evoluções. 🚀
