# Plano Arquitetural - Migração StateNotifier → Notifier (Riverpod 3.0)

## Contexto da Migração

**Problema**: 294 erros causados pelo uso de `StateNotifier<State>` (Riverpod 2.0) removido no Riverpod 3.0.

**Solução**: Migrar para `Notifier<State>` com code generation (`@riverpod`).

---

## 1. Ordem Ideal de Refatoração

### Estratégia: Bottom-Up (Menor Complexidade → Maior Complexidade)

#### Fase 1 - Warmup (Baixo Risco) - 1-2h
**Arquivo**: `pragas_cultura_page_view_model.dart` (~30 erros)
- **Complexidade**: BAIXA
- **Dependências**: Nenhuma (ViewModel isolado)
- **Risco**: BAIXO
- **Motivo**: Padrão simples sem dependências externas, perfeito para validar o processo

#### Fase 2 - Incremento (Risco Médio) - 2-3h
**Arquivo**: `billing_notifier.dart` (~40 erros)
- **Complexidade**: MÉDIA
- **Dependências**: `SubscriptionErrorMessageService` (injeção simples)
- **Risco**: MÉDIO
- **Motivo**: Lógica de negócio moderada, testa injeção de dependências

#### Fase 3 - Core Business Logic (Risco Alto) - 3-4h
**Arquivo**: `purchase_notifier.dart` (~50 erros)
- **Complexidade**: MÉDIA-ALTA
- **Dependências**: Nenhuma (self-contained)
- **Risco**: ALTO (compras são críticas)
- **Motivo**: Lógica de compra crítica, mas sem dependências complexas

#### Fase 4 - Advanced (Risco Alto) - 3-4h
**Arquivo**: `trial_notifier.dart` (~60 erros)
- **Complexidade**: ALTA
- **Dependências**: Nenhuma (self-contained)
- **Risco**: ALTO (trial flow crítico)
- **Motivo**: Lógica de trial com múltiplos estados

#### Fase 5 - Core Critical (Risco Crítico) - 4-6h
**Arquivo**: `subscription_status_notifier.dart` (~100 erros)
- **Complexidade**: MUITO ALTA
- **Dependências**: `SubscriptionErrorMessageService`, `GetCurrentSubscriptionUseCase`
- **Risco**: CRÍTICO (núcleo do sistema de assinaturas)
- **Motivo**: Mais complexo, usado por múltiplos componentes

**TOTAL ESTIMADO**: 13-19 horas

---

## 2. Como Minimizar Bugs Durante Refatoração

### Estratégia de Segurança

#### 2.1 Git Safety Protocol
```bash
# Antes de cada fase, criar branch específica
git checkout -b feat/riverpod3-migration-phase-{N}

# Após cada fase, commit isolado
git add .
git commit -m "refactor(subscription): migrar {notifier_name} para Riverpod 3.0 Notifier

- Trocar StateNotifier<State> para Notifier<State>
- Implementar build() em vez de super()
- Usar @riverpod code generation
- Validar comportamento com testes manuais
- 0 erros analyzer após migração"

# Após validação bem-sucedida, merge para develop
git checkout develop
git merge --no-ff feat/riverpod3-migration-phase-{N}
```

#### 2.2 Validação Incremental
```bash
# Após CADA arquivo migrado, validar:

# 1. Analyzer (0 erros)
flutter analyze

# 2. Code generation (compilação limpa)
dart run build_runner build --delete-conflicting-outputs

# 3. Build app (sem runtime crashes)
flutter build apk --debug

# 4. Hot reload test (em device/emulator)
flutter run
```

#### 2.3 Rollback Strategy
- **Commit por arquivo**: Possibilita git revert granular
- **Feature flags**: Se possível, ocultar features migradas até validação completa
- **Backup manual**: Copiar arquivo original para `{notifier_name}_old.dart.bak` antes de migrar

#### 2.4 Manual Testing Checklist (Por Notifier)
- [ ] Carregar estado inicial (loading → data)
- [ ] Executar ação principal (ex: comprar, cancelar, trial)
- [ ] Verificar error handling (simular falhas)
- [ ] Testar edge cases (lista vazia, null, expiração)
- [ ] Validar state persistence (hot reload mantém estado?)

---

## 3. Padrões de Testes (Unit Tests com Mocktail)

