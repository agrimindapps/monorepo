# 🔄 Provider → Riverpod Migration Master Plan

**Monorepo Flutter - Strategic Architecture Migration**

---

## 📋 Executive Summary

**Objetivo**: Migrar 10 apps Flutter de Provider/GetIt/Injectable para Riverpod puro com code generation (`@riverpod`), mantendo Clean Architecture, qualidade 10/10 e zero downtime.

**Status Atual**:
- ✅ 9 apps com Hive removido (90% cleanup concluído)
- ✅ 1 app Pure Riverpod de referência (app-nebulalist - 9/10)
- ✅ Guia de migração criado (`.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md`)
- 🔄 Pronto para iniciar migração sistemática

**Tempo Total Estimado**: 45-57 horas (1.5-2 semanas com time dedicado)

**Benefícios Esperados**:
- ⚡ +1000% performance em testes (unit tests sem widgets)
- 🛡️ +100% type safety (compile-time vs runtime errors)
- 📉 -40% boilerplate (auto-dispose, auto-loading/error states)
- 🧪 Testabilidade massivamente melhorada (ProviderContainer)
- 🔍 Debugging superior (Riverpod DevTools + provenance tracking)

---

## 🎯 1. Estratégia Geral

### **1.1 Approach: Incremental Migration (App-by-App)**

**❌ NÃO Big Bang**: Migrar todos apps simultaneamente (risco alto)

**✅ SIM Incremental**: Migrar um app por vez, validar, aplicar aprendizados ao próximo

**Razões**:
1. **Menor Risco**: Problemas isolados por app, não afeta todo monorepo
2. **Aprendizado Iterativo**: Padrões refinados a cada iteração
3. **Validação Contínua**: Cada app migrado é testado antes do próximo
4. **Rollback Seguro**: Fácil reverter um app sem impactar outros
5. **Paralelismo Possível**: 2 devs podem migrar apps independentes simultaneamente

### **1.2 Migration Waves (3 Waves)**

**Wave 1 - Learning Phase (8-14h)**:
- app-taskolist (2h) - Menor complexidade, aprendizado inicial
- app-petiveti (4-6h) - Médio porte, consolidar padrão
- app-calculei (4h) - Sem estado complexo, validar simplicidade
- **Goal**: Equipe domina padrões Riverpod

**Wave 2 - Scaling Phase (20-28h)**:
- app-receituagro (6-8h) - Grande porte, aplicar aprendizados
- app-gasometer (8-12h) - Médio/Grande, muito estado
- app-agrihurbi (6-8h) - Remover Provider misto
- **Goal**: Padrões validados em apps complexos

**Wave 3 - Excellence Phase (17-23h)**:
- web_receituagro (3h) - Web simples
- web_agrimind_site (2h) - Web simples
- app-nebulalist (2h) - Refactor (já Pure Riverpod)
- app-plantis (12-16h) - Gold Standard, migração cuidadosa
- **Goal**: Manter qualidade 10/10, completar migração

### **1.3 Pre-Migration Setup (CRÍTICO - 2h)**

**Antes de migrar qualquer app, executar**:

```bash
# 1. Backup completo
git checkout -b migration/provider-to-riverpod-backup
git push origin migration/provider-to-riverpod-backup

# 2. Create migration branch
git checkout main
git pull origin main
git checkout -b migration/provider-to-riverpod-wave1

# 3. Documentar estado atual
cd /Users/agrimindsolucoes/Documents/GitHub/monorepo
flutter analyze > MIGRATION_BASELINE_ANALYSIS.txt
flutter test > MIGRATION_BASELINE_TESTS.txt

# 4. Atualizar core package primeiro
cd packages/core
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**Checklist Pré-Migração** (validar antes de Wave 1):
- [ ] Backup branch criado e pushed
- [ ] Baseline analysis salvo (0 errors esperado)
- [ ] Baseline tests executados (100% pass esperado)
- [ ] Core package atualizado e buildando
- [ ] Team briefing realizado (padrões Riverpod)
- [ ] Rollback strategy documentada e validada
- [ ] CI/CD pipeline preparado para Riverpod linting

### **1.4 Rollback Strategy**

**Cenário 1: Migração de app falha (build/tests quebram)**

```bash
# Reverter app específico
cd apps/app-[nome]
git checkout main -- .
flutter pub get
flutter analyze
flutter test

# OU reverter commit específico
git revert <commit-hash-da-migracao>
```

**Cenário 2: Wave inteira precisa rollback**

```bash
# Reverter branch inteira
git checkout main
git branch -D migration/provider-to-riverpod-wave1

# Restaurar do backup
git checkout migration/provider-to-riverpod-backup
git checkout -b migration/provider-to-riverpod-wave1-retry
```

**Cenário 3: Migração parcial (alguns providers migrados)**

```bash
# Provider e Riverpod podem COEXISTIR temporariamente
# Manter ambos em pubspec.yaml durante transição:
dependencies:
  flutter_riverpod: ^2.6.1
  provider: any  # Remover apenas quando 100% migrado
```

**Red Flags para Rollback**:
- ❌ Build falha após 2h de debugging
- ❌ Testes caem abaixo de 80% pass rate
- ❌ Analyzer errors aumentam (target: 0 errors)
- ❌ Performance degrada (UI lag, memory leaks)
- ❌ Deadline comprometido (ajustar escopo, não qualidade)

---

## 🔧 2. Migration Phases (Detalhamento Técnico)

### **FASE 1: Setup Riverpod (30min por app)**

**2.1.1 Atualizar pubspec.yaml**

```yaml
# apps/app-[nome]/pubspec.yaml

dependencies:
  # MANTER temporariamente durante migração
  provider: any  # ⚠️ Remover apenas quando 100% migrado

  # ADICIONAR Riverpod
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

dev_dependencies:
  # ADICIONAR Code generation
  riverpod_generator: ^2.6.1
  build_runner: ^2.4.6
  custom_lint: ^0.6.0
  riverpod_lint: ^2.6.1

  # MANTER existentes
  injectable_generator: any
  build_runner: any
```

**2.1.2 Configurar analysis_options.yaml**

```yaml
# apps/app-[nome]/analysis_options.yaml

analyzer:
  plugins:
    - custom_lint

  errors:
    # Riverpod lints como errors (forçar correção)
    provider_dependencies: error
    scoped_providers_should_specify_dependencies: error

linter:
  rules:
    # Riverpod-specific
    - provider_dependencies
    - scoped_providers_should_specify_dependencies
    - avoid_manual_providers_as_generated_provider_dependency
