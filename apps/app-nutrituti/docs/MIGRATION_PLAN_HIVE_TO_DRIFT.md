# 📋 Plano de Migração: app-nutrituti (Hive → Drift)

**Data:** 13/11/2024  
**Estimativa:** 2-3 dias  
**Complexidade:** ⭐⭐⭐☆☆ MÉDIA  
**Template Base:** app-petiveti (validado 100%)

---

## 🎯 ANÁLISE COMPLETA DO APP

### Características
- **Tipo:** App de Nutrição e Saúde (Multi-feature)
- **DB Local:** 6 features com persistência Hive
- **Calculadoras:** 20+ calculadoras (DTOs, não precisam migração)
- **Settings:** SharedPreferences (não precisa migração)
- **Premium:** RevenueCat + LocalStorage (não precisa migração)

### Escopo DEFINIDO ✨
**6 features usam Hive para PERSISTÊNCIA:**
1. **Perfil** (usuário)
2. **Peso** (rastreamento)
3. **Água** (hidratação) - 2 features separadas
4. **Water** (nova implementação Clean Arch)
5. **Exercícios** (registro de atividades)
6. **Comentários** (anotações)

**20+ calculadoras NÃO precisam migração** (apenas DTOs para cálculos)

---

## 📊 INVENTÁRIO DETALHADO

### ✅ PERSISTÊNCIA - PRECISA MIGRAR (6 features)

#### 1. **Perfil do Usuário**
- **Model:** `lib/database/perfil_model.dart` (@HiveType typeId: 52)
- **Repository:** `lib/repository/perfil_repository.dart`
- **Campos:** id, nome, dataNascimento, altura, peso, genero, imagePath, createdAt, updatedAt
- **Complexidade:** ⭐⭐☆☆☆ BAIXA
- **Ação:** Migrar para Drift

#### 2. **Peso (Rastreamento)**
- **Model:** `lib/pages/peso/models/peso_model.dart` (@HiveType typeId: 53)
- **Repository:** `lib/pages/peso/repository/peso_repository.dart`
- **Campos:** id, dataRegistro, peso, fkIdPerfil, isDeleted, createdAt, updatedAt
- **Features:** 
  - CRUD com Hive + Firestore sync
  - Soft delete (isDeleted)
  - ValueNotifier para observable state
- **Complexidade:** ⭐⭐⭐☆☆ MÉDIA (sync com Firebase)
- **Ação:** Migrar para Drift

#### 3. **Água (Legacy Implementation)**
- **Model:** `lib/pages/agua/models/beber_agua_model.dart` (@HiveType typeId: 51)
- **Repository:** `lib/pages/agua/repository/agua_repository.dart`
- **Campos:** id, dataRegistro, quantidade, fkIdPerfil, createdAt, updatedAt
- **Features:**
  - CRUD com Hive + Firestore sync
  - SharedPreferences para metas/progresso/streak
  - Conectividade check
- **Complexidade:** ⭐⭐⭐☆☆ MÉDIA (sync + SharedPrefs)
- **Ação:** Migrar para Drift

#### 4. **Water (New Clean Architecture)**
- **Models:**
  - `lib/features/water/data/models/water_record_model.dart` (@HiveType typeId: 10)
  - `lib/features/water/data/models/water_achievement_model.dart` (@HiveType typeId: 12)
  - `AchievementTypeAdapter` enum (@HiveType typeId: 11)
- **Datasource:** `lib/features/water/data/datasources/water_local_datasource.dart` (277 linhas)
- **Campos:**
  - WaterRecord: id, amount, timestamp, note
  - Achievement: id, type (enum), title, description, unlockedAt, iconName
- **Features:**
  - Clean Architecture completa
  - Hive para records/achievements
  - SharedPreferences para dailyGoal/streak
  - Firebase Firestore support
- **Complexidade:** ⭐⭐⭐⭐☆ ALTA (Clean Arch + enum + 2 tables)
- **Ação:** Migrar para Drift (MAIOR PRIORIDADE - exemplo de Clean Arch)

#### 5. **Exercícios (Atividades Físicas)**
- **Model:** `lib/pages/exercicios/models/exercicio_model.dart` (NÃO usa @HiveType, mas persiste)
- **Service:** `lib/pages/exercicios/services/exercicio_persistence_service.dart`
- **Campos:** id, nome, categoria, duracao, caloriasQueimadas, dataRegistro, observacoes
- **Features:**
  - Offline-first com sync automática
  - 3 Hive boxes (exercicios_box, sync_queue, metadata)
  - Connectivity listener
  - Conflict resolution
  - Firebase repository integration
- **Complexidade:** ⭐⭐⭐⭐☆ ALTA (offline-first pattern + sync queue)
- **Ação:** Migrar para Drift