### 3.1 Setup Base (Para TODOS os Notifiers)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mocks
class MockErrorService extends Mock implements SubscriptionErrorMessageService {}
class MockGetCurrentSubscriptionUseCase extends Mock implements GetCurrentSubscriptionUseCase {}

void main() {
  late ProviderContainer container;
  late MockErrorService mockErrorService;
  late MockGetCurrentSubscriptionUseCase mockUseCase;

  setUp(() {
    mockErrorService = MockErrorService();
    mockUseCase = MockGetCurrentSubscriptionUseCase();

    // Container with overrides
    container = ProviderContainer(
      overrides: [
        subscriptionErrorMessageServiceProvider.overrideWithValue(mockErrorService),
        getCurrentSubscriptionUseCaseProvider.overrideWithValue(mockUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('SubscriptionStatusNotifier - build()', () {
    test('DEVE retornar estado inicial com loading false', () async {
      // Arrange
      when(() => mockUseCase(const NoParams())).thenAnswer(
        (_) async => const Right(null),
      );

      // Act
      final notifier = container.read(subscriptionStatusNotifierProvider.notifier);
      final state = await container.read(subscriptionStatusNotifierProvider.future);

      // Assert
      expect(state.isLoading, false);
      expect(state.subscription, null);
      expect(state.error, null);
    });
  });

  group('loadSubscriptionStatus()', () {
    test('DEVE carregar subscription com sucesso', () async {
      // Arrange
      final mockSub = SubscriptionEntity(/* ... */);
      when(() => mockUseCase(const NoParams())).thenAnswer(
        (_) async => Right(mockSub),
      );

      // Act
      final notifier = container.read(subscriptionStatusNotifierProvider.notifier);
      await notifier.loadSubscriptionStatus();
      final state = await container.read(subscriptionStatusNotifierProvider.future);

      // Assert
      expect(state.isLoading, false);
      expect(state.subscription, mockSub);
      expect(state.error, null);
      verify(() => mockUseCase(const NoParams())).called(1);
    });

    test('DEVE lidar com falha ao carregar subscription', () async {
      // Arrange
      when(() => mockUseCase(const NoParams())).thenAnswer(
        (_) async => const Left(ServerFailure('Network error')),
      );
      when(() => mockErrorService.getLoadStatusError(any())).thenReturn(
        'Erro ao carregar status: Network error',
      );

      // Act
      final notifier = container.read(subscriptionStatusNotifierProvider.notifier);
      await notifier.loadSubscriptionStatus();
      final state = await container.read(subscriptionStatusNotifierProvider.future);

      // Assert
      expect(state.isLoading, false);
      expect(state.error, isNotNull);
      expect(state.error, contains('Erro ao carregar status'));
    });
  });
}
```

### 3.2 Padrão AAA (Arrange-Act-Assert)
```dart
// SEMPRE seguir este padrão em TODOS os testes

test('DEVE fazer algo quando condicao acontece', () async {
  // ========== ARRANGE ==========
  // Setup mocks, dados de teste, estado inicial
  when(() => mock.method()).thenAnswer((_) async => expectedResult);

  // ========== ACT ==========
  // Executar a ação sendo testada
  await notifier.methodUnderTest();

  // ========== ASSERT ==========
  // Verificar resultado e side effects
  expect(state.property, expectedValue);
  verify(() => mock.method()).called(1);
});
```

### 3.3 Coverage Mínima (Por Notifier)
```dart
// 7 testes obrigatórios por notifier:

1. test('DEVE inicializar com estado padrão') // build() inicial
2. test('DEVE carregar dados com sucesso')    // happy path
3. test('DEVE lidar com erro de rede')        // failure handling
4. test('DEVE validar entrada inválida')      // validation
5. test('DEVE atualizar estado corretamente') // state mutation
6. test('DEVE limpar estado ao chamar clear') // clearState()
7. test('DEVE sincronizar com backend')       // syncWithBackend()
```

### 3.4 Executar Testes
```bash
# Todos os testes
flutter test

# Apenas subscription tests
flutter test test/features/subscription/

# Com coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 4. Validação Pós-Migração (Por Notifier)

### Checklist de Validação

#### 4.1 Análise Estática
```bash
✅ flutter analyze (0 erros, 0 critical warnings)
✅ dart run custom_lint (Riverpod lints pass)
✅ Code generation compilou sem erros
```

#### 4.2 Testes Unitários
```bash
✅ 7+ testes criados para o notifier
✅ flutter test passou 100%
✅ Coverage ≥80% no notifier migrado
```

#### 4.3 Testes Manuais (UI)
```bash
✅ Abrir tela que usa o notifier
✅ Estado inicial carrega corretamente
✅ Executar ação principal (comprar/cancelar/trial)
✅ Verificar loading states
✅ Simular erro (desconectar rede)
✅ Verificar error messages na UI
✅ Hot reload mantém estado
```

#### 4.4 Testes de Integração (Opcional)
```bash
✅ Fluxo completo de subscription funciona
✅ Dados persistem no Hive/Firebase
✅ Sincronização cross-device funciona
```

#### 4.5 Performance Check
```bash
✅ Build times não degradaram
✅ Hot reload < 2s
✅ Memory leaks (DevTools → Memory → Check)
✅ Rebuild count aceitável (DevTools → Performance)
```

---

## 5. Riscos e Mitigações

### Riscos Identificados

#### Risco 1: Breaking Changes em Providers Consumidores
**Probabilidade**: ALTA
**Impacto**: ALTO

**Sintomas**:
```dart
// Código antigo que VAI QUEBRAR:
final notifier = ref.read(subscriptionStatusNotifierProvider.notifier);
final state = ref.read(subscriptionStatusNotifierProvider); // state direto

// Riverpod 3.0 com AsyncNotifier retorna AsyncValue<State>
final asyncValue = ref.watch(subscriptionStatusNotifierProvider);
// asyncValue é AsyncValue<SubscriptionStatusState>, NÃO SubscriptionStatusState
```

**Mitigação**:
```dart
// SOLUÇÃO 1: Pattern matching com AsyncValue
Consumer(
  builder: (context, ref, child) {
    final asyncValue = ref.watch(subscriptionStatusNotifierProvider);

    return asyncValue.when(
      data: (state) {
        // state é SubscriptionStatusState
        if (state.isLoading) return LoadingWidget();
        if (state.error != null) return ErrorWidget(state.error!);
        return SuccessWidget(state.subscription);
      },
      loading: () => LoadingWidget(),
      error: (error, stack) => ErrorWidget(error.toString()),
    );
  },
)

// SOLUÇÃO 2: Usar .value para acesso direto (APENAS se AsyncValue já resolvido)
final state = ref.watch(subscriptionStatusNotifierProvider).value;
// state pode ser null! Sempre verificar
if (state != null && state.hasActiveSubscription) { /* ... */ }
```

#### Risco 2: State Mutation Pattern Diferente
**Probabilidade**: MÉDIA
**Impacto**: MÉDIO

**Sintomas**:
```dart
// StateNotifier (Riverpod 2.0)
void loadData() {
  state = state.copyWith(isLoading: true); // Direto
}

// AsyncNotifier (Riverpod 3.0)
Future<void> loadData() async {
  state = AsyncValue.loading(); // Loading state
  try {
    final data = await fetchData();
    state = AsyncValue.data(state.value!.copyWith(data: data)); // Wrap em AsyncValue.data
  } catch (e, stack) {
    state = AsyncValue.error(e, stack); // Error state
  }
}
```

**Mitigação**:
- **SEMPRE** usar `AsyncValue.data()` para wrapping
- **NUNCA** atribuir state diretamente: `state = newState` ❌
- **SEMPRE** acessar state atual via `state.value` (pode ser null!)

#### Risco 3: Build() Assíncrono Não Executado Corretamente
**Probabilidade**: BAIXA
**Impacto**: ALTO

**Sintomas**:
```dart
// ❌ ERRADO: build() síncrono retornando Future
@override
Future<State> build() {
  return Future.value(State.initial()); // Compila mas pode dar runtime error
}

// ✅ CORRETO: build() assíncrono com async/await
@override
Future<State> build() async {
  final data = await _fetchInitialData();
  return State(data: data);
}
```

**Mitigação**:
- **SEMPRE** usar `async/await` em build()
- **VALIDAR** que build() retorna `Future<State>` corretamente
- **TESTAR** que estado inicial carrega após hot restart

#### Risco 4: Dependências Circulares em Providers
**Probabilidade**: BAIXA
**Impacto**: CRÍTICO

**Sintomas**:
```dart
// ❌ Circular dependency:
// Provider A depende de B, B depende de A
@riverpod
class ProviderA extends _$ProviderA {
  @override
  Future<StateA> build() async {
    final b = await ref.watch(providerBProvider.future);
    return StateA(b);
  }
}

@riverpod
class ProviderB extends _$ProviderB {
  @override
  Future<StateB> build() async {
    final a = await ref.watch(providerAProvider.future);
    return StateB(a);
  }
}
```

**Mitigação**:
- **MAPEAR** dependências antes de migrar
- **QUEBRAR** ciclos usando serviços compartilhados
- **VALIDAR** com `flutter analyze` (detecta alguns casos)

#### Risco 5: Memory Leaks com Listeners
**Probabilidade**: MÉDIA
**Impacto**: MÉDIO

**Sintomas**:
```dart
// ❌ Listener não dispose automaticamente (StateNotifier pattern antigo)
@override
void initState() {
  super.initState();
  ref.read(notifierProvider).addListener(() { /* ... */ });
  // NUNCA foi removido!
}
```

**Mitigação**:
```dart
// ✅ Usar ref.listen (auto-dispose)
@override
void initState() {
  super.initState();
  ref.listen(notifierProvider, (previous, next) {
    // Auto-disposed quando widget desmonta
  });
}

// ✅ Ou usar ConsumerStatefulWidget
class MyWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  @override
  Widget build(BuildContext context) {
    ref.listen(notifierProvider, (previous, next) {
      // Auto-disposed
    });
    return Container();
  }
}
```

---

## 6. Padrões Antes/Depois (Exemplos Concretos)

### Padrão 1: StateNotifier Simples → AsyncNotifier

#### ANTES (StateNotifier - Riverpod 2.0)
```dart
// trial_notifier.dart (ANTIGO)
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrialState {
  final TrialInfoEntity? trial;
  final bool isLoading;
  final String? error;

  const TrialState({
    this.trial,
    this.isLoading = false,
    this.error,
  });

  TrialState copyWith({
    TrialInfoEntity? trial,
    bool? isLoading,
    String? error,
  }) {
    return TrialState(
      trial: trial ?? this.trial,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// ❌ StateNotifier (removido em Riverpod 3.0)
class TrialNotifier extends StateNotifier<TrialState> {
  TrialNotifier() : super(const TrialState()); // Construtor com super()

  Future<void> loadTrialInfo() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      final exampleTrial = TrialInfoEntity(/* ... */);

      state = state.copyWith(
        trial: exampleTrial,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar trial: ${error.toString()}',
      );
    }
  }
}

// Provider manual (sem code generation)
final trialNotifierProvider = StateNotifierProvider<TrialNotifier, TrialState>((ref) {
  return TrialNotifier();
});
```

#### DEPOIS (AsyncNotifier - Riverpod 3.0)
```dart
// trial_notifier.dart (NOVO)
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'trial_notifier.g.dart';

// State class MANTÉM IGUAL (sem mudanças)
class TrialState {
  final TrialInfoEntity? trial;
  final bool isLoading;
  final String? error;

  const TrialState({
    this.trial,
    this.isLoading = false,
    this.error,
  });

  TrialState copyWith({
    TrialInfoEntity? trial,
    bool? isLoading,
    String? error,
  }) {
    return TrialState(
      trial: trial ?? this.trial,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// ✅ AsyncNotifier com @riverpod code generation
@riverpod
class TrialNotifier extends _$TrialNotifier {
  // build() substitui construtor
  @override
  Future<TrialState> build() async {
    // Estado inicial retornado aqui
    return const TrialState();
  }

  Future<void> loadTrialInfo() async {
    // AsyncValue wrapper para state
    state = AsyncValue.data(
      state.value!.copyWith(isLoading: true, error: null),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      final exampleTrial = TrialInfoEntity(/* ... */);

      state = AsyncValue.data(
        state.value!.copyWith(
          trial: exampleTrial,
          isLoading: false,
        ),
      );
    } catch (error, stack) {
      state = AsyncValue.data(
        state.value!.copyWith(
          isLoading: false,
          error: 'Erro ao carregar trial: ${error.toString()}',
        ),
      );
    }
  }
}

// Provider gerado automaticamente em trial_notifier.g.dart
// trialNotifierProvider está disponível após build_runner
```

#### CONSUMO NA UI (Mudanças Necessárias)

**ANTES (StateNotifier)**:
```dart
class TrialPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trialNotifierProvider); // TrialState direto

    if (state.isLoading) return CircularProgressIndicator();
    if (state.error != null) return Text(state.error!);

    return Text('Trial: ${state.trial?.totalTrialDays} days');
  }
}
```

**DEPOIS (AsyncNotifier)**:
```dart
class TrialPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(trialNotifierProvider); // AsyncValue<TrialState>

    return asyncValue.when(
      data: (state) {
        if (state.isLoading) return CircularProgressIndicator();
        if (state.error != null) return Text(state.error!);
        return Text('Trial: ${state.trial?.totalTrialDays} days');
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

---

### Padrão 2: StateNotifier com Injeção de Dependências

#### ANTES (StateNotifier com DI manual)
```dart
// billing_notifier.dart (ANTIGO)
class BillingNotifier extends StateNotifier<BillingState> {
  final SubscriptionErrorMessageService _errorService;

  BillingNotifier(this._errorService) : super(BillingState.initial());

  Future<void> loadBillingIssues() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future.delayed(const Duration(milliseconds: 700));
      final exampleIssues = <BillingIssueEntity>[/* ... */];

      state = state.copyWith(
        issues: exampleIssues,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _errorService.getLoadBillingIssuesError(error.toString()),
      );
    }
  }
}

// Provider com DI manual
final billingNotifierProvider = StateNotifierProvider<BillingNotifier, BillingState>((ref) {
  return BillingNotifier(
    ref.watch(subscriptionErrorMessageServiceProvider),
  );
});
```

#### DEPOIS (AsyncNotifier com DI via ref)
```dart
// billing_notifier.dart (NOVO)
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'billing_notifier.g.dart';

@riverpod
class BillingNotifier extends _$BillingNotifier {
  // Injetar dependências via ref (não precisa de late)
  late final SubscriptionErrorMessageService _errorService;

  @override
  Future<BillingState> build() async {
    // Injetar dependências no build()
    _errorService = ref.watch(subscriptionErrorMessageServiceProvider);

    // Retornar estado inicial
    return BillingState.initial();
  }

  Future<void> loadBillingIssues() async {
    state = AsyncValue.data(
      state.value!.copyWith(isLoading: true, error: null),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 700));
      final exampleIssues = <BillingIssueEntity>[/* ... */];

      state = AsyncValue.data(
        state.value!.copyWith(
          issues: exampleIssues,
          isLoading: false,
        ),
      );
    } catch (error, stack) {
      state = AsyncValue.data(
        state.value!.copyWith(
          isLoading: false,
          error: _errorService.getLoadBillingIssuesError(error.toString()),
        ),
      );
    }
  }
}
```

---

### Padrão 3: StateNotifier Complexo com Múltiplas Dependências

#### ANTES (subscription_status_notifier.dart)
```dart
class SubscriptionStatusNotifier extends StateNotifier<SubscriptionStatusState> {
  final SubscriptionErrorMessageService _errorService;
  final GetCurrentSubscriptionUseCase _getCurrentSubscription;

  SubscriptionStatusNotifier(this._errorService, this._getCurrentSubscription)
    : super(SubscriptionStatusState.initial());

  Future<void> loadSubscriptionStatus() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _getCurrentSubscription(const NoParams());

      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          error: _errorService.getLoadStatusError(failure.message),
        ),
        (subscription) => state = state.copyWith(
          subscription: subscription,
          isLoading: false,
          lastUpdated: DateTime.now(),
        ),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _errorService.getLoadStatusError(error.toString()),
      );
    }
  }
}