```

**2.1.3 Executar instalação**

```bash
cd apps/app-[nome]
flutter clean
flutter pub get
dart run build_runner watch --delete-conflicting-outputs
```

**Checklist Fase 1**:
- [ ] pubspec.yaml atualizado (Riverpod + linting)
- [ ] analysis_options.yaml configurado
- [ ] `flutter pub get` executado sem erros
- [ ] `dart run build_runner watch` rodando em background
- [ ] Provider ainda funciona (coexistência validada)

---

### **FASE 2: Migração de Dependency Injection (20-30min por app)**

**2.2.1 Padrão: GetIt → Riverpod Providers**

**❌ ANTES (GetIt + Injectable)**:

```dart
// core/di/injection.dart
@InjectableInit()
void configureDependencies() {
  getIt.init();
}

// Registro manual em main.dart
void main() {
  configureDependencies();
  runApp(MyApp());
}
```

**✅ DEPOIS (Riverpod Providers)**:

```dart
// core/providers/services_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../di/injection.dart' as di;

part 'services_providers.g.dart';

/// Bridge GetIt → Riverpod (transitório)
/// Permite migrar UI sem quebrar DI existente
@riverpod
PlantsRepository plantsRepository(PlantsRepositoryRef ref) {
  return di.getIt<PlantsRepository>();
}

@riverpod
TasksRepository tasksRepository(TasksRepositoryRef ref) {
  return di.getIt<TasksRepository>();
}

@riverpod
SpacesRepository spacesRepository(SpacesRepositoryRef ref) {
  return di.getIt<SpacesRepository>();
}
```

**2.2.2 Use Cases Providers**

```dart
// features/plants/presentation/providers/plants_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/injection.dart' as di;
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/create_plant_usecase.dart';

part 'plants_providers.g.dart';

@riverpod
GetPlantsUseCase getPlantsUseCase(GetPlantsUseCaseRef ref) {
  return di.getIt<GetPlantsUseCase>();
}

@riverpod
CreatePlantUseCase createPlantUseCase(CreatePlantUseCaseRef ref) {
  return di.getIt<CreatePlantUseCase>();
}

@riverpod
UpdatePlantUseCase updatePlantUseCase(UpdatePlantUseCaseRef ref) {
  return di.getIt<UpdatePlantUseCase>();
}

@riverpod
DeletePlantUseCase deletePlantUseCase(DeletePlantUseCaseRef ref) {
  return di.getIt<DeletePlantUseCase>();
}
```

**2.2.3 Code Generation**

```bash
# Executar após criar providers
dart run build_runner build --delete-conflicting-outputs

# Validar que .g.dart foram gerados
ls -la lib/**/*_providers.g.dart
```

**Checklist Fase 2**:
- [ ] Services providers criados (GetIt bridge)
- [ ] Use cases providers criados por feature
- [ ] Code generation executado sem erros
- [ ] `.g.dart` files gerados corretamente
- [ ] GetIt ainda funciona (DI não quebrado)

---

### **FASE 3: Migração de State Management (60-80% do tempo)**

**2.3.1 Padrão: ChangeNotifier → AsyncNotifier**

**❌ ANTES (Provider + ChangeNotifier)**:

```dart
// providers/plants_provider.dart
import 'package:flutter/foundation.dart';

class PlantsProvider extends ChangeNotifier {
  final PlantsRepository _repository;

  PlantsProvider(this._repository);

  List<Plant> _plants = [];
  List<Plant> get plants => _plants;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadPlants() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getPlants();

    result.fold(
      (failure) => _errorMessage = failure.message,
      (plantsList) => _plants = plantsList,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPlant(Plant plant) async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.addPlant(plant);

    result.fold(
      (failure) => _errorMessage = failure.message,
      (newPlant) => _plants.add(newPlant),
    );

    _isLoading = false;
    notifyListeners();
  }
}
```

**✅ DEPOIS (Riverpod AsyncNotifier)**:

```dart
// providers/plants_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart';  // Either<Failure, T>

part 'plants_provider.g.dart';

/// Main Plants State Notifier
/// AsyncValue<T> gerencia loading/error/data automaticamente
@riverpod
class PlantsNotifier extends _$PlantsNotifier {
  @override
  Future<List<Plant>> build() async {
    // Carrega estado inicial automaticamente ao criar provider
    final result = await ref.read(getPlantsUseCaseProvider).call();

    return result.fold(
      (failure) => throw failure,  // AsyncValue.error captura automaticamente
      (plants) => plants,
    );
  }

  /// Add plant with optimistic update
  Future<void> addPlant(Plant plant) async {
    // AsyncValue.guard gerencia loading/error automaticamente
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await ref.read(createPlantUseCaseProvider).call(plant);

      return result.fold(
        (failure) => throw failure,  // Converte Either para Exception
        (newPlant) {
          // Atualiza state com nova planta
          final currentPlants = state.value ?? [];
          return [...currentPlants, newPlant];
        },
      );
    });
  }

  /// Update plant
  Future<void> updatePlant(Plant plant) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await ref.read(updatePlantUseCaseProvider).call(plant);

      return result.fold(
        (failure) => throw failure,
        (updatedPlant) {
          final currentPlants = state.value ?? [];
          return currentPlants.map((p) =>
            p.id == updatedPlant.id ? updatedPlant : p
          ).toList();
        },
      );
    });
  }

  /// Delete plant
  Future<void> deletePlant(String id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await ref.read(deletePlantUseCaseProvider).call(id);

      return result.fold(
        (failure) => throw failure,
        (_) {
          final currentPlants = state.value ?? [];
          return currentPlants.where((p) => p.id != id).toList();
        },
      );
    });
  }

  /// Refresh (reload from repository)
  Future<void> refresh() async {
    ref.invalidateSelf();  // Triggers build() again
  }
}
```

**2.3.2 Derived/Computed Providers**

```dart
// Providers derivados (substituem getters do ChangeNotifier)

