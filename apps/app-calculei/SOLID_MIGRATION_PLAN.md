# 🏗️ Plano de Padronização SOLID - app-calculei

**Objetivo**: Migrar todas as 13 calculadoras para Clean Architecture + SOLID + Riverpod

**Referência**: app-plantis (Gold Standard 10/10)

---

## 📊 Status Atual

### **Estrutura Existente (MVC Simples)**
```
lib/pages/calc/
├── trabalhistas/
│   ├── ferias/
│   │   ├── controllers/ferias_controller.dart      (ChangeNotifier manual)
│   │   ├── models/ferias_model.dart               (Data model)
│   │   ├── widgets/                               (Form + Result)
│   │   ├── services/                              (Business logic)
│   │   └── index.dart                             (StatefulWidget - 180 linhas)
│   ├── horas_extras/
│   ├── salario_liquido/
│   ├── decimo_terceiro/
│   └── seguro_desemprego/
└── financeiro/
    ├── juros_compostos/
    ├── valor_futuro/
    ├── vista_vs_parcelado/
    ├── reserva_emergencia/
    ├── orcamento_regra_3050/
    ├── independencia_financeira/
    ├── custo_efetivo_total/
    └── custo_real_credito/
```

### **Problemas Identificados**
- ❌ Business logic misturada com UI (controllers)
- ❌ Sem separação Domain/Data/Presentation
- ❌ Sem use cases (validações dispersas)
- ❌ Sem repository pattern
- ❌ State management manual (ChangeNotifier)
- ❌ Dificuldade para testar

---

## 🎯 Estrutura Alvo (Clean Architecture + SOLID)

### **Padrão Estabelecido**
```
lib/features/
├── vacation_calculator/                # Feature: Férias (PILOTO)
│   ├── domain/
│   │   ├── entities/
│   │   │   └── vacation_calculation.dart      # Pure Dart entity
│   │   ├── repositories/
│   │   │   └── vacation_repository.dart       # Interface (abstract)
│   │   └── usecases/
│   │       ├── calculate_vacation_usecase.dart
│   │       └── save_calculation_usecase.dart
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── vacation_local_datasource.dart # Hive
│   │   │   └── vacation_remote_datasource.dart # Firebase (opcional)
│   │   ├── models/
│   │   │   └── vacation_calculation_model.dart # Hive adapter
│   │   └── repositories/
│   │       └── vacation_repository_impl.dart   # Implementation
│   └── presentation/
│       ├── providers/
│       │   └── vacation_providers.dart         # Riverpod @riverpod
│       ├── pages/
│       │   └── vacation_calculator_page.dart   # ConsumerWidget
│       └── widgets/
│           ├── vacation_form.dart
│           └── vacation_result.dart
│
├── overtime_calculator/                # Horas Extras
├── net_salary_calculator/             # Salário Líquido
├── thirteenth_salary_calculator/      # 13º Salário
├── unemployment_insurance_calculator/ # Seguro Desemprego
├── compound_interest_calculator/      # Juros Compostos
├── future_value_calculator/           # Valor Futuro
└── ... (mais 6 calculadoras)
```

---

## 🚀 Fases de Implementação

### **FASE 1: Feature Piloto - Vacation Calculator** (4-6h)

#### **1.1 Domain Layer** (1-1.5h)
- [ ] Criar `lib/features/vacation_calculator/domain/entities/vacation_calculation.dart`
  - Entidade pura (sem dependencies)
  - Equatable para comparações
  - copyWith pattern

- [ ] Criar `lib/features/vacation_calculator/domain/repositories/vacation_repository.dart`
  - Interface abstrata
  - Either<Failure, T> em todos os métodos
  - Métodos: calculate(), save(), getHistory()

- [ ] Criar `lib/features/vacation_calculator/domain/usecases/`
  - `calculate_vacation_usecase.dart`:
    - Validações de entrada (salário > 0, dias > 0)
    - Cálculo de férias (salário base + 1/3 constitucional)
    - Desconto de INSS/IR se aplicável
    - Return Either<Failure, VacationCalculation>
  - `save_calculation_usecase.dart`:
    - Salvar histórico local
    - Optional: sync Firebase

