# Strategic Refactoring Plan - app-receituagro
**From 5.5/10 to 10/10 Quality Score (Gold Standard)**

**App**: app-receituagro (Agricultural Diagnostics Mobile App)
**Current State**: 5.5/10 quality score, mixed patterns, technical debt
**Target**: 10/10 (Gold Standard like app-plantis)
**Timeline**: 6-8 weeks (120-160 hours)
**Reference**: app-plantis (10/10 quality, 100% Riverpod, extensive Injectable)

---

## Executive Summary

### Overall Strategy

Transform app-receituagro through **4 coordinated priorities** executed incrementally over 6-8 weeks. The approach is **non-breaking, testable at each step**, and maintains business continuity throughout.

**Core Philosophy**:
1. **Foundation First** - Migrate DI and State Management (Weeks 1-4)
2. **Architecture Second** - Refactor God Objects to SOLID Services (Weeks 5-6)
3. **Continuous Validation** - Each step must compile and pass tests
4. **Incremental Progress** - No big bang migrations

### Timeline Overview

| Week | Focus | Deliverables | Risk |
|------|-------|-------------|------|
| 1-2 | Injectable DI + Simple ChangeNotifiers | 50%+ Injectable coverage, 5 ChangeNotifiers removed | LOW |
| 3-4 | Riverpod Core Migration | Core services on Riverpod, 80% coverage | MEDIUM |
| 5-6 | Specialized Services Refactor | God Objects split, SOLID compliance | MEDIUM |
| 7-8 | Riverpod Feature Migration + Final Polish | 100% Riverpod, 10/10 quality | LOW |

**Parallel Workstreams**:
- **Stream A**: DI Migration (Injectable) - Independent work
- **Stream B**: State Management (Provider → Riverpod) - Depends on Stream A
- **Stream C**: Architecture (God Objects → Services) - Can start Week 3

### Success Metrics

**Quantitative KPIs**:
- ✅ 0 ChangeNotifier files (currently 9)
- ✅ 0 Provider imports (currently 3 files)
- ✅ 100% Riverpod with @riverpod code generation
- ✅ ≥90% Injectable coverage (currently 2 files)
- ✅ ≤5 methods per repository (IDiagnosticosRepository has 23 methods!)
- ✅ injection_container.dart ≤100 lines (currently 342 lines)
- ✅ 0 analyzer errors
- ✅ ≥80% test coverage for use cases

**Qualitative KPIs**:
- ✅ app-plantis architectural patterns fully adopted
- ✅ Clean Architecture strictly enforced
- ✅ SOLID Principles in all services (Specialized Services pattern)
- ✅ Either<Failure, T> for all domain operations

### Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking existing features | MEDIUM | HIGH | Incremental migration, feature flags, comprehensive testing |
| Dependency deadlocks | MEDIUM | MEDIUM | Dependency graph analysis, bottom-up migration order |
| Team velocity drop | LOW | MEDIUM | Clear documentation, parallel workstreams, pairing sessions |
| Incomplete migration state | LOW | LOW | Strict validation gates, no partial states allowed |
| Premium features regression | MEDIUM | HIGH | Premium service migration first, manual testing |

---

## Discovery Phase - Codebase Audit Results

### ChangeNotifier Files (9 identified)

**Location**: `/Users/lucineiloch/Documents/deveopment/monorepo/apps/app-receituagro`

| File | Complexity | Dependency Count | Priority | Est. Hours |
|------|-----------|-----------------|----------|-----------|
| `lib/core/services/premium_service.dart` | HIGH | 4 deps | P0 | 8h |
| `lib/core/services/mock_premium_service.dart` | LOW | 0 deps | P1 | 2h |
| `lib/core/services/premium_status_notifier.dart` | MEDIUM | 1 dep | P1 | 3h |
| `lib/core/providers/remote_config_provider.dart` | MEDIUM | 1 dep | P1 | 3h |
| `lib/core/interfaces/i_premium_service.dart` | LOW | 0 deps (interface) | P2 | 2h |
| `lib/features/comentarios/presentation/comentarios_controller.dart` | MEDIUM | 1 dep | P2 | 4h |
| `lib/features/comentarios/domain/comentarios_service.dart` | MEDIUM | 2 deps | P2 | 4h |
| `lib/features/settings/domain/theme_service.dart` | LOW | 0 deps | P3 | 2h |
| `lib/features/settings/domain/premium_service.dart` | MEDIUM | 1 dep | P3 | 3h |

**Total Estimated Effort**: 31 hours

### Riverpod Files (25 identified)

**Good News**: Already 25 files using @riverpod! These provide patterns to follow.

**Key Riverpod Files to Study**:
- `lib/features/subscription/presentation/providers/subscription_notifier.dart`
- `lib/features/auth/presentation/notifiers/login_notifier.dart`
- `lib/core/providers/theme_notifier.dart`

### Injectable Usage (11 files)

**Current Usage**: Only 11 files use @injectable (subscription use cases)
- All in `lib/features/subscription/domain/usecases/`
- Good pattern established, needs expansion

**Gap**: 341 lines of manual DI in `injection_container.dart` need migration

### God Objects Identified

#### 1. IDiagnosticosRepository (23 methods!)

**Location**: `lib/features/diagnosticos/domain/repositories/i_diagnosticos_repository.dart`

**Methods by Category**:
```dart
// CRUD (2 methods)
- getAll({int? limit, int? offset})
- getById(String id)

// Filtering/Search (12 methods) ⚠️ EXTRACT TO SERVICE
- getByDefensivo(String idDefensivo)
- getByCultura(String idCultura)
- getByPraga(String idPraga)
- getByTriplaCombinacao({idDefensivo, idCultura, idPraga})
- getByTipoAplicacao(TipoAplicacao tipo)
- getByCompletude(DiagnosticoCompletude completude)
- getByFaixaDosagem({dosagemMinima, dosagemMaxima})
- searchWithFilters(DiagnosticoSearchFilters filters)
- getSimilarDiagnosticos(String diagnosticoId, {int limit})
- getRecomendacoesPara({idCultura, idPraga, int limit})
- countByFilters(DiagnosticoSearchFilters filters)
- searchByPattern(String pattern)

// Statistics/Aggregations (2 methods) ⚠️ EXTRACT TO SERVICE
- getStatistics()
- getPopularDiagnosticos({int limit})

// Validation (2 methods) ⚠️ EXTRACT TO SERVICE
- exists(String id)
- validarCompatibilidade({idDefensivo, idCultura, idPraga})

// Metadata/Lookup (5 methods) ⚠️ EXTRACT TO SERVICE
- getAllDefensivos()
- getAllCulturas()
- getAllPragas()
- getUnidadesMedida()
```

**Refactor Plan**: Extract to 5 specialized services

#### 2. IDefensivosRepository (17 methods)

**Location**: `lib/features/defensivos/domain/repositories/i_defensivos_repository.dart`

**Methods by Category**:
```dart
// CRUD (2 methods)
- getAllDefensivos()
- getDefensivoById(String id)

// Filtering/Search (9 methods) ⚠️ EXTRACT TO SERVICE
- getDefensivosByClasse(String classe)
- searchDefensivos(String query)
- getDefensivosByFabricante(String fabricante)
- getDefensivosByModoAcao(String modoAcao)
- getDefensivosRecentes({int limit})
- isDefensivoActive(String defensivoId)
- getDefensivosAgrupados({tipoAgrupamento, filtroTexto})
- getDefensivosCompletos()
- getDefensivosComFiltros({...})

// Metadata/Lookup (6 methods) ⚠️ EXTRACT TO SERVICE
- getClassesAgronomicas()
- getFabricantes()
- getModosAcao()
- getDefensivosStats()
```

**Refactor Plan**: Extract to 3 specialized services

#### 3. IPragasRepository (12 methods)

**Location**: `lib/features/pragas/domain/repositories/i_pragas_repository.dart`

**Methods by Category**:
```dart
// CRUD (3 methods)
- getAll()
- getById(String id)
- getByTipo(String tipo)

// Filtering/Search (3 methods)
- searchByName(String searchTerm)
- getByFamilia(String familia)
- getByCultura(String culturaId)

// Statistics (4 methods) ⚠️ EXTRACT TO SERVICE
- getCountByTipo(String tipo)
- getTotalCount()
- getPragasRecentes({int limit})
- getPragasStats()

// Metadata (2 methods) ⚠️ EXTRACT TO SERVICE
- getTiposPragas()
- getFamiliasPragas()
```

**Already Good**: Implements Interface Segregation with:
- `IPragasHistoryRepository` (3 methods)
- `IPragasFormatter` (3 methods)
- `IPragasInfoRepository` (2 methods)

**Refactor Plan**: Minimal - extract statistics service only

---

## Priority 1: Migrate to 100% Riverpod

**Duration**: 3-4 weeks (60-80 hours)
**Complexity**: HIGH
**Risk**: MEDIUM
**Dependency**: Must complete Priority 4 (Injectable) first for services

### Phase 1.1: Remove ChangeNotifier Files (Week 1-2)

#### Step 1: Migrate Premium Services (P0 - Week 1)

**Files**:
1. `lib/core/services/premium_service.dart` (HIGH complexity)
2. `lib/core/services/mock_premium_service.dart` (LOW complexity)
3. `lib/core/services/premium_status_notifier.dart` (MEDIUM complexity)

**Migration Pattern**:

