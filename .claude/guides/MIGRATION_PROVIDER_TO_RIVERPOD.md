# 🔄 Guia de Migração: Provider → Riverpod

**Objetivo**: Migrar apps do monorepo de Provider para Riverpod mantendo Clean Architecture e qualidade 10/10.

---

## 📋 Overview da Migração

### **Filosofia da Migração**
- ✅ **Manter**: Clean Architecture, Repository Pattern, SOLID, Either<Failure, T>
- 🔄 **Substituir**: Provider → Riverpod (state management layer)
- ⚡ **Melhorar**: Testabilidade, type safety, developer experience

### **Estimativa de Tempo por App**
- **Pequeno** (< 10 providers): 4-6 horas
- **Médio** (10-20 providers): 8-12 horas
- **Grande** (> 20 providers): 16-20 horas

---

## 🎯 Fase 1: Setup Riverpod (30min)

### **1.1 Atualizar pubspec.yaml**

```yaml
dependencies:
  # REMOVER (Provider antigo)
  # provider: any  ❌

  # ADICIONAR (Riverpod)
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

dev_dependencies:
  # ADICIONAR (Code generation)
  riverpod_generator: ^2.6.1
  build_runner: ^2.4.6
  custom_lint: ^0.6.0
  riverpod_lint: ^2.6.1
```

### **1.2 Executar instalação**

```bash
cd apps/app-[nome]
flutter pub get
dart run build_runner watch --delete-conflicting-outputs
```

### **1.3 Configurar analysis_options.yaml**

```yaml
analyzer:
  plugins:
    - custom_lint

linter:
  rules:
    # Riverpod lints
    - provider_dependencies
    - scoped_providers_should_specify_dependencies
```

---

## 🔄 Fase 2: Migração de Providers (60-80% do tempo)

### **Padrão de Migração: ChangeNotifier → AsyncNotifier**

#### **❌ ANTES (Provider)**

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

#### **✅ DEPOIS (Riverpod com code generation)**

```dart
// providers/plants_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plants_provider.g.dart';

// Repository provider
@riverpod
PlantsRepository plantsRepository(PlantsRepositoryRef ref) {
  return ref.watch(getItProvider).get<PlantsRepository>();
  // OU inject direto se preferir
}

// State notifier
@riverpod
class PlantsNotifier extends _$PlantsNotifier {
  @override
  Future<List<Plant>> build() async {
    // Carrega estado inicial automaticamente
    final result = await ref.read(plantsRepositoryProvider).getPlants();

    return result.fold(
      (failure) => throw failure,  // AsyncValue captura automaticamente
      (plants) => plants,
    );
  }

  Future<void> addPlant(Plant plant) async {
    // AsyncValue.guard gerencia loading/error automaticamente
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await ref.read(plantsRepositoryProvider).addPlant(plant);

      return result.fold(
        (failure) => throw failure,
        (newPlant) {
          final currentPlants = state.value ?? [];
          return [...currentPlants, newPlant];
        },
      );
    });
  }

  Future<void> updatePlant(Plant plant) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await ref.read(plantsRepositoryProvider).updatePlant(plant);

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

  Future<void> deletePlant(String id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await ref.read(plantsRepositoryProvider).deletePlant(id);

      return result.fold(
        (failure) => throw failure,
        (_) {
          final currentPlants = state.value ?? [];
          return currentPlants.where((p) => p.id != id).toList();
        },
      );
    });
  }
}

// Providers derivados (computed/filtered)
@riverpod
List<Plant> plantsBySpace(PlantsBySpaceRef ref, String spaceId) {
  final plantsAsync = ref.watch(plantsNotifierProvider);

  return plantsAsync.when(
    data: (plants) => plants.where((p) => p.spaceId == spaceId).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}
```

### **Checklist de Migração por Provider**

Para cada `XxxProvider extends ChangeNotifier`:

- [ ] Criar arquivo `xxx_provider.dart` com `@riverpod`
- [ ] Adicionar `part 'xxx_provider.g.dart';`
- [ ] Converter `ChangeNotifier` → `AsyncNotifier` ou função `@riverpod`
- [ ] Substituir `notifyListeners()` por atualizações de `state`
- [ ] Usar `AsyncValue.guard()` para async operations
- [ ] Converter getters para `@riverpod` functions (derived states)
- [ ] Executar `dart run build_runner build --delete-conflicting-outputs`
- [ ] Verificar que `.g.dart` foi gerado sem erros

---

## 🎨 Fase 3: Migração de UI (20-30% do tempo)

### **Padrão de Migração: Widget → ConsumerWidget**

#### **❌ ANTES (Provider)**

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
            return PlantTile(plant: plant);
          },
        );
      },
    );
  }
}
```

#### **✅ DEPOIS (Riverpod)**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlantsPage extends ConsumerWidget {
  const PlantsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsNotifierProvider);

    // AsyncValue.when é MUITO melhor que if/else manual
    return plantsAsync.when(
      data: (plants) => ListView.builder(
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final plant = plants[index];
          return PlantTile(plant: plant);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorWidget(
        error: error,
        onRetry: () => ref.invalidate(plantsNotifierProvider),
      ),
    );
  }
}
```

### **Padrão: StatefulWidget → ConsumerStatefulWidget**

