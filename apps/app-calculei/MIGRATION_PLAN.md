# app-calculei Migration Plan

## 🎯 Overview

Migrating **app-calculei** from legacy structure to Clean Architecture + Riverpod following monorepo standards.

**Current Status**: ✅ Structure setup complete
**Estimated Time**: 15-20 hours
**Complexity**: Medium-High (13 calculators)

---

## 📊 Current State Analysis

### Existing Structure
```
app-calculei/
├── app-page.dart (root)           # Legacy - needs migration
├── pages/                          # Legacy pages (mobile/desktop/calc)
├── constants/                      # App constants (config, database, etc)
├── repository/                     # Data repositories (needs review)
├── services/                       # Business services (needs review)
└── widgets/                        # Shared widgets
```

### Calculators Inventory

**Financial Calculators (8)**:
1. Juros Compostos (Compound Interest)
2. Valor Futuro (Future Value)
3. Vista vs Parcelado (Cash vs Installment)
4. Reserva de Emergência (Emergency Reserve)
5. Orçamento Regra 30-50 (Budget Rule)
6. Independência Financeira (Financial Independence)
7. Custo Efetivo Total (Total Effective Cost)
8. Custo Real de Crédito (Real Credit Cost)

**Labor Calculators (5)**:
1. Salário Líquido (Net Salary)
2. 13º Salário (13th Salary)
3. Férias (Vacation Pay)
4. Horas Extras (Overtime)
5. Seguro Desemprego (Unemployment Insurance)

**Total**: 13 calculators

### State Management Usage
- **Provider**: Majority of calculators
- **GetX**: 3 instances found (minimal usage)

---

## 🏗️ New Structure (Created)

```
lib/
├── core/                           # ✅ Created
│   ├── config/
│   │   └── firebase_options.dart   # ✅ Created (needs Firebase config)
│   ├── di/
│   │   └── injection.dart          # ✅ Created (needs code generation)
│   ├── router/
│   │   └── app_router.dart         # ✅ Created
│   └── theme/
│       └── theme_providers.dart    # ✅ Created
├── features/                       # 📁 Ready for migration
├── main.dart                       # ✅ Created
└── app_page.dart                   # ✅ Created (updated)
```

---

## 📋 Migration Phases

### Phase 1: Infrastructure Setup ✅ COMPLETE

- [x] Create `pubspec.yaml` with Riverpod dependencies
- [x] Create `lib/main.dart` with Firebase + DI setup
- [x] Create `lib/app_page.dart` with Riverpod integration
- [x] Create `lib/core/` infrastructure
  - [x] `config/firebase_options.dart`
  - [x] `di/injection.dart`
  - [x] `router/app_router.dart`
  - [x] `theme/theme_providers.dart`
- [x] Create `analysis_options.yaml`
- [x] Create `.gitignore`
- [x] Create `README.md`

### Phase 2: Dependencies & Code Generation ⏳ NEXT

**Tasks**:
1. Configure Firebase project and update `firebase_options.dart`
2. Run `flutter pub get`
3. Run `dart run build_runner build --delete-conflicting-outputs`
4. Fix any initial compilation errors

**Estimated Time**: 1-2 hours

### Phase 3: Migrate Constants & Utilities (2-3 hours)

**Tasks**:
1. Review `constants/` directory
   - Move to `lib/core/constants/`
   - Update imports
2. Review `widgets/` directory
   - Move to `lib/shared/widgets/`
   - Update imports
3. Review `services/` and `repository/`
   - Determine if keeping or refactoring
   - Update imports

### Phase 4: Create Feature Structure (2-3 hours)

**Directory Structure**:
```
lib/features/
├── financial_calculators/
│   ├── data/
│   │   ├── datasources/
│   │   ├── models/
│   │   └── repositories/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   └── presentation/
│       ├── providers/         # Riverpod
│       ├── pages/
│       └── widgets/
└── labor_calculators/
    └── [same structure]
```

### Phase 5: Migrate Financial Calculators (4-6 hours)

