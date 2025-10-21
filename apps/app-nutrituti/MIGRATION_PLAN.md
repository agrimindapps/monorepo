# 📋 Plano de Migração Detalhado: app-nutrituti

**Status Atual**: App standalone integrado ao monorepo (Fase 1 ✅)
**Objetivo**: App 100% funcional com Clean Architecture + Riverpod
**Prazo Estimado**: 40-60 horas (1.5-2 semanas)

---

## 📊 Análise Inicial

### Métricas do Projeto

| Métrica | Valor | Status |
|---------|-------|--------|
| **Total de arquivos Dart** | 282 | - |
| **Erros + Warnings** | 1,645 | 🔴 |
| **Pages** | 253 | - |
| **Controllers** | 30 | 🔴 GetX |
| **Arquivos com GetX** | 41 | 🔴 |
| **Variáveis reativas GetX** | 64+ | 🔴 |
| **Imports core antigos** | 33 únicos | 🔴 |
| **Calculadoras** | 19+ | ✅ |
| **Features principais** | 8+ | ✅ |

### Categorização de Erros (1,645 total)

#### 🔴 **Críticos** (400+ erros)
1. **GetX não existe** (150+ erros)
   - `package:get/get.dart` not found
   - 41 arquivos afetados
   - Controllers, pages, widgets

2. **Core antigo** (100+ erros)
   - 33 imports de arquivos que não existem
   - Serviços, models, controllers base
   - Precisa criar adapters ou migrar

3. **Dependencies faltando** (20+ erros)
   - `table_calendar` (beber_agua_page.dart)
   - Outras libs específicas

4. **Conflitos de nome** (5 erros)
   - `Environment` (local vs core)
   - Precisa renomear classe

#### 🟡 **Importantes** (600+ warnings)
- Reactive getters não definidos (`.obs`, `RxBool`, `RxList`)
- Métodos GetX não definidos (`Obx()`, `Get.to()`, `update()`)
- Override sem superclass (`onInit()`, `toMap()`)
- Type inference failures

#### 🟢 **Estilo** (600+ info)
- File naming (`app-page.dart`)
- Import ordering
- Unused variables
- Await missing
- Classes with only static members

---

## 🎯 Estratégia de Migração

### Princípios Norteadores

1. **Incremental**: Trabalhar por features, não tudo de uma vez
2. **Compilável**: Manter app compilando entre fases
3. **Testável**: Validar cada fase antes de avançar
4. **Documentado**: Atualizar README e documentação

### Ordem de Execução

```
FASE 1 ✅ → FASE 2 → FASE 3 → FASE 4 → FASE 5 → FASE 6 → FASE 7 → FASE 8
  Setup    Deps     Core     GetX     Clean    Features Quality  Polish
           Fix     Adapters  Remove   Arch     Migrate
```

---

## 📅 FASE 2: Correções de Dependencies (4-6h)

**Objetivo**: Resolver dependencies faltando e conflitos de nome

### Tarefas

#### 2.1. Adicionar Dependencies Faltando (1h)
- [ ] Adicionar `table_calendar` ao pubspec.yaml
- [ ] Verificar outras deps específicas (calendário, gráficos, etc)
- [ ] Executar `flutter pub get`

#### 2.2. Resolver Conflito de Nomes (1h)
- [ ] Renomear `lib/const/environment_const.dart::Environment` → `AppEnvironment`
- [ ] Atualizar todas as referências (main.dart, etc)
- [ ] Usar `GlobalEnvironment` do core onde apropriado

#### 2.3. File Naming (1h)
- [ ] Renomear `lib/app-page.dart` → **CONCLUÍDO** (já migrado)
- [ ] Verificar outros arquivos com hífen

#### 2.4. Organizar Imports (2h)
- [ ] Ordenar imports seguindo padrão Dart
- [ ] Remover imports não utilizados
- [ ] Agrupar: dart → flutter → packages → local

**Critério de Sucesso**:
- ✅ Erros de dependencies: 0
- ✅ Conflitos de nome: 0
- ✅ File naming warnings: 0

**Resultado Esperado**: ~100 erros resolvidos (de 1,645 → 1,545)

---

## 🔧 FASE 3: Core Adapters & Bridges (8-12h)

**Objetivo**: Criar adapters para serviços core antigos

### 3.1. Mapear Serviços Necessários (2h)

**Arquivos Core Antigos (33 únicos)**:

| Arquivo Antigo | Novo Equivalente | Ação |
|----------------|------------------|------|
| `../../core/services/info_device_service.dart` | `packages/core` Platform detection | Criar adapter |
| `../../core/services/subscription_factory_service.dart` | RevenueCat no core | Criar bridge |
| `../../core/controllers/base_auth_controller.dart` | Supabase auth | Criar base Riverpod |
| `../../core/models/base_model.dart` | Equatable entities | Criar base class |
| `../../core/models/auth_models.dart` | User entity | Criar models |
| `../../core/services/hive_service.dart` | `packages/core` Hive | Usar core |
| `../../core/themes/manager.dart` | Riverpod theme providers | **JÁ CRIADO** |
| `../../core/widgets/*` | Criar widgets compartilhados | Migrar/criar |
| `../../core/services/admob_service.dart` | `packages/core` AdMob | Usar core |
| `../../core/services/revenuecat_service.dart` | `packages/core` RevenueCat | Usar core |

### 3.2. Criar Adapters Prioritários (6h)

#### Adapter 1: InfoDeviceService (1h)
```dart
// lib/core/services/info_device_service.dart
class InfoDeviceService {
  ValueNotifier<bool> isProduction = ValueNotifier(true);

  void initialize() {
    // Usar GlobalEnvironment do core
    isProduction.value = GlobalEnvironment.isProduction;
  }
}
```

#### Adapter 2: BaseModel (1h)
```dart
// lib/core/models/base_model.dart
abstract class BaseModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BaseModel({this.id, this.createdAt, this.updatedAt});

  Map<String, dynamic> toMap();

  @override
  List<Object?> get props => [id, createdAt, updatedAt];
}
```

#### Adapter 3: BaseAuthController (2h)
```dart
// lib/features/auth/presentation/providers/auth_providers.dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<User?> build() async {
    // Supabase auth integration
    return _checkCurrentUser();
  }

  Future<void> signIn(String email, String password) async { }
  Future<void> signOut() async { }
}
```

#### Adapter 4: SubscriptionFactoryService (2h)
```dart
// lib/core/services/subscription_config.dart
import 'package:core/core.dart';

class SubscriptionConfig {
  static String getSubscriptionId(String platform, String tier) {
    // Usar RevenueCat do core
    return 'br.com.agrimind.nutrituti.$tier';
  }
}
```

### 3.3. Widgets Compartilhados (3h)

- [ ] Migrar widgets de `../../core/widgets/` necessários
- [ ] Criar versões locais ou usar do core
- [ ] SearchWidget, FeedbackWidget, AdMob widgets

**Critério de Sucesso**:
- ✅ Todos os imports de `../../core/` resolvidos
- ✅ Adapters compilando sem erros
- ✅ Serviços core integrados

**Resultado Esperado**: ~100 erros resolvidos (de 1,545 → 1,445)

---

## 🔄 FASE 4: Remoção Completa do GetX (12-16h)

**Objetivo**: Migrar de GetX para Riverpod

### 4.1. Preparação (2h)

- [ ] Criar provider structure base
- [ ] Definir padrões de notifiers
- [ ] Criar templates para migração

### 4.2. Migração de Controllers (8h)

**Controllers GetX (13 arquivos):**

| Controller | Linhas | Complexidade | Tempo |
|------------|--------|--------------|-------|
| `auth_controller.dart` | ~100 | Alta | 2h |
| `agua_controller.dart` | ~200 | Alta | 2h |
| `exercicio_controller.dart` | ~150 | Média | 1.5h |
| `meditacao_controller.dart` | ~100 | Média | 1h |
| `peso_controller.dart` | ~120 | Média | 1h |
| Outros (8 controllers) | ~400 | Baixa | 1.5h |

**Padrão de Migração:**

```dart
// ANTES (GetX)
class AguaController extends GetxController {
  RxList<BeberAgua> registros = <BeberAgua>[].obs;
  RxDouble metaDiaria = 2000.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void addRegistro(BeberAgua agua) {
    registros.add(agua);
    update();
  }
}

// DEPOIS (Riverpod)
@riverpod
class AguaNotifier extends _$AguaNotifier {
  @override
  Future<AguaState> build() async {
    return AguaState(
      registros: await _loadRegistros(),
      metaDiaria: await _loadMeta(),
    );
  }

  Future<void> addRegistro(BeberAgua agua) async {
    final current = await future;
    state = AsyncValue.data(
      current.copyWith(
        registros: [...current.registros, agua],
      ),
    );
    await _saveRegistro(agua);
  }
}
```