/// Filter plants by space
@riverpod
List<Plant> plantsBySpace(PlantsBySpaceRef ref, String spaceId) {
  final plantsAsync = ref.watch(plantsNotifierProvider);

  return plantsAsync.when(
    data: (plants) => plants.where((p) => p.spaceId == spaceId).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Get favorite plants
@riverpod
List<Plant> favoritePlants(FavoritePlantsRef ref) {
  final plantsAsync = ref.watch(plantsNotifierProvider);

  return plantsAsync.when(
    data: (plants) => plants.where((p) => p.isFavorite).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Get plants count
@riverpod
int plantsCount(PlantsCountRef ref) {
  final plantsAsync = ref.watch(plantsNotifierProvider);

  return plantsAsync.when(
    data: (plants) => plants.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Search plants by name
@riverpod
List<Plant> searchPlants(SearchPlantsRef ref, String query) {
  final plantsAsync = ref.watch(plantsNotifierProvider);

  if (query.trim().isEmpty) {
    return plantsAsync.value ?? [];
  }

  return plantsAsync.when(
    data: (plants) => plants.where((p) =>
      p.name.toLowerCase().contains(query.toLowerCase())
    ).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}
```

**2.3.3 Analytics Integration**

```dart
// Integrar analytics usando ref.read()

@riverpod
class PlantsNotifier extends _$PlantsNotifier {
  // ... código anterior

  Future<void> addPlant(Plant plant) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await ref.read(createPlantUseCaseProvider).call(plant);

      return result.fold(
        (failure) => throw failure,
        (newPlant) {
          // Track analytics (fire-and-forget)
          ref.read(analyticsServiceProvider).logPlantCreated(
            plantId: newPlant.id,
            plantName: newPlant.name,
          );

          final currentPlants = state.value ?? [];
          return [...currentPlants, newPlant];
        },
      );
    });
  }
}
```

**Checklist Fase 3** (por provider migrado):
- [ ] Criar arquivo `xxx_provider.dart` com `@riverpod`
- [ ] Adicionar `part 'xxx_provider.g.dart';`
- [ ] Converter `ChangeNotifier` → `AsyncNotifier`
- [ ] Substituir `notifyListeners()` por `state = ...`
- [ ] Usar `AsyncValue.guard()` para async operations
- [ ] Converter getters para `@riverpod` functions (derived states)
- [ ] Integrar analytics com `ref.read()`
- [ ] Executar `dart run build_runner build`
- [ ] Verificar `.g.dart` gerado sem erros
- [ ] Validar que Provider antigo ainda funciona (coexistência)

---

### **FASE 4: Migração de UI Layer (20-30% do tempo)**

**2.4.1 Padrão: Widget → ConsumerWidget**

**❌ ANTES (Provider)**:

```dart
import 'package:provider/provider.dart';

class PlantsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlantsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return ErrorWidget(message: provider.errorMessage!);
        }

        return ListView.builder(
          itemCount: provider.plants.length,
          itemBuilder: (context, index) {
            final plant = provider.plants[index];
            return PlantTile(
              plant: plant,
              onTap: () => _showPlantDetails(context, plant),
            );
          },
        );
      },
    );
  }
}
```

**✅ DEPOIS (Riverpod)**:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlantsPage extends ConsumerWidget {
  const PlantsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsNotifierProvider);

    // AsyncValue.when é MUITO melhor que if/else manual
    // Gerencia 3 estados (loading, error, data) automaticamente
    return plantsAsync.when(
      data: (plants) {
        if (plants.isEmpty) {
          return const EmptyPlantsWidget();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(plantsNotifierProvider.notifier).refresh();
          },
          child: ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              return PlantTile(
                plant: plant,
                onTap: () => _showPlantDetails(context, plant),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorWidget(
        error: error,
        onRetry: () => ref.invalidate(plantsNotifierProvider),
      ),
    );
  }
}
```

**2.4.2 Padrão: StatefulWidget → ConsumerStatefulWidget**

**❌ ANTES (Provider)**:

```dart
class AddPlantDialog extends StatefulWidget {
  @override
  _AddPlantDialogState createState() => _AddPlantDialogState();
}

class _AddPlantDialogState extends State<AddPlantDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlantsProvider>(context);

    return AlertDialog(
      title: const Text('Nova Planta'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Nome'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nome é obrigatório';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: provider.isLoading ? null : _savePlant,
          child: provider.isLoading
              ? const CircularProgressIndicator()
              : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _savePlant() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<PlantsProvider>(context, listen: false);

      await provider.addPlant(
        Plant(name: _nameController.text.trim()),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
```

**✅ DEPOIS (Riverpod)**:

```dart
class AddPlantDialog extends ConsumerStatefulWidget {
  const AddPlantDialog({super.key});

  @override
  ConsumerState<AddPlantDialog> createState() => _AddPlantDialogState();
}

class _AddPlantDialogState extends ConsumerState<AddPlantDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref disponível automaticamente em ConsumerState
    // Use .select() para rebuilds granulares (apenas quando isLoading muda)
    final isLoading = ref.watch(
      plantsNotifierProvider.select((state) => state.isLoading),
    );

    return AlertDialog(
      title: const Text('Nova Planta'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Nome'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nome é obrigatório';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _savePlant,
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _savePlant() async {
    if (_formKey.currentState!.validate()) {
      // Não precisa de context, ref sempre disponível
      // Use .notifier para acessar métodos do notifier
      await ref.read(plantsNotifierProvider.notifier).addPlant(
        Plant(name: _nameController.text.trim()),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
```

**2.4.3 Performance Optimization: .select()**

```dart
// ❌ EVITAR: Rebuild desnecessário
final plantsAsync = ref.watch(plantsNotifierProvider);
final plantsCount = plantsAsync.value?.length ?? 0;
// Widget rebuilda SEMPRE que qualquer planta muda

// ✅ PREFERIR: Rebuild granular
final plantsCount = ref.watch(
  plantsNotifierProvider.select((state) =>
    state.value?.length ?? 0
  ),
);
// Widget rebuilda APENAS quando o count muda
```

**2.4.4 Migração de main.dart**

**❌ ANTES (Provider)**:

```dart
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  configureDependencies();  // GetIt

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlantsProvider(getIt())),
        ChangeNotifierProvider(create: (_) => SpacesProvider(getIt())),
        ChangeNotifierProvider(create: (_) => TasksProvider(getIt())),
        ChangeNotifierProvider(create: (_) => AuthProvider(getIt())),
      ],
      child: const MyApp(),
    ),
  );
}
```

**✅ DEPOIS (Riverpod)**:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  configureDependencies();  // GetIt (ainda necessário para bridge)

  runApp(
    const ProviderScope(  // MUITO mais simples!
      child: MyApp(),
    ),
  );
}

// Providers são declarados globalmente nos arquivos *_provider.dart
// Não precisa registrar em main.dart!
```

**Checklist Fase 4** (por widget migrado):
- [ ] `StatelessWidget` → `ConsumerWidget`
- [ ] `StatefulWidget` → `ConsumerStatefulWidget`
- [ ] `State<T>` → `ConsumerState<T>`
- [ ] Adicionar `WidgetRef ref` no `build()`
- [ ] `Consumer<T>` → `ref.watch(provider)`
- [ ] `Provider.of<T>(context, listen: false)` → `ref.read(provider)`
- [ ] `Provider.of<T>(context)` → `ref.watch(provider)`
- [ ] Usar `.when()` ou `.maybeWhen()` para `AsyncValue`
- [ ] Usar `.select()` para rebuilds granulares (performance)
- [ ] Testar hot reload funcionando
- [ ] Validar que UI se comporta identicamente

---

### **FASE 5: Limpeza e Validação (15-30min por app)**

**2.5.1 Remover Provider Dependencies**

```yaml
# pubspec.yaml - APÓS 100% migração