#### 6. **Comentários**
- **Model:** `lib/database/comentarios_models.dart` (@HiveType typeId: 50)
- **Repository:** `lib/repository/comentarios_repository.dart`
- **Campos:** id, titulo, conteudo, ferramenta, pkIdentificador, createdAt, updatedAt
- **Features:**
  - CRUD básico
  - Filtro por ferramenta
  - Max 10 comentários
- **Complexidade:** ⭐☆☆☆☆ MUITO BAIXA
- **Ação:** Migrar para Drift

---

### ⚠️ DTOs - NÃO PRECISA MIGRAR (20+ calculadoras)

Estas classes são apenas estruturas temporárias para cálculos, sem persistência:

#### Calculadoras (em `/lib/pages/calc/`)
1. **Adiposidade** - Cálculo de adiposidade corporal
2. **Alcool Sangue** - Cálculo de teor alcoólico
3. **Calorias Diárias** - Modelo `ExercicioModel` (DTO temporário)
4. **Calorias por Exercício** - Modelo `AtividadeFisicaModel` (DTO temporário)
5. **Cintura Quadril** - Cálculo de proporções
6. **Composição Corporal** - Análise corporal
7. **Deficit Superavit** - Cálculo calórico
8. **Densidade Nutrientes** - Análise nutricional
9. **Densidade Óssea** - Cálculo ósseo
10. **Gasto Energético** - Cálculo de energia
11. **Gordura Corporal** - Percentual de gordura
12. **Índice Adiposidade** - Índice corporal
13. **Macronutrientes** - Cálculo de macros
14. **Massa Corporal** - IMC
15. **Necessidade Hídrica** - Cálculo de água
16. **Peso Ideal** - Peso recomendado
17. **Proteínas Diárias** - Cálculo proteico
18. **Taxa Metabólica Basal** - TMB
19. **Volume Sanguíneo** - Cálculo de volume

**Ação:** ✅ NENHUMA (manter como estão)

#### Repositórios Estáticos (não usam Hive)
- **AtividadeFisicaRepository** - Lista estática de 94 atividades físicas
  - `lib/repository/atividade_fisica_repository.dart`
  - `lib/database/atividade_fisica_model.dart`
  - Singleton com dados hardcoded
  - Apenas conversões toMap/fromMap
  - **Ação:** ✅ NENHUMA

---

### 🔧 Serviços Core

#### HiveService (a remover)
- `lib/core/services/hive_service.dart` - Wrapper genérico
- `lib/services/nutrituti_hive_service.dart` - Inicialização app-specific
- **Ação:** Remover após migração completa

---

## 🗄️ ESTRUTURA DRIFT A CRIAR

### Database: NutriTutiDatabase

```dart
@DriftDatabase(
  tables: [
    PerfilTable,
    PesoTable,
    AguaTable,
    WaterRecordTable,
    WaterAchievementTable,
    ExercicioTable,
    ComentarioTable,
  ],
  daos: [
    PerfilDao,
    PesoDao,
    AguaDao,
    WaterDao,
    ExercicioDao,
    ComentarioDao,
  ],
)
class NutriTutiDatabase extends _$NutriTutiDatabase { ... }
```

**Total:** 7 tabelas, 6 DAOs

---

### Tabelas Detalhadas