### 4.3. Migração de Pages (4h)

**Pages com GetX (41 arquivos):**

- [ ] Substituir `Obx()` por `Consumer` ou `ref.watch()`
- [ ] Remover `Get.to()` por `context.go()` (go_router)
- [ ] Converter widgets reativos

**Padrão de Migração:**

```dart
// ANTES
class BeberAguaPage extends StatelessWidget {
  final controller = Get.find<AguaController>();

  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
      itemCount: controller.registros.length,
      itemBuilder: (ctx, i) => Text('${controller.registros[i]}'),
    ));
  }
}

// DEPOIS
class BeberAguaPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aguaAsync = ref.watch(aguaNotifierProvider);

    return aguaAsync.when(
      data: (agua) => ListView.builder(
        itemCount: agua.registros.length,
        itemBuilder: (ctx, i) => Text('${agua.registros[i]}'),
      ),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Erro: $err'),
    );
  }
}
```

### 4.4. Variáveis Reativas (2h)

**64+ linhas com `.obs`, `RxBool`, etc:**

- [ ] `RxBool` → `ValueNotifier<bool>` ou state no Notifier
- [ ] `RxList<T>` → `List<T>` no state
- [ ] `RxDouble` → `double` no state
- [ ] `.obs` → remover, usar `state = ...`
- [ ] `.value` → acessar state diretamente

**Critério de Sucesso**:
- ✅ Nenhum import de `package:get/get.dart`
- ✅ Nenhum `extends GetxController`
- ✅ Nenhum `Obx()`, `Get.to()`, etc
- ✅ Todos os controllers migrados para Riverpod

**Resultado Esperado**: ~400 erros resolvidos (de 1,445 → 1,045)

---

## 🏗️ FASE 5: Clean Architecture Foundation (10-14h)

**Objetivo**: Reorganizar código seguindo Clean Architecture

### 5.1. Criar Estrutura de Features (2h)

```
lib/
├── core/                      # ✅ Já existe
│   ├── di/
│   ├── router/
│   ├── theme/
│   └── widgets/               # Criar
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── providers/
│   │       └── widgets/
│   ├── calculators/          # 19 calculadoras
│   ├── water_tracking/       # Água
│   ├── exercise/             # Exercícios
│   ├── meditation/           # Meditação
│   ├── weight_tracking/      # Peso
│   ├── meals/                # Pratos
│   ├── recipes/              # Receitas
│   └── foods/                # Alimentos
└── shared/
    ├── models/
    ├── utils/
    └── constants/
```

### 5.2. Definir Entities e Models (3h)

**Entities Principais:**

```dart
// lib/features/water_tracking/domain/entities/water_record.dart
class WaterRecord extends Equatable {
  final String id;
  final DateTime timestamp;
  final double amount;
  final String? notes;

  const WaterRecord({
    required this.id,
    required this.timestamp,
    required this.amount,
    this.notes,
  });

  @override
  List<Object?> get props => [id, timestamp, amount, notes];
}
```

**Models (Data layer):**

```dart
// lib/features/water_tracking/data/models/water_record_model.dart
@HiveType(typeId: 10)
class WaterRecordModel extends WaterRecord {
  WaterRecordModel({
    required super.id,
    required super.timestamp,
    required super.amount,
    super.notes,
  });

  factory WaterRecordModel.fromEntity(WaterRecord entity) { }
  Map<String, dynamic> toJson() { }
  factory WaterRecordModel.fromJson(Map<String, dynamic> json) { }
}
```

### 5.3. Criar Repositories (3h)

**Repository Interfaces (Domain):**

```dart
// lib/features/water_tracking/domain/repositories/water_repository.dart
abstract class WaterRepository {
  Future<Either<Failure, List<WaterRecord>>> getRecords(DateTime date);
  Future<Either<Failure, WaterRecord>> addRecord(WaterRecord record);
  Future<Either<Failure, Unit>> deleteRecord(String id);
  Future<Either<Failure, double>> getDailyGoal();
  Future<Either<Failure, Unit>> setDailyGoal(double goal);
}
```

**Repository Implementation (Data):**