```dart
// BEFORE (ChangeNotifier)
class ReceitaAgroPremiumService extends ChangeNotifier {
  final ReceitaAgroAnalyticsService _analytics;
  bool _initialized = false;
  PremiumStatus _status = PremiumStatus.free();

  ReceitaAgroPremiumService({required analytics}) : _analytics = analytics;

  Future<void> initialize() async {
    // ... async logic
    _initialized = true;
    notifyListeners();
  }

  bool get isPremium => _status.isPremium;
}

// AFTER (Riverpod AsyncNotifier)
@riverpod
class ReceitaAgroPremium extends _$ReceitaAgroPremium {
  @override
  Future<PremiumStatus> build() async {
    final analytics = ref.read(analyticsServiceProvider);
    final cloudFunctions = ref.read(cloudFunctionsServiceProvider);
    final remoteConfig = ref.read(remoteConfigServiceProvider);
    final subscriptionRepo = ref.read(subscriptionRepositoryProvider);

    // Initialize and return initial state
    return await _initialize(analytics, cloudFunctions, remoteConfig, subscriptionRepo);
  }

  Future<PremiumStatus> _initialize(...) async {
    // Initialization logic
    return PremiumStatus.free();
  }

  Future<Either<String, SubscriptionEntity>> purchaseProduct(String productId) async {
    state = const AsyncValue.loading();

    final analytics = ref.read(analyticsServiceProvider);
    final subscriptionRepo = ref.read(subscriptionRepositoryProvider);

    final result = await subscriptionRepo.purchaseProduct(productId: productId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return Left(failure.message);
      },
      (subscription) {
        state = AsyncValue.data(_statusFromEntity(subscription));
        return Right(subscription);
      },
    );
  }
}

// Provider definition (generated)
final receitaAgroPremiumProvider =
    AsyncNotifierProvider<ReceitaAgroPremium, PremiumStatus>(
  ReceitaAgroPremium.new,
);
```

**Implementation Steps**:

1. **Create Riverpod providers** for dependencies:
```bash
# Create providers file
touch lib/core/providers/core_services_providers.dart
```

```dart
// lib/core/providers/core_services_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/analytics_service.dart';
import '../services/cloud_functions_service.dart';
import '../services/remote_config_service.dart';

part 'core_services_providers.g.dart';

@riverpod
ReceitaAgroAnalyticsService analyticsService(AnalyticsServiceRef ref) {
  return ReceitaAgroAnalyticsService.instance;
}

@riverpod
ReceitaAgroCloudFunctionsService cloudFunctionsService(CloudFunctionsServiceRef ref) {
  return ReceitaAgroCloudFunctionsService.instance;
}

@riverpod
ReceitaAgroRemoteConfigService remoteConfigService(RemoteConfigServiceRef ref) {
  return ReceitaAgroRemoteConfigService.instance;
}
```

2. **Generate code**:
```bash
cd /Users/lucineiloch/Documents/deveopment/monorepo/apps/app-receituagro
dart run build_runner watch --delete-conflicting-outputs
```

3. **Migrate ReceitaAgroPremiumService to AsyncNotifier**:
```dart
// lib/features/subscription/presentation/providers/premium_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart';
import '../../domain/entities/premium_status.dart';
import '../../../../core/providers/core_services_providers.dart';

part 'premium_notifier.g.dart';

@riverpod
class ReceitaAgroPremium extends _$ReceitaAgroPremium {
  @override
  Future<PremiumStatus> build() async {
    // Dependencies auto-managed by Riverpod
    final analytics = ref.read(analyticsServiceProvider);
    final cloudFunctions = ref.read(cloudFunctionsServiceProvider);
    final remoteConfig = ref.read(remoteConfigServiceProvider);
    final subscriptionRepo = ref.read(subscriptionRepositoryProvider);

    // Listen to subscription changes
    ref.listen(subscriptionRepositoryProvider.selectAsync((data) => data), (previous, next) {
      next.whenData((subscription) {
        if (subscription != null) {
          state = AsyncValue.data(_statusFromEntity(subscription));
        }
      });
    });

    return await _initialize(analytics, cloudFunctions, remoteConfig, subscriptionRepo);
  }

  Future<PremiumStatus> _initialize(...) async {
    // Initialization logic (no notifyListeners needed!)
    return PremiumStatus.free();
  }

  Future<Either<String, SubscriptionEntity>> purchaseProduct(String productId) async {
    // Update state to loading
    state = const AsyncValue.loading();

    final analytics = ref.read(analyticsServiceProvider);
    final subscriptionRepo = ref.read(subscriptionRepositoryProvider);

    await analytics.logSubscriptionEvent('purchase_started', productId);

    final result = await subscriptionRepo.purchaseProduct(productId: productId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return Left(failure.message);
      },
      (subscription) {
        final newStatus = _statusFromEntity(subscription);
        state = AsyncValue.data(newStatus);

        analytics.logSubscriptionEvent('purchased', productId, additionalData: {
          'tier': subscription.tier.name,
          'status': subscription.status.name,
        });

        return Right(subscription);
      },
    );
  }

  Future<Either<String, List<SubscriptionEntity>>> restorePurchases() async {
    state = const AsyncValue.loading();

    final subscriptionRepo = ref.read(subscriptionRepositoryProvider);
    final result = await subscriptionRepo.restorePurchases();

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return Left(failure.message);
      },
      (subscriptions) {
        if (subscriptions.isNotEmpty) {
          final active = subscriptions.firstWhere(
            (sub) => sub.isActive,
            orElse: () => subscriptions.first,
          );
          state = AsyncValue.data(_statusFromEntity(active));
        }
        return Right(subscriptions);
      },
    );
  }

  bool hasFeatureAccess(PremiumFeature feature) {
    return state.maybeWhen(
      data: (status) => status.hasFeature(feature),
      orElse: () => false,
    );
  }

  PremiumStatus _statusFromEntity(SubscriptionEntity subscription) {
    if (subscription.isActive && subscription.isReceitaAgroSubscription) {
      return PremiumStatus.premium(
        expirationDate: subscription.expirationDate ?? DateTime.now().add(Duration(days: 30)),
        productId: subscription.productId,
        isTrialActive: subscription.isTrialActive,
        maxDevices: 3, // from remote config
      );
    }
    return PremiumStatus.free();
  }
}
```

4. **Update UI consumers**:
```dart
// BEFORE (ChangeNotifierProvider)
ChangeNotifierProvider<ReceitaAgroPremiumService>(
  create: (_) => sl<ReceitaAgroPremiumService>()..initialize(),
  child: MyApp(),
)

// AFTER (Riverpod ConsumerWidget)
class PremiumFeatureButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumState = ref.watch(receitaAgroPremiumProvider);

    return premiumState.when(
      data: (status) {
        if (status.isPremium) {
          return ElevatedButton(
            onPressed: () => _unlockFeature(),
            child: Text('Unlock Feature'),
          );
        }
        return ElevatedButton(
          onPressed: () => _showPaywall(),
          child: Text('Upgrade to Premium'),
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

5. **Validation**:
```bash
# Run analyzer
flutter analyze

# Run tests
flutter test

# Manual testing
flutter run
# Test premium purchase flow
# Test restore purchases
# Test feature gating
```

**Gotchas & Solutions**:
- **Issue**: ChangeNotifier singleton pattern breaks Riverpod auto-dispose
  - **Solution**: Remove singleton, let Riverpod manage lifecycle
- **Issue**: StreamSubscription cleanup needed for subscription status
  - **Solution**: Use `ref.listen` with automatic cleanup
- **Issue**: Multiple widgets listening cause multiple initializations
  - **Solution**: Use `.autoDispose` modifier selectively, cache in Riverpod

**Completion Criteria**:
- ✅ 0 ChangeNotifier in premium services
- ✅ All premium UI using ConsumerWidget
- ✅ AsyncValue error handling working
- ✅ Premium purchase flow tested manually
- ✅ Restore purchases working

#### Step 2: Migrate Core Services (P1 - Week 1)

**Files**:
1. `lib/core/providers/remote_config_provider.dart` (MEDIUM complexity)

**Pattern**: Same as Step 1, use `@riverpod` AsyncNotifier

#### Step 3: Migrate Feature Services (P2 - Week 2)

**Files**:
1. `lib/features/comentarios/presentation/comentarios_controller.dart` (MEDIUM complexity)
2. `lib/features/comentarios/domain/comentarios_service.dart` (MEDIUM complexity)

**Migration Pattern for ComentariosController**:

```dart
// BEFORE (ChangeNotifier)
class ComentariosController extends ChangeNotifier {
  final ComentariosService _service;
  final TextEditingController searchController = TextEditingController();

  ComentariosState _state = const ComentariosState();
  ComentariosState get state => _state;

  void _updateState(ComentariosState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadComentarios() async {
    _updateState(_state.copyWith(isLoading: true));
    // ... logic
  }
}

// AFTER (Riverpod Notifier)
@riverpod
class Comentarios extends _$Comentarios {
  @override
  ComentariosState build() {
    // Auto-cleanup handled by Riverpod
    return const ComentariosState();
  }

  Future<void> loadComentarios({
    String? pkIdentificador,
    String? ferramenta,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(comentariosServiceProvider);
      final comentarios = await service.getAllComentarios(
        pkIdentificador: pkIdentificador,
      );

      final maxComentarios = service.getMaxComentarios();
      final filtrados = service.filterComentarios(
        comentarios,
        state.searchText,
        pkIdentificador: pkIdentificador,
        ferramenta: ferramenta,
      );

      state = state.copyWith(
        comentarios: comentarios,
        comentariosFiltrados: filtrados,
        quantComentarios: comentarios.length,
        maxComentarios: maxComentarios,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar comentários: $e',
      );
    }
  }

  Future<void> addComentario(String conteudo, {
    String? pkIdentificador,
    String? ferramenta,
  }) async {
    final service = ref.read(comentariosServiceProvider);

    if (!service.isValidContent(conteudo)) {
      state = state.copyWith(error: service.getValidationErrorMessage());
      return;
    }

    if (!service.canAddComentario(state.quantComentarios)) {
      state = state.copyWith(error: 'Limite de comentários atingido');
      return;
    }

    final comentario = ComentarioModel(
      id: service.generateId(),
      idReg: service.generateIdReg(),
      titulo: '',
      conteudo: conteudo,
      ferramenta: ferramenta ?? 'Comentário direto',
      pkIdentificador: pkIdentificador ?? '',
      status: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await service.addComentario(comentario);
      await loadComentarios(
        pkIdentificador: pkIdentificador,
        ferramenta: ferramenta,
      );
    } catch (e) {
      state = state.copyWith(error: 'Erro ao salvar: $e');
    }
  }