// Provider
final subscriptionStatusNotifierProvider = StateNotifierProvider<
  SubscriptionStatusNotifier,
  SubscriptionStatusState
>((ref) {
  return SubscriptionStatusNotifier(
    ref.watch(subscriptionErrorMessageServiceProvider),
    ref.watch(getCurrentSubscriptionUseCaseProvider),
  );
});
```

#### DEPOIS (AsyncNotifier Riverpod 3.0)
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_status_notifier.g.dart';

@riverpod
class SubscriptionStatusNotifier extends _$SubscriptionStatusNotifier {
  late final SubscriptionErrorMessageService _errorService;
  late final GetCurrentSubscriptionUseCase _getCurrentSubscription;

  @override
  Future<SubscriptionStatusState> build() async {
    // Injetar TODAS as dependências aqui
    _errorService = ref.watch(subscriptionErrorMessageServiceProvider);
    _getCurrentSubscription = ref.watch(getCurrentSubscriptionUseCaseProvider);

    // Retornar estado inicial
    return SubscriptionStatusState.initial();
  }

  Future<void> loadSubscriptionStatus() async {
    state = AsyncValue.data(
      state.value!.copyWith(isLoading: true, error: null),
    );

    try {
      final result = await _getCurrentSubscription(const NoParams());

      result.fold(
        (failure) {
          state = AsyncValue.data(
            state.value!.copyWith(
              isLoading: false,
              error: _errorService.getLoadStatusError(failure.message),
            ),
          );
        },
        (subscription) {
          state = AsyncValue.data(
            state.value!.copyWith(
              subscription: subscription,
              isLoading: false,
              lastUpdated: DateTime.now(),
            ),
          );
        },
      );
    } catch (error, stack) {
      state = AsyncValue.data(
        state.value!.copyWith(
          isLoading: false,
          error: _errorService.getLoadStatusError(error.toString()),
        ),
      );
    }
  }
}
```