**Priority Order** (simplest to most complex):
1. **Vista vs Parcelado** (simple comparison)
2. **Reserva de Emergência** (basic calculation)
3. **Valor Futuro** (moderate complexity)
4. **Juros Compostos** (has charts)
5. **Orçamento Regra 30-50** (budget logic)
6. **Custo Real de Crédito** (complex logic)
7. **Custo Efetivo Total** (complex logic)
8. **Independência Financeira** (most complex)

**For each calculator**:
- Create domain entities
- Create repository interface + implementation
- Create use cases with validation
- Create Riverpod providers
- Migrate UI widgets
- Add unit tests

### Phase 6: Migrate Labor Calculators (3-5 hours)

**Priority Order**:
1. **Férias** (simplest)
2. **13º Salário** (moderate)
3. **Horas Extras** (moderate)
4. **Salário Líquido** (complex - tax calculations)
5. **Seguro Desemprego** (complex - government rules)

**Same pattern as Phase 5**.

### Phase 7: Testing & Quality (2-3 hours)

**Tasks**:
1. Add unit tests for all use cases (≥80% coverage)
2. Add widget tests for critical paths
3. Run `flutter analyze` - fix all issues
4. Run `dart run custom_lint` - fix Riverpod issues
5. Performance testing (chart rendering)

### Phase 8: Final Integration (1-2 hours)

**Tasks**:
1. Update navigation routes in `app_router.dart`
2. Remove legacy `pages/` directory
3. Remove `app-page.dart` from root
4. Update README with final structure
5. Create changelog

---

## 🔧 Technical Details

### Riverpod Migration Pattern

**Current (Provider)**:
```dart
class CalculatorController extends ChangeNotifier {
  void calculate() {
    // logic
    notifyListeners();
  }
}

final controller = ChangeNotifierProvider((ref) => CalculatorController());
```

**Target (Riverpod)**:
```dart
@riverpod
class CalculatorNotifier extends _$CalculatorNotifier {
  @override
  Future<Result> build() async {
    // initial state
  }

  Future<void> calculate(Params params) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(calculatorRepositoryProvider).calculate(params);
      return result.fold(
        (failure) => throw failure,
        (data) => data,
      );
    });
  }
}
```

### Clean Architecture Layers

**Domain Layer** (Business Logic):
- Entities (immutable data classes)
- Repository interfaces
- Use cases (single responsibility)

**Data Layer** (Implementation):
- Models (with JSON serialization)
- Repository implementations
- Data sources (local/remote)

**Presentation Layer** (UI):
- Riverpod providers
- Pages (ConsumerWidget)
- Widgets (UI components)

---

## 📝 Next Steps

### Immediate (Today)
1. ✅ Review this migration plan
2. Configure Firebase project
3. Run `flutter pub get`
4. Run code generation
5. Test app compilation

### Short-term (This Week)
1. Migrate constants and utilities (Phase 3)
2. Create feature structure (Phase 4)
3. Start migrating simplest calculators (Phase 5)

### Medium-term (Next Week)
1. Complete all calculator migrations
2. Add comprehensive tests
3. Quality assurance and linting
4. Final integration

---

## ⚠️ Blockers & Risks

### Potential Issues
1. **Firebase Configuration**: Need actual Firebase project credentials
2. **Complex Calculations**: Some calculators have intricate logic (tax tables, government rules)
3. **Chart Migration**: `fl_chart` integration with Riverpod AsyncValue
4. **State Persistence**: Need to handle calculator history/favorites

### Mitigation
1. Start with simplest calculators to establish pattern
2. Thoroughly test calculation logic during migration
3. Keep legacy code until new implementation is verified
4. Document any business rule changes

---

## 📊 Success Metrics

- [ ] 0 analyzer errors
- [ ] 0 critical warnings
- [ ] ≥80% test coverage for use cases
- [ ] All 13 calculators migrated and working
- [ ] Clean Architecture properly implemented
- [ ] Riverpod code generation working
- [ ] Performance maintained or improved

---

**Status**: ✅ Phase 1 Complete - Ready for Phase 2
**Next Action**: Configure Firebase and run dependencies installation