  void updateSearch(String searchText) {
    final service = ref.read(comentariosServiceProvider);
    final filtrados = service.filterComentarios(
      state.comentarios,
      searchText,
      pkIdentificador: null, // Get from params if needed
      ferramenta: null,
    );

    state = state.copyWith(
      searchText: searchText,
      comentariosFiltrados: filtrados,
    );
  }
}

// Provider with search debouncing
@riverpod
class ComentariosSearch extends _$ComentariosSearch {
  Timer? _debounceTimer;

  @override
  String build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return '';
  }

  void updateSearch(String searchText) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      state = searchText;
      // Trigger comentarios provider to update
      ref.read(comentariosProvider.notifier).updateSearch(searchText);
    });
  }

  void clear() {
    _debounceTimer?.cancel();
    state = '';
    ref.read(comentariosProvider.notifier).updateSearch('');
  }
}
```

**UI Integration**:
```dart
// BEFORE (ChangeNotifierProvider)
class ComentariosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ComentariosController(service: sl<ComentariosService>())
        ..setFilters(pkIdentificador: '123', ferramenta: 'diagnostico'),
      child: Consumer<ComentariosController>(
        builder: (context, controller, _) {
          if (controller.state.isLoading) {
            return CircularProgressIndicator();
          }
          return ListView.builder(...);
        },
      ),
    );
  }
}

// AFTER (ConsumerWidget with Riverpod)
class ComentariosPage extends ConsumerStatefulWidget {
  final String? pkIdentificador;
  final String? ferramenta;

  const ComentariosPage({
    this.pkIdentificador,
    this.ferramenta,
  });

  @override
  ConsumerState<ComentariosPage> createState() => _ComentariosPageState();
}

class _ComentariosPageState extends ConsumerState<ComentariosPage> {
  @override
  void initState() {
    super.initState();
    // Load comentarios on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(comentariosProvider.notifier).loadComentarios(
        pkIdentificador: widget.pkIdentificador,
        ferramenta: widget.ferramenta,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(comentariosProvider);
    final searchText = ref.watch(comentariosSearchProvider);

    if (state.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    return Column(
      children: [
        // Search field
        TextField(
          onChanged: (value) {
            ref.read(comentariosSearchProvider.notifier).updateSearch(value);
          },
          decoration: InputDecoration(
            hintText: 'Buscar comentários...',
            suffixIcon: searchText.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      ref.read(comentariosSearchProvider.notifier).clear();
                    },
                  )
                : null,
          ),
        ),

        // Comments list
        Expanded(
          child: ListView.builder(
            itemCount: state.comentariosFiltrados.length,
            itemBuilder: (context, index) {
              final comentario = state.comentariosFiltrados[index];
              return ComentarioCard(comentario: comentario);
            },
          ),
        ),

        // Add button
        FloatingActionButton(
          onPressed: () async {
            final result = await showDialog<String>(
              context: context,
              builder: (_) => ComentarioDialog(),
            );
            if (result != null) {
              await ref.read(comentariosProvider.notifier).addComentario(
                result,
                pkIdentificador: widget.pkIdentificador,
                ferramenta: widget.ferramenta,
              );
            }
          },
          child: Icon(Icons.add),
        ),
      ],
    );
  }
}
```

**Validation**:
```bash
flutter analyze
flutter test features/comentarios/test/
flutter run
# Test: Add comentario
# Test: Search comentarios
# Test: Edit comentario
# Test: Delete comentario
```

#### Step 4: Migrate Settings Services (P3 - Week 2)

**Files**:
1. `lib/features/settings/domain/theme_service.dart` (LOW complexity)
2. `lib/features/settings/domain/premium_service.dart` (MEDIUM complexity)

**Pattern**: Same as previous steps

### Phase 1.2: Riverpod Providers Migration (Week 3-4)

**Goal**: Ensure ALL 25 existing Riverpod files follow @riverpod code generation pattern

**Audit Command**:
```bash
cd /Users/lucineiloch/Documents/deveopment/monorepo/apps/app-receituagro

# Check which files use old StateNotifier pattern
grep -l "extends StateNotifier" lib/**/*.dart

# Check which files use @riverpod already
grep -l "@riverpod" lib/**/*.dart
```

**Migration Pattern** (if needed):

```dart
// OLD PATTERN (Manual StateNotifier)
final counterProvider = StateNotifierProvider<Counter, int>((ref) {
  return Counter();
});

class Counter extends StateNotifier<int> {
  Counter() : super(0);

  void increment() {
    state = state + 1;
  }
}

// NEW PATTERN (@riverpod code generation)
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() {
    state = state + 1;
  }
}
```

**Implementation**:
1. Audit all 25 Riverpod files
2. Convert manual StateNotifier to @riverpod Notifier
3. Update imports from manual providers to generated
4. Run code generation
5. Update UI consumers (minimal changes needed)

### Phase 1.3: Remove Provider Package (Week 4)

**Final Cleanup**:

1. **Remove Provider imports**:
```bash
# Find all Provider imports
grep -rn "package:provider/provider.dart" lib/

# Should find only 3 files:
# - lib/features/pragas/di/pragas_di.dart
# - lib/core/providers/auth_providers.dart
# - lib/features/auth/README.md (docs only)
```

2. **Migrate remaining ChangeNotifierProvider**:
```dart
// lib/features/pragas/di/pragas_di.dart
// BEFORE
import 'package:provider/provider.dart';

class PragasDI {
  static void configure() {
    sl.registerFactory(() => PragasProvider(...));
  }
}

// AFTER
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
PragasService pragasService(PragasServiceRef ref) {
  return PragasService(
    repository: ref.read(pragasRepositoryProvider),
  );
}

@riverpod
class Pragas extends _$Pragas {
  @override
  PragasState build() {
    return const PragasState();
  }

  // Methods from old PragasProvider
}
```

3. **Remove Provider dependency**:
```yaml
# pubspec.yaml
dependencies:
  # provider: ^6.0.0  # REMOVE THIS
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

dev_dependencies:
  riverpod_generator: ^2.6.2
  riverpod_lint: ^2.6.1
```

4. **Final validation**:
```bash
# Ensure no Provider imports
grep -r "package:provider" lib/
# Should return ZERO results

# Run analyzer
flutter analyze

# Run all tests
flutter test

# Check app builds
flutter build apk --debug
```

**Completion Criteria**:
- ✅ 0 ChangeNotifier files in codebase
- ✅ 0 `package:provider` imports
- ✅ 100% Riverpod usage with @riverpod
- ✅ All 25+ Riverpod files follow code generation pattern
- ✅ App compiles without errors
- ✅ All tests pass

---

## Priority 2: Remove 9 ChangeNotifier Files

**Duration**: Included in Priority 1
**Complexity**: MEDIUM
**Risk**: LOW (incremental approach)

This priority is **integrated into Priority 1 Phase 1.1** with detailed steps already provided above.

**Summary**:
- Week 1: Premium services (3 files) + Remote config (1 file)
- Week 2: Comentarios (2 files) + Settings (2 files)
- Total: 8 files migrated in 2 weeks

**Remaining file**: `lib/core/interfaces/i_premium_service.dart` (interface, refactor to pure Dart interface)

---

## Priority 3: Refactor God Objects to Specialized Services

**Duration**: 2-3 weeks (40-60 hours)
**Complexity**: HIGH
**Risk**: MEDIUM
**Dependency**: Can start Week 3 in parallel with Priority 1 Phase 1.2

### Phase 3.1: Extract IDiagnosticosRepository Services (Week 5)

**Goal**: Split 23-method repository into 5 specialized services

**Target Structure**:
```
lib/features/diagnosticos/domain/
├── repositories/
│   └── i_diagnosticos_repository.dart (CRUD only - 2 methods)
└── services/
    ├── diagnosticos_filter_service.dart (12 filtering methods)
    ├── diagnosticos_stats_service.dart (2 statistics methods)
    ├── diagnosticos_validation_service.dart (2 validation methods)
    ├── diagnosticos_metadata_service.dart (5 metadata methods)
    └── diagnosticos_search_service.dart (search logic)
```

#### Step 1: Create Specialized Service Interfaces

**Create**: `lib/features/diagnosticos/domain/services/i_diagnosticos_filter_service.dart`

```dart
import 'package:core/core.dart';
import '../entities/diagnostico_entity.dart';

/// Service for filtering diagnosticos
/// Single Responsibility: Filter operations only
abstract class IDiagnosticosFilterService {
  /// Filter by defensivo
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByDefensivo(String idDefensivo);

  /// Filter by cultura
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByCultura(String idCultura);

  /// Filter by praga
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByPraga(String idPraga);

  /// Filter by triple combination
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByTriplaCombinacao({
    String? idDefensivo,
    String? idCultura,
    String? idPraga,
  });

  /// Filter by application type
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByTipoAplicacao(
    TipoAplicacao tipo,
  );

  /// Filter by completeness
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByCompletude(
    DiagnosticoCompletude completude,
  );

  /// Filter by dosage range
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByFaixaDosagem({
    required double dosagemMinima,
    required double dosagemMaxima,
  });

  /// Search with structured filters
  Future<Either<Failure, List<DiagnosticoEntity>>> searchWithFilters(
    DiagnosticoSearchFilters filters,
  );

  /// Get similar diagnosticos
  Future<Either<Failure, List<DiagnosticoEntity>>> getSimilarDiagnosticos(
    String diagnosticoId, {
    int limit = 5,
  });