```dart
// lib/features/water_tracking/data/repositories/water_repository_impl.dart
@Injectable(as: WaterRepository)
class WaterRepositoryImpl implements WaterRepository {
  final HiveService _hive;

  WaterRepositoryImpl(this._hive);

  @override
  Future<Either<Failure, List<WaterRecord>>> getRecords(DateTime date) async {
    try {
      final box = await _hive.openBox<WaterRecordModel>('water_records');
      final records = box.values
          .where((r) => isSameDay(r.timestamp, date))
          .toList();
      return Right(records);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
```

### 5.4. Criar Use Cases (4h)

**Use Cases com Either<Failure, T>:**

```dart
// lib/features/water_tracking/domain/usecases/add_water_record.dart
@injectable
class AddWaterRecord {
  final WaterRepository _repository;

  AddWaterRecord(this._repository);

  Future<Either<Failure, WaterRecord>> call(AddWaterRecordParams params) async {
    // Validação
    if (params.amount <= 0) {
      return Left(ValidationFailure('Amount must be positive'));
    }

    final record = WaterRecord(
      id: const Uuid().v4(),
      timestamp: params.timestamp,
      amount: params.amount,
      notes: params.notes,
    );

    return await _repository.addRecord(record);
  }
}

class AddWaterRecordParams extends Equatable {
  final DateTime timestamp;
  final double amount;
  final String? notes;

  const AddWaterRecordParams({
    required this.timestamp,
    required this.amount,
    this.notes,
  });

  @override
  List<Object?> get props => [timestamp, amount, notes];
}
```

### 5.5. Atualizar Providers (2h)

```dart
// lib/features/water_tracking/presentation/providers/water_providers.dart
@riverpod
class WaterNotifier extends _$WaterNotifier {
  late final AddWaterRecord _addWaterRecord;
  late final GetWaterRecords _getWaterRecords;

  @override
  Future<WaterState> build() async {
    _addWaterRecord = getIt<AddWaterRecord>();
    _getWaterRecords = getIt<GetWaterRecords>();

    return _loadInitialData();
  }

  Future<void> addRecord(double amount, String? notes) async {
    state = const AsyncValue.loading();

    final result = await _addWaterRecord(
      AddWaterRecordParams(
        timestamp: DateTime.now(),
        amount: amount,
        notes: notes,
      ),
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (record) async => state = AsyncValue.data(await _loadInitialData()),
    );
  }
}
```

**Critério de Sucesso**:
- ✅ Features organizadas por domínio
- ✅ Entities e Models definidos
- ✅ Repositories com Either<Failure, T>
- ✅ Use Cases implementados
- ✅ Providers usando DI

**Resultado Esperado**: ~200 erros resolvidos (de 1,045 → 845)

---

## 🔨 FASE 6: Migração de Features (16-20h)

**Objetivo**: Migrar todas as features para Clean Architecture

### Priorização de Features

| Feature | Arquivos | Complexidade | Prioridade | Tempo |
|---------|----------|--------------|------------|-------|
| **Auth** | 5 | Alta | 🔴 P0 | 3h |
| **Water Tracking** | 8 | Alta | 🔴 P0 | 4h |
| **Calculators** (19 calcs) | 95 | Média | 🟡 P1 | 8h |
| **Weight Tracking** | 6 | Média | 🟡 P1 | 2h |
| **Exercise** | 12 | Média | 🟡 P1 | 3h |
| **Foods/Meals** | 20 | Baixa | 🟢 P2 | 4h |
| **Recipes** | 8 | Baixa | 🟢 P2 | 2h |
| **Meditation** | 4 | Baixa | 🟢 P2 | 1h |
| **Profile/Settings** | 10 | Média | 🟡 P1 | 3h |

### 6.1. Feature: Auth (3h)

- [ ] Entities: User, AuthState
- [ ] Repository: AuthRepository (Supabase)
- [ ] Use Cases: SignIn, SignUp, SignOut, GetCurrentUser
- [ ] Providers: authNotifierProvider
- [ ] Pages: LoginPage, SignupPage

### 6.2. Feature: Water Tracking (4h)

- [ ] Entities: WaterRecord, WaterGoal, WaterAchievement
- [ ] Repository: WaterRepository (Hive)
- [ ] Use Cases: AddRecord, GetRecords, SetGoal, GetAchievements
- [ ] Providers: waterNotifierProvider, waterStatsProvider
- [ ] Pages: BeberAguaPage, BeberAguaCadastroPage
- [ ] Widgets: WaterCard, WaterChart, CalendarWidget

### 6.3. Feature: Calculators (8h)

**19 Calculadoras para migrar:**

