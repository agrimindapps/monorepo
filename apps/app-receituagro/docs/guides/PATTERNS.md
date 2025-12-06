# 🏗️ Design Patterns - app-receituagro

## Strategy Pattern

Utilizado para agrupamento de defensivos agrícolas.

### Problema Resolvido

**Antes (Hard-coded if/else):**
```dart
// ❌ Modificar código existente para adicionar nova estratégia
if (strategy == 'byNome') {
  // lógica
} else if (strategy == 'byTipo') {
  // lógica
}
```

**Depois (Strategy Pattern):**
```dart
// ✅ Criar novo Strategy, não modificar código existente
class ByNovaEstrategiaGrouping implements IDefensivoGroupingStrategy {
  @override
  Map<String, List<Defensivo>> group(List<Defensivo> items) {
    // implementação
  }
}
```

### Estrutura

```
lib/features/defensivos/domain/strategies/
├── i_defensivo_grouping_strategy.dart  # Interface
├── by_nome_grouping.dart               # Estratégia por nome
├── by_tipo_grouping.dart               # Estratégia por tipo
└── by_aplicacao_grouping.dart          # Estratégia por aplicação
```

### Uso

```dart
final strategy = ref.watch(groupingStrategyProvider);
final grouped = strategy.group(defensivos);
```

---

## Repository Pattern

Abstração entre domínio e fonte de dados.

### Estrutura

```dart
// Interface (domain)
abstract class IDefensivosRepository {
  Future<Either<Failure, List<Defensivo>>> getAll();
}

// Implementação (data)
class DefensivosRepositoryImpl implements IDefensivosRepository {
  final DefensivosLocalDataSource _local;
  final DefensivosRemoteDataSource _remote;
  
  @override
  Future<Either<Failure, List<Defensivo>>> getAll() async {
    // Offline-first: tenta local, depois remote
  }
}
```

---

## AsyncNotifier Pattern (Riverpod 3.0)

Padrão para gerenciamento de estado assíncrono.

### Estrutura

```dart
@Riverpod(keepAlive: true)
class MyNotifier extends _$MyNotifier {
  @override
  Future<MyState> build() async {
    // Inicialização
    return MyState.initial();
  }
  
  Future<void> doSomething() async {
    final currentState = state.value;
    if (currentState == null) return;
    
    state = AsyncValue.data(currentState.copyWith(isLoading: true));
    // ... lógica
    state = AsyncValue.data(newState);
  }
}
```

### Consumo

```dart
// Widget
final asyncState = ref.watch(myNotifierProvider);
return asyncState.when(
  data: (state) => MyWidget(state),
  loading: () => LoadingWidget(),
  error: (e, s) => ErrorWidget(e),
);
```