  /// Get recommendations for cultura-praga combination
  Future<Either<Failure, List<DiagnosticoEntity>>> getRecomendacoesPara({
    required String idCultura,
    required String idPraga,
    int limit = 10,
  });

  /// Count by filters
  Future<Either<Failure, int>> countByFilters(DiagnosticoSearchFilters filters);
}
```

**Create**: `lib/features/diagnosticos/domain/services/i_diagnosticos_stats_service.dart`

```dart
import 'package:core/core.dart';
import '../entities/diagnostico_entity.dart';

/// Service for diagnosticos statistics
/// Single Responsibility: Statistics and aggregations
abstract class IDiagnosticosStatsService {
  /// Get overall statistics
  Future<Either<Failure, DiagnosticosStats>> getStatistics();

  /// Get popular diagnosticos
  Future<Either<Failure, List<DiagnosticoPopular>>> getPopularDiagnosticos({
    int limit = 10,
  });
}
```

**Create**: `lib/features/diagnosticos/domain/services/i_diagnosticos_validation_service.dart`

```dart
import 'package:core/core.dart';

/// Service for diagnosticos validation
/// Single Responsibility: Validation logic
abstract class IDiagnosticosValidationService {
  /// Check if diagnostico exists
  Future<Either<Failure, bool>> exists(String id);

  /// Validate compatibility of defensivo-cultura-praga
  Future<Either<Failure, bool>> validarCompatibilidade({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  });
}
```

**Create**: `lib/features/diagnosticos/domain/services/i_diagnosticos_metadata_service.dart`

```dart
import 'package:core/core.dart';

/// Service for diagnosticos metadata
/// Single Responsibility: Metadata and lookup tables
abstract class IDiagnosticosMetadataService {
  /// Get all unique defensivos
  Future<Either<Failure, List<String>>> getAllDefensivos();

  /// Get all unique culturas
  Future<Either<Failure, List<String>>> getAllCulturas();

  /// Get all unique pragas
  Future<Either<Failure, List<String>>> getAllPragas();

  /// Get available measurement units
  Future<Either<Failure, List<String>>> getUnidadesMedida();
}
```

**Create**: `lib/features/diagnosticos/domain/services/i_diagnosticos_search_service.dart`

```dart
import 'package:core/core.dart';
import '../entities/diagnostico_entity.dart';

/// Service for diagnosticos search
/// Single Responsibility: Search operations
abstract class IDiagnosticosSearchService {
  /// Search by pattern (nome defensivo, cultura, praga)
  Future<Either<Failure, List<DiagnosticoEntity>>> searchByPattern(String pattern);
}
```

#### Step 2: Simplify Repository Interface

**Edit**: `lib/features/diagnosticos/domain/repositories/i_diagnosticos_repository.dart`

```dart
import 'package:core/core.dart';
import '../entities/diagnostico_entity.dart';

/// Interface do repositório de diagnósticos (Domain Layer)
/// REFACTORED: Now follows Single Responsibility - CRUD operations ONLY
///
/// Filtering, statistics, validation, metadata → Extracted to specialized services
abstract class IDiagnosticosRepository {
  /// Busca todos os diagnósticos com paginação opcional
  Future<Either<Failure, List<DiagnosticoEntity>>> getAll({
    int? limit,
    int? offset,
  });

  /// Busca diagnóstico por ID
  Future<Either<Failure, DiagnosticoEntity?>> getById(String id);
}

/// Interface para dados de filtros (maintained for backward compatibility)
/// TODO: Consider moving to IDiagnosticosMetadataService
abstract class IDiagnosticoFiltersDataRepository {
  Future<Either<Failure, DiagnosticoFiltersData>> getFiltersData();
}
```

#### Step 3: Implement Specialized Services

**Create**: `lib/features/diagnosticos/data/services/diagnosticos_filter_service_impl.dart`

```dart
import 'package:injectable/injectable.dart';
import 'package:core/core.dart';

import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/repositories/i_diagnosticos_repository.dart';
import '../../domain/services/i_diagnosticos_filter_service.dart';

@injectable
@LazySingleton(as: IDiagnosticosFilterService)
class DiagnosticosFilterServiceImpl implements IDiagnosticosFilterService {
  final IDiagnosticosRepository _repository;