dependencies:
  # REMOVER completamente
  # provider: any  ❌

  # MANTER Riverpod
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
```

**2.5.2 Limpar Imports**

```bash
# Buscar e remover imports de Provider
cd apps/app-[nome]

# Encontrar arquivos com import 'package:provider/provider.dart'
grep -r "import 'package:provider/provider.dart'" lib/

# Remover manualmente ou com script
find lib/ -name "*.dart" -exec sed -i '' "/import 'package:provider\/provider.dart'/d" {} \;
```

**2.5.3 Validação de Qualidade**

```bash
cd apps/app-[nome]

# 1. Flutter analyze (target: 0 errors)
flutter analyze
# Esperado: "No issues found!"

# 2. Riverpod lint (target: 0 warnings)
dart run custom_lint
# Esperado: "No issues found!"

# 3. Testes (target: 100% pass rate)
flutter test
# Esperado: "All tests passed!"

# 4. Build (target: build sucesso)
flutter build apk --debug
# Esperado: Build concluído sem erros

# 5. Code generation check
dart run build_runner build --delete-conflicting-outputs
# Esperado: ".g.dart files are up to date"
```

**2.5.4 Documentação**

```markdown
# apps/app-[nome]/MIGRATION_RIVERPOD_COMPLETE.md

## Migração Provider → Riverpod Completa ✅

**Data**: [data de conclusão]
**Tempo Total**: [horas gastas]
**Developers**: [nomes]

### Métricas de Qualidade

- ✅ Flutter analyze: 0 errors, 0 warnings
- ✅ Riverpod lint: 0 issues
- ✅ Tests: 100% pass rate ([X] tests)
- ✅ Build: Sucesso (debug + release)
- ✅ Code coverage: [X]%

### Providers Migrados

1. PlantsProvider → PlantsNotifier ✅
2. SpacesProvider → SpacesNotifier ✅
3. TasksProvider → TasksNotifier ✅
4. AuthProvider → AuthNotifier ✅

### Breaking Changes

- Nenhuma (migração transparente para usuário final)

### Performance Improvements

- Testes: [antes]ms → [depois]ms (-X% tempo)
- Build size: [antes]MB → [depois]MB (-X% tamanho)

### Lições Aprendidas