Estratégia: Criar base class para calculadoras

```dart
// lib/features/calculators/domain/entities/calculator_result.dart
abstract class CalculatorResult extends Equatable {
  final double value;
  final String unit;
  final String interpretation;
  final DateTime calculatedAt;
}

// lib/features/calculators/domain/usecases/calculate.dart
abstract class Calculate<P extends CalculatorParams, R extends CalculatorResult> {
  Either<Failure, R> call(P params);
}
```

Migrar cada calculadora:
- [ ] IMC (Massa Corpórea)
- [ ] Peso Ideal
- [ ] Calorias Diárias
- [ ] Taxa Metabólica Basal
- [ ] Macronutrientes
- [ ] Proteínas Diárias
- [ ] Necessidade Hídrica
- [ ] Déficit/Superávit
- [ ] Densidade Óssea
- [ ] Cintura/Quadril
- [ ] Volume Sanguíneo
- [ ] Álcool no Sangue
- [ ] Calorias por Exercício
- [ ] Gasto Energético
- [ ] Densidade de Nutrientes
- [ ] ... (mais 4 calculadoras)

### 6.4. Feature: Weight Tracking (2h)

- [ ] Similar ao Water Tracking
- [ ] Entities: WeightRecord, WeightGoal
- [ ] Repository: WeightRepository
- [ ] Use Cases: AddRecord, GetHistory, GetStats
- [ ] Providers: weightNotifierProvider
- [ ] Pages: PesoPage

### 6.5. Feature: Exercise (3h)

- [ ] Entities: Exercise, ExerciseRecord, ExerciseCategory
- [ ] Repository: ExerciseRepository
- [ ] Use Cases: LogExercise, GetExercises, GetStats
- [ ] Providers: exerciseNotifierProvider
- [ ] Pages: ExercicioPage

### 6.6. Outras Features (12h)

- [ ] Foods/Meals (4h)
- [ ] Recipes (2h)
- [ ] Meditation (1h)
- [ ] Profile/Settings (3h)
- [ ] Premium/Subscription (2h)

**Critério de Sucesso**:
- ✅ Todas as features migradas
- ✅ Clean Architecture rigorosa
- ✅ Either<Failure, T> em todos os use cases
- ✅ Riverpod em toda presentation layer
- ✅ DI funcionando

**Resultado Esperado**: ~400 erros resolvidos (de 845 → 445)

---

## ✅ FASE 7: Quality & Testing (8-12h)

**Objetivo**: Alcançar qualidade Gold Standard

### 7.1. Corrigir Analyzer (4h)

- [ ] Resolver todos os erros restantes
- [ ] Corrigir warnings críticos
- [ ] Aplicar lints recomendados
- [ ] Executar `flutter analyze`: 0 errors

### 7.2. Testes Unitários (6h)

**Cobertura mínima: ≥80% para use cases**

```dart
// test/features/water_tracking/domain/usecases/add_water_record_test.dart
void main() {
  late AddWaterRecord usecase;
  late MockWaterRepository mockRepository;

  setUp(() {
    mockRepository = MockWaterRepository();
    usecase = AddWaterRecord(mockRepository);
  });

  group('AddWaterRecord', () {
    test('should return WaterRecord when successful', () async {
      // Arrange
      final params = AddWaterRecordParams(
        timestamp: DateTime.now(),
        amount: 250.0,
      );
      final expectedRecord = WaterRecord(/* ... */);
      when(() => mockRepository.addRecord(any()))
          .thenAnswer((_) async => Right(expectedRecord));

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, Right(expectedRecord));
      verify(() => mockRepository.addRecord(any())).called(1);
    });

    test('should return ValidationFailure when amount is negative', () async {
      // ...
    });

    test('should return CacheFailure when repository fails', () async {
      // ...
    });
  });
}
```

**Testes por Feature:**

- [ ] Auth: 5-7 testes por use case
- [ ] Water: 5-7 testes por use case
- [ ] Calculators: 3-5 testes por calculator
- [ ] Weight: 5-7 testes
- [ ] Exercise: 5-7 testes

### 7.3. Code Review & Refactoring (2h)

- [ ] Remover código morto
- [ ] Otimizar imports
- [ ] Aplicar const constructors
- [ ] Verificar performance

**Critério de Sucesso**:
- ✅ `flutter analyze`: 0 errors, 0 warnings
- ✅ `flutter test`: All tests passing
- ✅ Coverage: ≥80% use cases
- ✅ Sem código morto

