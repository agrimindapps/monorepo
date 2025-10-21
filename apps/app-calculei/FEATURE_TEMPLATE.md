# 📐 Template de Feature - Clean Architecture + SOLID

**Baseado em**: Vacation Calculator (Feature Piloto)
**Status**: ✅ **Gold Standard - Padrão de Referência**
**Testes**: 14/14 passando (100%)

---

## 🎯 Estrutura Padrão (Copiar para Cada Calculadora)

```
lib/features/[nome_calculadora]/
├── domain/
│   ├── entities/
│   │   └── [nome]_calculation.dart          # Entity pura (Equatable, copyWith)
│   ├── repositories/
│   │   └── [nome]_repository.dart           # Interface abstrata
│   └── usecases/
│       ├── calculate_[nome]_usecase.dart    # Lógica de cálculo + validação
│       ├── save_calculation_usecase.dart    # Persistência
│       └── get_calculation_history_usecase.dart  # Histórico
│
├── data/
│   ├── models/
│   │   ├── [nome]_calculation_model.dart    # Hive adapter
│   │   └── [nome]_calculation_model.g.dart  # Generated
│   ├── datasources/
│   │   └── [nome]_local_datasource.dart     # Hive operations
│   └── repositories/
│       └── [nome]_repository_impl.dart      # Concrete repository
│
└── presentation/
    ├── providers/
    │   ├── [nome]_calculator_provider.dart  # @riverpod providers
    │   └── [nome]_calculator_provider.g.dart # Generated
    ├── pages/
    │   └── [nome]_calculator_page.dart      # Main UI (ConsumerWidget)
    └── widgets/
        ├── [nome]_input_form.dart           # Input form
        └── calculation_result_card.dart     # Result display
```

---

## 📋 Checklist de Implementação

### **FASE 1: Domain Layer** (1-1.5h)

#### **1.1 Entity**
- [ ] Criar `domain/entities/[nome]_calculation.dart`
  ```dart
  class [Nome]Calculation extends Equatable {
    // Inputs
    final double input1;
    final double input2;

    // Results
    final double result;

    // Metadata
    final String id;
    final DateTime calculatedAt;

    // copyWith method
    // props override
  }
  ```

#### **1.2 Repository Interface**
- [ ] Criar `domain/repositories/[nome]_repository.dart`
  ```dart
  abstract class [Nome]Repository {
    Future<Either<Failure, [Nome]Calculation>> saveCalculation([Nome]Calculation);
    Future<Either<Failure, List<[Nome]Calculation>>> getCalculationHistory({int limit = 10});
    Future<Either<Failure, [Nome]Calculation>> getCalculationById(String id);
    Future<Either<Failure, void>> deleteCalculation(String id);
    Future<Either<Failure, void>> clearHistory();
  }
  ```

#### **1.3 Calculate Use Case**
- [ ] Criar `domain/usecases/calculate_[nome]_usecase.dart`
  ```dart
  @injectable
  class Calculate[Nome]UseCase {
    Future<Either<Failure, [Nome]Calculation>> call(Calculate[Nome]Params params) async {
      // 1. VALIDATION
      final validationError = _validate(params);
      if (validationError != null) return Left(validationError);

      // 2. CALCULATION
      try {
        final calculation = _performCalculation(params);
        return Right(calculation);
      } catch (e) {
        return Left(ValidationFailure('Erro no cálculo: $e'));
      }
    }

    ValidationFailure? _validate(Calculate[Nome]Params params) {
      // Validações de regras de negócio
    }

    [Nome]Calculation _performCalculation(Calculate[Nome]Params params) {
      // Lógica de cálculo
    }
  }
  ```

#### **1.4 Save Use Case**
- [ ] Criar `domain/usecases/save_calculation_usecase.dart`
  ```dart
  @injectable
  class Save[Nome]CalculationUseCase {
    final [Nome]Repository repository;

    Future<Either<Failure, [Nome]Calculation>> call([Nome]Calculation calculation) async {
      return repository.saveCalculation(calculation);
    }
  }
  ```

#### **1.5 Get History Use Case**
- [ ] Criar `domain/usecases/get_calculation_history_usecase.dart`
  ```dart
  @injectable
  class Get[Nome]CalculationHistoryUseCase {
    final [Nome]Repository repository;

    Future<Either<Failure, List<[Nome]Calculation>>> call({int limit = 10}) async {
      return repository.getCalculationHistory(limit: limit);
    }
  }
  ```

---

### **FASE 2: Data Layer** (1-1.5h)