- [Insight 1]
- [Insight 2]
- [Padrões validados para próximo app]
```

**Checklist Fase 5**:
- [ ] Provider removido do pubspec.yaml
- [ ] Imports de Provider removidos
- [ ] `flutter analyze` → 0 errors
- [ ] `dart run custom_lint` → 0 issues
- [ ] `flutter test` → 100% pass
- [ ] `flutter build apk --debug` → sucesso
- [ ] Documentação de migração criada
- [ ] README atualizado (mencionar Riverpod)
- [ ] Commit com mensagem descritiva
- [ ] PR criado (se workflow de review)

---

## 📱 3. Checklist Específico por App

### **3.1 app-taskolist (2h - WAVE 1 - Prioridade 1)**

**Contexto**:
- Menor esforço
- Clean Architecture simples
- 6 providers aproximadamente
- Já usa Riverpod parcialmente

**Providers a Migrar**:
1. `task_notifier.dart` → `TasksNotifier` (AsyncNotifier)
2. `theme_notifier.dart` → Já Riverpod (StateNotifier) → Migrar para `@riverpod`
3. `subscription_notifier.dart` → `SubscriptionNotifier`
4. `auth_providers.dart` → Já Riverpod → Validar padrão
5. `notification_providers.dart` → Já Riverpod → Validar padrão
6. `subtask_providers.dart` → Já Riverpod → Validar padrão

**Estratégia**:
- Converter `StateNotifier` para `@riverpod` AsyncNotifier
- Aproveitar que já tem estrutura Riverpod
- **Goal**: Template para outros apps

**Checklist app-taskolist**:
- [ ] FASE 1: Setup (15min) → Atualizar dependencies, linting
- [ ] FASE 2: DI (15min) → Services providers via GetIt bridge
- [ ] FASE 3: State (60min) → Migrar 6 providers para `@riverpod`
- [ ] FASE 4: UI (20min) → Atualizar widgets (já usa ConsumerWidget)
- [ ] FASE 5: Cleanup (10min) → Análise, testes, docs
- [ ] **Total Esperado**: 2h
- [ ] **Validation**: 0 errors, tests pass, build OK

---

### **3.2 app-petiveti (4-6h - WAVE 1 - Prioridade 2)**

**Contexto**:
- Médio porte
- Pet care management
- ~10 providers
- Provider + Riverpod misto

**Providers a Migrar**:
1. `animals_notifier.dart` → Pure Riverpod AsyncNotifier
2. `weights_provider.dart` → Pure Riverpod AsyncNotifier
3. `reminders_provider.dart` → Pure Riverpod AsyncNotifier
4. `auth_provider.dart` → Pure Riverpod AsyncNotifier
5. `theme_provider.dart` → Pure Riverpod AsyncNotifier
6. `settings_provider.dart` → Pure Riverpod AsyncNotifier
7. Outros providers secundários

**Estratégia**:
- Consolidar padrão aprendido em taskolist
- Aplicar Specialized Services pattern
- Validar performance em app médio

**Checklist app-petiveti**:
- [ ] FASE 1: Setup (20min)
- [ ] FASE 2: DI (20min)
- [ ] FASE 3: State (3-4h) → 10 providers
- [ ] FASE 4: UI (30-60min) → Muitos widgets
- [ ] FASE 5: Cleanup (20min)
- [ ] **Total Esperado**: 4-6h
- [ ] **Validation**: Quality score ≥9/10

---

### **3.3 app-calculei (4h - WAVE 1 - Prioridade 3)**

**Contexto**:
- Apps de calculadoras trabalhistas
- Sem estado complexo (cálculos stateless)
- ~8 calculadoras independentes
- Pouco ou nenhum Provider atualmente

**Providers a Migrar**:
1. Criar providers para cada calculadora (se necessário)
2. Theme provider
3. Settings provider
4. Premium/subscription provider

**Estratégia**:
- Validar simplicidade (muitas calculadoras são stateless)
- Usar `@riverpod` functions (não AsyncNotifier) para cálculos puros
- Template para apps simples

**Checklist app-calculei**:
- [ ] FASE 1: Setup (20min)
- [ ] FASE 2: DI (15min) → Minimal
- [ ] FASE 3: State (2-3h) → Criar providers se necessário
- [ ] FASE 4: UI (30min) → Widgets simples
- [ ] FASE 5: Cleanup (15min)
- [ ] **Total Esperado**: 4h
- [ ] **Validation**: Build OK, 0 errors

---

### **3.4 app-receituagro (6-8h - WAVE 2 - Prioridade 4)**

**Contexto**:
- Grande porte
- Agricultural diagnostics
- ~15 providers
- Muitos notifiers Riverpod existentes

**Providers a Migrar**:
1. `diagnosticos_notifier.dart` → Validar/refactor
2. `pragas_notifier.dart` → Validar/refactor
3. `favoritos_notifier.dart` → Validar/refactor
4. `comentarios_notifier.dart` → Validar/refactor
5. `busca_avancada_notifier.dart` → Validar/refactor
6. `auth_notifier.dart` → Validar/refactor
7. `settings_notifier.dart` → Validar/refactor
8. E outros ~8 providers

**Estratégia**:
- Já tem muitos notifiers Riverpod
- Refatorar para `@riverpod` code generation
- Aplicar aprendizados de apps anteriores

**Checklist app-receituagro**:
- [ ] FASE 1: Setup (30min)
- [ ] FASE 2: DI (30min)
- [ ] FASE 3: State (4-5h) → 15 providers
- [ ] FASE 4: UI (1-2h) → UI complexa
- [ ] FASE 5: Cleanup (30min)
- [ ] **Total Esperado**: 6-8h
- [ ] **Validation**: Manter quality score existente

---

### **3.5 app-gasometer (8-12h - WAVE 2 - Prioridade 5)**

**Contexto**:
- Médio/Grande porte
- Vehicle control
- ~20 providers
- Muito estado (vehicles, fuel, maintenance, expenses)

**Providers a Migrar**:
1. `fuel_riverpod_notifier.dart` → Já Riverpod, migrar para `@riverpod`
2. `vehicles_provider.dart` → Pure Riverpod AsyncNotifier
3. `maintenance_provider.dart` → Pure Riverpod AsyncNotifier
4. `expenses_provider.dart` → Pure Riverpod AsyncNotifier
5. `odometer_provider.dart` → Pure Riverpod AsyncNotifier
6. `analytics_provider.dart` → Pure Riverpod AsyncNotifier
7. `sync_provider.dart` → Pure Riverpod AsyncNotifier
8. `auth_provider.dart` → Pure Riverpod AsyncNotifier
9. E outros ~12 providers

**Estratégia**:
- App complexo com muitos providers
- Aplicar Specialized Services pattern
- Validar performance em app com muitos dados

**Checklist app-gasometer**:
- [ ] FASE 1: Setup (30min)
- [ ] FASE 2: DI (45min)
- [ ] FASE 3: State (6-8h) → 20 providers
- [ ] FASE 4: UI (1-2h) → UI complexa com gráficos
- [ ] FASE 5: Cleanup (45min)
- [ ] **Total Esperado**: 8-12h
- [ ] **Validation**: Quality score ≥9/10

---

### **3.6 app-agrihurbi (6-8h - WAVE 2 - Prioridade 6)**

**Contexto**:
- Agricultural management
- Provider + Riverpod misto
- ~12 providers
- Remover Provider completamente

**Providers a Migrar**:
1. `weather_provider.dart` → Pure Riverpod AsyncNotifier
2. `livestock_provider.dart` → Pure Riverpod AsyncNotifier
3. `markets_provider.dart` → Pure Riverpod AsyncNotifier
4. `news_provider.dart` → Pure Riverpod AsyncNotifier
5. `settings_provider.dart` → Pure Riverpod AsyncNotifier
6. E outros ~7 providers

**Estratégia**:
- Remover Provider misto definitivamente
- Unificar em Riverpod puro
- Aplicar padrões consolidados

**Checklist app-agrihurbi**:
- [ ] FASE 1: Setup (30min)
- [ ] FASE 2: DI (30min)
- [ ] FASE 3: State (4-5h) → 12 providers
- [ ] FASE 4: UI (1-2h)
- [ ] FASE 5: Cleanup (30min)
- [ ] **Total Esperado**: 6-8h
- [ ] **Validation**: Pure Riverpod, 0 Provider deps

---

### **3.7 web_receituagro (3h - WAVE 3 - Prioridade 7)**

**Contexto**:
- Web platform
- Compartilha código com app-receituagro
- ~6 providers
- Web-specific considerations

**Providers a Migrar**:
1. Shared providers com app-receituagro
2. Web-specific providers (routing, responsive)

**Estratégia**:
- Aproveitar providers de app-receituagro
- Adicionar web-specific providers
- Validar Riverpod em Flutter Web

**Checklist web_receituagro**:
- [ ] FASE 1: Setup (20min)
- [ ] FASE 2: DI (20min)
- [ ] FASE 3: State (1.5h) → 6 providers
- [ ] FASE 4: UI (45min) → Responsive widgets
- [ ] FASE 5: Cleanup (15min)
- [ ] **Total Esperado**: 3h
- [ ] **Validation**: Web build OK

---

### **3.8 web_agrimind_site (2h - WAVE 3 - Prioridade 8)**

**Contexto**:
- Simple web site
- Minimal state management
- ~4 providers
- Marketing/promotional content

**Providers a Migrar**:
1. Navigation provider
2. Theme provider
3. Analytics provider
4. Contact form provider

**Estratégia**:
- Simplicidade máxima
- Validar Riverpod em site estático

**Checklist web_agrimind_site**:
- [ ] FASE 1: Setup (15min)
- [ ] FASE 2: DI (15min)
- [ ] FASE 3: State (1h) → 4 providers
- [ ] FASE 4: UI (20min)
- [ ] FASE 5: Cleanup (10min)
- [ ] **Total Esperado**: 2h
- [ ] **Validation**: Web build OK

---

### **3.9 app-nebulalist (2h - WAVE 3 - Prioridade 9)**

**Contexto**:
- **JÁ Pure Riverpod (9/10 quality score)**
- Refactor para seguir padrões finalizados
- ~15 providers já com `@riverpod`

**Tarefas**:
1. Validar se seguem padrões finalizados
2. Refactor minor se necessário
3. Adicionar testes (priority)
4. README update

**Estratégia**:
- Não migrar (já Riverpod)
- Refinar para seguir padrões consolidados
- **PRIORIDADE: Adicionar testes (blocker para 10/10)**

**Checklist app-nebulalist**:
- [ ] Review providers (validar padrões)
- [ ] Refactor se necessário (minor)
- [ ] **PRIORITY: Adicionar testes unitários (5-7 por use case)**
- [ ] README profissional (já feito ✅)
- [ ] Sync service completar (stub mode atual)
- [ ] **Total Esperado**: 2h refactor + 8h testes
- [ ] **Validation**: Quality score 10/10

---

### **3.10 app-plantis (12-16h - WAVE 3 - Prioridade 10 - ÚLTIMO)**

**Contexto**:
- **Gold Standard 10/10**
- Maior complexidade
- ~20 providers
- 13 testes unitários existentes
- Migração CUIDADOSA mantendo qualidade

**Providers a Migrar**:
1. `plants_provider.dart` → Pure Riverpod AsyncNotifier
2. `tasks_notifier.dart` → Pure Riverpod AsyncNotifier
3. `spaces_provider.dart` → Pure Riverpod AsyncNotifier
4. `comments_provider.dart` → Pure Riverpod AsyncNotifier
5. `sync_provider.dart` → Pure Riverpod AsyncNotifier
6. `notifications_provider.dart` → Pure Riverpod AsyncNotifier
7. `settings_provider.dart` → Pure Riverpod AsyncNotifier
8. E outros ~13 providers

**Estratégia**:
- **ÚLTIMA migração (aplicar TODOS aprendizados)**
- Manter 0 errors, 0 warnings
- Manter 100% test pass rate
- Adicionar testes para novos providers Riverpod
- Documentação exemplar

**Checklist app-plantis**:
- [ ] FASE 1: Setup (45min) → Cuidadoso
- [ ] FASE 2: DI (1h) → Bridge GetIt completo
- [ ] FASE 3: State (8-10h) → 20 providers, Specialized Services
- [ ] FASE 4: UI (2-3h) → UI complexa, muitos widgets
- [ ] FASE 5: Cleanup (1-2h) → Testes, análise, docs
- [ ] **Migrar testes**: Adapter para ProviderContainer
- [ ] **Adicionar testes**: Novos providers Riverpod
- [ ] **README**: Atualizar para mencionar Riverpod
- [ ] **Total Esperado**: 12-16h
- [ ] **Validation**: Quality score 10/10 MANTIDO

---

## ⚠️ 4. Riscos e Mitigações

### **4.1 Riscos Técnicos**

**RISCO 1: Build runner falha em code generation**

**Impacto**: Alto (bloqueia migração)
**Probabilidade**: Média

**Mitigações**:
```bash
# Limpar cache antes de build
flutter clean
flutter pub get
rm -rf .dart_tool/build/