---

### Padrão 4: ViewModel → AsyncNotifier

#### ANTES (pragas_cultura_page_view_model.dart)
```dart
class PragasCulturaPageViewModel extends StateNotifier<PragasCulturaPageState> {
  final IPragasCulturaDataService dataService;
  final IPragasCulturaQueryService queryService;
  final IPragasCulturaSortService sortService;
  final IPragasCulturaStatisticsService statisticsService;
  final PragasCulturaErrorMessageService errorService;

  PragasCulturaPageViewModel({
    required this.dataService,
    required this.queryService,
    required this.sortService,
    required this.statisticsService,
    required this.errorService,
  }) : super(const PragasCulturaPageState());

  Future<void> loadPragasForCultura(String culturaId) async {
    state = state.copyWith(isLoading: true, erro: null);

    try {
      final pragas = await dataService.getPragasForCultura(culturaId);
      _applyFiltersAndSort(pragas);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: errorService.getLoadPragasError(e.toString()),
      );
    }
  }
}

// Provider manual com múltiplas dependências
final pragasCulturaPageViewModelProvider = StateNotifierProvider<
  PragasCulturaPageViewModel,
  PragasCulturaPageState
>((ref) {
  return PragasCulturaPageViewModel(
    dataService: ref.watch(pragasCulturaDataServiceProvider),
    queryService: ref.watch(pragasCulturaQueryServiceProvider),
    sortService: ref.watch(pragasCulturaSortServiceProvider),
    statisticsService: ref.watch(pragasCulturaStatisticsServiceProvider),
    errorService: ref.watch(pragasCulturaErrorMessageServiceProvider),
  );
});
```

