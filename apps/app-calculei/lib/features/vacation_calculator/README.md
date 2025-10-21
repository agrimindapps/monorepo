# Vacation Calculator Feature

**Status**: ✅ FEATURE PILOTO IMPLEMENTADA (Gold Standard)

Esta é a **feature de referência** para padronização das 13 calculadoras do app-calculei.

## 📐 Arquitetura

### Clean Architecture + SOLID + Riverpod

```
vacation_calculator/
├── domain/                    # Business Logic (Pure Dart)
│   ├── entities/
│   │   └── vacation_calculation.dart       # Entity com Equatable
│   ├── repositories/
│   │   └── vacation_repository.dart        # Interface (abstraction)
│   └── usecases/
│       ├── calculate_vacation_usecase.dart # Core business logic
│       ├── save_calculation_usecase.dart
│       └── get_calculation_history_usecase.dart
│
├── data/                      # Data Layer (Hive + Firebase)
│   ├── models/
│   │   └── vacation_calculation_model.dart # Hive adapter + JSON
│   ├── datasources/
│   │   └── vacation_local_datasource.dart  # Hive implementation
│   └── repositories/
│       └── vacation_repository_impl.dart   # Concrete implementation
│
└── presentation/              # UI Layer (Riverpod + Flutter)
    ├── providers/
    │   └── vacation_calculator_provider.dart  # Riverpod @riverpod
    ├── pages/
    │   └── vacation_calculator_page.dart      # Main UI
    └── widgets/
        ├── vacation_input_form.dart
        └── calculation_result_card.dart
```

## 🎯 Padrões Aplicados

### ✅ Domain Layer (Pure Dart - Zero Dependencies)
- **Entities**: Immutable with Equatable
- **Repositories**: Interface only (DIP - Dependency Inversion Principle)
- **Use Cases**: Single Responsibility + Validation centralizada
- **Error Handling**: Either<Failure, T> (dartz)

### ✅ Data Layer
- **Models**: Hive adapters + JSON serialization
- **Datasources**: Local (Hive) + Remote (Firebase preparado)
- **Repository Impl**: Offline-first pattern

### ✅ Presentation Layer (Riverpod)
- **Providers**: Code generation (@riverpod)
- **State**: AsyncValue<T> para loading/error/data
- **UI**: ConsumerWidget/ConsumerStatefulWidget
- **Auto-dispose**: Lifecycle gerenciado automaticamente

## 🧪 Testes

**Cobertura**: 100% do use case principal

```bash
# Executar testes
cd apps/app-calculei
flutter test test/features/vacation_calculator/

# Resultado: 14/14 testes passando ✅
```

### Cenários Testados:
1. ✅ Cálculo válido com 30 dias
2. ✅ Cálculo com venda de férias (abono)
3. ✅ Férias proporcionais (15 dias)
4. ✅ Validação: salário zero
5. ✅ Validação: salário negativo
6. ✅ Validação: salário acima do limite
7. ✅ Validação: dias zero
8. ✅ Validação: dias > 30
9. ✅ Validação: venda com < 10 dias
10. ✅ INSS progressivo 2024
11. ✅ IR progressivo 2024
12. ✅ IR isento para baixa renda
13. ✅ IDs únicos por cálculo
14. ✅ Timestamp de criação

## 📊 Regras de Negócio

### Cálculo de Férias Trabalhistas
```dart
// Base value (proporcional aos dias)
baseValue = (grossSalary / 30) * vacationDays

// Adicional 1/3 constitucional
constitutionalBonus = baseValue / 3

// Abono pecuniário (venda até 1/3)
if (sellVacationDays) {
  soldDays = min(10, vacationDays / 3)
  soldDaysValue = (grossSalary / 30) * soldDays
  soldDaysValue += soldDaysValue / 3  // +1/3 sobre vendidos
}

// Total bruto
grossTotal = baseValue + constitutionalBonus + soldDaysValue

// INSS (tabela progressiva 2024)
inssDiscount = calculateInss(grossTotal)

// IR (tabela progressiva 2024)
irDiscount = calculateIR(grossTotal - inssDiscount)

// Total líquido
netTotal = grossTotal - inssDiscount - irDiscount
```

### Validações
- Salário: R$ 0,01 até R$ 1.000.000,00
- Dias: 1 a 30
- Venda de férias: apenas se dias ≥ 10

## 🚀 Como Usar

### 1. Importar a página
```dart
import 'package:app_calculei/features/vacation_calculator/presentation/pages/vacation_calculator_page.dart';
```

### 2. Adicionar à rota
```dart
GoRoute(
  path: '/vacation-calculator',
  builder: (context, state) => const VacationCalculatorPage(),
)
```

### 3. Usar o provider (para lógica customizada)
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculation = ref.watch(vacationCalculatorProvider);

    // Realizar cálculo
    await ref.read(vacationCalculatorProvider.notifier).calculate(
      grossSalary: 3000.0,
      vacationDays: 30,
      sellVacationDays: true,
    );

    // Histórico
    final historyAsync = ref.watch(vacationHistoryProvider);
  }
}
```

## 📋 Checklist para Novas Calculadoras

Ao implementar as próximas 12 calculadoras, siga este padrão:

### Domain Layer
- [ ] Entity com Equatable
- [ ] Repository interface (abstraction)
- [ ] Calculate UseCase com validação
- [ ] Save UseCase
- [ ] Get History UseCase
- [ ] Either<Failure, T> error handling

### Data Layer
- [ ] Model com @HiveType
- [ ] LocalDataSource (Hive)
- [ ] Repository implementation
- [ ] Offline-first pattern

### Presentation Layer
- [ ] Provider com @riverpod
- [ ] AsyncNotifier para state
- [ ] ConsumerWidget/ConsumerStatefulWidget
- [ ] Input form widget
- [ ] Result card widget

### Testing
- [ ] 14+ unit tests (success + validations + failures)
- [ ] 100% use case coverage
- [ ] Namespace conflict resolution (hide test)

### Code Quality
- [ ] 0 analyzer errors
- [ ] < 10 analyzer warnings (info only)
- [ ] Clean imports (remove duplicates)
- [ ] Code generation (build_runner)

## 🔄 Próximas Calculadoras (12)

1. **FGTS Calculator** - Seguir este template
2. **13th Salary Calculator** - Seguir este template
3. **Overtime Calculator** - Seguir este template
4. **Notice Period Calculator** - Seguir este template
5. **Unemployment Insurance** - Seguir este template
6. **Income Tax Calculator** - Seguir este template
7. **Loan Calculator** - Seguir este template
8. **Compound Interest** - Seguir este template
9. **Investment Calculator** - Seguir este template
10. **Retirement Calculator** - Seguir este template
11. **Profit Sharing** - Seguir este template
12. **Payroll Calculator** - Seguir este template

## 📚 Referências

- **app-plantis**: Gold Standard 10/10 (arquitetura de referência)
- **CLAUDE.md**: Padrões do monorepo
- **.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md**: Guia de migração

---

**Autor**: Claude Code (Flutter Senior Engineer)
**Data**: 2025-10-21
**Versão**: 1.0.0 (Feature Piloto)
