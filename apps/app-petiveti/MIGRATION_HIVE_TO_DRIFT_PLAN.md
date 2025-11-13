# 🔄 Plano de Migração: Hive → Drift (app-petiveti)

**Data de Criação:** 13/11/2024  
**Status:** 📋 Planejamento  
**Objetivo:** Migrar app-petiveti de Hive para Drift para suportar Web + Melhor Performance

---

## 📊 Análise do Estado Atual

### Estatísticas do Projeto
- **Total de arquivos Dart:** 488
- **Features:** 14 módulos
- **Models com HiveObject:** 9 arquivos
- **Uso da API Hive:** ~9+ ocorrências
- **Datasources locais:** ~19 arquivos

### Features Identificadas

#### ✅ Features CRUD Completas (Prioridade Alta)
1. **animals** - Gestão de Pets (COMPLETA)
2. **appointments** - Consultas Veterinárias
3. **vaccines** - Controle de Vacinas
4. **medications** - Gestão de Medicamentos
5. **weight** - Controle de Peso
6. **expenses** - Controle de Despesas
7. **reminders** - Sistema de Lembretes

#### 🟡 Features Secundárias (Prioridade Média)
8. **calculators** - Calculadoras (4/13 funcionais)
9. **promo** - Conteúdo promocional

#### 🟢 Features Sem Dados Locais (Baixa Prioridade)
10. **auth** - Autenticação (Firebase)
11. **subscription** - Assinaturas (RevenueCat)
12. **home** - Dashboard
13. **profile** - Perfil do usuário
14. **settings** - Configurações

---

## 🎯 Estratégia de Migração

### Fase 1: Preparação e Setup (Estimativa: 1-2 dias)

#### 1.1 Criar Database Drift
```dart
@DriftDatabase(
  tables: [
    Animals,
    Appointments,
    Vaccines,
    Medications,
    WeightRecords,
    Expenses,
    Reminders,
    CalculationHistory,
    PromoContent,
    UserPreferences,
  ],
  daos: [
    AnimalDao,
    AppointmentDao,
    VaccineDao,
    MedicationDao,
    WeightDao,
    ExpenseDao,
    ReminderDao,
    CalculatorDao,
    PromoDao,
  ],
)
class PetivetiDatabase extends _$PetivetiDatabase {
  // Configuração web + mobile
}
```

#### 1.2 Configurar Web Support
- [ ] Criar `web/drift_worker.dart`
- [ ] Adicionar `sqlite3.wasm` no pubspec
- [ ] Configurar inicialização condicional (web vs mobile)

#### 1.3 Atualizar Dependências
```yaml
dependencies:
  drift: ^2.28.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.0.0
  path: ^1.8.0

dev_dependencies:
  drift_dev: ^2.28.0
  build_runner: ^2.4.0
```

---

### Fase 2: Migração Core (Estimativa: 2-3 dias)

#### 2.1 Models Base (Prioridade: CRÍTICA)