#### 1. Perfil Table
```dart
class PerfilTable extends Table {
  @override
  String get tableName => 'perfil';
  
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  
  // Dados pessoais
  TextColumn get nome => text()();
  DateTimeColumn get dataNascimento => dateTime()();
  RealColumn get altura => real()();
  RealColumn get peso => real()();
  IntColumn get genero => integer()();  // 0=M, 1=F
  TextColumn get imagePath => text().nullable()();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

#### 2. Peso Table
```dart
class PesoTable extends Table {
  @override
  String get tableName => 'peso';
  
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  
  // Dados do peso
  IntColumn get dataRegistro => integer()();  // timestamp
  RealColumn get peso => real()();
  TextColumn get fkIdPerfil => text()();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

#### 3. Agua Table (Legacy)
```dart
class AguaTable extends Table {
  @override
  String get tableName => 'agua';
  
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  
  // Dados de hidratação
  IntColumn get dataRegistro => integer()();  // timestamp
  RealColumn get quantidade => real()();
  TextColumn get fkIdPerfil => text()();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
```

#### 4. Water Record Table (Clean Arch)
```dart
class WaterRecordTable extends Table {
  @override
  String get tableName => 'water_records';
  
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recordId => text().unique()();  // UUID from domain
  TextColumn get userId => text()();
  
  // Dados do registro
  IntColumn get amount => integer()();  // ml
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get note => text().nullable()();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime()();
}
```

#### 5. Water Achievement Table
```dart
class WaterAchievementTable extends Table {
  @override
  String get tableName => 'water_achievements';
  
  IntColumn get id => integer().autoIncrement()();
  TextColumn get achievementId => text().unique()();  // UUID from domain
  TextColumn get userId => text()();
  
  // Dados da conquista
  IntColumn get achievementType => integer()();  // enum as int
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get unlockedAt => dateTime()();
  TextColumn get iconName => text().nullable()();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime()();
}
```

**Enum Converter:**
```dart
class AchievementTypeConverter extends TypeConverter<AchievementType, int> {
  const AchievementTypeConverter();
  
  @override
  AchievementType fromSql(int fromDb) {
    return AchievementType.values[fromDb];
  }
  
  @override
  int toSql(AchievementType value) {
    return value.index;
  }
}
```

#### 6. Exercicio Table
```dart
class ExercicioTable extends Table {
  @override
  String get tableName => 'exercicios';
  
  IntColumn get id => integer().autoIncrement()();
  TextColumn get exercicioId => text().unique()();  // ID from Firebase
  TextColumn get userId => text()();
  
  // Dados do exercício
  TextColumn get nome => text()();
  TextColumn get categoria => text()();
  IntColumn get duracao => integer()();  // minutos
  IntColumn get caloriasQueimadas => integer()();
  IntColumn get dataRegistro => integer()();  // timestamp
  TextColumn get observacoes => text().nullable()();
  
  // Sync metadata
  BoolColumn get isPendingSync => boolean().withDefault(const Constant(false))();
  IntColumn get syncAttempts => integer().withDefault(const Constant(0))();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

#### 7. Comentario Table
```dart
class ComentarioTable extends Table {
  @override
  String get tableName => 'comentarios';
  
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  
  // Dados do comentário
  TextColumn get titulo => text()();
  TextColumn get conteudo => text()();
  TextColumn get ferramenta => text()();  // Categoria/feature
  TextColumn get pkIdentificador => text()();  // ID do item comentado
  
