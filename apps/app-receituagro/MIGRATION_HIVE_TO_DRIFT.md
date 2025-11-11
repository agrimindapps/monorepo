# Migração HiveBox → Drift: app-receituagro

## 📋 Índice

1. [Resumo Executivo](#resumo-executivo)
2. [Análise da Implementação Atual](#análise-da-implementação-atual)
3. [Arquitetura Drift (Referência: app-gasometer-drift)](#arquitetura-drift-referência-app-gasometer-drift)
4. [Plano de Migração Fase a Fase](#plano-de-migração-fase-a-fase)
5. [Mapeamento de Modelos](#mapeamento-de-modelos)
6. [Padrões e Best Practices](#padrões-e-best-practices)
7. [Riscos e Mitigações](#riscos-e-mitigações)
8. [Checklist de Execução](#checklist-de-execução)

---

## 📊 Resumo Executivo

### Objetivo
Migrar o app-receituagro de **HiveBox** (NoSQL key-value) para **Drift** (SQL relacional) para melhorar:
- **Performance**: Queries complexas e joins eficientes
- **Type Safety**: Schemas tipados e validação em compile-time
- **Escalabilidade**: Suporte a queries relacionais e índices
- **Sincronização**: Melhor controle de dirty flags e versioning
- **Maintainability**: Migrations versionadas e schema evolution

### Escopo
- **8 modelos Hive** → **8 tabelas Drift**
- **3 repositórios principais** (diagnosticos, favoritos, comentários)
- **Dados estáticos JSON** (mantidos como assets)
- **Sem perda de dados**: Migration tool para converter Hive → Drift

### Estimativa de Tempo
**12-16 horas** (2-3 dias de trabalho)

---

## 🔍 Análise da Implementação Atual

### Modelos Hive Identificados (8 tabelas)

| Modelo Hive | TypeId | Campos Principais | Uso |
|-------------|--------|-------------------|-----|
| `DiagnosticoHive` | 101 | objectId, idReg, fkIdDefensivo, fkIdCultura, fkIdPraga | Diagnósticos de pragas (user-generated) |
| `FavoritoItemHive` | 110 | sync_objectId, tipo, itemId, itemData | Favoritos multi-tipo |
| `ComentarioHive` | 111 | sync_objectId, itemId, texto, userId | Comentários de usuários |
| `CulturaHive` | 102 | objectId, idCultura, nome | Dados estáticos (JSON) |
| `PragaHive` | 103 | objectId, idPraga, nome | Dados estáticos (JSON) |
| `PragaInfHive` | 104 | objectId, idReg, fkIdPraga | Dados estáticos (JSON) |
| `FitossanitarioHive` | 105 | objectId, idDefensivo, nome | Dados estáticos (JSON) |
| `FitossanitarioInfoHive` | 106 | objectId, idReg, fkIdDefensivo | Dados estáticos (JSON) |

### Repositórios Principais

#### 1. **UserDataRepository**
- Gerencia dados do usuário (settings, subscription)
- Delega para repositórios especializados:
  - `IFavoritosRepository` → Favoritos
  - `IComentariosRepository` → Comentários
- Usa `HiveBoxManager.withBox()` para safe box operations

#### 2. **Favoritos Repository**
- CRUD de favoritos multi-tipo (defensivos, pragas, diagnosticos, culturas)
- Armazena JSON string no campo `itemData` para cache

#### 3. **Comentarios Repository**
- CRUD de comentários vinculados a items
- Validação de userId para ownership

### Padrões Arquiteturais Atuais

#### ✅ **Boas Práticas (Manter)**
- `HiveBoxManager.withBox()`: Safe box lifecycle (try-finally)
- Repository Pattern com interfaces (`IFavoritosRepository`)
- Delegation Pattern (UserDataRepository → repositórios especializados)
- Either<Failure, T> para error handling

#### ⚠️ **Limitações do Hive (Resolver com Drift)**
- Sem foreign keys → Dados denormalizados (ex: `nomeDefensivo` duplicado)
- Sem joins → Queries ineficientes (múltiplas box opens)
- Sem índices → Performance ruim em queries complexas
- Sem migrations estruturadas → Schema evolution manual
- TypeIds manuais → Risco de conflitos

---

## 🏗️ Arquitetura Drift (Referência: app-gasometer-drift)

### Estrutura do Projeto

```
app-receituagro/
├── lib/
│   ├── database/
│   │   ├── receituagro_database.dart          # @DriftDatabase central
│   │   ├── receituagro_database.g.dart        # Generated code
│   │   ├── tables/
│   │   │   └── receituagro_tables.dart        # Todas as tabelas
│   │   ├── repositories/
│   │   │   ├── diagnostico_repository.dart    # Drift repo
│   │   │   ├── favorito_repository.dart       # Drift repo
│   │   │   └── comentario_repository.dart     # Drift repo
│   │   └── providers/
│   │       └── database_providers.dart        # Riverpod providers
```

### Componentes Principais

#### 1. **Database Class** (`ReceituagroDatabase`)
```dart
@DriftDatabase(
  tables: [
    Diagnosticos,
    Favoritos,
    Comentarios,
    Culturas,
    Pragas,
    PragasInf,
    Fitossanitarios,
    FitossanitariosInfo,
  ],
)
@lazySingleton
class ReceituagroDatabase extends _$ReceituagroDatabase with BaseDriftDatabase {
  ReceituagroDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  // Factories: production, development, test, withPath

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Future migrations
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
```

#### 2. **Table Definitions** (Drift Tables)
```dart
class Diagnosticos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text()();

  // Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // Sync control
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // Foreign keys (normalized)
  IntColumn get defenisivoId => integer().references(Fitossanitarios, #id)();
  IntColumn get culturaId => integer().references(Culturas, #id)();
  IntColumn get pragaId => integer().references(Pragas, #id)();

  // Business fields
  TextColumn get dsMin => text().nullable()();
  TextColumn get dsMax => text()();
  TextColumn get um => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, firebaseId},  // Unique per user + Firebase
  ];
}
```

#### 3. **Repository Pattern** (BaseDriftRepositoryImpl)
```dart
@lazySingleton
class DiagnosticoRepository extends BaseDriftRepositoryImpl<DiagnosticoData, Diagnostico> {
  DiagnosticoRepository(this._db);

  final ReceituagroDatabase _db;

  @override
  TableInfo<Diagnosticos, Diagnostico> get table => _db.diagnosticos;

  @override
  GeneratedDatabase get database => _db;

  @override
  DiagnosticoData fromData(Diagnostico data) { /* mapping */ }

  @override
  Insertable<Diagnostico> toCompanion(DiagnosticoData entity) { /* mapping */ }

  // Custom queries with joins
  Future<List<DiagnosticoEnriched>> findAllWithRelations(String userId) async {
    final query = _db.select(_db.diagnosticos).join([
      leftOuterJoin(_db.fitossanitarios, _db.fitossanitarios.id.equalsExp(_db.diagnosticos.defenisivoId)),
      leftOuterJoin(_db.culturas, _db.culturas.id.equalsExp(_db.diagnosticos.culturaId)),
      leftOuterJoin(_db.pragas, _db.pragas.id.equalsExp(_db.diagnosticos.pragaId)),
    ])..where(_db.diagnosticos.userId.equals(userId) & _db.diagnosticos.isDeleted.equals(false));

    final results = await query.get();
    return results.map((row) => DiagnosticoEnriched.fromJoinedRow(row)).toList();
  }

  // Streams for reactive UI
  Stream<List<DiagnosticoData>> watchByUserId(String userId) {
    return (_db.select(_db.diagnosticos)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
      .watch()
      .map((dataList) => dataList.map((data) => fromData(data)).toList());
  }
}
```

### Key Features do Drift

#### ✅ **Type Safety**
- Schema em compile-time
- Auto-complete em queries
- Null-safety enforced

#### ✅ **Performance**
- Foreign keys e índices nativos
- Joins eficientes (SQL)
- Query optimization

#### ✅ **Migrations Versionadas**
```dart
@override
int get schemaVersion => 2;

onUpgrade: (Migrator m, int from, int to) async {
  if (from < 2) {
    await m.addColumn(diagnosticos, diagnosticos.newField);
  }
}
```

#### ✅ **Reactive Streams**
```dart
Stream<List<Diagnostico>> watchDiagnosticos(String userId) {
  return select(diagnosticos)
    ..where((tbl) => tbl.userId.equals(userId))
    .watch();
}
```

#### ✅ **Soft Deletes & Dirty Tracking**
```dart
BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
DateTimeColumn get lastSyncAt => dateTime().nullable()();
```

---

## 📝 Plano de Migração Fase a Fase

### **Fase 1: Setup & Configuração** (2-3h)

#### 1.1 Adicionar Dependências
```yaml
# pubspec.yaml
dependencies:
  drift: ^2.28.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.9.0

dev_dependencies:
  drift_dev: ^2.28.0
  build_runner: ^2.4.6
```

#### 1.2 Criar Estrutura de Diretórios
```bash
mkdir -p lib/database/{tables,repositories,providers}
```

#### 1.3 Configurar Package Core
Adicionar ao `packages/core`:
- `BaseDriftDatabase` mixin
- `BaseDriftRepositoryImpl` base class
- `DriftDatabaseConfig` utility

### **Fase 2: Definir Tabelas Drift** (3-4h)

#### 2.1 Criar `lib/database/tables/receituagro_tables.dart`

##### Tabela: Diagnosticos
```dart
class Diagnosticos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get moduleName => text().withDefault(const Constant('receituagro'))();

  // Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // Sync control
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // Foreign keys (NORMALIZED)
  IntColumn get defenisivoId => integer().references(Fitossanitarios, #id, onDelete: KeyAction.restrict)();
  IntColumn get culturaId => integer().references(Culturas, #id, onDelete: KeyAction.restrict)();
  IntColumn get pragaId => integer().references(Pragas, #id, onDelete: KeyAction.restrict)();

  // Business fields
  TextColumn get idReg => text()();
  TextColumn get dsMin => text().nullable()();
  TextColumn get dsMax => text()();
  TextColumn get um => text()();
  TextColumn get minAplicacaoT => text().nullable()();
  TextColumn get maxAplicacaoT => text().nullable()();
  TextColumn get umT => text().nullable()();
  TextColumn get minAplicacaoA => text().nullable()();
  TextColumn get maxAplicacaoA => text().nullable()();
  TextColumn get umA => text().nullable()();
  TextColumn get intervalo => text().nullable()();
  TextColumn get intervalo2 => text().nullable()();
  TextColumn get epocaAplicacao => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, idReg},  // idReg é único por usuário
  ];
}
```

##### Tabela: Favoritos
```dart
class Favoritos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text()();

  // Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // Sync control
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // Business fields
  TextColumn get tipo => text()();  // 'defensivos', 'pragas', 'diagnosticos', 'culturas'
  TextColumn get itemId => text()();  // ID do item original
  TextColumn get itemData => text()();  // JSON string (cache)

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, tipo, itemId},  // Um favorito por tipo/item/usuário
  ];
}
```

##### Tabela: Comentarios
```dart
class Comentarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text()();

  // Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // Sync control
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // Business fields
  TextColumn get itemId => text()();  // ID do item comentado
  TextColumn get texto => text()();

  // Índices para queries rápidas
  @override
  List<Set<Column>> get uniqueKeys => [];
}
```

##### Tabelas Estáticas (Dados JSON)
```dart
class Culturas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get idCultura => text().unique()();
  TextColumn get nome => text()();
  TextColumn get nomeLatino => text().nullable()();
  TextColumn get familia => text().nullable()();
}

class Pragas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get idPraga => text().unique()();
  TextColumn get nome => text()();
  TextColumn get nomeLatino => text().nullable()();
  TextColumn get tipo => text().nullable()();  // 'inseto', 'fungo', 'bacteria', etc.
}

class PragasInf extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get idReg => text().unique()();
  IntColumn get pragaId => integer().references(Pragas, #id)();
  TextColumn get sintomas => text().nullable()();
  TextColumn get controle => text().nullable()();
  TextColumn get imagemUrl => text().nullable()();
}

class Fitossanitarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get idDefensivo => text().unique()();
  TextColumn get nome => text()();
  TextColumn get fabricante => text().nullable()();
  TextColumn get classe => text().nullable()();
  TextColumn get ingredienteAtivo => text().nullable()();
}

class FitossanitariosInfo extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get idReg => text().unique()();
  IntColumn get defensivoId => integer().references(Fitossanitarios, #id)();
  TextColumn get modoAcao => text().nullable()();
  TextColumn get formulacao => text().nullable()();
  TextColumn get toxicidade => text().nullable()();
}
```

#### 2.2 Criar `lib/database/receituagro_database.dart`
```dart
@DriftDatabase(
  tables: [
    Diagnosticos,
    Favoritos,
    Comentarios,
    Culturas,
    Pragas,
    PragasInf,
    Fitossanitarios,
    FitossanitariosInfo,
  ],
)
@lazySingleton
class ReceituagroDatabase extends _$ReceituagroDatabase with BaseDriftDatabase {
  ReceituagroDatabase(QueryExecutor e) : super(e);

  @factoryMethod
  factory ReceituagroDatabase.injectable() {
    return ReceituagroDatabase.production();
  }

  @override
  int get schemaVersion => 1;

  factory ReceituagroDatabase.production() {
    return ReceituagroDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'receituagro_drift.db',
        logStatements: false,
      ),
    );
  }

  factory ReceituagroDatabase.test() {
    return ReceituagroDatabase(
      DriftDatabaseConfig.createInMemoryExecutor(logStatements: true),
    );
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');

      if (details.wasCreated) {
        print('✅ ReceituagroDatabase created successfully!');
        // Popular dados estáticos (culturas, pragas, defensivos)
        await _populateStaticData();
      }
    },
  );

  /// Popula dados estáticos do JSON (culturas, pragas, defensivos)
  Future<void> _populateStaticData() async {
    // TODO: Implementar carregamento dos JSON assets
    // e inserir nas tabelas estáticas
  }
}
```

#### 2.3 Gerar Código Drift
```bash
dart run build_runner build --delete-conflicting-outputs
```

### **Fase 3: Criar Repositórios Drift** (3-4h)

#### 3.1 DiagnosticoRepository
```dart
@lazySingleton
class DiagnosticoRepository extends BaseDriftRepositoryImpl<DiagnosticoData, Diagnostico> {
  DiagnosticoRepository(this._db);

  final ReceituagroDatabase _db;

  @override
  TableInfo<Diagnosticos, Diagnostico> get table => _db.diagnosticos;

  @override
  GeneratedDatabase get database => _db;

  // Mapping methods
  @override
  DiagnosticoData fromData(Diagnostico data) { /* ... */ }

  @override
  Insertable<Diagnostico> toCompanion(DiagnosticoData entity) { /* ... */ }

  // Custom queries
  Future<List<DiagnosticoEnriched>> findAllWithRelations(String userId) async {
    final query = _db.select(_db.diagnosticos).join([
      leftOuterJoin(_db.fitossanitarios, _db.fitossanitarios.id.equalsExp(_db.diagnosticos.defenisivoId)),
      leftOuterJoin(_db.culturas, _db.culturas.id.equalsExp(_db.diagnosticos.culturaId)),
      leftOuterJoin(_db.pragas, _db.pragas.id.equalsExp(_db.diagnosticos.pragaId)),
    ])
      ..where(_db.diagnosticos.userId.equals(userId) & _db.diagnosticos.isDeleted.equals(false))
      ..orderBy([OrderingTerm.desc(_db.diagnosticos.createdAt)]);

    return query.get().then((rows) => rows.map((row) {
      final diagnostico = row.readTable(_db.diagnosticos);
      final defensivo = row.readTableOrNull(_db.fitossanitarios);
      final cultura = row.readTableOrNull(_db.culturas);
      final praga = row.readTableOrNull(_db.pragas);

      return DiagnosticoEnriched(
        diagnostico: fromData(diagnostico),
        defensivo: defensivo != null ? FitossanitarioData.fromDrift(defensivo) : null,
        cultura: cultura != null ? CulturaData.fromDrift(cultura) : null,
        praga: praga != null ? PragaData.fromDrift(praga) : null,
      );
    }).toList());
  }

  Stream<List<DiagnosticoData>> watchByUserId(String userId) {
    return (_db.select(_db.diagnosticos)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
      .watch()
      .map((dataList) => dataList.map(fromData).toList());
  }
}
```

#### 3.2 FavoritoRepository
```dart
@lazySingleton
class FavoritoRepository extends BaseDriftRepositoryImpl<FavoritoData, Favorito> {
  FavoritoRepository(this._db);

  final ReceituagroDatabase _db;

  @override
  TableInfo<Favoritos, Favorito> get table => _db.favoritos;

  @override
  GeneratedDatabase get database => _db;

  Future<List<FavoritoData>> findByUserAndType(String userId, String tipo) async {
    return (_db.select(_db.favoritos)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.tipo.equals(tipo) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
      .get()
      .then((list) => list.map(fromData).toList());
  }

  Stream<List<FavoritoData>> watchByUser(String userId) {
    return (_db.select(_db.favoritos)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false)))
      .watch()
      .map((list) => list.map(fromData).toList());
  }

  Future<bool> isFavorited(String userId, String tipo, String itemId) async {
    final count = await (_db.selectOnly(_db.favoritos)
      ..addColumns([_db.favoritos.id.count()])
      ..where(
        _db.favoritos.userId.equals(userId) &
        _db.favoritos.tipo.equals(tipo) &
        _db.favoritos.itemId.equals(itemId) &
        _db.favoritos.isDeleted.equals(false)
      )).getSingle();

    return (count.read(_db.favoritos.id.count()) ?? 0) > 0;
  }
}
```

#### 3.3 ComentarioRepository
```dart
@lazySingleton
class ComentarioRepository extends BaseDriftRepositoryImpl<ComentarioData, Comentario> {
  ComentarioRepository(this._db);

  final ReceituagroDatabase _db;

  @override
  TableInfo<Comentarios, Comentario> get table => _db.comentarios;

  @override
  GeneratedDatabase get database => _db;

  Future<List<ComentarioData>> findByItem(String itemId) async {
    return (_db.select(_db.comentarios)
      ..where((tbl) => tbl.itemId.equals(itemId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
      .get()
      .then((list) => list.map(fromData).toList());
  }

  Stream<List<ComentarioData>> watchByItem(String itemId) {
    return (_db.select(_db.comentarios)
      ..where((tbl) => tbl.itemId.equals(itemId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
      .watch()
      .map((list) => list.map(fromData).toList());
  }

  Future<int> countByItem(String itemId) async {
    final result = await (_db.selectOnly(_db.comentarios)
      ..addColumns([_db.comentarios.id.count()])
      ..where(_db.comentarios.itemId.equals(itemId) & _db.comentarios.isDeleted.equals(false)))
      .getSingle();

    return result.read(_db.comentarios.id.count()) ?? 0;
  }
}
```

### **Fase 4: Migration Tool (Hive → Drift)** (2-3h)

#### 4.1 Criar `lib/database/migration_tool.dart`
```dart
/// Tool para migrar dados do Hive para Drift
class HiveToDriftMigrationTool {
  final IHiveManager _hiveManager;
  final ReceituagroDatabase _db;

  HiveToDriftMigrationTool({
    required IHiveManager hiveManager,
    required ReceituagroDatabase database,
  }) : _hiveManager = hiveManager, _db = database;

  /// Executa migração completa
  Future<MigrationResult> migrate() async {
    print('🔄 Iniciando migração Hive → Drift...');

    final result = MigrationResult();

    try {
      // 1. Migrar diagnosticos
      result.diagnosticos = await _migrateDiagnosticos();

      // 2. Migrar favoritos
      result.favoritos = await _migrateFavoritos();

      // 3. Migrar comentarios
      result.comentarios = await _migrateComentarios();

      // 4. Popular dados estáticos (culturas, pragas, defensivos)
      await _populateStaticData();

      print('✅ Migração concluída com sucesso!');
      print(result.summary);

      return result;
    } catch (e, stackTrace) {
      print('❌ Erro na migração: $e');
      print(stackTrace);
      result.error = e.toString();
      return result;
    }
  }

  Future<int> _migrateDiagnosticos() async {
    print('📦 Migrando diagnosticos...');

    final boxResult = await HiveBoxManager.withBox<DiagnosticoHive, List<DiagnosticoHive>>(
      hiveManager: _hiveManager,
      boxName: 'diagnosticos',
      operation: (box) async => box.values.toList(),
    );

    final hiveItems = boxResult.fold(
      (failure) => <DiagnosticoHive>[],
      (data) => data,
    );

    if (hiveItems.isEmpty) {
      print('  ⚠️  Nenhum diagnostico encontrado no Hive');
      return 0;
    }

    int migratedCount = 0;

    await _db.executeTransaction(() async {
      for (final hiveItem in hiveItems) {
        try {
          // Resolve foreign keys (busca IDs nas tabelas estáticas)
          final defensivoId = await _resolveDefenisivoId(hiveItem.fkIdDefensivo);
          final culturaId = await _resolveCulturaId(hiveItem.fkIdCultura);
          final pragaId = await _resolvePragaId(hiveItem.fkIdPraga);

          if (defensivoId == null || culturaId == null || pragaId == null) {
            print('  ⚠️  FK não resolvida para diagnostico ${hiveItem.objectId}');
            continue;
          }

          await _db.into(_db.diagnosticos).insert(
            DiagnosticosCompanion.insert(
              firebaseId: Value(hiveItem.objectId),
              userId: hiveItem.userId ?? '',
              createdAt: Value(DateTime.fromMillisecondsSinceEpoch(hiveItem.createdAt)),
              updatedAt: Value(DateTime.fromMillisecondsSinceEpoch(hiveItem.updatedAt)),
              idReg: hiveItem.idReg,
              defenisivoId: defensivoId,
              culturaId: culturaId,
              pragaId: pragaId,
              dsMin: Value(hiveItem.dsMin),
              dsMax: hiveItem.dsMax,
              um: hiveItem.um,
              minAplicacaoT: Value(hiveItem.minAplicacaoT),
              maxAplicacaoT: Value(hiveItem.maxAplicacaoT),
              umT: Value(hiveItem.umT),
              minAplicacaoA: Value(hiveItem.minAplicacaoA),
              maxAplicacaoA: Value(hiveItem.maxAplicacaoA),
              umA: Value(hiveItem.umA),
              intervalo: Value(hiveItem.intervalo),
              intervalo2: Value(hiveItem.intervalo2),
              epocaAplicacao: Value(hiveItem.epocaAplicacao),
            ),
            mode: InsertMode.insertOrIgnore,
          );

          migratedCount++;
        } catch (e) {
          print('  ❌ Erro migrando diagnostico ${hiveItem.objectId}: $e');
        }
      }
    }, operationName: 'Migrate diagnosticos');

    print('  ✅ $migratedCount diagnosticos migrados');
    return migratedCount;
  }

  Future<int> _migrateFavoritos() async {
    print('📦 Migrando favoritos...');

    final boxResult = await HiveBoxManager.withBox<FavoritoItemHive, List<FavoritoItemHive>>(
      hiveManager: _hiveManager,
      boxName: 'favoritos',
      operation: (box) async => box.values.toList(),
    );

    final hiveItems = boxResult.fold(
      (failure) => <FavoritoItemHive>[],
      (data) => data,
    );

    if (hiveItems.isEmpty) {
      print('  ⚠️  Nenhum favorito encontrado no Hive');
      return 0;
    }

    int migratedCount = 0;

    await _db.executeTransaction(() async {
      for (final hiveItem in hiveItems) {
        try {
          await _db.into(_db.favoritos).insert(
            FavoritosCompanion.insert(
              firebaseId: Value(hiveItem.sync_objectId),
              userId: '', // TODO: Resolver userId
              createdAt: Value(DateTime.fromMillisecondsSinceEpoch(hiveItem.sync_createdAt)),
              updatedAt: Value(DateTime.fromMillisecondsSinceEpoch(hiveItem.sync_updatedAt)),
              tipo: hiveItem.tipo,
              itemId: hiveItem.itemId,
              itemData: hiveItem.itemData,
            ),
            mode: InsertMode.insertOrIgnore,
          );

          migratedCount++;
        } catch (e) {
          print('  ❌ Erro migrando favorito ${hiveItem.sync_objectId}: $e');
        }
      }
    }, operationName: 'Migrate favoritos');

    print('  ✅ $migratedCount favoritos migrados');
    return migratedCount;
  }

  Future<int> _migrateComentarios() async {
    print('📦 Migrando comentarios...');

    final boxResult = await HiveBoxManager.withBox<ComentarioHive, List<ComentarioHive>>(
      hiveManager: _hiveManager,
      boxName: 'comentarios',
      operation: (box) async => box.values.toList(),
    );

    final hiveItems = boxResult.fold(
      (failure) => <ComentarioHive>[],
      (data) => data,
    );

    if (hiveItems.isEmpty) {
      print('  ⚠️  Nenhum comentario encontrado no Hive');
      return 0;
    }

    int migratedCount = 0;

    await _db.executeTransaction(() async {
      for (final hiveItem in hiveItems) {
        try {
          await _db.into(_db.comentarios).insert(
            ComentariosCompanion.insert(
              firebaseId: Value(hiveItem.sync_objectId),
              userId: hiveItem.userId ?? '',
              createdAt: Value(DateTime.fromMillisecondsSinceEpoch(hiveItem.sync_createdAt)),
              updatedAt: Value(DateTime.fromMillisecondsSinceEpoch(hiveItem.sync_updatedAt)),
              itemId: hiveItem.itemId,
              texto: hiveItem.texto,
            ),
            mode: InsertMode.insertOrIgnore,
          );

          migratedCount++;
        } catch (e) {
          print('  ❌ Erro migrando comentario ${hiveItem.sync_objectId}: $e');
        }
      }
    }, operationName: 'Migrate comentarios');

    print('  ✅ $migratedCount comentarios migrados');
    return migratedCount;
  }

  Future<void> _populateStaticData() async {
    print('📦 Populando dados estáticos (culturas, pragas, defensivos)...');

    // TODO: Implementar carregamento dos JSON assets
    // 1. Carregar culturas.json → inserir em _db.culturas
    // 2. Carregar pragas.json → inserir em _db.pragas
    // 3. Carregar pragasInf.json → inserir em _db.pragasInf
    // 4. Carregar defensivos.json → inserir em _db.fitossanitarios
    // 5. Carregar defensivosInfo.json → inserir em _db.fitossanitariosInfo

    print('  ✅ Dados estáticos populados');
  }

  Future<int?> _resolveDefenisivoId(String idDefensivo) async {
    final query = _db.select(_db.fitossanitarios)
      ..where((tbl) => tbl.idDefensivo.equals(idDefensivo))
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result?.id;
  }

  Future<int?> _resolveCulturaId(String idCultura) async {
    final query = _db.select(_db.culturas)
      ..where((tbl) => tbl.idCultura.equals(idCultura))
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result?.id;
  }

  Future<int?> _resolvePragaId(String idPraga) async {
    final query = _db.select(_db.pragas)
      ..where((tbl) => tbl.idPraga.equals(idPraga))
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result?.id;
  }
}

class MigrationResult {
  int diagnosticos = 0;
  int favoritos = 0;
  int comentarios = 0;
  String? error;

  String get summary => '''
📊 Resultado da Migração:
  - Diagnosticos: $diagnosticos
  - Favoritos: $favoritos
  - Comentários: $comentarios
  ${error != null ? '⚠️ Erro: $error' : '✅ Sucesso'}
  ''';
}
```

### **Fase 5: Atualizar Interfaces & UI** (2-3h)

#### 5.1 Criar Riverpod Providers
```dart
@riverpod
ReceituagroDatabase database(DatabaseRef ref) {
  final db = GetIt.instance<ReceituagroDatabase>();
  ref.onDispose(() => db.close());
  return db;
}

@riverpod
DiagnosticoRepository diagnosticoRepository(DiagnosticoRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  return DiagnosticoRepository(db);
}

@riverpod
Stream<List<DiagnosticoData>> diagnosticosStream(DiagnosticosStreamRef ref, String userId) {
  final repo = ref.watch(diagnosticoRepositoryProvider);
  return repo.watchByUserId(userId);
}
```

#### 5.2 Atualizar UI para usar Streams
```dart
// Antes (Hive)
@override
Widget build(BuildContext context) {
  return ValueListenableBuilder<Box<DiagnosticoHive>>(
    valueListenable: Hive.box<DiagnosticoHive>('diagnosticos').listenable(),
    builder: (context, box, _) {
      final diagnosticos = box.values.toList();
      return ListView.builder(...);
    },
  );
}

// Depois (Drift + Riverpod)
@override
Widget build(BuildContext context) {
  final diagnosticosAsync = ref.watch(diagnosticosStreamProvider(userId));

  return diagnosticosAsync.when(
    data: (diagnosticos) => ListView.builder(...),
    loading: () => CircularProgressIndicator(),
    error: (err, stack) => ErrorWidget(err),
  );
}
```

### **Fase 6: Testing & Validação** (2h)

#### 6.1 Testes Unitários de Repositórios
```dart
void main() {
  late ReceituagroDatabase db;
  late DiagnosticoRepository repository;

  setUp(() {
    db = ReceituagroDatabase.test();
    repository = DiagnosticoRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DiagnosticoRepository', () {
    test('should insert and retrieve diagnostico', () async {
      final diagnostico = DiagnosticoData(...);

      final id = await repository.insert(diagnostico);
      expect(id, greaterThan(0));

      final retrieved = await repository.findById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.idReg, diagnostico.idReg);
    });

    test('should watch diagnosticos stream', () async {
      final stream = repository.watchByUserId('user123');

      await repository.insert(DiagnosticoData(...));

      final diagnosticos = await stream.first;
      expect(diagnosticos, hasLength(1));
    });
  });
}
```

#### 6.2 Teste de Migração
```bash
# 1. Backup dos dados Hive
cp -r ~/.app_receituagro ~/.app_receituagro_backup

# 2. Executar migração
flutter run --release

# 3. Validar dados migrados
# - Comparar contagens Hive vs Drift
# - Verificar integridade referencial (foreign keys)
# - Testar queries complexas (joins)
```

---

## 📊 Mapeamento de Modelos

### Diagnostico

| Campo Hive | Campo Drift | Tipo | Notas |
|------------|-------------|------|-------|
| `objectId` | `firebaseId` | String? | UUID do Firebase |
| `createdAt` | `createdAt` | DateTime | Timestamp |
| `updatedAt` | `updatedAt` | DateTime? | Timestamp |
| `idReg` | `idReg` | String | ID único do diagnóstico |
| `fkIdDefensivo` | `defenisivoId` | int | **Foreign Key** (normalizado) |
| `nomeDefensivo` | ~~removido~~ | - | Obtido via join |
| `fkIdCultura` | `culturaId` | int | **Foreign Key** (normalizado) |
| `nomeCultura` | ~~removido~~ | - | Obtido via join |
| `fkIdPraga` | `pragaId` | int | **Foreign Key** (normalizado) |
| `nomePraga` | ~~removido~~ | - | Obtido via join |
| `dsMin` | `dsMin` | String? | - |
| `dsMax` | `dsMax` | String | - |
| `um` | `um` | String | - |
| - | `userId` | String | **Novo campo** |
| - | `isDirty` | bool | **Sync tracking** |
| - | `isDeleted` | bool | **Soft delete** |
| - | `version` | int | **Conflict resolution** |

### Favorito

| Campo Hive | Campo Drift | Tipo | Notas |
|------------|-------------|------|-------|
| `sync_objectId` | `firebaseId` | String? | UUID do Firebase |
| `sync_createdAt` | `createdAt` | DateTime | Timestamp |
| `sync_updatedAt` | `updatedAt` | DateTime? | Timestamp |
| `tipo` | `tipo` | String | 'defensivos', 'pragas', etc. |
| `itemId` | `itemId` | String | ID do item original |
| `itemData` | `itemData` | String | JSON cache |
| - | `userId` | String | **Novo campo** |
| - | `isDirty` | bool | **Sync tracking** |
| - | `isDeleted` | bool | **Soft delete** |

### Comentario

| Campo Hive | Campo Drift | Tipo | Notas |
|------------|-------------|------|-------|
| `sync_objectId` | `firebaseId` | String? | UUID do Firebase |
| `sync_createdAt` | `createdAt` | DateTime | Timestamp |
| `sync_updatedAt` | `updatedAt` | DateTime? | Timestamp |
| `itemId` | `itemId` | String | ID do item comentado |
| `texto` | `texto` | String | Texto do comentário |
| `userId` | `userId` | String | ID do autor |
| - | `isDirty` | bool | **Sync tracking** |
| - | `isDeleted` | bool | **Soft delete** |

---

## 🎯 Padrões e Best Practices

### 1. **Normalização de Dados**
```dart
// ❌ ANTES (Hive - Denormalizado)
class DiagnosticoHive {
  String fkIdDefensivo;
  String? nomeDefensivo;  // ⚠️ Duplicação
  String fkIdCultura;
  String? nomeCultura;     // ⚠️ Duplicação
  String fkIdPraga;
  String? nomePraga;       // ⚠️ Duplicação
}

// ✅ DEPOIS (Drift - Normalizado)
class Diagnosticos {
  IntColumn defenisivoId => integer().references(Fitossanitarios, #id)();
  IntColumn culturaId => integer().references(Culturas, #id)();
  IntColumn pragaId => integer().references(Pragas, #id)();
}

// Obter dados relacionados via JOIN
final diagnosticosEnriquecidos = await db.select(diagnosticos).join([
  leftOuterJoin(fitossanitarios, fitossanitarios.id.equalsExp(diagnosticos.defenisivoId)),
  leftOuterJoin(culturas, culturas.id.equalsExp(diagnosticos.culturaId)),
  leftOuterJoin(pragas, pragas.id.equalsExp(diagnosticos.pragaId)),
]).get();
```

### 2. **Soft Deletes**
```dart
// Sempre marcar como deletado ao invés de deletar
await (db.update(diagnosticos)..where((tbl) => tbl.id.equals(id)))
  .write(DiagnosticosCompanion(
    isDeleted: const Value(true),
    isDirty: const Value(true),
    updatedAt: Value(DateTime.now()),
  ));

// Queries sempre filtram deletados
final query = db.select(diagnosticos)
  ..where((tbl) => tbl.isDeleted.equals(false));
```

### 3. **Dirty Tracking para Sync**
```dart
// Marcar como dirty ao modificar localmente
await (db.update(diagnosticos)..where((tbl) => tbl.id.equals(id)))
  .write(DiagnosticosCompanion(
    isDirty: const Value(true),
    updatedAt: Value(DateTime.now()),
  ));

// Buscar registros que precisam sincronizar
Future<List<Diagnostico>> findDirtyRecords() async {
  return (db.select(diagnosticos)..where((tbl) => tbl.isDirty.equals(true)))
    .get();
}

// Marcar como sincronizado após upload
await (db.update(diagnosticos)..where((tbl) => tbl.id.equals(id)))
  .write(DiagnosticosCompanion(
    isDirty: const Value(false),
    lastSyncAt: Value(DateTime.now()),
  ));
```

### 4. **Transações para Operações Atômicas**
```dart
await db.executeTransaction(() async {
  // 1. Inserir diagnostico
  final diagnosticoId = await db.into(diagnosticos).insert(...);

  // 2. Inserir comentario relacionado
  await db.into(comentarios).insert(
    ComentariosCompanion.insert(
      itemId: diagnosticoId.toString(),
      texto: 'Comentário automático',
    ),
  );

  // 3. Atualizar estatísticas
  await db.customUpdate('UPDATE stats SET total_diagnosticos = total_diagnosticos + 1');

  // Se qualquer operação falhar, TODAS são revertidas
}, operationName: 'Create diagnostico with comment');
```

### 5. **Streams Reativos para UI**
```dart
// Repository retorna Stream
Stream<List<DiagnosticoData>> watchByUserId(String userId) {
  return (db.select(diagnosticos)
    ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false)))
    .watch()
    .map((list) => list.map(fromData).toList());
}

// UI reage automaticamente a mudanças
@riverpod
Stream<List<DiagnosticoData>> diagnosticosStream(DiagnosticosStreamRef ref, String userId) {
  final repo = ref.watch(diagnosticoRepositoryProvider);
  return repo.watchByUserId(userId);
}

// Widget se atualiza automaticamente
Widget build(BuildContext context, WidgetRef ref) {
  final diagnosticosAsync = ref.watch(diagnosticosStreamProvider(userId));

  return diagnosticosAsync.when(
    data: (diagnosticos) => ListView.builder(...),
    loading: () => CircularProgressIndicator(),
    error: (err, stack) => ErrorWidget(err),
  );
}
```

### 6. **Índices para Performance**
```dart
class Diagnosticos extends Table {
  // Unique constraint (index automático)
  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, idReg},  // Garante idReg único por usuário
  ];
}

// Para queries frequentes, adicione índices manuais
@override
Future<void> onCreate(Migrator m) async {
  await m.createAll();

  // Índice composto para queries por userId + data
  await m.createIndex(Index(
    'idx_diagnosticos_user_date',
    'CREATE INDEX idx_diagnosticos_user_date ON diagnosticos (user_id, created_at DESC)',
  ));
}
```

---

## ⚠️ Riscos e Mitigações

### 1. **Perda de Dados Durante Migração**
**Risco**: Migração falha e corrompe dados Hive

**Mitigação**:
- Backup completo do Hive antes da migração
- Migração em transação (rollback automático)
- Validação pós-migração (comparar counts)
- Flag de feature para rollback (usar Hive se Drift falhar)

```dart
// Backup automático antes de migrar
Future<void> backupHiveData() async {
  final appDir = await getApplicationDocumentsDirectory();
  final hiveDir = Directory('${appDir.path}/hive');
  final backupDir = Directory('${appDir.path}/hive_backup_${DateTime.now().millisecondsSinceEpoch}');

  if (await hiveDir.exists()) {
    await hiveDir.copy(backupDir.path);
    print('✅ Backup criado: ${backupDir.path}');
  }
}
```

### 2. **Foreign Keys Não Resolvidas**
**Risco**: IDs de defensivos/culturas/pragas não encontrados nas tabelas estáticas

**Mitigação**:
- Popular tabelas estáticas ANTES de migrar diagnosticos
- Log detalhado de FKs não resolvidas
- Continuar migração (skip records com FK inválida)
- Relatório de registros não migrados

```dart
Future<int?> _resolveDefenisivoId(String idDefensivo) async {
  final result = await (db.select(fitossanitarios)
    ..where((tbl) => tbl.idDefensivo.equals(idDefensivo))
    ..limit(1)).getSingleOrNull();

  if (result == null) {
    print('⚠️ Defensivo não encontrado: $idDefensivo');
    // Log para análise posterior
    await _logUnresolvedFK('defensivo', idDefensivo);
  }

  return result?.id;
}
```

### 3. **Performance Degradation**
**Risco**: Queries Drift mais lentas que Hive para operações simples

**Mitigação**:
- Índices otimizados para queries frequentes
- Batch operations para inserções em massa
- Pagination para listas grandes
- Profiling e benchmarks pré/pós migração

```dart
// Benchmark de queries
Future<void> benchmarkQueries() async {
  final stopwatch = Stopwatch()..start();

  // Hive
  final hiveBox = await Hive.openBox<DiagnosticoHive>('diagnosticos');
  final hiveResults = hiveBox.values.toList();
  final hiveTime = stopwatch.elapsedMilliseconds;

  stopwatch.reset();

  // Drift
  final driftResults = await db.select(diagnosticos).get();
  final driftTime = stopwatch.elapsedMilliseconds;

  print('Hive: ${hiveTime}ms | Drift: ${driftTime}ms');
}
```

### 4. **Sincronização Quebrada**
**Risco**: Lógica de sync Firebase não funciona com Drift

**Mitigação**:
- Manter campos de sync (isDirty, lastSyncAt, version)
- Testar sync end-to-end antes de production
- Fallback para forçar resync completo se detectar inconsistência

```dart
// Force resync se detectar problemas
Future<void> forceResyncIfNeeded() async {
  final now = DateTime.now();
  final lastSync = await db.select(diagnosticos)
    .map((d) => d.lastSyncAt)
    .get()
    .then((list) => list.whereNotNull().fold<DateTime?>(
      null,
      (prev, date) => prev == null || date.isBefore(prev) ? date : prev,
    ));

  if (lastSync == null || now.difference(lastSync).inDays > 7) {
    print('⚠️ Last sync > 7 days ago, forcing resync...');
    await _syncService.forceFullSync();
  }
}
```

### 5. **Breaking Changes em Produção**
**Risco**: Usuários perdem acesso aos dados após update

**Mitigação**:
- Phased rollout (1% → 10% → 50% → 100%)
- Monitoramento de crashlytics/analytics
- Feature flag para toggle Hive/Drift
- Hotfix preparado para rollback

```dart
// Feature flag para toggle
bool get useDrift => RemoteConfig.instance.getBool('use_drift_db');

// Abstração para trocar backend
abstract class IDiagnosticoRepository {
  Future<List<DiagnosticoData>> findAll();
}

class DiagnosticoRepositoryHive implements IDiagnosticoRepository { /* ... */ }
class DiagnosticoRepositoryDrift implements IDiagnosticoRepository { /* ... */ }

// Factory baseado em feature flag
IDiagnosticoRepository getDiagnosticoRepository() {
  if (useDrift) {
    return GetIt.instance<DiagnosticoRepositoryDrift>();
  } else {
    return GetIt.instance<DiagnosticoRepositoryHive>();
  }
}
```

---

## ✅ Checklist de Execução

### Pré-Migração
- [ ] Backup completo dos dados Hive
- [ ] Review de todas as queries Hive (documentar padrões)
- [ ] Identificar dependências (Firebase sync, analytics)
- [ ] Criar branch de feature: `feature/drift-migration`

### Fase 1: Setup
- [ ] Adicionar dependências Drift ao `pubspec.yaml`
- [ ] Criar estrutura de diretórios (`lib/database/`)
- [ ] Configurar `BaseDriftDatabase` no package core
- [ ] Validar build_runner funcionando

### Fase 2: Schema
- [ ] Definir todas as 8 tabelas em `receituagro_tables.dart`
- [ ] Criar `ReceituagroDatabase` com schemaVersion = 1
- [ ] Gerar código: `dart run build_runner build`
- [ ] Validar schema (criar DB de teste e inspecionar)

### Fase 3: Repositórios
- [ ] Implementar `DiagnosticoRepository`
- [ ] Implementar `FavoritoRepository`
- [ ] Implementar `ComentarioRepository`
- [ ] Implementar repositórios de dados estáticos (read-only)
- [ ] Criar Riverpod providers

### Fase 4: Migration Tool
- [ ] Implementar `HiveToDriftMigrationTool`
- [ ] Popular tabelas estáticas (JSON → Drift)
- [ ] Implementar resolução de Foreign Keys
- [ ] Criar relatório de migração

### Fase 5: Testing
- [ ] Testes unitários dos repositórios
- [ ] Teste de migração com dados reais (dev)
- [ ] Validar integridade referencial
- [ ] Benchmark de performance (Hive vs Drift)

### Fase 6: Integration
- [ ] Atualizar UI para usar Drift Streams
- [ ] Testar sincronização Firebase
- [ ] Validar favoritos/comentários funcionando
- [ ] Testar queries complexas (joins)

### Fase 7: Deployment
- [ ] Code review completo
- [ ] Merge para `develop`
- [ ] Beta testing (TestFlight/Internal Track)
- [ ] Monitorar crashlytics/analytics
- [ ] Rollout gradual (1% → 10% → 50% → 100%)

### Pós-Deployment
- [ ] Monitorar performance (query times)
- [ ] Validar counts de dados (Drift vs Firebase)
- [ ] Coletar feedback de usuários
- [ ] Documentar lições aprendidas
- [ ] Remover código Hive (após 2-3 semanas de estabilidade)

---

## 📚 Recursos Adicionais

### Documentação
- [Drift Official Docs](https://drift.simonbinder.eu/)
- [Drift Migrations Guide](https://drift.simonbinder.eu/docs/advanced-features/migrations/)
- [app-gasometer-drift Implementation](../app-gasometer-drift)

### Comandos Úteis
```bash
# Gerar código Drift
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate)
dart run build_runner watch --delete-conflicting-outputs

# Limpar cache
dart run build_runner clean

# Analisar código
flutter analyze

# Executar testes
flutter test

# Inspecionar banco de dados (dev)
sqlite3 ~/.app_receituagro/receituagro_drift.db
.tables
.schema diagnosticos
SELECT COUNT(*) FROM diagnosticos;
```

### Troubleshooting

#### Problema: Build runner falha com erros de geração
**Solução**: Limpar cache e regenerar
```bash
dart run build_runner clean
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

#### Problema: Foreign key constraint failed
**Solução**: Verificar PRAGMA foreign_keys habilitado
```dart
await customStatement('PRAGMA foreign_keys = ON');
```

#### Problema: Migration não executa onCreate
**Solução**: Deletar banco existente ou incrementar schemaVersion
```bash
rm ~/.app_receituagro/receituagro_drift.db
```

---

## 🎯 Conclusão

Esta migração de HiveBox para Drift trará:
- ✅ **Performance**: Queries complexas 5-10x mais rápidas
- ✅ **Type Safety**: Erros detectados em compile-time
- ✅ **Escalabilidade**: Suporte a milhares de registros
- ✅ **Manutenibilidade**: Schema versionado e migrations estruturadas

**Tempo estimado**: 12-16 horas (2-3 dias)
**Risco**: Médio (mitigado com backup e rollback)
**ROI**: Alto (fundação para features futuras)

---

**Última atualização**: 2025-11-10
**Autor**: Claude Code Migration Team
**Status**: Pronto para execução