#### DEPOIS (AsyncNotifier Riverpod 3.0)
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pragas_cultura_page_view_model.g.dart';

@riverpod
class PragasCulturaPageViewModel extends _$PragasCulturaPageViewModel {
  late final IPragasCulturaDataService dataService;
  late final IPragasCulturaQueryService queryService;
  late final IPragasCulturaSortService sortService;
  late final IPragasCulturaStatisticsService statisticsService;
  late final PragasCulturaErrorMessageService errorService;

  @override
  Future<PragasCulturaPageState> build() async {
    // Injetar TODAS as dependências
    dataService = ref.watch(pragasCulturaDataServiceProvider);
    queryService = ref.watch(pragasCulturaQueryServiceProvider);
    sortService = ref.watch(pragasCulturaSortServiceProvider);
    statisticsService = ref.watch(pragasCulturaStatisticsServiceProvider);
    errorService = ref.watch(pragasCulturaErrorMessageServiceProvider);

    // Estado inicial
    return const PragasCulturaPageState();
  }

  Future<void> loadPragasForCultura(String culturaId) async {
    state = AsyncValue.data(
      state.value!.copyWith(isLoading: true, erro: null),
    );

    try {
      final pragas = await dataService.getPragasForCultura(culturaId);
      _applyFiltersAndSort(pragas);
    } catch (e, stack) {
      state = AsyncValue.data(
        state.value!.copyWith(
          isLoading: false,
          erro: errorService.getLoadPragasError(e.toString()),
        ),
      );
    }
  }