  // Metadata
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get status => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

---

### DAOs a Implementar

#### 1. PerfilDao (~12 métodos)
```dart
@DriftAccessor(tables: [PerfilTable])
class PerfilDao extends DatabaseAccessor<NutriTutiDatabase> 
    with _$PerfilDaoMixin {
  
  Future<PerfilTableData?> getPerfil(String userId);
  Future<int> createPerfil(PerfilTableCompanion perfil);
  Future<void> updatePerfil(int id, PerfilTableCompanion perfil);
  Future<void> deletePerfil(int id);
  Stream<PerfilTableData?> watchPerfil(String userId);
}
```

#### 2. PesoDao (~15 métodos)
```dart
@DriftAccessor(tables: [PesoTable])
class PesoDao extends DatabaseAccessor<NutriTutiDatabase> 
    with _$PesoDaoMixin {
  
  Future<List<PesoTableData>> getAll(String userId);
  Future<PesoTableData?> getById(int id);
  Future<int> createPeso(PesoTableCompanion peso);
  Future<void> updatePeso(int id, PesoTableCompanion peso);
  Future<void> softDelete(int id);
  Stream<List<PesoTableData>> watchPesos(String userId);
  Future<List<PesoTableData>> getByDateRange(String userId, DateTime start, DateTime end);
}
```

#### 3. AguaDao (~15 métodos)
```dart
@DriftAccessor(tables: [AguaTable])
class AguaDao extends DatabaseAccessor<NutriTutiDatabase> 
    with _$AguaDaoMixin {
  
  Future<List<AguaTableData>> getAll(String userId);
  Future<AguaTableData?> getById(int id);
  Future<int> createAgua(AguaTableCompanion agua);
  Future<void> updateAgua(int id, AguaTableCompanion agua);
  Future<void> deleteAgua(int id);
  Stream<List<AguaTableData>> watchAgua(String userId);
  Future<List<AguaTableData>> getByDate(String userId, int timestamp);
}
```

#### 4. WaterDao (~20 métodos)
```dart
@DriftAccessor(tables: [WaterRecordTable, WaterAchievementTable])
class WaterDao extends DatabaseAccessor<NutriTutiDatabase> 
    with _$WaterDaoMixin {
  
  // Water Records
  Future<List<WaterRecordTableData>> getRecords(String userId);
  Future<WaterRecordTableData?> getRecordById(String recordId);
  Future<int> addRecord(WaterRecordTableCompanion record);
  Future<void> updateRecord(String recordId, WaterRecordTableCompanion record);
  Future<void> deleteRecord(String recordId);
  Future<List<WaterRecordTableData>> getRecordsByDate(String userId, DateTime date);
  Future<List<WaterRecordTableData>> getRecordsInRange(String userId, DateTime start, DateTime end);
  Stream<List<WaterRecordTableData>> watchRecords(String userId);
  
  // Water Achievements
  Future<List<WaterAchievementTableData>> getAchievements(String userId);
  Future<int> addAchievement(WaterAchievementTableCompanion achievement);
  Future<bool> hasAchievement(String achievementId);
  Stream<List<WaterAchievementTableData>> watchAchievements(String userId);
  
  // Clear all
  Future<void> clearAllData(String userId);
}
```

#### 5. ExercicioDao (~18 métodos)
```dart
@DriftAccessor(tables: [ExercicioTable])
class ExercicioDao extends DatabaseAccessor<NutriTutiDatabase> 
    with _$ExercicioDaoMixin {
  
  Future<List<ExercicioTableData>> getAll(String userId);
  Future<ExercicioTableData?> getById(String exercicioId);
  Future<int> createExercicio(ExercicioTableCompanion exercicio);
  Future<void> updateExercicio(String exercicioId, ExercicioTableCompanion exercicio);
  Future<void> softDelete(String exercicioId);
  Stream<List<ExercicioTableData>> watchExercicios(String userId);
  
  // Sync queue management
  Future<List<ExercicioTableData>> getPendingSync(String userId);
  Future<void> markAsSynced(String exercicioId);
  Future<void> incrementSyncAttempts(String exercicioId);
  Future<void> clearSyncQueue(String userId);
}
```

#### 6. ComentarioDao (~12 métodos)
```dart
@DriftAccessor(tables: [ComentarioTable])
class ComentarioDao extends DatabaseAccessor<NutriTutiDatabase> 
    with _$ComentarioDaoMixin {
  
  Future<List<ComentarioTableData>> getAll(String userId);
  Future<List<ComentarioTableData>> getByFerramenta(String userId, String ferramenta);
  Future<ComentarioTableData?> getById(int id);
  Future<int> createComentario(ComentarioTableCompanion comentario);
  Future<void> updateComentario(int id, ComentarioTableCompanion comentario);
  Future<void> deleteComentario(int id);
  Future<void> deleteAll(String userId);
  Stream<List<ComentarioTableData>> watchComentarios(String userId);
  Stream<List<ComentarioTableData>> watchByFerramenta(String userId, String ferramenta);
}
```

**Total:** ~92 métodos nos DAOs

---

## 📋 FASES DA MIGRAÇÃO

### ✅ FASE 1: Setup Database (3-4 horas)

#### 1.1 Adicionar Dependências
```yaml
dependencies:
  drift: ^2.28.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: any
  path: any

dev_dependencies:
  drift_dev: ^2.28.0
  build_runner: any
```

#### 1.2 Criar Estrutura
```bash
mkdir -p lib/database/{tables,daos,converters}
touch lib/database/tables/perfil_table.dart
touch lib/database/tables/peso_table.dart
touch lib/database/tables/agua_table.dart
touch lib/database/tables/water_record_table.dart
touch lib/database/tables/water_achievement_table.dart
touch lib/database/tables/exercicio_table.dart
touch lib/database/tables/comentario_table.dart

touch lib/database/daos/perfil_dao.dart
touch lib/database/daos/peso_dao.dart
touch lib/database/daos/agua_dao.dart
touch lib/database/daos/water_dao.dart
touch lib/database/daos/exercicio_dao.dart
touch lib/database/daos/comentario_dao.dart

touch lib/database/converters/achievement_type_converter.dart

touch lib/database/nutrituti_database.dart
```

#### 1.3 Implementar Tabelas (7 tabelas)
- PerfilTable
- PesoTable
- AguaTable
- WaterRecordTable
- WaterAchievementTable
- ExercicioTable
- ComentarioTable

**Tempo:** ~2 horas (7 tabelas × ~15 min)

#### 1.4 Implementar DAOs (6 DAOs)
- PerfilDao (~12 métodos)
- PesoDao (~15 métodos)
- AguaDao (~15 métodos)
- WaterDao (~20 métodos)
- ExercicioDao (~18 métodos)
- ComentarioDao (~12 métodos)

**Tempo:** ~2 horas (6 DAOs × ~20 min)

#### 1.5 Implementar Converters
- AchievementTypeConverter (enum → int)

**Tempo:** ~15 min

#### 1.6 Criar Database
- Criar `nutrituti_database.dart`
- Registrar 7 tabelas e 6 DAOs
- Configurar web + mobile

**Tempo:** ~30 min

#### 1.7 Build Runner
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Tempo:** ~5 min

---

### ✅ FASE 2: DI Integration (30 min)

#### 2.1 Database Module
```dart
@module
abstract class DatabaseModule {
  @singleton
  NutriTutiDatabase get database => NutriTutiDatabase();
}
```

#### 2.2 Atualizar Injectable
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### ✅ FASE 3: Migrar Features (8-10 horas)

#### 3.1 Feature: Comentários (1h)
**Prioridade:** 1 (mais simples)
**Complexidade:** ⭐☆☆☆☆

1. Backup datasource e model
2. Reimplementar datasource com ComentarioDao
3. Atualizar model (remover Hive)
4. Testar CRUD

**Arquivos:**
- `lib/repository/comentarios_repository.dart`
- `lib/database/comentarios_models.dart`

#### 3.2 Feature: Perfil (1-1.5h)
**Prioridade:** 2
**Complexidade:** ⭐⭐☆☆☆

1. Backup repository e model
2. Reimplementar com PerfilDao
3. Atualizar model
4. Testar CRUD

**Arquivos:**
- `lib/repository/perfil_repository.dart`
- `lib/database/perfil_model.dart`

#### 3.3 Feature: Peso (2-2.5h)
**Prioridade:** 3
**Complexidade:** ⭐⭐⭐☆☆ (Firebase sync + soft delete)

1. Backup repository e model
2. Reimplementar com PesoDao
3. Manter integração Firebase
4. Testar CRUD + sync + soft delete

**Arquivos:**
- `lib/pages/peso/repository/peso_repository.dart`
- `lib/pages/peso/models/peso_model.dart`

#### 3.4 Feature: Água Legacy (2-2.5h)
**Prioridade:** 4
**Complexidade:** ⭐⭐⭐☆☆ (Firebase sync + SharedPrefs)

1. Backup repository e model
2. Reimplementar com AguaDao
3. Manter SharedPreferences para metas/streak
4. Manter integração Firebase
5. Testar CRUD + sync

**Arquivos:**
- `lib/pages/agua/repository/agua_repository.dart`
- `lib/pages/agua/models/beber_agua_model.dart`

#### 3.5 Feature: Water Clean Arch (3-4h)
**Prioridade:** 5 (mais complexa)
**Complexidade:** ⭐⭐⭐⭐☆ (Clean Arch + enum + 2 tables)

1. Backup datasource e models
2. Reimplementar datasource com WaterDao
3. Converter enum AchievementType
4. Atualizar models (remover Hive)
5. Manter SharedPreferences para dailyGoal/streak
6. Testar CRUD + achievements

**Arquivos:**
- `lib/features/water/data/datasources/water_local_datasource.dart`
- `lib/features/water/data/models/water_record_model.dart`
- `lib/features/water/data/models/water_achievement_model.dart`

#### 3.6 Feature: Exercícios (3-4h)
**Prioridade:** 6 (mais complexa)
**Complexidade:** ⭐⭐⭐⭐☆ (offline-first + sync queue)

1. Backup service e model
2. Reimplementar com ExercicioDao
3. Implementar sync queue management com Drift
4. Manter connectivity listener
5. Testar offline-first + sync

**Arquivos:**
- `lib/pages/exercicios/services/exercicio_persistence_service.dart`
- `lib/pages/exercicios/models/exercicio_model.dart`

---

### ✅ FASE 4: Cleanup (1 hora)

#### 4.1 Remover Hive Models e Services
```bash
rm -rf lib/database/perfil_model.g.dart
rm -rf lib/database/comentarios_models.g.dart
rm lib/pages/agua/models/beber_agua_model.g.dart
rm lib/pages/peso/models/peso_model.g.dart
rm lib/features/water/data/models/water_record_model.g.dart
rm lib/features/water/data/models/water_achievement_model.g.dart

rm lib/core/services/hive_service.dart
rm lib/services/nutrituti_hive_service.dart
```

#### 4.2 Remover Hive do pubspec.yaml
```yaml
# Remover:
hive: any
hive_flutter: any
hive_generator: ^2.0.1
```

#### 4.3 Limpar Imports
- Buscar e remover imports de Hive não usados
- Verificar arquivos que importam models Hive

#### 4.4 Build Final
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze --no-pub
```

---

## 🎯 ESTIMATIVAS DETALHADAS

| Fase | Tarefa | Tempo | Complexidade |
|------|--------|-------|--------------|
| **FASE 1: Database Setup** | | |
| 1.1 | Dependências | 5 min | ⭐ |
| 1.2 | Estrutura | 10 min | ⭐ |
| 1.3 | 7 Tabelas | 2h | ⭐⭐⭐ |
| 1.4 | 6 DAOs (~92 métodos) | 2h | ⭐⭐⭐ |
| 1.5 | Converters | 15 min | ⭐⭐ |
| 1.6 | Database | 30 min | ⭐⭐ |
| 1.7 | Build | 5 min | ⭐ |
| **Subtotal FASE 1** | | **~5h** | ⭐⭐⭐ |
| **FASE 2: DI** | | |
| 2.1 | DI Module | 10 min | ⭐ |
| 2.2 | Build | 5 min | ⭐ |
| **Subtotal FASE 2** | | **~15min** | ⭐ |
| **FASE 3: Features** | | |
| 3.1 | Comentários | 1h | ⭐ |
| 3.2 | Perfil | 1.5h | ⭐⭐ |
| 3.3 | Peso | 2.5h | ⭐⭐⭐ |
| 3.4 | Água Legacy | 2.5h | ⭐⭐⭐ |
| 3.5 | Water Clean Arch | 4h | ⭐⭐⭐⭐ |
| 3.6 | Exercícios | 4h | ⭐⭐⭐⭐ |
| **Subtotal FASE 3** | | **~15.5h** | ⭐⭐⭐⭐ |
| **FASE 4: Cleanup** | | |
| 4.1-4.4 | Cleanup completo | 1h | ⭐⭐ |
| **Subtotal FASE 4** | | **~1h** | ⭐⭐ |
| **TOTAL ESTIMADO** | | **~22h** | ⭐⭐⭐ |

**Distribuição em dias úteis:**
- Dia 1: FASE 1 + FASE 2 (5.25h)
- Dia 2: FASE 3.1-3.4 (7.5h)
- Dia 3: FASE 3.5-3.6 + FASE 4 (9h)

**Estimativa final:** 2-3 dias + testes

---

## 🔧 PADRÕES A SEGUIR

### Conversões (Template petiveti)

#### IDs
```dart
// Hive usa String, Drift usa Int autoincrement
// Model mantém String? id para compatibilidade
// Na conversão para Companion:
final companion = TableCompanion.insert(
  // id não inclui (autoincrement)
  userId: userId,
  // outros campos
);

// Na conversão de Entity para Model:
final model = Model(
  id: entity.id.toString(),  // Int → String
  // outros campos
);
```

#### Timestamps
```dart
// Drift gerencia automaticamente
createdAt: Value(DateTime.now())
updatedAt: Value(DateTime.now())
```

#### Enums (Water Achievement)
```dart
// Usar TypeConverter
class AchievementTypeConverter extends TypeConverter<AchievementType, int> {
  @override
  AchievementType fromSql(int fromDb) => AchievementType.values[fromDb];
  