#### **❌ ANTES (Provider)**

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
  Widget build(BuildContext context) {
    final provider = Provider.of<PlantsProvider>(context);

    return AlertDialog(
      content: Form(
        key: _formKey,
        child: TextFormField(controller: _nameController),
      ),
      actions: [
        ElevatedButton(
          onPressed: provider.isLoading ? null : _savePlant,
          child: provider.isLoading
              ? CircularProgressIndicator()
              : Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _savePlant() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<PlantsProvider>(context, listen: false);
      await provider.addPlant(Plant(name: _nameController.text));
      Navigator.pop(context);
    }
  }
}
```

#### **✅ DEPOIS (Riverpod)**

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
  Widget build(BuildContext context) {
    // ref disponível automaticamente em ConsumerState
    final isLoading = ref.watch(
      plantsNotifierProvider.select((state) => state.isLoading),
    );

    return AlertDialog(
      content: Form(
        key: _formKey,
        child: TextFormField(controller: _nameController),
      ),
      actions: [
        ElevatedButton(
          onPressed: isLoading ? null : _savePlant,
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _savePlant() async {
    if (_formKey.currentState!.validate()) {
      // Não precisa de context, ref sempre disponível
      await ref.read(plantsNotifierProvider.notifier).addPlant(
        Plant(name: _nameController.text),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
```

### **Checklist de Migração de UI**

Para cada widget que usa Provider:

- [ ] `StatelessWidget` → `ConsumerWidget`
- [ ] `StatefulWidget` → `ConsumerStatefulWidget`
- [ ] `State<T>` → `ConsumerState<T>`
- [ ] Adicionar `WidgetRef ref` no `build()`
- [ ] `Consumer<T>` → `ref.watch(provider)`
- [ ] `Provider.of<T>(context, listen: false)` → `ref.read(provider)`
- [ ] `Provider.of<T>(context)` → `ref.watch(provider)`
- [ ] Usar `.when()` ou `.maybeWhen()` para `AsyncValue`
- [ ] Testar hot reload funcionando

---

## 🎯 Fase 4: Migração de main.dart (15min)

#### **❌ ANTES (Provider)**

```dart
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlantsProvider(getIt())),
        ChangeNotifierProvider(create: (_) => SpacesProvider(getIt())),
        ChangeNotifierProvider(create: (_) => TasksProvider(getIt())),
      ],
      child: const MyApp(),
    ),
  );
}
```

#### **✅ DEPOIS (Riverpod)**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Providers são declarados globalmente, não em main!
// Ver plants_provider.dart, spaces_provider.dart, etc.
```

**Benefício**: Providers auto-managed, sem boilerplate em `main.dart`!

---

## 🧪 Fase 5: Migração de Testes (10-20% do tempo)

### **Vantagem Riverpod: Testes SEM Widgets!**

#### **❌ ANTES (Provider - precisa de widgets)**

```dart
testWidgets('should add plant', (tester) async {
  final mockRepository = MockPlantsRepository();
  when(() => mockRepository.addPlant(any()))
      .thenAnswer((_) async => Right(Plant(id: '1')));

  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => PlantsProvider(mockRepository),
        child: const AddPlantPage(),
      ),
    ),
  );

  await tester.enterText(find.byType(TextField), 'Rosa');
  await tester.tap(find.text('Salvar'));
  await tester.pumpAndSettle();

  verify(() => mockRepository.addPlant(any())).called(1);
});
```

#### **✅ DEPOIS (Riverpod - testes puros!)**

```dart
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
});
```

**Benefício**: Testes 10x mais rápidos (sem widget rendering)!

---

## ✅ Checklist Final de Qualidade

### **Análise Estática**
```bash
flutter analyze
# Meta: 0 errors, warnings apenas informativos
```

### **Testes**
```bash
flutter test
# Meta: 100% dos testes passando
```

### **Build**
```bash
flutter build apk --debug
# Meta: Build sem erros
```

### **Riverpod Lint**
```bash
dart run custom_lint
# Meta: Sem warnings de Riverpod
```

---

## 📊 Comparação de Qualidade

| Métrica | Provider | Riverpod | Melhoria |
|---------|----------|----------|----------|
| **Type Safety** | Runtime | Compile-time | ✅ +100% |
| **Testabilidade** | Widget tests | Unit tests puros | ✅ +1000% performance |
| **Boilerplate** | Manual notifyListeners | Auto-managed | ✅ -40% código |
| **DevEx** | Boa | Excelente | ✅ +50% |
| **Loading/Error** | Manual | AsyncValue built-in | ✅ -60% código |
| **Debugging** | Medium | Provenance tracking | ✅ +80% |

---

## 🎯 Ordem Recomendada de Migração dos Apps

### **1. app-taskolist** (2h)
- Já usa core com Riverpod
- Menor esforço
- Aprendizado do time

### **2. app-petiveti** (4-6h)
- App simples
- Consolidar padrão

### **3. app-receituagro** (6-8h)
- Médio porte
- Aplicar aprendizados

### **4. app-gasometer** (8-12h)
- Médio/Grande porte
- Muitos providers

### **5. app-agrihurbi** (6-8h)
- Já tem Riverpod parcial
- Remover Provider misto

### **6. app-plantis** (12-16h) - **ÚLTIMO**
- Gold Standard 10/10
- Mais complexo
- Migração cuidadosa mantendo qualidade

**Total estimado**: 40-50 horas (1-2 semanas)

---

## 💡 Dicas e Truques

### **Performance Optimization**
```dart
// ✅ Use .select() para rebuilds granulares
final plantName = ref.watch(
  plantsNotifierProvider.select((state) =>
    state.value?.first.name ?? '',
  ),
);
```

### **Dependências entre Providers**
```dart
@riverpod
List<Task> plantTasks(PlantTasksRef ref, String plantId) {
  final plant = ref.watch(plantByIdProvider(plantId));
  final allTasks = ref.watch(tasksNotifierProvider);

  // Dependencies auto-tracked!
  return allTasks.where((t) => t.plantId == plantId).toList();
}
```

### **Auto-dispose**
```dart
// Riverpod auto-dispose quando não tem listeners
// Não precisa de dispose() manual!
```

---

**Pronto para começar a migração? Use este guia como referência passo a passo!** 🚀