**AnimalModel** → **Animals Table**
```dart
class Animals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get species => text()();
  TextColumn get breed => text().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get gender => text()();
  RealColumn get weight => real().nullable()();
  TextColumn get photo => text().nullable()();
  TextColumn get userId => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

**MedicationModel** → **Medications Table**
```dart
class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get animalId => integer().references(Animals, #id)();
  TextColumn get name => text()();
  TextColumn get dosage => text()();
  TextColumn get frequency => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get userId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

**VaccineModel** → **Vaccines Table**
```dart
class Vaccines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get animalId => integer().references(Animals, #id)();
  TextColumn get name => text()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get nextDueDate => dateTime().nullable()();
  TextColumn get veterinarian => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get userId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

**AppointmentModel** → **Appointments Table**
```dart
class Appointments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get animalId => integer().references(Animals, #id)();
  TextColumn get title => text()();
  DateTimeColumn get dateTime => dateTime()();
  TextColumn get veterinarian => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text()(); // scheduled, completed, cancelled
  TextColumn get userId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

**WeightModel** → **WeightRecords Table**
```dart
class WeightRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get animalId => integer().references(Animals, #id)();
  RealColumn get weight => real()();
  TextColumn get unit => text().withDefault(const Constant('kg'))();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get userId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

**ExpenseModel** → **Expenses Table**
```dart
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get animalId => integer().references(Animals, #id)();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  TextColumn get category => text()(); // food, veterinary, grooming, etc
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get userId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

**ReminderModel** → **Reminders Table**
```dart
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get animalId => integer().references(Animals, #id).nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get dateTime => dateTime()();
  TextColumn get frequency => text().nullable()(); // once, daily, weekly, monthly
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get userId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

#### 2.2 Models Secundários

**CalculationHistoryModel** → **CalculationHistory Table**
```dart
class CalculationHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get calculatorType => text()();
  TextColumn get inputData => text()(); // JSON
  TextColumn get result => text()(); // JSON
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get userId => text()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

**PromoContentModel** → **PromoContent Table**
```dart
class PromoContent extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

---

### Fase 3: DAOs e Repository Layer (Estimativa: 3-4 dias)

#### 3.1 Criar DAOs
```dart
@DriftAccessor(tables: [Animals])
class AnimalDao extends DatabaseAccessor<PetivetiDatabase> with _$AnimalDaoMixin {
  AnimalDao(PetivetiDatabase db) : super(db);

  Future<List<Animal>> getAllAnimals(String userId) {
    return (select(animals)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();
  }

  Future<Animal?> getAnimalById(int id) {
    return (select(animals)..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
      .getSingleOrNull();
  }

  Future<int> createAnimal(AnimalsCompanion animal) {
    return into(animals).insert(animal);
  }

  Future<bool> updateAnimal(int id, AnimalsCompanion animal) {
    return (update(animals)..where((tbl) => tbl.id.equals(id))).write(animal);
  }

  Future<bool> deleteAnimal(int id) {
    return (update(animals)..where((tbl) => tbl.id.equals(id)))
      .write(AnimalsCompanion(isDeleted: Value(true)));
  }
}
```

#### 3.2 Atualizar Datasources
- Substituir `Box<T>` por `Dao`
- Remover `HiveObject` das models
- Converter TypeAdapters em Converters (se necessário)

#### 3.3 Atualizar Repositories
- Manter interface de repositório
- Atualizar implementação para usar DAOs

---

### Fase 4: Migração de Dados (Estimativa: 1-2 dias)

#### 4.1 Criar Migration Service
```dart
class HiveToDriftMigrationService {
  final PetivetiDatabase _driftDb;
  final HiveInterface _hive;

  Future<void> migrateAllData() async {
    await _migrateAnimals();
    await _migrateMedications();
    await _migrateVaccines();
    await _migrateAppointments();
    await _migrateWeightRecords();
    await _migrateExpenses();
    await _migrateReminders();
    await _migrateCalculationHistory();
    // ...
  }

  Future<void> _migrateAnimals() async {
    final box = await _hive.openBox<AnimalModel>('animals');
    for (final animal in box.values) {
      await _driftDb.animalDao.createAnimal(
        AnimalsCompanion.insert(
          name: animal.name,
          species: animal.species,
          // ...
        ),
      );
    }
  }
}
```

#### 4.2 Estratégia de Migração
1. Executar migração na primeira abertura após update
2. Manter backup dos dados Hive
3. Validar dados migrados
4. Remover dados Hive após confirmação

---

### Fase 5: Testing & Validação (Estimativa: 2-3 dias)

#### 5.1 Testes Unitários
- [ ] Testes de DAOs
- [ ] Testes de Repositories
- [ ] Testes de Migration Service

#### 5.2 Testes de Integração
- [ ] CRUD completo de cada feature
- [ ] Relacionamentos entre tabelas
- [ ] Performance web vs mobile

#### 5.3 Testes Manuais
- [ ] Build web
- [ ] Build Android
- [ ] Build iOS
- [ ] Migração de dados reais

---

### Fase 6: Build Web & Deploy (Estimativa: 1 dia)

#### 6.1 Configuração Web
- [ ] Testar `flutter build web --release`
- [ ] Validar performance
- [ ] Testar offline-first

#### 6.2 Otimizações
- [ ] Tree shaking
- [ ] Lazy loading
- [ ] Cache strategy

---

## 📋 Checklist de Migração

### Setup Inicial
- [ ] Adicionar dependências Drift
- [ ] Criar estrutura de database
- [ ] Configurar build_runner
- [ ] Criar arquivos web (drift_worker.dart, sqlite3.wasm)

### Models & Tables
- [ ] Animals
- [ ] Medications
- [ ] Vaccines
- [ ] Appointments
- [ ] WeightRecords
- [ ] Expenses
- [ ] Reminders
- [ ] CalculationHistory
- [ ] PromoContent

### DAOs
- [ ] AnimalDao
- [ ] MedicationDao
- [ ] VaccineDao
- [ ] AppointmentDao
- [ ] WeightDao
- [ ] ExpenseDao
- [ ] ReminderDao
- [ ] CalculatorDao
- [ ] PromoDao

### Datasources
- [ ] Atualizar 19 datasources locais
- [ ] Remover dependências de Hive
- [ ] Implementar novos métodos com Drift

### Repositories
- [ ] Atualizar implementações
- [ ] Manter contratos de interfaces
- [ ] Adicionar error handling

### Migration
- [ ] Criar HiveToDriftMigrationService
- [ ] Implementar migração por feature
- [ ] Adicionar validação de dados
- [ ] Criar backup/rollback strategy

### Services
- [ ] Atualizar AutoSyncService
- [ ] Atualizar DataIntegrityService
- [ ] Atualizar PetivetiDataCleaner
- [ ] Remover dependências de HiveInterface

### Testing
- [ ] Testes unitários de DAOs
- [ ] Testes de repositories
- [ ] Testes de migração
- [ ] Testes de integração
- [ ] Testes de build (Android/iOS/Web)

### Deployment
- [ ] Build web funcional
- [ ] Build mobile funcional
- [ ] Documentação atualizada
- [ ] Release notes

---

## ⚠️ Pontos de Atenção

### Complexidade Alta
1. **19 Datasources** para migrar
2. **9 Models** com HiveObject
3. **14 Features** para validar
4. **Relacionamentos** entre tabelas (Animals → Medications, Vaccines, etc.)
5. **Migration de dados** de produção

### Riscos
- Perda de dados durante migração
- Performance inferior no web
- Breaking changes para usuários existentes
- Tempo de desenvolvimento maior que estimado

### Mitigações
- Backup automático antes da migração
- Testes extensivos em ambiente de staging
- Rollback strategy bem definida
- Comunicação clara com usuários sobre update

---

## 📊 Estimativa de Tempo Total

| Fase | Estimativa | Status |
|------|-----------|---------|
| Fase 1: Setup | 1-2 dias | ⏳ Pendente |
| Fase 2: Core Models | 2-3 dias | ⏳ Pendente |
| Fase 3: DAOs & Repos | 3-4 dias | ⏳ Pendente |
| Fase 4: Migration | 1-2 dias | ⏳ Pendente |
| Fase 5: Testing | 2-3 dias | ⏳ Pendente |
| Fase 6: Deploy | 1 dia | ⏳ Pendente |
| **TOTAL** | **10-15 dias** | ⏳ Pendente |

---

## 🎯 Próximos Passos

1. **Revisar este plano** com a equipe
2. **Aprovar arquitetura** de database Drift
3. **Criar branch de migração** (`feature/migrate-to-drift`)
4. **Iniciar Fase 1** (Setup e configuração)
5. **Documentar decisões** arquiteturais

---

## 📚 Referências

- [Drift Documentation](https://drift.simonbinder.eu/)
- [app-gasometer Migration](../app-gasometer/DRIFT_IMPLEMENTATION_ANALYSIS.md)
- [Clean Architecture + Drift](https://drift.simonbinder.eu/docs/advanced-features/daos/)
- [Web Support](https://drift.simonbinder.eu/web/)

---

**Documento vivo - Atualizar conforme progresso**