  @override
  int toSql(AchievementType value) => value.index;
}

// No model:
@UseRowClass(WaterAchievementTableData, constructor: 'fromDb')
class WaterAchievementTable extends Table {
  IntColumn get achievementType => integer()
    .map(const AchievementTypeConverter())();
}
```

#### Soft Delete
```dart
// Implementar nos DAOs que precisam
Future<void> softDelete(int id) {
  return (update(table)..where((t) => t.id.equals(id)))
    .write(TableCompanion(
      isDeleted: Value(true),
      updatedAt: Value(DateTime.now()),
    ));
}

// Query ignorando deletados
Future<List<TableData>> getAll(String userId) {
  return (select(table)
    ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
  ).get();
}
```

#### Firebase Sync
```dart
// Manter lógica de sync existente
// Exemplo no PesoRepository:
Future<void> add(PesoModel registro) async {
  // 1. Salvar no Drift
  await _database.pesoDao.createPeso(registro.toCompanion());
  
  // 2. Sync com Firebase
  await _firestore.createRecord(collectionName, registro.toMap());
  
  // 3. Atualizar observable (se necessário)
  await getAll();
}
```

---

## ⚠️ PONTOS DE ATENÇÃO

### Alto Risco ⚠️⚠️
1. **Water Feature (Clean Arch):**
   - Tem enum AchievementType para converter
   - 2 tabelas relacionadas (records + achievements)
   - SharedPreferences separado para settings
   - Precisa manter compatibilidade com domain layer

2. **Exercícios (Offline-first):**
   - 3 Hive boxes diferentes (exercicios, sync_queue, metadata)
   - Sync queue management complexo
   - Conflict resolution
   - Connectivity listener
   - **Solução:** Implementar sync queue usando campos na ExercicioTable

3. **Firebase Sync (3 features):**
   - Peso, Água Legacy, Exercícios usam Firestore
   - Precisa manter lógica de sync
   - Verificar conectividade antes de sync
   - **Solução:** Manter repositories com dupla persistência

### Médio Risco ⚠️
1. **Duplicação Água/Water:**
   - Duas implementações de rastreamento de água
   - Verificar se podem coexistir ou migrar para uma única
   - **Recomendação:** Manter ambas durante migração, depois avaliar unificação

2. **Soft Delete (Peso):**
   - Usar isDeleted ao invés de delete real
   - Filtrar queries para ignorar deletados
   - **Solução:** Implementar em PesoDao

3. **ValueNotifier Observable (Peso):**
   - Repository atual usa ValueNotifier para UI reactivity
   - **Solução:** Manter ou migrar para Streams do Drift

### Baixo Risco ✅
1. **Comentários:** Feature mais simples, sem sync
2. **Perfil:** Feature isolada, sem relacionamentos
3. **Calculadoras:** Não precisam migração (DTOs)
4. **Settings:** Já usa SharedPreferences

---

## 📊 COMPARATIVO: ANTES vs DEPOIS

| Aspecto | Antes (Hive) | Depois (Drift) |
|---------|--------------|----------------|
| Tabelas | 6 Hive Boxes | 7 SQLite Tables |
| Type Safety | Runtime | Compile-time ✅ |
| Queries | Manual loops | SQL tipado ✅ |
| Streams | Manual ValueNotifier | Nativos watch() ✅ |
| Enums | Manual int/string | TypeConverter ✅ |
| Web Support | Parcial | Completo ✅ |
| Sync Queue | 3 separate boxes | 1 table + flags ✅ |
| Relations | Manual FK | Foreign Keys ✅ |
| Code | ~800 linhas | ~700 linhas ✅ |
| Manutenção | Hive (declínio) | Drift (ativo) ✅ |

---

## 🎯 CHECKLIST DE EXECUÇÃO

### Preparação
- [ ] Criar branch `feature/migrate-to-drift`
- [ ] Backup completo do código
- [ ] Documentar estado atual
- [ ] Validar builds atuais

### Fase 1: Database (Dia 1 manhã)
- [ ] Adicionar dependências Drift
- [ ] Criar estrutura de diretórios
- [ ] Implementar 7 tabelas
- [ ] Implementar 6 DAOs (~92 métodos)
- [ ] Implementar AchievementTypeConverter
- [ ] Criar NutriTutiDatabase
- [ ] Executar build_runner
- [ ] Verificar arquivos `.g.dart` gerados

### Fase 2: DI (Dia 1 manhã)
- [ ] Criar DatabaseModule
- [ ] Registrar no injectable
- [ ] Executar build_runner
- [ ] Verificar injeção funcionando

### Fase 3: Features (Dia 1 tarde + Dia 2 completo)

#### 3.1 Comentários (1h)
- [ ] Backup datasource e model
- [ ] Reimplementar com ComentarioDao
- [ ] Atualizar model
- [ ] Testar CRUD básico

#### 3.2 Perfil (1.5h)
- [ ] Backup repository e model
- [ ] Reimplementar com PerfilDao
- [ ] Atualizar model
- [ ] Testar CRUD + ValueNotifier

#### 3.3 Peso (2.5h)
- [ ] Backup repository e model
- [ ] Reimplementar com PesoDao
- [ ] Manter Firebase sync
- [ ] Implementar soft delete
- [ ] Testar CRUD + sync + soft delete

#### 3.4 Água Legacy (2.5h)
- [ ] Backup repository e model
- [ ] Reimplementar com AguaDao
- [ ] Manter SharedPreferences settings
- [ ] Manter Firebase sync
- [ ] Testar CRUD + settings + sync

#### 3.5 Water Clean Arch (4h)
- [ ] Backup datasource e models
- [ ] Reimplementar com WaterDao
- [ ] Converter enum AchievementType
- [ ] Atualizar models (remover Hive)
- [ ] Manter SharedPreferences settings
- [ ] Testar records + achievements + settings

#### 3.6 Exercícios (4h)
- [ ] Backup service e model
- [ ] Reimplementar com ExercicioDao
- [ ] Migrar sync queue para flags na tabela
- [ ] Manter connectivity listener
- [ ] Testar offline-first + sync + queue

### Fase 4: Cleanup (Dia 3)
- [ ] Remover Hive models (`.g.dart`)
- [ ] Remover HiveService files
- [ ] Remover Hive do pubspec.yaml
- [ ] Limpar imports não usados
- [ ] Executar `flutter pub get`
- [ ] Executar build_runner final
- [ ] Executar `flutter analyze`
- [ ] Validar compilação

### Testes Finais
- [ ] Testar CRUD de todas features
- [ ] Testar Firebase sync (Peso, Água, Exercícios)
- [ ] Testar offline-first (Exercícios)
- [ ] Testar SharedPreferences integration
- [ ] Validar calculadoras funcionando
- [ ] Validar settings funcionando

### Finalização
- [ ] Commit organizado por feature
- [ ] Atualizar MIGRATION_ANALYSIS.md
- [ ] Criar MIGRATION_COMPLETE.md
- [ ] Marcar como completo no MONOREPO_MIGRATION_STATUS.md
- [ ] Celebrar! 🎉

---

## 📚 RECURSOS DISPONÍVEIS

### Templates Validados
- ✅ app-petiveti (100% completo)
- ✅ app-termostecnicos (100% completo)
- ✅ Datasource pattern
- ✅ Model pattern
- ✅ DAO pattern
- ✅ Conversions pattern
- ✅ Enum converter pattern

### Documentação
- `apps/app-petiveti/MIGRATION_COMPLETE.md`
- `apps/app-petiveti/MIGRATION_FINAL_REPORT.md`
- `apps/app-termostecnicos/MIGRATION_PLAN_HIVE_TO_DRIFT.md`
- `MONOREPO_MIGRATION_STATUS.md`

---

## 💡 COMPARAÇÃO COM OUTRAS MIGRAÇÕES

| App | Features | Tabelas | DAOs | Tempo | Complexidade |
|-----|----------|---------|------|-------|--------------|
| **termostecnicos** | 1 | 1 | 1 | 3h | ⭐⭐☆☆☆ |
| **petiveti** | 8 | 8 | 8 | 1 dia | ⭐⭐⭐☆☆ |
| **nutrituti** | 6 | 7 | 6 | 2-3 dias | ⭐⭐⭐☆☆ |

### Por que nutrituti é mais complexo?

1. **Clean Architecture (Water feature):**
   - Primeira feature com Clean Arch completa
   - Domain layer separada
   - Enum converter necessário
   - 2 tabelas relacionadas

2. **Offline-first (Exercícios):**
   - Sync queue management
   - 3 Hive boxes para migrar
   - Conflict resolution
   - Background sync

3. **Firebase Sync (3 features):**
   - Peso, Água, Exercícios
   - Dupla persistência (local + remote)
   - Connectivity checks

4. **Duplicação (Água/Water):**
   - Duas implementações coexistindo
   - Legacy + Clean Arch

**Mas ainda é MÉDIA complexidade porque:**
- ✅ 20+ calculadoras NÃO precisam migração (DTOs)
- ✅ Settings já usa SharedPreferences
- ✅ Templates validados disponíveis
- ✅ Padrões bem definidos

---

## 🎉 PÓS-MIGRAÇÃO

### Validações Obrigatórias
1. ✅ Build limpo (zero erros)
2. ✅ Analyzer sem warnings
3. ✅ CRUD de 6 features funcional
4. ✅ Firebase sync funcionando (3 features)
5. ✅ Offline-first funcionando (Exercícios)
6. ✅ SharedPreferences settings OK
7. ✅ Calculadoras funcionando
8. ✅ Enum conversion OK (Water achievements)

### Métricas de Sucesso
- **Type Safety:** 100% compile-time
- **Code Reduction:** ~100 linhas menos
- **Performance:** Queries 2-3x mais rápidas
- **Web Support:** 100% funcional
- **Maintenance:** Zero dependências deprecated

### Next Steps
1. Testes unitários (DAOs)
2. Testes de integração (repositories)
3. Testes E2E (features)
4. Deploy em staging
5. Validação com usuários
6. Deploy em produção

### Possível Otimização Futura
- **Unificar Água/Water:** Avaliar migração de legacy para Clean Arch
- **Remove ValueNotifier:** Migrar para Streams nativos do Drift
- **Centralize Sync:** Extrair lógica de sync para service compartilhado

---

## 🎯 VANTAGENS DESTA MIGRAÇÃO

### Segurança 🛡️
- Type-safe queries (compile-time)
- Foreign keys validadas
- Enum converters seguros
- Migrations automáticas

### Performance 🚀
- Queries SQL otimizadas
- Índices automáticos
- Streams nativos eficientes
- Web performance melhorada

### Manutenibilidade 🔧
- Código mais limpo
- DAOs organizados
- Conversões centralizadas
- Documentação clara

### Escalabilidade 📈
- Fácil adicionar novas tabelas
- Relacionamentos suportados
- Migrations versionadas
- Cross-platform 100%

---

**🚀 Esta será a SEGUNDA maior migração do monorepo!**

**Motivo:** 6 features com persistência + Clean Arch + offline-first + Firebase sync

**Tempo real esperado:** 22 horas (~3 dias úteis)

**Complexidade real:** MÉDIA (não tão simples quanto termostecnicos, mais complexa que petiveti)

---

**📅 Criado:** 13/11/2024  
**📝 Baseado:** Templates petiveti + termostecnicos  
**🎯 Status:** PRONTO PARA EXECUTAR  
**👤 Responsável:** flutter-architect + flutter-engineer  
**🔄 Revisão:** Recomendado após cada fase