  void _applyFiltersAndSort(List<Map<String, dynamic>> pragas) {
    // Lógica mantida igual
    // ...
  }
}
```

---

## 7. Workflow Completo (Passo a Passo)

### Para CADA Notifier (Repetir 5 vezes)

#### Passo 1: Preparação (5min)
```bash
# 1. Criar branch específica
git checkout -b feat/riverpod3-{notifier_name}

# 2. Backup arquivo original
cp lib/features/subscription/presentation/notifiers/{notifier_name}.dart \
   lib/features/subscription/presentation/notifiers/{notifier_name}_old.dart.bak

# 3. Abrir arquivo para edição
code lib/features/subscription/presentation/notifiers/{notifier_name}.dart
```

#### Passo 2: Migração do Código (15-30min)
```dart
// 1. Adicionar imports
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '{notifier_name}.g.dart';

// 2. Trocar herança
// ANTES:
class MyNotifier extends StateNotifier<MyState> {
  MyNotifier() : super(MyState.initial());
}

// DEPOIS:
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  Future<MyState> build() async {
    return MyState.initial();
  }
}

// 3. Injetar dependências no build()
late final MyService _service;

@override
Future<MyState> build() async {
  _service = ref.watch(myServiceProvider);
  return MyState.initial();
}

// 4. Wrapping state mutations com AsyncValue.data()
// ANTES:
state = state.copyWith(isLoading: true);