#### **2.1 Model**
- [ ] Criar `data/models/[nome]_calculation_model.dart`
  ```dart
  import 'package:hive/hive.dart';

  part '[nome]_calculation_model.g.dart';

  @HiveType(typeId: XX) // Unique typeId (incrementar de 10+)
  class [Nome]CalculationModel extends [Nome]Calculation {
    @HiveField(0)
    @override
    final String id;

    @HiveField(1)
    @override
    final double input1;

    // ... todos os campos com @HiveField

    // fromEntity, toEntity
    // toJson, fromJson (Firebase)
  }
  ```

#### **2.2 Local DataSource**
- [ ] Criar `data/datasources/[nome]_local_datasource.dart`
  ```dart
  abstract class [Nome]LocalDataSource {
    Future<[Nome]CalculationModel> save([Nome]CalculationModel model);
    Future<List<[Nome]CalculationModel>> getAll({int limit = 10});
    Future<[Nome]CalculationModel?> getById(String id);
    Future<void> delete(String id);
    Future<void> clearAll();
  }

  @Injectable(as: [Nome]LocalDataSource)
  class [Nome]LocalDataSourceImpl implements [Nome]LocalDataSource {
    final Box<[Nome]CalculationModel> box;

    // Implementação com Hive
  }
  ```

#### **2.3 Repository Implementation**
- [ ] Criar `data/repositories/[nome]_repository_impl.dart`
  ```dart
  @Injectable(as: [Nome]Repository)
  class [Nome]RepositoryImpl implements [Nome]Repository {
    final [Nome]LocalDataSource localDataSource;

    @override
    Future<Either<Failure, [Nome]Calculation>> saveCalculation([Nome]Calculation calculation) async {
      try {
        final model = [Nome]CalculationModel.fromEntity(calculation);
        final saved = await localDataSource.save(model);
        return Right(saved.toEntity());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      } catch (e) {
        return Left(CacheFailure('Erro ao salvar: $e'));
      }
    }

    // Implementar outros métodos...
  }
  ```

---

### **FASE 3: Presentation Layer** (1.5-2h)

#### **3.1 Providers (Riverpod)**
- [ ] Criar `presentation/providers/[nome]_calculator_provider.dart`
  ```dart
  import 'package:riverpod_annotation/riverpod_annotation.dart';

  part '[nome]_calculator_provider.g.dart';

  // State
  class [Nome]CalculatorState {
    final [Nome]Calculation? calculation;
    final bool isLoading;
    final String? errorMessage;

    const [Nome]CalculatorState({
      this.calculation,
      this.isLoading = false,
      this.errorMessage,
    });

    [Nome]CalculatorState copyWith(...) { ... }
  }

  // Notifier
  @riverpod
  class [Nome]CalculatorNotifier extends _$[Nome]CalculatorNotifier {
    @override
    [Nome]CalculatorState build() {
      return const [Nome]CalculatorState();
    }

    Future<void> calculate(Calculate[Nome]Params params) async {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final useCase = ref.read(calculate[Nome]UseCaseProvider);
      final result = await useCase(params);

      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
        (calculation) => state = state.copyWith(
          isLoading: false,
          calculation: calculation,
        ),
      );
    }

    void clearCalculation() {
      state = const [Nome]CalculatorState();
    }
  }

  // Use Case Providers
  @riverpod
  Calculate[Nome]UseCase calculate[Nome]UseCase(Calculate[Nome]UseCaseRef ref) {
    return getIt<Calculate[Nome]UseCase>();
  }
  ```

#### **3.2 Page**
- [ ] Criar `presentation/pages/[nome]_calculator_page.dart`
  ```dart
  class [Nome]CalculatorPage extends ConsumerStatefulWidget {
    const [Nome]CalculatorPage({super.key});

    @override
    ConsumerState<[Nome]CalculatorPage> createState() => _[Nome]CalculatorPageState();
  }

  class _[Nome]CalculatorPageState extends ConsumerState<[Nome]CalculatorPage> {
    // Form controllers
    final _formKey = GlobalKey<FormState>();

    @override
    Widget build(BuildContext context) {
      final state = ref.watch([nome]CalculatorNotifierProvider);

      return Scaffold(
        appBar: AppBar(title: Text('[Nome] Calculator')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              [Nome]InputForm(
                formKey: _formKey,
                onCalculate: _handleCalculate,
              ),
              if (state.isLoading) CircularProgressIndicator(),
              if (state.errorMessage != null) ErrorWidget(state.errorMessage!),
              if (state.calculation != null) CalculationResultCard(
                calculation: state.calculation!,
              ),
            ],
          ),
        ),
      );
    }

    void _handleCalculate(Calculate[Nome]Params params) {
      if (_formKey.currentState!.validate()) {
        ref.read([nome]CalculatorNotifierProvider.notifier).calculate(params);
      }
    }
  }
  ```