**Resultado Esperado**: 0 erros (de 445 → 0) ✅

---

## 🎨 FASE 8: Polish & Documentation (4-6h)

**Objetivo**: Finalizar app para produção

### 8.1. UI/UX Polish (2h)

- [ ] Verificar responsividade
- [ ] Testar dark mode
- [ ] Adicionar loading states
- [ ] Melhorar mensagens de erro
- [ ] Accessibility (Semantics, contrast)

### 8.2. Documentation (2h)

- [ ] Atualizar README.md
- [ ] Documentar features
- [ ] Criar CHANGELOG.md
- [ ] Documentar APIs internas

### 8.3. Performance (1h)

- [ ] Otimizar builds
- [ ] Lazy loading
- [ ] Cache strategies
- [ ] Asset optimization

### 8.4. Final Checks (1h)

- [ ] Build debug APK
- [ ] Build release APK
- [ ] Test em dispositivos reais
- [ ] Verificar integração monorepo

**Critério de Sucesso**:
- ✅ App compila em debug e release
- ✅ README completo
- ✅ Performance aceitável
- ✅ Pronto para deploy

---

## 📈 Progresso e Métricas

### Roadmap Visual

```
FASE 1 ████████████████████ 100% ✅ Setup Inicial
FASE 2 ░░░░░░░░░░░░░░░░░░░░   0%    Dependencies Fix
FASE 3 ░░░░░░░░░░░░░░░░░░░░   0%    Core Adapters
FASE 4 ░░░░░░░░░░░░░░░░░░░░   0%    Remover GetX
FASE 5 ░░░░░░░░░░░░░░░░░░░░   0%    Clean Architecture
FASE 6 ░░░░░░░░░░░░░░░░░░░░   0%    Migrar Features
FASE 7 ░░░░░░░░░░░░░░░░░░░░   0%    Quality & Testing
FASE 8 ░░░░░░░░░░░░░░░░░░░░   0%    Polish & Docs
```

### Estimativas de Tempo

| Fase | Horas | Dias (8h/dia) | Cumulative |
|------|-------|---------------|------------|
| FASE 1 ✅ | 6h | 0.75 | 0.75 dias |
| FASE 2 | 5h | 0.6 | 1.35 dias |
| FASE 3 | 10h | 1.25 | 2.6 dias |
| FASE 4 | 14h | 1.75 | 4.35 dias |
| FASE 5 | 12h | 1.5 | 5.85 dias |
| FASE 6 | 18h | 2.25 | 8.1 dias |
| FASE 7 | 10h | 1.25 | 9.35 dias |
| FASE 8 | 5h | 0.6 | 9.95 dias |
| **TOTAL** | **80h** | **10 dias** | - |

**Prazo realista**: 2 semanas (10 dias úteis)

### Redução de Erros Esperada

```
1,645 erros (inicial)
↓ -100 (FASE 2: Dependencies)
1,545 erros
↓ -100 (FASE 3: Core Adapters)
1,445 erros
↓ -400 (FASE 4: Remover GetX)
1,045 erros
↓ -200 (FASE 5: Clean Arch)
845 erros
↓ -400 (FASE 6: Features)
445 erros
↓ -445 (FASE 7: Quality)
0 erros ✅
```

---

## 🚀 Próximos Passos Imediatos

### Para Começar FASE 2 (Dependencies Fix):

```bash
# 1. Adicionar table_calendar
flutter pub add table_calendar

# 2. Renomear Environment class
# (Manual edit em lib/const/environment_const.dart)

# 3. Organizar imports
dart fix --apply

# 4. Verificar progresso
flutter analyze
```

### Decisão Necessária

**Você quer que eu:**

**A)** Comece FASE 2 agora (Dependencies Fix - 4-6h)
- Adicionar deps faltando
- Resolver conflitos de nome
- Organizar imports

**B)** Revise o plano e ajuste prioridades
- Discutir abordagem
- Ajustar estimativas
- Definir escopo

**C)** Execute uma fase específica diferente
- Pular para FASE 4 (GetX removal)?
- Focar em uma feature específica?

---

## 📚 Referências

- **Gold Standard**: app-plantis (README.md, tests/, architecture)
- **Guia Riverpod**: `.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md`
- **Padrões Monorepo**: `CLAUDE.md`
- **Core Package**: `packages/core/`

---

**Status**: Plano criado, aguardando aprovação para execução 🚦