# Executar com verbose para debug
dart run build_runner build --delete-conflicting-outputs --verbose

# Se falhar, gerar um provider por vez
dart run build_runner build --build-filter="lib/features/plants/presentation/providers/plants_provider.dart"
```

**Rollback**: Usar providers sem code generation temporariamente (manual)

---

**RISCO 2: Testes quebram após migração**

**Impacto**: Alto (qualidade comprometida)
**Probabilidade**: Média-Alta

**Mitigações**:
```dart
// Migrar testes para ProviderContainer
test('should add plant', () async {
  final mockRepository = MockPlantsRepository();
  when(() => mockRepository.addPlant(any()))
      .thenAnswer((_) async => Right(Plant(id: '1')));

  final container = ProviderContainer(
    overrides: [
      plantsRepositoryProvider.overrideWithValue(mockRepository),
    ],
  );

  final notifier = container.read(plantsNotifierProvider.notifier);
  await notifier.addPlant(Plant(name: 'Rosa'));

  final state = container.read(plantsNotifierProvider);
  expect(state.hasValue, true);
  expect(state.value!.length, 1);

  verify(() => mockRepository.addPlant(any())).called(1);
  container.dispose();
});
```

**Rollback**: Manter testes Provider em paralelo até validar Riverpod

---

**RISCO 3: Performance degrada (memory leaks, UI lag)**

**Impacto**: Crítico (UX comprometida)
**Probabilidade**: Baixa

**Mitigações**:
- Usar `.select()` para rebuilds granulares
- Validar auto-dispose funcionando (Riverpod Inspector)
- Profile app antes e depois (Flutter DevTools)

```dart
// Performance monitoring
@riverpod
class PerformanceMonitor extends _$PerformanceMonitor {
  @override
  Map<String, int> build() {
    // Track provider builds
    ref.onDispose(() {
      print('PerformanceMonitor disposed');
    });
    return {};
  }
}
```

**Rollback**: Reverter app se performance degradar >20%

---

**RISCO 4: GetIt bridge não funciona (DI quebra)**

**Impacto**: Alto (app não inicia)
**Probabilidade**: Baixa

**Mitigações**:
```dart
// Validar bridge GetIt → Riverpod
@riverpod
PlantsRepository plantsRepository(PlantsRepositoryRef ref) {
  try {
    return getIt<PlantsRepository>();
  } catch (e) {
    // Fallback para instância direta (emergency)
    return PlantsRepositoryImpl(
      localDataSource: getIt<PlantsLocalDataSource>(),
      remoteDataSource: getIt<PlantsRemoteDataSource>(),
    );
  }
}
```

**Rollback**: Manter GetIt direto se bridge falhar

---

### **4.2 Riscos de Processo**

**RISCO 5: Deadline não cumprido (migração demora mais)**

**Impacto**: Médio (projeto atrasa)
**Probabilidade**: Média

**Mitigações**:
- Priorizar apps por valor (Wave 1 > Wave 2 > Wave 3)
- Aceitar migração parcial (alguns apps em Riverpod, outros em Provider)
- Ajustar escopo, NÃO qualidade

**Rollback**: Pausar migração e consolidar apps já migrados

---

**RISCO 6: Conhecimento insuficiente do time (curva de aprendizado)**

**Impacto**: Alto (migração lenta/erros)
**Probabilidade**: Média

**Mitigações**:
- Treinamento antes de Wave 1 (2h)
- Pair programming em primeiros apps
- Code review rigoroso
- Documentar padrões em cada app migrado

**Rollback**: N/A (investir em treinamento)

---

**RISCO 7: Conflitos de merge (multiple devs)**

**Impacto**: Médio (retrabalho)
**Probabilidade**: Baixa-Média

**Mitigações**:
- Migrar um app por vez (sequencial)
- OU dividir apps independentes entre devs (paralelo)
- Branches isolados por app
- Merge frequente (daily)

**Rollback**: Resolver conflitos manualmente

---

## 🎯 5. Métricas de Sucesso

### **5.1 Métricas Técnicas**

**Análise Estática**:
```bash
flutter analyze
```
- ✅ **Target**: 0 errors
- ⚠️ **Warning**: ≤5 warnings informativos
- ❌ **Failure**: >0 errors OU >10 warnings

**Riverpod Linting**:
```bash
dart run custom_lint
```
- ✅ **Target**: 0 issues
- ⚠️ **Warning**: ≤3 issues minor
- ❌ **Failure**: >5 issues

**Testes**:
```bash
flutter test
```
- ✅ **Target**: 100% pass rate
- ⚠️ **Warning**: ≥95% pass rate
- ❌ **Failure**: <95% pass rate

**Code Coverage**:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```
- ✅ **Target**: ≥80% coverage em use cases
- ⚠️ **Warning**: ≥70% coverage
- ❌ **Failure**: <70% coverage

**Build**:
```bash
flutter build apk --debug
flutter build apk --release
```
- ✅ **Target**: Build sucesso (debug + release)
- ❌ **Failure**: Build falha

---

### **5.2 Métricas de Performance**