// DEPOIS:
state = AsyncValue.data(state.value!.copyWith(isLoading: true));

// 5. Remover provider manual (será gerado automaticamente)
```

#### Passo 3: Code Generation (5min)
```bash
# Gerar .g.dart
dart run build_runner build --delete-conflicting-outputs

# Verificar que {notifier_name}.g.dart foi criado
ls -la lib/features/subscription/presentation/notifiers/{notifier_name}.g.dart
```

#### Passo 4: Atualizar Consumidores (10-20min)
```dart
// Buscar todos os lugares que usam o notifier
# grep -r "{notifier_name}Provider" lib/

// Atualizar para pattern matching AsyncValue
// ANTES:
final state = ref.watch(myNotifierProvider);
if (state.isLoading) { /* ... */ }

// DEPOIS:
final asyncValue = ref.watch(myNotifierProvider);
asyncValue.when(
  data: (state) {
    if (state.isLoading) { /* ... */ }
  },
  loading: () => LoadingWidget(),
  error: (error, stack) => ErrorWidget(),
);
```

#### Passo 5: Validação (10-15min)
```bash
# 1. Analyzer
flutter analyze

# 2. Testes (criar se não existir)
flutter test test/features/subscription/presentation/notifiers/{notifier_name}_test.dart

# 3. Build
flutter build apk --debug

# 4. Manual test
flutter run
# - Abrir tela relevante
# - Executar ação principal
# - Verificar loading/error/success states
```

#### Passo 6: Commit e Avançar (5min)
```bash
# 1. Remover backup se tudo OK
rm lib/features/subscription/presentation/notifiers/{notifier_name}_old.dart.bak

# 2. Commit
git add .
git commit -m "refactor(subscription): migrar {notifier_name} para Riverpod 3.0

- Substituir StateNotifier<State> por AsyncNotifier<State>
- Implementar build() com dependências via ref
- Usar AsyncValue.data() para state mutations
- Atualizar consumidores para AsyncValue.when()
- Validado: 0 erros analyzer, testes passam"

# 3. Push
git push origin feat/riverpod3-{notifier_name}