#### **1.2 Data Layer** (1-1.5h)
- [ ] Criar `lib/features/vacation_calculator/data/models/vacation_calculation_model.dart`
  - Extends VacationCalculation
  - @HiveType annotations
  - toEntity(), fromEntity()
  - toJson(), fromJson() (Firebase)

- [ ] Criar `lib/features/vacation_calculator/data/datasources/vacation_local_datasource.dart`
  - Interface + Implementation
  - Hive box operations
  - save(), get(), getAll(), delete()

- [ ] Criar `lib/features/vacation_calculator/data/repositories/vacation_repository_impl.dart`
  - @Injectable(as: VacationRepository)
  - Implementa interface do domain
  - Converte exceptions → Failures
  - Offline-first pattern

#### **1.3 Presentation Layer** (1.5-2h)
- [ ] Criar `lib/features/vacation_calculator/presentation/providers/vacation_providers.dart`
  - @riverpod annotation
  - AsyncNotifier<VacationState>
  - States: initial, loading, success, error
  - Methods: calculate(), saveCalculation(), clearForm()

- [ ] Criar `lib/features/vacation_calculator/presentation/pages/vacation_calculator_page.dart`
  - ConsumerWidget ou ConsumerStatefulWidget
  - ref.watch(vacationProvider)
  - AsyncValue handling (loading, error, data)

- [ ] Criar `lib/features/vacation_calculator/presentation/widgets/`
  - `vacation_form.dart` - Form com TextFields
  - `vacation_result.dart` - Display results
  - `vacation_history_list.dart` - Histórico (opcional)

#### **1.4 DI & Testes** (1h)
- [ ] Registrar dependencies em `lib/core/di/injection.dart`
- [ ] Executar build_runner
- [ ] Criar testes unitários:
  - `test/features/vacation_calculator/domain/usecases/calculate_vacation_usecase_test.dart`
  - Mínimo 5 testes:
    1. ✅ Cálculo correto (salário base)
    2. ✅ Adicional 1/3 constitucional
    3. ❌ Salário inválido (≤ 0)
    4. ❌ Dias inválidos (< 0 ou > 30)
    5. ✅ Desconto INSS/IR quando aplicável

---

### **FASE 2: Aplicar Padrão nas Outras Calculadoras** (15-20h)

#### **Ordem de Migração** (do mais simples ao mais complexo)

**Trabalhistas (5 calculadoras)** - 8-10h
1. ✅ **Férias** (PILOTO - 4-6h)
2. **13º Salário** (2h) - Similar a férias
3. **Horas Extras** (2-3h) - Cálculo com variações
4. **Seguro Desemprego** (3-4h) - Regras governamentais complexas
5. **Salário Líquido** (3-4h) - Tabelas INSS/IR complexas

**Financeiras Simples (3 calculadoras)** - 4-5h
6. **Vista vs Parcelado** (1-2h) - Comparação simples
7. **Reserva de Emergência** (1-2h) - Cálculo direto
8. **Valor Futuro** (2h) - Fórmula matemática

**Financeiras Intermediárias (3 calculadoras)** - 6-8h
9. **Orçamento Regra 30-50** (2h) - Lógica de distribuição
10. **Juros Compostos** (2-3h) - Charts com fl_chart
11. **Independência Financeira** (3-4h) - FIRE, múltiplos cenários

**Financeiras Complexas (2 calculadoras)** - 6-8h
12. **Custo Efetivo Total** (3-4h) - CET, múltiplas taxas
13. **Custo Real de Crédito** (3-4h) - Comparações complexas

---

### **FASE 3: Refactoring & Quality** (4-6h)

- [ ] Corrigir todos analyzer errors
- [ ] Adicionar testes unitários (≥80% coverage em use cases)
- [ ] Adicionar testes de integração (principais fluxos)
- [ ] Code review e refactoring
- [ ] Documentação de cada feature (README.md)