**Test Performance**:
```bash
# Medir tempo de execução de testes
time flutter test

# ANTES (Provider): ~30s para 50 testes
# DEPOIS (Riverpod): ~3s para 50 testes (10x faster)
```
- ✅ **Target**: Redução ≥50% tempo de testes
- ⚠️ **Warning**: Redução ≥20%
- ❌ **Failure**: Aumento de tempo

**Build Size**:
```bash
# Comparar tamanho do APK
ls -lh build/app/outputs/flutter-apk/app-release.apk
```
- ✅ **Target**: Redução ≥5% OU manutenção
- ⚠️ **Warning**: Aumento ≤10%
- ❌ **Failure**: Aumento >10%

**UI Performance** (Flutter DevTools):
- Frame render time: ≤16ms (60fps)
- Jank count: 0 (smooth UI)
- Memory usage: Sem leaks

---

### **5.3 Métricas de Qualidade**

**Quality Score por App**:

| App | Score Atual | Target Score | Status |
|-----|-------------|--------------|--------|
| app-taskolist | ? | ≥9/10 | 🟡 Pending |
| app-petiveti | ? | ≥9/10 | 🟡 Pending |
| app-calculei | ? | ≥9/10 | 🟡 Pending |
| app-receituagro | ? | ≥9/10 | 🟡 Pending |
| app-gasometer | ? | ≥9/10 | 🟡 Pending |
| app-agrihurbi | ? | ≥9/10 | 🟡 Pending |
| web_receituagro | ? | ≥8/10 | 🟡 Pending |
| web_agrimind_site | ? | ≥8/10 | 🟡 Pending |
| app-nebulalist | 9/10 | 10/10 | 🟢 Target |
| app-plantis | 10/10 | 10/10 | 🟢 Maintain |

**Code Quality Checklist** (por app):
- [ ] 0 analyzer errors
- [ ] 0 critical warnings
- [ ] 0 Riverpod lint issues
- [ ] ≥80% test coverage (use cases)
- [ ] 100% test pass rate
- [ ] README atualizado
- [ ] Documentação de migração

---

### **5.4 Métricas de Processo**

**Timeline Tracking**:

| Wave | Apps | Estimated | Actual | Status |
|------|------|-----------|--------|--------|
| Wave 1 | taskolist, petiveti, calculei | 8-14h | ? | 🟡 Pending |
| Wave 2 | receituagro, gasometer, agrihurbi | 20-28h | ? | 🟡 Pending |
| Wave 3 | web_receituagro, web_agrimind, nebulalist, plantis | 17-23h | ? | 🟡 Pending |
| **TOTAL** | 10 apps | 45-57h | ? | 🟡 Pending |

**Velocity Tracking**:
- App-taskolist: [X]h (baseline)
- App-petiveti: [X]h (comparar com baseline)
- App-calculei: [X]h (comparar)
- Velocity média: [X]h/app
- Estimate accuracy: [X]%

---

## 🔄 6. Decisões Arquiteturais a Validar

### **6.1 Auto-Dispose Behavior**

**Decisão**: Usar auto-dispose padrão do Riverpod

**Rationale**:
- Riverpod auto-dispose providers quando não têm listeners
- Reduz memory leaks automaticamente
- Sem necessidade de `dispose()` manual

**Validação**:
```dart
// Verificar auto-dispose funcionando
@riverpod
class PlantsNotifier extends _$PlantsNotifier {
  @override
  Future<List<Plant>> build() async {
    // Log quando provider é criado
    print('PlantsNotifier created');

    ref.onDispose(() {
      // Log quando provider é auto-disposed
      print('PlantsNotifier disposed');
    });

    return await _loadPlants();
  }
}
```

**Exceções**:
- Providers que devem persistir: usar `keepAlive: true`

```dart
@Riverpod(keepAlive: true)  // Não auto-dispose
AppConfig appConfig(AppConfigRef ref) {
  return AppConfig.load();
}
```

---

### **6.2 Caching Strategy**

**Decisão**: Usar cache automático do Riverpod (read vs watch)

**Padrão**:
```dart
// ref.watch() → Rebuild quando provider muda (reactive)
final plants = ref.watch(plantsNotifierProvider);

// ref.read() → Não rebuild (one-time read)
final notifier = ref.read(plantsNotifierProvider.notifier);
```

**Cache Invalidation**:
```dart
// Manual invalidation
ref.invalidate(plantsNotifierProvider);  // Force reload

// Self invalidation
ref.invalidateSelf();  // Dentro do notifier

// Selective invalidation
ref.refresh(plantsNotifierProvider);  // Reload específico
```

**Validação**:
- Verificar que dados não ficam stale
- Validar que refresh funciona corretamente

---

### **6.3 Error Handling**

**Decisão**: Either<Failure, T> → Exception em Riverpod

**Padrão**:
```dart
// Use case retorna Either<Failure, T>
final result = await useCase.call(params);

// Converter para exception para AsyncValue
return result.fold(
  (failure) => throw failure,  // AsyncValue.error captura
  (data) => data,              // AsyncValue.data
);
```

**Tratamento na UI**:
```dart
plantsAsync.when(
  data: (plants) => SuccessWidget(plants),
  loading: () => LoadingWidget(),
  error: (error, stack) {
    // error é Failure object
    if (error is ValidationFailure) {
      return ValidationErrorWidget(error.message);
    } else if (error is NetworkFailure) {
      return NetworkErrorWidget(error.message);
    }
    return GenericErrorWidget(error.toString());
  },
);
```

**Validação**:
- Verificar que todos Failures são capturados
- Validar que UI mostra erros apropriados

---

### **6.4 Dependency Ordering**

**Decisão**: Riverpod resolve dependências automaticamente

**Padrão**:
```dart
// Provider A depende de Provider B
@riverpod
class PlantsNotifier extends _$PlantsNotifier {
  @override
  Future<List<Plant>> build() async {
    // Riverpod garante que spacesNotifierProvider está pronto
    final spaces = await ref.watch(spacesNotifierProvider.future);

    // Usa spaces para filtrar plants
    final plants = await _loadPlants();
    return _filterBySpaces(plants, spaces);
  }
}
```

**Circular Dependencies** (EVITAR):
```dart
// ❌ ERRADO: A depende de B, B depende de A
@riverpod
class A extends _$A {
  @override
  int build() => ref.watch(bProvider) + 1;
}

@riverpod
class B extends _$B {
  @override
  int build() => ref.watch(aProvider) + 1;  // Circular!
}
```

**Solução**:
```dart
// ✅ CORRETO: Extrair lógica compartilhada
@riverpod
int sharedValue(SharedValueRef ref) => 42;

@riverpod
class A extends _$A {
  @override
  int build() => ref.watch(sharedValueProvider) + 1;
}

@riverpod
class B extends _$B {
  @override
  int build() => ref.watch(sharedValueProvider) + 2;
}
```