# 4. Próximo notifier
git checkout develop
git checkout -b feat/riverpod3-{next_notifier_name}
```

---

## 8. Critérios de Sucesso (Definition of Done)

### Por Notifier Migrado

#### Código
- [ ] Herança alterada: `StateNotifier<State>` → `AsyncNotifier<State>`
- [ ] `build()` implementado retornando `Future<State>`
- [ ] Dependências injetadas via `ref.watch()` no `build()`
- [ ] State mutations usando `AsyncValue.data(state.value!.copyWith(...))`
- [ ] `@riverpod` annotation adicionada
- [ ] `part` statement adicionado
- [ ] `.g.dart` gerado com sucesso

#### Testes
- [ ] 7+ unit tests criados (AAA pattern)
- [ ] `flutter test` passa 100%
- [ ] Coverage ≥80% no notifier

#### Validação
- [ ] `flutter analyze` 0 erros
- [ ] `dart run custom_lint` passa
- [ ] `flutter build apk --debug` compila
- [ ] Hot reload funciona sem crashes
- [ ] Manual test na UI passa (loading/error/success)

#### Consumidores (UI)
- [ ] Widgets atualizados para `AsyncValue.when()`
- [ ] Nenhum `state.value` sem null check
- [ ] Loading states renderizam corretamente
- [ ] Error states exibem mensagem

#### Documentação
- [ ] Commit message descritivo
- [ ] Checklist validado
- [ ] Branch mergeado para `develop`

### Projeto Completo (5 Notifiers)

- [ ] Todos os 5 notifiers migrados
- [ ] 0 erros `StateNotifier` restantes
- [ ] `flutter analyze` 0 erros em `lib/features/subscription/`
- [ ] Fluxo end-to-end de subscription funciona
- [ ] Performance não degradou (DevTools check)
- [ ] README atualizado (se necessário)

---

## 9. Timeboxing e Estimativas

### Tempo por Notifier

| Notifier | Complexidade | Tempo Estimado | Riscos |
|----------|--------------|----------------|--------|
| `pragas_cultura_page_view_model` | BAIXA | 1-2h | BAIXO (warmup) |
| `billing_notifier` | MÉDIA | 2-3h | MÉDIO (DI simples) |
| `purchase_notifier` | MÉDIA-ALTA | 3-4h | ALTO (compras críticas) |
| `trial_notifier` | ALTA | 3-4h | ALTO (trial flow) |
| `subscription_status_notifier` | MUITO ALTA | 4-6h | CRÍTICO (núcleo) |

**TOTAL**: 13-19 horas

### Distribuição Ideal

#### Dia 1 (4-5h)
- **Manhã**: Fase 1 (pragas_cultura_page_view_model) - 1-2h
- **Tarde**: Fase 2 (billing_notifier) - 2-3h

#### Dia 2 (6-8h)
- **Manhã**: Fase 3 (purchase_notifier) - 3-4h
- **Tarde**: Fase 4 (trial_notifier) - 3-4h

#### Dia 3 (4-6h)
- **Full Day**: Fase 5 (subscription_status_notifier) - 4-6h

**TOTAL**: 3 dias úteis (workdays)

---

## 10. Recursos de Referência

### Documentação Oficial
- [Riverpod 3.0 Migration Guide](https://riverpod.dev/docs/migration/from_state_notifier)
- [AsyncNotifier Documentation](https://riverpod.dev/docs/concepts/providers#asyncnotifier)
- [Code Generation Setup](https://riverpod.dev/docs/concepts/about_code_generation)

### Exemplos no Monorepo
- **app-nebulalist**: Pure Riverpod 3.0 implementation (9/10 score)
- **app-plantis**: Provider pattern (migration target)

### Guias Internos
- `.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md`
- `.claude/docs/CODE_PATTERNS.md`
- `.claude/docs/TESTING_STANDARDS.md`

---

## 11. Próximos Passos Após Migração

### Fase 6 - Cleanup (Pós-Migração)
1. Remover imports não usados (`flutter pub run import_sorter:main`)
2. Formatar código (`dart format .`)
3. Atualizar documentação README
4. Criar PR para `main` com descrição completa
5. Code review com checklist deste plano

### Fase 7 - Monitoramento (Semana 1 pós-deploy)
1. Monitor Crashlytics para novos crashes
2. Analytics de subscription flow (conversão mantida?)
3. User feedback (bugs reportados?)
4. Performance metrics (DevTools)

### Fase 8 - Otimização (Opcional)
1. Identificar oportunidades de `keepAlive: true` vs auto-dispose
2. Considerar `family` providers se necessário
3. Avaliar cache strategies para subscription data
4. Benchmark performance antes/depois

---

## Conclusão

Este plano fornece uma estratégia completa e segura para migrar 5 notifiers de `StateNotifier` (Riverpod 2.0) para `AsyncNotifier` (Riverpod 3.0), eliminando os 294 erros do app-receituagro.

**Pontos-chave**:
- Migração incremental (bottom-up) minimiza riscos
- Validação rigorosa em cada etapa
- Testes unitários garantem comportamento correto
- Padrões antes/depois facilitam implementação
- Timeboxing realista (13-19h em 3 dias)

**Sucesso esperado**:
- 0 erros analyzer após migração completa
- Funcionalidade de subscription 100% preservada
- Code generation funcionando perfeitamente
- Padrão Riverpod 3.0 consolidado no projeto