#### **3.3 Widgets**
- [ ] Criar `presentation/widgets/[nome]_input_form.dart`
  ```dart
  class [Nome]InputForm extends StatefulWidget {
    final GlobalKey<FormState> formKey;
    final Function(Calculate[Nome]Params) onCalculate;

    // TextEditingControllers
    // Input fields
    // Validation
    // Submit button
  }
  ```

- [ ] Criar `presentation/widgets/calculation_result_card.dart`
  ```dart
  class CalculationResultCard extends StatelessWidget {
    final [Nome]Calculation calculation;

    // Display result fields
    // Format numbers
    // Show breakdown
  }
  ```

---

### **FASE 4: DI & Testes** (1h)

#### **4.1 Registrar Hive Adapter**
- [ ] Em `lib/main.dart`:
  ```dart
  await Hive.initFlutter();
  Hive.registerAdapter([Nome]CalculationModelAdapter());
  ```

#### **4.2 Executar Build Runner**
- [ ] `dart run build_runner build --delete-conflicting-outputs`

#### **4.3 Criar Testes Unitários**
- [ ] Criar `test/features/[nome]_calculator/domain/usecases/calculate_[nome]_usecase_test.dart`
  ```dart
  void main() {
    late Calculate[Nome]UseCase useCase;

    setUp(() {
      useCase = Calculate[Nome]UseCase();
    });

    group('Calculate[Nome]UseCase -', () {
      // SUCCESS SCENARIOS (mínimo 3 testes)
      test('should calculate successfully with valid data', () async { ... });
      test('should calculate with edge case scenario 1', () async { ... });
      test('should calculate with edge case scenario 2', () async { ... });

      // VALIDATION FAILURES (mínimo 6 testes)
      test('should return ValidationFailure when input1 is zero', () async { ... });
      test('should return ValidationFailure when input1 is negative', () async { ... });
      test('should return ValidationFailure when input1 exceeds limit', () async { ... });
      test('should return ValidationFailure when input2 is invalid', () async { ... });
      // ... mais validações conforme regras de negócio

      // CALCULATION TESTS (2-3 testes)
      test('should calculate correctly for low values', () async { ... });
      test('should calculate correctly for high values', () async { ... });

      // METADATA TESTS (2 testes)
      test('should generate unique ID for each calculation', () async { ... });
      test('should set calculatedAt timestamp', () async { ... });
    });
  }
  ```

- [ ] Executar testes: `flutter test test/features/[nome]_calculator/`

---

## 🎯 Padrões SOLID (Validação)

### **Checklist SOLID**
- [ ] **SRP**: Cada classe tem UMA responsabilidade
  - Use Case = cálculo e validação
  - Repository = persistência
  - Provider = state management
  - Widget = UI

- [ ] **OCP**: Aberto para extensão, fechado para modificação
  - Entity tem copyWith (extensível)
  - Repository é interface (múltiplas implementações possíveis)

- [ ] **LSP**: Substituição de classes
  - Model estende Entity
  - Repository implementation substituível por interface

- [ ] **ISP**: Interfaces segregadas
  - Repository específico por feature
  - DataSource específico (Local vs Remote)

- [ ] **DIP**: Depender de abstrações
  - Use Case depende de Repository interface (não implementação)
  - Presentation depende de Use Cases (injetados via DI)

---

## ✅ Critérios de Conclusão

### **Code Quality**
- [ ] 0 analyzer errors na feature
- [ ] ≥14 testes unitários (100% pass rate)
- [ ] Build runner executado sem erros
- [ ] Imports organizados (package:app_calculei/)

### **Architecture**
- [ ] Domain Layer 100% Pure Dart (zero dependencies externas)
- [ ] Data Layer com Hive (typeId único)
- [ ] Presentation Layer com Riverpod (@riverpod)
- [ ] Either<Failure, T> em todo domain

### **Functionality**
- [ ] Cálculo correto (testar manualmente)
- [ ] Validações funcionando
- [ ] Histórico salvo (Hive)
- [ ] UI responsiva

---

## 📊 Métricas de Referência (Vacation Calculator)

```
✅ Arquivos: 14 (12 source + 2 generated)
✅ Linhas de código: ~1,500
✅ Testes: 14/14 (100% pass rate)
✅ Analyzer errors: 0
✅ Tempo de implementação: 4-6 horas (primeira vez)
✅ Tempo de replicação: 2-3 horas (seguindo template)
```

---

## 🚀 Próximas Calculadoras (Ordem Sugerida)

1. **13th Salary** - Similar a férias
2. **Overtime** - Cálculo com variações
3. **Future Value** - Fórmula matemática
4. **Cash vs Installment** - Comparação simples
5. ... (continuar do mais simples ao mais complexo)

---

**Template validado**: Vacation Calculator (4-6h primeira implementação)
**Replicação estimada**: 2-3h por calculadora seguindo este template
**Total para 12 calculadoras**: 24-36 horas