**Validação**:
- Usar Riverpod Inspector para visualizar dependências
- Verificar que não há circular dependencies

---

### **6.5 Testing Strategy**

**Decisão**: ProviderContainer para testes unitários (sem widgets)

**Padrão**:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockPlantsRepository extends Mock implements PlantsRepository {}

void main() {
  late ProviderContainer container;
  late MockPlantsRepository mockRepository;

  setUp(() {
    mockRepository = MockPlantsRepository();

    container = ProviderContainer(
      overrides: [
        plantsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('should load plants on build', () async {
    // Arrange
    when(() => mockRepository.getPlants())
        .thenAnswer((_) async => Right([Plant(id: '1', name: 'Rosa')]));

    // Act
    final plantsAsync = container.read(plantsNotifierProvider);
    await container.read(plantsNotifierProvider.future);

    // Assert
    expect(plantsAsync.hasValue, true);
    expect(plantsAsync.value!.length, 1);
    verify(() => mockRepository.getPlants()).called(1);
  });

  test('should add plant', () async {
    // Arrange
    when(() => mockRepository.getPlants())
        .thenAnswer((_) async => Right([]));
    when(() => mockRepository.addPlant(any()))
        .thenAnswer((_) async => Right(Plant(id: '1', name: 'Rosa')));

    // Act
    await container.read(plantsNotifierProvider.future);
    await container.read(plantsNotifierProvider.notifier).addPlant(
      Plant(name: 'Rosa'),
    );

    // Assert
    final state = container.read(plantsNotifierProvider);
    expect(state.value!.length, 1);
    verify(() => mockRepository.addPlant(any())).called(1);
  });
}
```

**Validação**:
- Migrar todos testes existentes para ProviderContainer
- Adicionar testes para novos providers Riverpod
- Target: ≥80% coverage

---

## 📝 7. Próximos Passos

### **7.1 Antes de Começar (HOJE)**

1. [ ] **Review deste plano** com time técnico (30min)
2. [ ] **Aprovar estratégia** e ordem de migração
3. [ ] **Agendar Wave 1** (app-taskolist inicio)
4. [ ] **Setup CI/CD** para Riverpod linting
5. [ ] **Criar branches**:
   ```bash
   git checkout -b migration/provider-to-riverpod-backup
   git push origin migration/provider-to-riverpod-backup
   git checkout main
   git checkout -b migration/provider-to-riverpod-wave1
   ```

### **7.2 Wave 1 - Learning Phase (3-5 dias)**

**Dia 1-2: app-taskolist (2h)**
- [ ] Executar Fases 1-5
- [ ] Validar métricas de sucesso
- [ ] Documentar aprendizados

**Dia 2-3: app-petiveti (4-6h)**
- [ ] Aplicar padrões de taskolist
- [ ] Validar em app médio
- [ ] Refinar documentação

**Dia 4-5: app-calculei (4h)**
- [ ] Validar simplicidade
- [ ] Consolidar padrões
- [ ] **Wave 1 Review**: Retrospectiva e ajustes

### **7.3 Wave 2 - Scaling Phase (1-1.5 semanas)**

**Semana 1**:
- [ ] app-receituagro (6-8h)
- [ ] app-gasometer (8-12h)
- [ ] app-agrihurbi (6-8h)
- [ ] **Wave 2 Review**: Validar escalabilidade

### **7.4 Wave 3 - Excellence Phase (1 semana)**

**Semana 2**:
- [ ] web_receituagro (3h)
- [ ] web_agrimind_site (2h)
- [ ] app-nebulalist refactor + TESTES (10h)
- [ ] app-plantis (12-16h) - **ÚLTIMO, cuidadoso**
- [ ] **Wave 3 Review**: Qualidade 10/10 validada

### **7.5 Após Migração Completa**

1. [ ] **Remover Provider** do monorepo completamente
2. [ ] **Atualizar CLAUDE.md** (padrão único: Riverpod)
3. [ ] **Atualizar agents** (.claude/agents/*.md)
4. [ ] **Criar guide**: `.claude/guides/RIVERPOD_BEST_PRACTICES.md`
5. [ ] **Team training**: Workshop Riverpod avançado (2h)
6. [ ] **Celebrate**: 🎉 Monorepo 100% Riverpod!

---

## 📚 8. Referências

### **Documentação Oficial**
- [Riverpod Docs](https://riverpod.dev)
- [Riverpod Code Generation](https://riverpod.dev/docs/concepts/about_code_generation)
- [Migration Guide](https://riverpod.dev/docs/migration/from_provider)

### **Guias Internos**
- `.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md`
- `apps/app-nebulalist/README.md` (Pure Riverpod reference)
- `apps/app-plantis/README.md` (Gold Standard 10/10)

### **Code Examples**
- `apps/app-nebulalist/lib/features/lists/presentation/providers/lists_provider.dart`
- `apps/app-nebulalist/lib/features/items/presentation/providers/item_masters_provider.dart`

---

## 🎯 9. Conclusão

Este plano fornece uma estratégia **sistemática, incremental e de baixo risco** para migrar 10 apps Flutter de Provider para Riverpod, mantendo qualidade 10/10 e zero downtime.

**Key Takeaways**:

1. **Incremental > Big Bang**: Migrar app por app com validação contínua
2. **Learning Waves**: Aplicar aprendizados iterativamente (Wave 1 → 2 → 3)
3. **Quality First**: Manter 0 errors, 100% tests, ≥80% coverage
4. **Safe Rollback**: Branch strategy + coexistência Provider/Riverpod
5. **Excellence Last**: app-plantis por último (aplicar TODOS aprendizados)

**Tempo Total**: 45-57 horas → 1.5-2 semanas com time dedicado

**Benefícios**:
- ⚡ +1000% performance em testes
- 🛡️ +100% type safety
- 📉 -40% boilerplate
- 🧪 Testabilidade massivamente melhorada

**Próximo Passo**: Aprovar este plano e iniciar Wave 1 (app-taskolist).

---

**Prepared by**: flutter-architect (Claude Code)
**Date**: 2025-11-15
**Version**: 1.0
**Status**: 🟡 Awaiting Approval

---

## ✅ Aprovação

- [ ] **Tech Lead**: Revisado e aprovado
- [ ] **Team**: Alinhado e treinado
- [ ] **CI/CD**: Configurado para Riverpod
- [ ] **Timeline**: Confirmado (1.5-2 semanas)

**Assinaturas**:
- Tech Lead: _________________ Data: _______
- Senior Dev 1: ______________ Data: _______
- Senior Dev 2: ______________ Data: _______

**Ready to start**: [ ] YES [ ] NO

---

🚀 **Let's migrate to Riverpod and elevate our monorepo to the next level!**