  const DiagnosticosFilterServiceImpl(this._repository);

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByDefensivo(
    String idDefensivo,
  ) async {
    // Get all diagnosticos
    final result = await _repository.getAll();

    return result.map((diagnosticos) {
      // Filter in-memory (since data is static JSON)
      return diagnosticos.where((d) => d.idDefensivo == idDefensivo).toList();
    });
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByCultura(
    String idCultura,
  ) async {
    final result = await _repository.getAll();

    return result.map((diagnosticos) {
      return diagnosticos.where((d) => d.idCultura == idCultura).toList();
    });
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByPraga(
    String idPraga,
  ) async {
    final result = await _repository.getAll();

    return result.map((diagnosticos) {
      return diagnosticos.where((d) => d.idPraga == idPraga).toList();
    });
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByTriplaCombinacao({
    String? idDefensivo,
    String? idCultura,
    String? idPraga,
  }) async {
    final result = await _repository.getAll();

    return result.map((diagnosticos) {
      return diagnosticos.where((d) {
        final matchDefensivo = idDefensivo == null || d.idDefensivo == idDefensivo;
        final matchCultura = idCultura == null || d.idCultura == idCultura;
        final matchPraga = idPraga == null || d.idPraga == idPraga;

        return matchDefensivo && matchCultura && matchPraga;
      }).toList();
    });
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByTipoAplicacao(
    TipoAplicacao tipo,
  ) async {
    final result = await _repository.getAll();

    return result.map((diagnosticos) {
      return diagnosticos.where((d) => d.tipoAplicacao == tipo).toList();
    });
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByCompletude(
    DiagnosticoCompletude completude,
  ) async {
    final result = await _repository.getAll();

    return result.map((diagnosticos) {
      return diagnosticos.where((d) => d.completude == completude).toList();
    });
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByFaixaDosagem({
    required double dosagemMinima,
    required double dosagemMaxima,
  }) async {
    final result = await _repository.getAll();

    return result.map((diagnosticos) {
      return diagnosticos.where((d) {
        final dosagem = d.dosagemMedia ?? 0.0;
        return dosagem >= dosagemMinima && dosagem <= dosagemMaxima;
      }).toList();
    });
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> searchWithFilters(
    DiagnosticoSearchFilters filters,
  ) async {
    final result = await _repository.getAll();

    return result.map((diagnosticos) {
      var filtered = diagnosticos;

      if (filters.idDefensivo != null) {
        filtered = filtered.where((d) => d.idDefensivo == filters.idDefensivo).toList();
      }

      if (filters.idCultura != null) {
        filtered = filtered.where((d) => d.idCultura == filters.idCultura).toList();
      }

      if (filters.idPraga != null) {
        filtered = filtered.where((d) => d.idPraga == filters.idPraga).toList();
      }

      if (filters.tipoAplicacao != null) {
        filtered = filtered.where((d) => d.tipoAplicacao == filters.tipoAplicacao).toList();
      }

      if (filters.completude != null) {
        filtered = filtered.where((d) => d.completude == filters.completude).toList();
      }

      return filtered;
    });
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getSimilarDiagnosticos(
    String diagnosticoId, {
    int limit = 5,
  }) async {
    // Get the reference diagnostico
    final diagnosticoResult = await _repository.getById(diagnosticoId);

    return diagnosticoResult.fold(
      (failure) => Left(failure),
      (diagnostico) async {
        if (diagnostico == null) {
          return Left(NotFoundFailure('Diagnóstico não encontrado'));
        }

        final allResult = await _repository.getAll();

        return allResult.map((diagnosticos) {
          // Find similar by defensivo or praga
          final similar = diagnosticos.where((d) {
            if (d.id == diagnostico.id) return false; // Exclude self

            return d.idDefensivo == diagnostico.idDefensivo ||
                   d.idPraga == diagnostico.idPraga;
          }).take(limit).toList();

          return similar;
        });
      },
    );
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getRecomendacoesPara({
    required String idCultura,
    required String idPraga,
    int limit = 10,
  }) async {
    final result = await _repository.getAll();

    return result.map((diagnosticos) {
      // Filter by cultura and praga
      final recommendations = diagnosticos.where((d) {
        return d.idCultura == idCultura && d.idPraga == idPraga;
      }).take(limit).toList();

      return recommendations;
    });
  }

  @override
  Future<Either<Failure, int>> countByFilters(
    DiagnosticoSearchFilters filters,
  ) async {
    final filteredResult = await searchWithFilters(filters);

    return filteredResult.map((diagnosticos) => diagnosticos.length);
  }
}
```

**Create**: `lib/features/diagnosticos/data/services/diagnosticos_stats_service_impl.dart`

```dart
import 'package:injectable/injectable.dart';
import 'package:core/core.dart';

import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/repositories/i_diagnosticos_repository.dart';
import '../../domain/services/i_diagnosticos_stats_service.dart';

@injectable
@LazySingleton(as: IDiagnosticosStatsService)
class DiagnosticosStatsServiceImpl implements IDiagnosticosStatsService {
  final IDiagnosticosRepository _repository;

  const DiagnosticosStatsServiceImpl(this._repository);

  @override
  Future<Either<Failure, DiagnosticosStats>> getStatistics() async {
    final result = await _repository.getAll();

    return result.map((diagnosticos) {
      // Calculate statistics
      final totalDiagnosticos = diagnosticos.length;

      final uniqueDefensivos = diagnosticos
          .map((d) => d.idDefensivo)
          .toSet()
          .length;

      final uniqueCulturas = diagnosticos
          .map((d) => d.idCultura)
          .toSet()
          .length;

      final uniquePragas = diagnosticos
          .map((d) => d.idPraga)
          .toSet()
          .length;

      // Count by tipo aplicacao
      final tipoAplicacaoCount = <TipoAplicacao, int>{};
      for (final d in diagnosticos) {
        tipoAplicacaoCount[d.tipoAplicacao] =
            (tipoAplicacaoCount[d.tipoAplicacao] ?? 0) + 1;
      }

      // Count by completude
      final completudeCount = <DiagnosticoCompletude, int>{};
      for (final d in diagnosticos) {
        completudeCount[d.completude] =
            (completudeCount[d.completude] ?? 0) + 1;
      }

      return DiagnosticosStats(
        totalDiagnosticos: totalDiagnosticos,
        totalDefensivos: uniqueDefensivos,
        totalCulturas: uniqueCulturas,
        totalPragas: uniquePragas,
        byTipoAplicacao: tipoAplicacaoCount,
        byCompletude: completudeCount,
      );
    });
  }

  @override
  Future<Either<Failure, List<DiagnosticoPopular>>> getPopularDiagnosticos({
    int limit = 10,
  }) async {
    final result = await _repository.getAll();

    return result.map((diagnosticos) {
      // For now, return first N diagnosticos
      // In real app, this would use access count from usage analytics
      final popular = diagnosticos.take(limit).map((d) {
        return DiagnosticoPopular(
          diagnostico: d,
          accessCount: 0, // TODO: Implement real access tracking
          lastAccessed: DateTime.now(),
        );
      }).toList();

      return popular;
    });
  }
}
```

**Create other service implementations similarly**:
- `diagnosticos_validation_service_impl.dart`
- `diagnosticos_metadata_service_impl.dart`
- `diagnosticos_search_service_impl.dart`

#### Step 4: Update Use Cases to Use Services

**Before** (Use Case calling Repository directly):
```dart
class GetDiagnosticosByPragaUseCase {
  final IDiagnosticosRepository repository;

  Future<Either<Failure, List<DiagnosticoEntity>>> call(String pragaId) {
    return repository.getByPraga(pragaId);
  }
}
```

**After** (Use Case calling Specialized Service):
```dart
@injectable
class GetDiagnosticosByPragaUseCase {
  final IDiagnosticosFilterService _filterService;

  const GetDiagnosticosByPragaUseCase(this._filterService);

  Future<Either<Failure, List<DiagnosticoEntity>>> call(String pragaId) {
    // Validation
    if (pragaId.trim().isEmpty) {
      return Future.value(Left(ValidationFailure('ID da praga é obrigatório')));
    }

    // Delegate to specialized service
    return _filterService.filterByPraga(pragaId);
  }
}
```

#### Step 5: Update Riverpod Providers

**Create**: `lib/features/diagnosticos/presentation/providers/diagnosticos_services_providers.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/services/i_diagnosticos_filter_service.dart';
import '../../domain/services/i_diagnosticos_stats_service.dart';
import '../../domain/services/i_diagnosticos_validation_service.dart';
import '../../domain/services/i_diagnosticos_metadata_service.dart';
import '../../domain/services/i_diagnosticos_search_service.dart';
import '../../../../core/di/injection_container.dart' as di;

part 'diagnosticos_services_providers.g.dart';

@riverpod
IDiagnosticosFilterService diagnosticosFilterService(
  DiagnosticosFilterServiceRef ref,
) {
  return di.sl<IDiagnosticosFilterService>();
}

@riverpod
IDiagnosticosStatsService diagnosticosStatsService(
  DiagnosticosStatsServiceRef ref,
) {
  return di.sl<IDiagnosticosStatsService>();
}

@riverpod
IDiagnosticosValidationService diagnosticosValidationService(
  DiagnosticosValidationServiceRef ref,
) {
  return di.sl<IDiagnosticosValidationService>();
}

@riverpod
IDiagnosticosMetadataService diagnosticosMetadataService(
  DiagnosticosMetadataServiceRef ref,
) {
  return di.sl<IDiagnosticosMetadataService>();
}

@riverpod
IDiagnosticosSearchService diagnosticosSearchService(
  DiagnosticosSearchServiceRef ref,
) {
  return di.sl<IDiagnosticosSearchService>();
}
```

**Update**: `lib/features/diagnosticos/presentation/providers/diagnosticos_notifier.dart`

```dart
@riverpod
class Diagnosticos extends _$Diagnosticos {
  @override
  DiagnosticosState build() {
    return const DiagnosticosState();
  }

  Future<void> loadDiagnosticosByPraga(String pragaId) async {
    state = state.copyWith(isLoading: true);

    // Use specialized filter service
    final filterService = ref.read(diagnosticosFilterServiceProvider);
    final result = await filterService.filterByPraga(pragaId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (diagnosticos) => state = state.copyWith(
        isLoading: false,
        diagnosticos: diagnosticos,
        error: null,
      ),
    );
  }

  Future<void> loadStatistics() async {
    state = state.copyWith(isLoadingStats: true);

    // Use specialized stats service
    final statsService = ref.read(diagnosticosStatsServiceProvider);
    final result = await statsService.getStatistics();

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingStats: false,
        statsError: failure.message,
      ),
      (stats) => state = state.copyWith(
        isLoadingStats: false,
        stats: stats,
        statsError: null,
      ),
    );
  }
}
```

#### Step 6: Validation

```bash
cd /Users/lucineiloch/Documents/deveopment/monorepo/apps/app-receituagro

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Run analyzer
flutter analyze

# Run tests
flutter test features/diagnosticos/

# Manual testing
flutter run
# Test: Filter diagnosticos by praga
# Test: Filter by cultura
# Test: View statistics
# Test: Search diagnosticos
```

**Completion Criteria**:
- ✅ IDiagnosticosRepository has ≤3 methods (CRUD only)
- ✅ 5 specialized services created and implemented
- ✅ All services use @injectable
- ✅ All use cases updated to use services
- ✅ Riverpod providers updated
- ✅ All tests pass

### Phase 3.2: Extract IDefensivosRepository Services (Week 6)

**Goal**: Split 17-method repository into 3 specialized services

**Target Structure**:
```
lib/features/defensivos/domain/
├── repositories/
│   └── i_defensivos_repository.dart (CRUD only - 2 methods)
└── services/
    ├── defensivos_filter_service.dart (9 filtering methods)
    ├── defensivos_metadata_service.dart (6 metadata methods)
    └── defensivos_stats_service.dart (stats methods)
```

**Implementation**: Follow same pattern as Phase 3.1

**Estimated Effort**: 24 hours

### Phase 3.3: Extract IPragasRepository Services (Week 6)

**Goal**: Extract statistics service (already has good Interface Segregation)

**Target Structure**:
```
lib/features/pragas/domain/
├── repositories/
│   └── i_pragas_repository.dart (CRUD + basic filters - keep)
├── services/
│   └── pragas_stats_service.dart (4 statistics methods)
└── (existing segregated interfaces remain)
```

**Estimated Effort**: 8 hours

### Phase 3.4: Final Validation (Week 6)

**Metrics Check**:
```bash
# Count methods in each repository interface
grep -c "Future<Either" lib/features/diagnosticos/domain/repositories/i_diagnosticos_repository.dart
# Should output: 2

grep -c "Future<Either" lib/features/defensivos/domain/repositories/i_defensivos_repository.dart
# Should output: 2

grep -c "Future<Either" lib/features/pragas/domain/repositories/i_pragas_repository.dart
# Should output: ≤8 (keeping basic filters is acceptable)
```

**Completion Criteria**:
- ✅ All repositories have ≤5 methods (CRUD + minimal necessary)
- ✅ Specialized services follow SOLID (Single Responsibility)
- ✅ All services use @injectable DI
- ✅ Use cases refactored to use services
- ✅ Riverpod providers updated
- ✅ 0 analyzer errors
- ✅ All tests pass

---

## Priority 4: Migrate to Injectable DI Extensively

**Duration**: 1-2 weeks (20-30 hours)
**Complexity**: LOW
**Risk**: LOW
**Dependency**: NONE (can start immediately, Week 1)
**Priority**: DO THIS FIRST - Foundation for other priorities

### Phase 4.1: Audit Current DI State (Week 1 - Day 1)

**Commands**:
```bash
cd /Users/lucineiloch/Documents/deveopment/monorepo/apps/app-receituagro

# Count @injectable usage
grep -r "@injectable" lib/ | wc -l
# Current: 11 files

# Count @LazySingleton usage
grep -r "@LazySingleton" lib/ | wc -l
# Current: 0 files

# Count manual registrations in injection_container.dart
wc -l lib/core/di/injection_container.dart
# Current: 342 lines

# Analyze manual registrations by type
grep "registerLazySingleton" lib/core/di/injection_container.dart | wc -l
# Count singleton registrations

grep "registerFactory" lib/core/di/injection_container.dart | wc -l
# Count factory registrations
```

**Create Audit Report**:
```bash
# Create audit file
cat > /Users/lucineiloch/Documents/deveopment/monorepo/apps/app-receituagro/DI_AUDIT_REPORT.md << 'EOF'
# DI Audit Report - app-receituagro

## Current State

### Injectable Usage
- **Files with @injectable**: 11 (all in subscription feature)
- **Files with @LazySingleton**: 0
- **Manual DI lines**: 342 lines in injection_container.dart

### Manual Registrations by Type
- **Repositories**: [Count from grep]
- **Services**: [Count from grep]
- **Use Cases**: [Count from grep]
- **Providers/Notifiers**: [Count from grep]

### Target State
- **Injectable coverage**: ≥90%
- **Manual DI lines**: ≤100 lines
- **All repositories**: @LazySingleton(as: Interface)
- **All use cases**: @injectable
- **All services**: @injectable

## Migration Plan
See Priority 4 in STRATEGIC_REFACTORING_PLAN.md
EOF
```

### Phase 4.2: Migrate Repositories to Injectable (Week 1 - Day 2-3)

**Pattern Template**:

```dart
// BEFORE (Manual DI)
// lib/core/di/injection_container.dart
sl.registerLazySingleton<IDiagnosticosRepository>(
  () => DiagnosticosRepositoryImpl(sl<DiagnosticoHiveRepository>()),
);

// AFTER (Injectable)
// lib/features/diagnosticos/data/repositories/diagnosticos_repository_impl.dart
import 'package:injectable/injectable.dart';
import 'package:core/core.dart';
import '../../domain/repositories/i_diagnosticos_repository.dart';
import '../../../../core/data/repositories/diagnostico_hive_repository.dart';

@LazySingleton(as: IDiagnosticosRepository)
class DiagnosticosRepositoryImpl implements IDiagnosticosRepository {
  final DiagnosticoHiveRepository _hiveRepository;

  const DiagnosticosRepositoryImpl(this._hiveRepository);

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getAll({
    int? limit,
    int? offset,
  }) async {
    // Implementation
  }

  @override
  Future<Either<Failure, DiagnosticoEntity?>> getById(String id) async {
    // Implementation
  }
}
```

**Implementation Steps**:

1. **Add @LazySingleton to all repositories**:
```bash
# List all repository implementation files
find lib/features -name "*_repository_impl.dart" -type f

# For each file:
# 1. Add import: import 'package:injectable/injectable.dart';
# 2. Add annotation: @LazySingleton(as: IRepositoryInterface)
# 3. Ensure constructor uses dependency injection
```

2. **Update Hive repositories**:
```dart
// lib/core/data/repositories/diagnostico_hive_repository.dart
import 'package:injectable/injectable.dart';
import 'package:core/core.dart';

@lazySingleton
class DiagnosticoHiveRepository {
  final IBoxRegistryService _boxRegistry;

  const DiagnosticoHiveRepository(this._boxRegistry);

  // Methods...
}
```

3. **Remove manual registrations**:
```dart
// lib/core/di/injection_container.dart
// DELETE these lines:
sl.registerLazySingleton<DiagnosticoHiveRepository>(
  () => DiagnosticoHiveRepository(),
);

sl.registerLazySingleton<IDiagnosticosRepository>(
  () => DiagnosticosRepositoryImpl(sl<DiagnosticoHiveRepository>()),
);
```

4. **Regenerate Injectable code**:
```bash
cd /Users/lucineiloch/Documents/deveopment/monorepo/apps/app-receituagro
dart run build_runner build --delete-conflicting-outputs
```

5. **Validation**:
```bash
flutter analyze
flutter test
flutter run
```

**Repeat for all repositories**:
- DiagnosticosRepositoryImpl
- DefensivosRepositoryImpl
- PragasRepositoryImpl
- CulturasRepositoryImpl
- FavoritosRepositoryImpl
- ComentariosRepositoryImpl
- And all Hive repositories

**Estimated Effort**: 8 hours

### Phase 4.3: Migrate Use Cases to Injectable (Week 1 - Day 4-5)

**Pattern Template**:

```dart
// BEFORE (Manual DI)
// lib/core/di/injection_container.dart
sl.registerLazySingleton<GetDiagnosticosUseCase>(
  () => GetDiagnosticosUseCase(sl<IDiagnosticosRepository>()),
);

// AFTER (Injectable)
// lib/features/diagnosticos/domain/usecases/get_diagnosticos_usecase.dart
import 'package:injectable/injectable.dart';
import 'package:core/core.dart';
import '../repositories/i_diagnosticos_repository.dart';
import '../entities/diagnostico_entity.dart';

@injectable
class GetDiagnosticosUseCase {
  final IDiagnosticosRepository _repository;

  const GetDiagnosticosUseCase(this._repository);

  Future<Either<Failure, List<DiagnosticoEntity>>> call({
    int? limit,
    int? offset,
  }) async {
    // Validation
    if (limit != null && limit <= 0) {
      return Left(ValidationFailure('Limit deve ser maior que zero'));
    }

    // Repository call
    return _repository.getAll(limit: limit, offset: offset);
  }
}
```

**Implementation**:
```bash
# Find all use case files
find lib/features -name "*_usecase.dart" -type f

# For each file:
# 1. Add @injectable annotation
# 2. Ensure constructor uses DI
# 3. Remove manual registration from injection_container.dart
```

**Estimated Effort**: 8 hours

### Phase 4.4: Migrate Services to Injectable (Week 2 - Day 1-2)

**Pattern Template**:

```dart
// BEFORE (Manual DI)
sl.registerLazySingleton<ReceitaAgroNavigationService>(
  () => ReceitaAgroNavigationService(
    coreService: sl<core.EnhancedNavigationService>(),
    agricExtension: sl<AgriculturalNavigationExtension>(),
  ),
);

// AFTER (Injectable)
import 'package:injectable/injectable.dart';
import 'package:core/core.dart' as core;

@lazySingleton
class ReceitaAgroNavigationService {
  final core.EnhancedNavigationService _coreService;
  final AgriculturalNavigationExtension _agricExtension;

  const ReceitaAgroNavigationService(
    this._coreService,
    this._agricExtension,
  );

  // Methods...
}
```

**Implementation**:
```bash
# Find all service files
find lib/core/services lib/features -name "*_service.dart" -type f

# For each file:
# 1. Add @lazySingleton or @injectable
# 2. Use constructor injection
# 3. Remove manual registration
```

**Estimated Effort**: 8 hours

### Phase 4.5: Clean Up injection_container.dart (Week 2 - Day 3)

**Goal**: Reduce from 342 lines to ≤100 lines

**Before**:
```dart
// 342 lines of manual registrations
Future<void> init() async {
  await core.InjectionContainer.init();
  await injectable.configureDependencies();

  // 200+ lines of manual registrations
  sl.registerLazySingleton<DiagnosticoHiveRepository>(
    () => DiagnosticoHiveRepository(),
  );
  // ... 100+ more registrations
}
```

**After**:
```dart
// ≤100 lines - only special cases
Future<void> init() async {
  // 1. Initialize core package DI
  await core.InjectionContainer.init();

  // 2. Initialize app-specific Injectable DI
  await injectable.configureDependencies();

  // 3. Register data cleaner (special case - implements core interface)
  sl.registerLazySingleton<core.IAppDataCleaner>(
    () => ReceitaAgroDataCleaner(),
  );

  // 4. Initialize feature modules
  await DeviceManagementDI.registerDependencies(sl);
  FavoritosDI.registerDependencies();
  PragasDI.configure();
  ComentariosDI.register(sl);
  SettingsDI.register(sl);

  // 5. Special singleton initializations (if needed)
  await _initializeSingletons();
}

Future<void> _initializeSingletons() async {
  // Only for services that require special initialization
  // Most should be handled by @lazySingleton
}
```

**Validation**:
```bash
# Count remaining lines
wc -l lib/core/di/injection_container.dart
# Should be ≤100

# Ensure app still compiles
flutter analyze

# Ensure DI resolution works
flutter test

# Run app
flutter run
```

**Completion Criteria**:
- ✅ injection_container.dart ≤100 lines
- ✅ ≥90% Injectable coverage
- ✅ All repositories use @LazySingleton
- ✅ All use cases use @injectable
- ✅ All services use @injectable or @lazySingleton
- ✅ 0 analyzer errors
- ✅ All tests pass

---

## Coordination Plan

### Dependencies Matrix

| Priority | Depends On | Can Start | Duration |
|----------|-----------|-----------|----------|
| Priority 4 (Injectable DI) | None | Week 1 | 1-2 weeks |
| Priority 1 (Riverpod) | Priority 4 (for services) | Week 1 (ChangeNotifiers), Week 3 (Full migration) | 3-4 weeks |
| Priority 2 (Remove ChangeNotifiers) | Integrated in Priority 1 | Week 1 | Integrated |
| Priority 3 (Specialized Services) | Priority 4 (for DI) | Week 3 | 2-3 weeks |

### Parallel Workstreams

**Weeks 1-2: Foundation Phase**
- **Stream A (Priority 4)**: Injectable DI migration (full-time)
- **Stream B (Priority 1.1)**: Remove simple ChangeNotifiers (part-time)

**Weeks 3-4: State Management Phase**
- **Stream A (Priority 1.2)**: Riverpod providers migration (full-time)
- **Stream B (Priority 3.1)**: Start extracting services (part-time)

**Weeks 5-6: Architecture Phase**
- **Stream A (Priority 3)**: Specialized services refactor (full-time)
- **Stream B (Priority 1.3)**: Final Riverpod cleanup (part-time)

**Weeks 7-8: Polish & Validation**
- Final testing
- Documentation updates
- Performance optimization
- Code review and refinement

### Resource Allocation

**Single Developer**: 8 weeks (sequential)
**Two Developers**: 4-6 weeks (parallel streams)
**Three Developers**: 3-4 weeks (all streams parallel)

**Recommended**: 2 developers for optimal balance

---

## Implementation Guides

### Guide 1: Migrate ChangeNotifier to Riverpod AsyncNotifier

**Difficulty**: Medium
**Time**: 2-4 hours per file
**Prerequisites**: Injectable DI in place for dependencies

#### Step-by-Step Process

**1. Analyze the ChangeNotifier**

```bash
# Open the file and identify:
# - State variables
# - Dependencies (constructor parameters)
# - Async operations
# - Listeners and streams
# - Disposal logic
```

**2. Create State Class (if not exists)**

```dart
// Create immutable state class
@freezed
class MyFeatureState with _$MyFeatureState {
  const factory MyFeatureState({
    @Default([]) List<MyEntity> items,
    @Default(false) bool isLoading,
    String? error,
  }) = _MyFeatureState;
}
```

**3. Create Riverpod Notifier**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_feature_notifier.g.dart';

@riverpod
class MyFeature extends _$MyFeature {
  @override
  MyFeatureState build() {
    // Initialize state
    // Set up listeners if needed
    ref.onDispose(() {
      // Cleanup (automatic for most cases)
    });

    return const MyFeatureState();
  }

  // Methods from ChangeNotifier
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(myServiceProvider);
      final result = await service.getData();

      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          error: failure.message,
        ),
        (data) => state = state.copyWith(
          isLoading: false,
          items: data,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
```

**4. Generate Code**

```bash
dart run build_runner watch --delete-conflicting-outputs
```

**5. Update UI**

```dart
// BEFORE
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyFeatureController(service: sl())..loadData(),
      child: Consumer<MyFeatureController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return CircularProgressIndicator();
          }
          return ListView.builder(...);
        },
      ),
    );
  }
}

// AFTER
class MyPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myFeatureProvider.notifier).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myFeatureProvider);

    if (state.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    return ListView.builder(
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return ListTile(title: Text(item.name));
      },
    );
  }
}
```

**6. Test**

```bash
# Run tests
flutter test path/to/feature/test/

# Manual testing
flutter run
# Test all user flows
```

**7. Remove Old File**

```bash
# Once confirmed working, delete ChangeNotifier file
rm lib/path/to/old_controller.dart

# Remove from DI registration
# (edit injection_container.dart if needed)
```

### Guide 2: Extract God Object to Specialized Services

**Difficulty**: High
**Time**: 8-12 hours per repository
**Prerequisites**: Repository methods identified by category

#### Step-by-Step Process

**1. Audit Repository Methods**

```bash
# Create audit file
cat > REPOSITORY_AUDIT_[FEATURE].md << 'EOF'
# Repository Audit - [Feature]

## Current Methods (Total: X)

### CRUD (Keep in Repository)
- method1()
- method2()

### Filtering (Extract to FilterService)
- method3()
- method4()
- method5()

### Statistics (Extract to StatsService)
- method6()
- method7()

### Validation (Extract to ValidationService)
- method8()
- method9()

### Metadata (Extract to MetadataService)
- method10()
- method11()

## Target Structure
- Repository: 2-3 methods (CRUD only)
- FilterService: X methods
- StatsService: Y methods
- ValidationService: Z methods
- MetadataService: W methods
EOF
```

**2. Create Service Interfaces**

```dart
// lib/features/[feature]/domain/services/i_[feature]_filter_service.dart
import 'package:core/core.dart';
import '../entities/[feature]_entity.dart';

abstract class I[Feature]FilterService {
  Future<Either<Failure, List<[Feature]Entity>>> filterBy[Criteria](String criteria);
  Future<Either<Failure, List<[Feature]Entity>>> searchWithFilters([Feature]SearchFilters filters);
  // ... other filter methods
}
```

**3. Implement Services**

```dart
// lib/features/[feature]/data/services/[feature]_filter_service_impl.dart
import 'package:injectable/injectable.dart';
import 'package:core/core.dart';

@injectable
@LazySingleton(as: I[Feature]FilterService)
class [Feature]FilterServiceImpl implements I[Feature]FilterService {
  final I[Feature]Repository _repository;

  const [Feature]FilterServiceImpl(this._repository);

  @override
  Future<Either<Failure, List<[Feature]Entity>>> filterBy[Criteria](
    String criteria,
  ) async {
    final result = await _repository.getAll();

    return result.map((entities) {
      return entities.where((e) => e.criteria == criteria).toList();
    });
  }

  // Implement other methods...
}
```

**4. Simplify Repository**

```dart
// lib/features/[feature]/domain/repositories/i_[feature]_repository.dart
import 'package:core/core.dart';
import '../entities/[feature]_entity.dart';

/// Repository Interface - CRUD operations ONLY
/// Filtering, statistics, validation → Extracted to specialized services
abstract class I[Feature]Repository {
  /// Get all entities
  Future<Either<Failure, List<[Feature]Entity>>> getAll({
    int? limit,
    int? offset,
  });

  /// Get entity by ID
  Future<Either<Failure, [Feature]Entity?>> getById(String id);
}
```

**5. Update Use Cases**

```dart
// BEFORE
@injectable
class Get[Feature]By[Criteria]UseCase {
  final I[Feature]Repository _repository;

  Future<Either<Failure, List<[Feature]Entity>>> call(String criteria) {
    return _repository.getBy[Criteria](criteria); // Method removed from repo!
  }
}

// AFTER
@injectable
class Get[Feature]By[Criteria]UseCase {
  final I[Feature]FilterService _filterService; // Use service instead

  const Get[Feature]By[Criteria]UseCase(this._filterService);

  Future<Either<Failure, List<[Feature]Entity>>> call(String criteria) {
    // Validation
    if (criteria.trim().isEmpty) {
      return Future.value(Left(ValidationFailure('[Criteria] é obrigatório')));
    }

    // Delegate to service
    return _filterService.filterBy[Criteria](criteria);
  }
}
```

**6. Create Service Providers**

```dart
// lib/features/[feature]/presentation/providers/[feature]_services_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/services/i_[feature]_filter_service.dart';
import '../../../../core/di/injection_container.dart' as di;

part '[feature]_services_providers.g.dart';

@riverpod
I[Feature]FilterService [feature]FilterService([Feature]FilterServiceRef ref) {
  return di.sl<I[Feature]FilterService>();
}

// Repeat for other services...
```

**7. Update Notifiers**

```dart
// lib/features/[feature]/presentation/providers/[feature]_notifier.dart
@riverpod
class [Feature] extends _$[Feature] {
  @override
  [Feature]State build() {
    return const [Feature]State();
  }

  Future<void> filterBy[Criteria](String criteria) async {
    state = state.copyWith(isLoading: true);

    // Use service instead of repository directly
    final filterService = ref.read([feature]FilterServiceProvider);
    final result = await filterService.filterBy[Criteria](criteria);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (entities) => state = state.copyWith(
        isLoading: false,
        entities: entities,
        error: null,
      ),
    );
  }
}
```

**8. Generate Code & Test**

```bash
# Generate Injectable + Riverpod code
dart run build_runner build --delete-conflicting-outputs

# Run analyzer
flutter analyze

# Run tests
flutter test features/[feature]/

# Manual testing
flutter run
# Test all filtering/stats/validation operations
```

**9. Validation Checklist**

- [ ] Repository has ≤5 methods
- [ ] All services use @injectable
- [ ] All use cases updated to use services
- [ ] Riverpod providers created for services
- [ ] Notifiers use services instead of repository
- [ ] All tests pass
- [ ] 0 analyzer errors
- [ ] Manual testing confirms functionality

### Guide 3: Add Injectable to Existing Class

**Difficulty**: Easy
**Time**: 15-30 minutes per class
**Prerequisites**: Dependencies use DI (GetIt or Injectable)

#### Step-by-Step Process

**1. Add Injectable Import**

```dart
import 'package:injectable/injectable.dart';
```

**2. Add Annotation**

```dart
// For repositories (singleton, interface-based)
@LazySingleton(as: IMyRepository)
class MyRepositoryImpl implements IMyRepository {
  // ...
}

// For use cases (factory, new instance each time)
@injectable
class MyUseCase {
  // ...
}

// For services (singleton)
@lazySingleton
class MyService {
  // ...
}
```

**3. Ensure Constructor DI**

```dart
// BEFORE (manual instantiation)
class MyRepositoryImpl implements IMyRepository {
  final MyDependency _dependency;

  MyRepositoryImpl() : _dependency = MyDependency();
}

// AFTER (DI)
@LazySingleton(as: IMyRepository)
class MyRepositoryImpl implements IMyRepository {
  final MyDependency _dependency;

  const MyRepositoryImpl(this._dependency); // Injected
}
```

**4. Remove Manual Registration**

```dart
// lib/core/di/injection_container.dart
// DELETE this:
sl.registerLazySingleton<IMyRepository>(
  () => MyRepositoryImpl(),
);
```

**5. Regenerate Injectable**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**6. Test**

```bash
flutter test
flutter run
```

---

## Architecture Decision Records (ADRs)

### ADR-001: Why Riverpod over Provider?

**Status**: Accepted
**Date**: 2025-10-13
**Context**: app-receituagro uses mixed Provider + Riverpod, need to standardize

**Decision**: Migrate to 100% Riverpod with @riverpod code generation

**Rationale**:
1. **Type Safety**: Riverpod provides compile-time safety, Provider is runtime-based
2. **No BuildContext**: Riverpod doesn't require context, cleaner architecture
3. **Auto-Dispose**: Riverpod manages lifecycle automatically, fewer memory leaks
4. **Code Generation**: @riverpod eliminates boilerplate, reduces errors
5. **Monorepo Standard**: CLAUDE.md specifies Riverpod as monorepo standard
6. **Testing**: ProviderContainer allows pure unit tests without widgets

**Consequences**:
- Migration effort: 3-4 weeks
- All Provider imports removed
- All ChangeNotifier files converted to Riverpod Notifier
- Improved maintainability and testability

**Reference**: app-plantis (10/10 quality) uses Provider successfully, but monorepo is standardizing on Riverpod

---

### ADR-002: Why Specialized Services over God Objects?

**Status**: Accepted
**Date**: 2025-10-13
**Context**: IDiagnosticosRepository has 23 methods, violates Single Responsibility Principle

**Decision**: Extract methods into specialized services following SOLID principles

**Rationale**:
1. **Single Responsibility (SOLID)**: Each service has one clear purpose
   - FilterService: Filtering operations
   - StatsService: Statistics and aggregations
   - ValidationService: Validation logic
   - MetadataService: Lookup tables and metadata

2. **Testability**: Smaller services are easier to unit test
3. **Maintainability**: Changes to filtering don't affect statistics
4. **Reusability**: Services can be composed in different ways
5. **app-plantis Pattern**: Gold Standard uses Specialized Services pattern

**Consequences**:
- Repository interfaces simplified to 2-3 methods (CRUD only)
- 5+ new service interfaces and implementations per feature
- Use cases updated to use services instead of repositories
- Initial effort: 2-3 weeks
- Long-term benefit: Easier to extend and maintain

**Example** (from app-plantis):
```dart
// God Object (400+ lines, 30+ methods) ❌
class PlantsProvider extends ChangeNotifier {
  void addPlant() { ... }
  void filterPlants() { ... }
  void sortPlants() { ... }
  void calculateStats() { ... }
  // ... 25+ more methods
}

// Specialized Services (SOLID) ✅
class PlantsCrudService {
  Future<void> addPlant(Plant plant) { ... }
  // Only CRUD
}

class PlantsFilterService {
  List<Plant> filterBySpace(String id) { ... }
  // Only filtering
}

class PlantsSortService {
  List<Plant> sortByName(List<Plant> plants) { ... }
  // Only sorting
}

// Provider as Facade (Delegation Pattern)
class PlantsProvider extends ChangeNotifier {
  final PlantsCrudService _crud;
  final PlantsFilterService _filter;
  final PlantsSortService _sort;

  void addPlant(Plant p) => _crud.addPlant(p);
  List<Plant> filterBySpace(String id) => _filter.filterBySpace(id);
}
```

---

### ADR-003: Why Injectable over Manual DI?

**Status**: Accepted
**Date**: 2025-10-13
**Context**: 342 lines of manual DI in injection_container.dart, only 11 @injectable usage

**Decision**: Migrate ≥90% of manual DI to Injectable annotations

**Rationale**:
1. **Boilerplate Reduction**: 342 lines → <100 lines
2. **Compile-Time Safety**: Injectable validates dependencies at compile time
3. **Automatic Resolution**: No need to manually wire dependencies
4. **Refactoring Safety**: Adding dependencies doesn't require updating DI container
5. **Monorepo Consistency**: Other apps use Injectable extensively

**Consequences**:
- All repositories: @LazySingleton(as: Interface)
- All use cases: @injectable
- All services: @injectable or @lazySingleton
- injection_container.dart only for special cases
- Must run build_runner after changes
- Initial migration: 1-2 weeks
- Ongoing benefit: No DI maintenance

**Pattern**:
```dart
// BEFORE (Manual - 10 lines per class)
sl.registerLazySingleton<IMyRepository>(
  () => MyRepositoryImpl(
    sl<Dependency1>(),
    sl<Dependency2>(),
    sl<Dependency3>(),
  ),
);

// AFTER (Injectable - 1 line)
@LazySingleton(as: IMyRepository)
class MyRepositoryImpl implements IMyRepository {
  const MyRepositoryImpl(this._dep1, this._dep2, this._dep3);
  // Injectable handles registration automatically
}
```

---

## Migration Metrics Dashboard

### Phase Completion Tracking

```markdown
## Priority 1: Riverpod Migration

- [ ] Phase 1.1: Remove ChangeNotifiers (0/9 files)
  - [ ] Premium services (0/3)
  - [ ] Core services (0/1)
  - [ ] Feature services (0/4)
  - [ ] Interfaces (0/1)

- [ ] Phase 1.2: Riverpod Providers (0/25 files)
  - [ ] Manual StateNotifier → @riverpod (0/X)
  - [ ] Provider patterns standardized (0/25)

- [ ] Phase 1.3: Remove Provider Package
  - [ ] 0 Provider imports (currently 3)
  - [ ] Provider removed from pubspec.yaml

**Progress**: 0% (0/37 files)

## Priority 2: ChangeNotifier Removal

Integrated in Priority 1 Phase 1.1

**Progress**: 0% (0/9 files)

## Priority 3: Specialized Services

- [ ] Phase 3.1: IDiagnosticosRepository
  - [ ] Services created (0/5)
  - [ ] Methods moved (0/21)
  - [ ] Repository simplified (23 → 2 methods)
  - [ ] Use cases updated (0/10)

- [ ] Phase 3.2: IDefensivosRepository
  - [ ] Services created (0/3)
  - [ ] Methods moved (0/15)
  - [ ] Repository simplified (17 → 2 methods)
  - [ ] Use cases updated (0/8)

- [ ] Phase 3.3: IPragasRepository
  - [ ] Services created (0/1)
  - [ ] Methods moved (0/4)
  - [ ] Repository simplified (12 → 8 methods)
  - [ ] Use cases updated (0/3)

**Progress**: 0% (0/41 methods extracted)

## Priority 4: Injectable DI

- [ ] Phase 4.1: Audit Complete
  - [ ] DI_AUDIT_REPORT.md created

- [ ] Phase 4.2: Repositories (0/10 repositories)
  - [ ] Diagnosticos (0/1)
  - [ ] Defensivos (0/1)
  - [ ] Pragas (0/1)
  - [ ] Culturas (0/1)
  - [ ] Favoritos (0/1)
  - [ ] Comentarios (0/1)
  - [ ] Hive repositories (0/4+)

- [ ] Phase 4.3: Use Cases (0/30+ use cases)

- [ ] Phase 4.4: Services (0/20+ services)

- [ ] Phase 4.5: injection_container.dart cleanup
  - [ ] Lines: 342 → ≤100
  - [ ] Injectable coverage: 11 files → 90%+

**Progress**: 0% (11/100+ files with @injectable)
```

### Quality Metrics Tracking

```markdown
## Analyzer Health

- [ ] 0 errors (currently: ?)
- [ ] ≤10 warnings (currently: ?)
- [ ] 0 critical warnings (currently: ?)

## Test Coverage

- [ ] Use cases: ≥80% (currently: ?)
- [ ] Repositories: ≥70% (currently: ?)
- [ ] Services: ≥70% (currently: ?)

## Architecture Metrics

- [ ] Avg methods per repository: ≤5 (currently: ~17)
- [ ] Injectable coverage: ≥90% (currently: ~5%)
- [ ] Riverpod adoption: 100% (currently: ~40% mixed)
- [ ] ChangeNotifier files: 0 (currently: 9)

## Code Quality Score

- **Current**: 5.5/10
- **Week 2 Target**: 6.0/10 (Injectable + simple ChangeNotifiers)
- **Week 4 Target**: 7.5/10 (Riverpod core migration)
- **Week 6 Target**: 9.0/10 (Specialized services)
- **Week 8 Target**: 10/10 (Final polish)
```

---

## Final Validation Checklist

### Pre-Release Validation (Week 8)

**Code Quality**:
- [ ] 0 analyzer errors
- [ ] ≤5 analyzer warnings (non-critical)
- [ ] 0 TODO/FIXME comments in critical paths
- [ ] All deprecated code removed

**Architecture Compliance**:
- [ ] 0 ChangeNotifier files
- [ ] 0 Provider imports
- [ ] 100% Riverpod with @riverpod
- [ ] All repositories ≤5 methods
- [ ] ≥90% Injectable coverage
- [ ] injection_container.dart ≤100 lines

**Testing**:
- [ ] All unit tests pass (100%)
- [ ] Integration tests pass (if exist)
- [ ] Widget tests pass (if exist)
- [ ] ≥80% coverage for use cases
- [ ] Manual testing completed for critical flows

**Documentation**:
- [ ] README.md updated with new architecture
- [ ] Architecture diagrams updated
- [ ] API documentation current
- [ ] Migration notes for team

**Performance**:
- [ ] App startup time ≤3 seconds
- [ ] No memory leaks detected
- [ ] Smooth 60fps scrolling
- [ ] No jank in critical paths

**Functional Testing**:
- [ ] All features work as before migration
- [ ] Premium features functional
- [ ] Offline mode working
- [ ] Data persistence working
- [ ] Search and filtering functional
- [ ] Statistics display correctly
- [ ] User authentication working

**Device Testing**:
- [ ] Tested on Android (min SDK)
- [ ] Tested on Android (latest)
- [ ] Tested on iOS (min version)
- [ ] Tested on iOS (latest)
- [ ] Tested on tablet layouts
- [ ] Tested offline scenarios

**Final Score Calculation**:
```
Quality Score = (
  (Analyzer Health * 0.15) +
  (Architecture Compliance * 0.30) +
  (Test Coverage * 0.25) +
  (Documentation * 0.10) +
  (Performance * 0.20)
)

Target: 10/10
- Analyzer: 10/10 (0 errors, <5 warnings)
- Architecture: 10/10 (100% compliance)
- Tests: 10/10 (≥80% coverage, all pass)
- Docs: 10/10 (complete, current)
- Performance: 10/10 (smooth, fast, no leaks)
```

---

## Conclusion

This strategic refactoring plan provides a **comprehensive, actionable roadmap** to transform app-receituagro from 5.5/10 to 10/10 quality score over 6-8 weeks.

**Key Success Factors**:
1. **Incremental Approach**: No big bang migrations, app compiles at every step
2. **Clear Priorities**: Injectable DI first (foundation), then Riverpod, then Services
3. **Parallel Workstreams**: Multiple priorities can progress simultaneously
4. **Validation Gates**: Each phase must pass quality checks before proceeding
5. **app-plantis Reference**: Follow proven patterns from Gold Standard app

**Expected Outcomes**:
- Clean, maintainable codebase following SOLID principles
- 100% Riverpod state management with compile-time safety
- Specialized services adhering to Single Responsibility
- ≥90% Injectable DI coverage with minimal boilerplate
- Gold Standard 10/10 quality score

**Next Steps**:
1. Review and approve this plan
2. Begin Priority 4 (Injectable DI) Week 1
3. Track progress using Migration Metrics Dashboard
4. Adjust timeline based on actual velocity
5. Celebrate 10/10 quality score achievement! 🚀