---

### **FASE 4: Features Avançadas** (Opcional - 6-8h)

- [ ] Sincronização Firebase (histórico em nuvem)
- [ ] Compartilhamento de resultados (Share Plus)
- [ ] Export PDF/Excel
- [ ] Comparação de cenários (múltiplos cálculos)
- [ ] Dark mode otimizado por calculadora

---

## 📋 Checklist por Calculadora

### **Template de Migração**

Para cada calculadora, seguir:

#### **Domain Layer**
- [ ] Entity pura criada (Equatable, copyWith)
- [ ] Repository interface definida (Either<Failure, T>)
- [ ] Use cases criados com validações

#### **Data Layer**
- [ ] Model com Hive annotations
- [ ] Local datasource implementado
- [ ] Repository implementation com @Injectable

#### **Presentation Layer**
- [ ] Riverpod provider com @riverpod
- [ ] Page com ConsumerWidget
- [ ] Widgets desacoplados (Form, Result)

#### **Quality**
- [ ] Build runner executado sem erros
- [ ] Analyzer 0 errors
- [ ] Mínimo 5 testes unitários
- [ ] Documentação inline (comentários)

---

## 🎯 Padrões SOLID Aplicados

### **Single Responsibility Principle (SRP)**
- ✅ Cada classe tem UMA responsabilidade:
  - Use Case: **APENAS** lógica de negócio
  - Repository: **APENAS** persistência
  - Provider: **APENAS** state management
  - Widget: **APENAS** UI

### **Open/Closed Principle (OCP)**
- ✅ Entidades abertas para extensão (copyWith), fechadas para modificação
- ✅ Interfaces permitem múltiplas implementações (Repository)

### **Liskov Substitution Principle (LSP)**
- ✅ Repository implementation substituível pela interface
- ✅ Models substituíveis por Entities (toEntity/fromEntity)

### **Interface Segregation Principle (ISP)**
- ✅ Repository interfaces específicas por feature
- ✅ DataSources específicos (Local vs Remote)

### **Dependency Inversion Principle (DIP)**
- ✅ Depender de abstrações (Repository interface), não implementações
- ✅ Use Cases dependem de Repository interface
- ✅ Presentation depende de Use Cases (injetados via DI)

---

## 📊 Estimativas de Tempo

| Fase | Calculadoras | Tempo Estimado |
|------|--------------|----------------|
| **Fase 1: Piloto (Férias)** | 1 | 4-6 horas |
| **Fase 2a: Trabalhistas** | 4 | 8-10 horas |
| **Fase 2b: Financeiras Simples** | 3 | 4-5 horas |
| **Fase 2c: Financeiras Intermediárias** | 3 | 6-8 horas |
| **Fase 2d: Financeiras Complexas** | 2 | 6-8 horas |
| **Fase 3: Quality** | - | 4-6 horas |
| **Fase 4: Features Avançadas** | - | 6-8 horas (opcional) |
| **TOTAL** | **13** | **38-51 horas** |

---

## ✅ Critérios de Sucesso

### **Por Calculadora**
- ✅ Clean Architecture rigorosa (Domain/Data/Presentation)
- ✅ SOLID principles aplicados
- ✅ Riverpod com code generation
- ✅ Either<Failure, T> em toda camada de domínio
- ✅ ≥5 testes unitários por use case
- ✅ 0 analyzer errors
- ✅ Documentação inline

### **Projeto Completo**
- ✅ 13 calculadoras migradas
- ✅ Padrão consistente entre features
- ✅ Código testável e maintainável
- ✅ Performance otimizada (Riverpod auto-dispose)
- ✅ README.md atualizado

---

## 📚 Referências

- **Gold Standard**: `/apps/app-plantis/lib/features/`
- **Guia Riverpod**: `/.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md`
- **Padrões**: `/.claude/agents/flutter-architect.md`

---

**Próximo passo**: Começar FASE 1 - Implementar Vacation Calculator como feature piloto.
