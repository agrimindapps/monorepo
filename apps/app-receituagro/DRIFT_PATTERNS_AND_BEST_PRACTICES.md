# Drift Patterns & Best Practices

## 📋 Guia de Referência Rápida

Documento complementar ao `MIGRATION_HIVE_TO_DRIFT.md` com padrões, antipadrões e exemplos práticos do Drift baseados na implementação do **app-gasometer-drift**.

---

## 🎯 Princípios Fundamentais

### 1. **Single Source of Truth**
O banco de dados Drift é a ÚNICA fonte de verdade para dados locais. UI reage a streams do DB.

```dart
// ✅ CORRETO: UI observa stream do DB
@override
Widget build(BuildContext context, WidgetRef ref) {
  final diagnosticosAsync = ref.watch(diagnosticosStreamProvider(userId));

  return diagnosticosAsync.when(
    data: (diagnosticos) => ListView(...),
    loading: () => CircularProgressIndicator(),
    error: (err, _) => ErrorWidget(err),
  );
}

// ❌ ERRADO: Cache em memória desacoplado do DB
List<Diagnostico> _cachedDiagnosticos = [];

Future<void> loadDiagnosticos() async {
  _cachedDiagnosticos = await db.select(diagnosticos).get();
  setState(() {});  // Cache pode ficar desatualizado
}
```

### 2. **Type Safety First**
Use o type system do Dart ao máximo. Drift gera código tipado - aproveite!

```dart
// ✅ CORRETO: Tipos explícitos
Future<List<Diagnostico>> findActiveByUser(String userId) async {
  return (select(diagnosticos)
    ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false)))
    .get();
}

// ❌ ERRADO: dynamic sem necessidade
Future<dynamic> findData(String id) async {
  return await (select(diagnosticos)..where((tbl) => tbl.id.equals(id))).getSingle();
}
```

### 3. **Fail Fast, Fail Loud**
Erros de schema devem quebrar em compile-time, não em runtime.

```dart
// ✅ CORRETO: Companion types garantem todos os campos obrigatórios
await into(diagnosticos).insert(
  DiagnosticosCompanion.insert(
    userId: 'user123',
    idReg: 'diag001',
    defenisivoId: 42,      // Required - compile error se faltar
    culturaId: 10,
    pragaId: 5,
    dsMax: 'Sintomas',
    um: 'L/ha',
  ),
);

// ❌ ERRADO: Map sem type checking
await into(diagnosticos).insert({
  'user_id': 'user123',
  'id_reg': 'diag001',
  // Faltou defenisivoId - só quebra em runtime!
});
```

---

## 🏗️ Arquitetura e Estrutura

### Database Class Pattern

```dart
@DriftDatabase(tables: [Diagnosticos, Favoritos, Comentarios])
@lazySingleton
class ReceituagroDatabase extends _$ReceituagroDatabase with BaseDriftDatabase {
  ReceituagroDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  // ✅ Factory pattern para diferentes ambientes
  @factoryMethod
  factory ReceituagroDatabase.injectable() => ReceituagroDatabase.production();

  factory ReceituagroDatabase.production() {
    return ReceituagroDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'receituagro.db',
        logStatements: false,  // Prod: logging off
      ),
    );
  }

  factory ReceituagroDatabase.development() {
    return ReceituagroDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'receituagro_dev.db',
        logStatements: true,  // Dev: logging on
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
      await _seedStaticData();  // Popular dados iniciais
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(diagnosticos, diagnosticos.newField);
      }
    },
    beforeOpen: (details) async {
      // ⚠️ CRÍTICO: Habilitar foreign keys
      await customStatement('PRAGMA foreign_keys = ON');

      if (details.wasCreated) {
        print('✅ Database created v${details.versionNow}');
      } else if (details.hadUpgrade) {
        print('⬆️ Database upgraded v${details.versionBefore} → v${details.versionNow}');
      }
    },
  );

  Future<void> _seedStaticData() async {
    // Carregar dados estáticos do JSON/assets
  }
}
```

### Repository Pattern (BaseDriftRepositoryImpl)

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
  Expression<int> idColumn(Diagnosticos tbl) => tbl.id;

  // ✅ Mappers bem definidos
  @override
  DiagnosticoData fromData(Diagnostico data) {
    return DiagnosticoData(
      id: data.id,
      userId: data.userId,
      idReg: data.idReg,
      defenisivoId: data.defenisivoId,
      culturaId: data.culturaId,
      pragaId: data.pragaId,
      dsMax: data.dsMax,
      um: data.um,
      // ... outros campos
    );
  }

  @override
  Insertable<Diagnostico> toCompanion(DiagnosticoData entity) {
    return DiagnosticosCompanion(
      id: entity.id > 0 ? Value(entity.id) : Value.absent(),
      userId: Value(entity.userId),
      idReg: Value(entity.idReg),
      defenisivoId: Value(entity.defenisivoId),
      culturaId: Value(entity.culturaId),
      pragaId: Value(entity.pragaId),
      dsMax: Value(entity.dsMax),
      um: Value(entity.um),
      // ... outros campos
    );
  }

  // ✅ Queries customizadas tipadas
  Future<List<DiagnosticoEnriched>> findAllWithRelations(String userId) async {
    final query = _db.select(_db.diagnosticos).join([
      leftOuterJoin(_db.fitossanitarios, _db.fitossanitarios.id.equalsExp(_db.diagnosticos.defenisivoId)),
      leftOuterJoin(_db.culturas, _db.culturas.id.equalsExp(_db.diagnosticos.culturaId)),
      leftOuterJoin(_db.pragas, _db.pragas.id.equalsExp(_db.diagnosticos.pragaId)),
    ])
      ..where(_db.diagnosticos.userId.equals(userId) & _db.diagnosticos.isDeleted.equals(false))
      ..orderBy([OrderingTerm.desc(_db.diagnosticos.createdAt)]);

    final results = await query.get();
    return results.map(_mapJoinedRow).toList();
  }

  DiagnosticoEnriched _mapJoinedRow(TypedResult row) {
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
  }

  // ✅ Streams reativos
  Stream<List<DiagnosticoData>> watchByUserId(String userId) {
    return (_db.select(_db.diagnosticos)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
      .watch()
      .map((list) => list.map(fromData).toList());
  }
}
```

---

## 📊 Table Design Patterns

### 1. **Base Fields Pattern** (Sync-ready)

Todos os modelos de usuário devem ter campos base para sincronização:

```dart
class Diagnosticos extends Table {
  // ========== PRIMARY KEY ==========
  IntColumn get id => integer().autoIncrement()();

  // ========== FIREBASE SYNC ==========
  TextColumn get firebaseId => text().nullable()();  // UUID do Firebase
  TextColumn get userId => text()();                 // Owner
  TextColumn get moduleName => text().withDefault(const Constant('receituagro'))();

  // ========== TIMESTAMPS ==========
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== SYNC CONTROL ==========
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== BUSINESS FIELDS ==========
  TextColumn get idReg => text()();
  // ... outros campos específicos do modelo
}
```

### 2. **Foreign Keys Pattern**

```dart
class Diagnosticos extends Table {
  // ✅ CORRETO: Foreign key com cascade behavior
  IntColumn get defenisivoId => integer()
    .references(Fitossanitarios, #id, onDelete: KeyAction.restrict)();

  IntColumn get culturaId => integer()
    .references(Culturas, #id, onDelete: KeyAction.restrict)();

  IntColumn get pragaId => integer()
    .references(Pragas, #id, onDelete: KeyAction.restrict)();

  // ❌ ERRADO: String FK (não valida integridade)
  TextColumn get fkDefensivo => text()();
}
```

**Cascade Options**:
- `KeyAction.cascade` - Deletar pai deleta filhos (use para 1:N forte)
- `KeyAction.restrict` - Previne deletar pai se houver filhos (use para referências)
- `KeyAction.setNull` - Seta FK como null ao deletar pai
- `KeyAction.setDefault` - Seta FK como default ao deletar pai

### 3. **Unique Keys Pattern**

```dart
class Diagnosticos extends Table {
  TextColumn get userId => text()();
  TextColumn get idReg => text()();

  // ✅ Unique constraint composto (userId + idReg)
  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, idReg},  // idReg único por usuário
  ];
}

class Favoritos extends Table {
  TextColumn get userId => text()();
  TextColumn get tipo => text()();
  TextColumn get itemId => text()();

  // ✅ Previne favoritar o mesmo item duas vezes
  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, tipo, itemId},
  ];
}
```

### 4. **Indexes Pattern**

```dart
@override
Future<void> onCreate(Migrator m) async {
  await m.createAll();

  // ✅ Índice composto para query frequente (userId + createdAt)
  await m.createIndex(Index(
    'idx_diagnosticos_user_date',
    'CREATE INDEX idx_diagnosticos_user_date ON diagnosticos (user_id, created_at DESC)',
  ));

  // ✅ Índice para busca por texto (full-text search)
  await m.createIndex(Index(
    'idx_diagnosticos_search',
    'CREATE INDEX idx_diagnosticos_search ON diagnosticos (ds_max)',
  ));
}
```

**Quando criar índices**:
- ✅ Colunas usadas em WHERE frequentemente (ex: userId)
- ✅ Colunas usadas em ORDER BY (ex: createdAt)
- ✅ Colunas de foreign keys (SQLite NÃO cria automaticamente)
- ❌ Colunas raramente consultadas
- ❌ Tabelas pequenas (<1000 rows)

---

## 🔍 Query Patterns

### 1. **Simple Select**

```dart
// Buscar todos os diagnósticos ativos de um usuário
Future<List<Diagnostico>> findByUserId(String userId) async {
  return (select(diagnosticos)
    ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
    ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
    .get();
}

// Buscar por ID (single)
Future<Diagnostico?> findById(int id) async {
  return (select(diagnosticos)..where((tbl) => tbl.id.equals(id)))
    .getSingleOrNull();
}

// Buscar com limite
Future<List<Diagnostico>> findRecent(String userId, {int limit = 10}) async {
  return (select(diagnosticos)
    ..where((tbl) => tbl.userId.equals(userId))
    ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
    ..limit(limit))
    .get();
}
```

### 2. **Joins (Relacionamentos)**

```dart
// LEFT OUTER JOIN (retorna diagnostico mesmo sem defensivo)
Future<List<TypedResult>> findDiagnosticosWithDefensivo(String userId) async {
  final query = select(diagnosticos).join([
    leftOuterJoin(fitossanitarios, fitossanitarios.id.equalsExp(diagnosticos.defenisivoId)),
  ])
    ..where(diagnosticos.userId.equals(userId))
    ..orderBy([OrderingTerm.desc(diagnosticos.createdAt)]);

  return query.get();
}

// INNER JOIN (retorna apenas diagnosticos com defensivo)
Future<List<TypedResult>> findDiagnosticosWithDefensivoRequired(String userId) async {
  final query = select(diagnosticos).join([
    innerJoin(fitossanitarios, fitossanitarios.id.equalsExp(diagnosticos.defenisivoId)),
  ])
    ..where(diagnosticos.userId.equals(userId));

  return query.get();
}

// JOIN múltiplas tabelas
Future<List<TypedResult>> findFullDiagnosticos(String userId) async {
  final query = select(diagnosticos).join([
    leftOuterJoin(fitossanitarios, fitossanitarios.id.equalsExp(diagnosticos.defenisivoId)),
    leftOuterJoin(culturas, culturas.id.equalsExp(diagnosticos.culturaId)),
    leftOuterJoin(pragas, pragas.id.equalsExp(diagnosticos.pragaId)),
  ])
    ..where(diagnosticos.userId.equals(userId) & diagnosticos.isDeleted.equals(false))
    ..orderBy([OrderingTerm.desc(diagnosticos.createdAt)]);

  return query.get();
}

// ✅ Mapear resultado do join
DiagnosticoEnriched mapJoinedRow(TypedResult row) {
  final diagnostico = row.readTable(diagnosticos);
  final defensivo = row.readTableOrNull(fitossanitarios);  // Null-safe
  final cultura = row.readTableOrNull(culturas);
  final praga = row.readTableOrNull(pragas);

  return DiagnosticoEnriched(
    diagnostico: diagnostico,
    defensivo: defensivo,
    cultura: cultura,
    praga: praga,
  );
}
```

### 3. **Aggregations (COUNT, SUM, AVG)**

```dart
// Contar registros
Future<int> countDiagnosticos(String userId) async {
  final query = selectOnly(diagnosticos)
    ..addColumns([diagnosticos.id.count()])
    ..where(diagnosticos.userId.equals(userId) & diagnosticos.isDeleted.equals(false));

  final result = await query.getSingle();
  return result.read(diagnosticos.id.count()) ?? 0;
}

// Soma (ex: total de despesas)
Future<double> getTotalDespesas(String userId) async {
  final query = selectOnly(maintenances)
    ..addColumns([maintenances.valor.sum()])
    ..where(maintenances.userId.equals(userId) & maintenances.isDeleted.equals(false));

  final result = await query.getSingle();
  return result.read(maintenances.valor.sum()) ?? 0.0;
}

// Média
Future<double?> getMediaConsumo(int vehicleId) async {
  final query = selectOnly(fuelSupplies)
    ..addColumns([fuelSupplies.liters.avg()])
    ..where(fuelSupplies.vehicleId.equals(vehicleId));

  final result = await query.getSingle();
  return result.read(fuelSupplies.liters.avg());
}

// Group By
Future<Map<String, int>> countByTipo() async {
  final query = selectOnly(favoritos, distinct: true)
    ..addColumns([favoritos.tipo, favoritos.id.count()])
    ..groupBy([favoritos.tipo]);

  final results = await query.get();
  return Map.fromEntries(
    results.map((row) => MapEntry(
      row.read(favoritos.tipo)!,
      row.read(favoritos.id.count()) ?? 0,
    )),
  );
}
```

### 4. **Custom SQL**

```dart
// SQL customizado quando query builder não é suficiente
Future<List<Map<String, Object?>>> customQuery() async {
  return customSelect(
    '''
    SELECT d.*, f.nome AS defensivo_nome, c.nome AS cultura_nome
    FROM diagnosticos d
    LEFT JOIN fitossanitarios f ON d.defensivo_id = f.id
    LEFT JOIN culturas c ON d.cultura_id = c.id
    WHERE d.user_id = ? AND d.is_deleted = 0
    ORDER BY d.created_at DESC
    ''',
    variables: [Variable.withString('user123')],
  ).get();
}

// Custom statement (INSERT/UPDATE/DELETE)
Future<void> customUpdate(String userId) async {
  await customStatement(
    'UPDATE diagnosticos SET is_dirty = 1 WHERE user_id = ?',
    [userId],
  );
}
```

### 5. **Streams Reativos**

```dart
// Stream simples
Stream<List<Diagnostico>> watchByUserId(String userId) {
  return (select(diagnosticos)
    ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false)))
    .watch();
}

// Stream com transformação
Stream<int> watchCountByUserId(String userId) {
  return (select(diagnosticos)
    ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false)))
    .watch()
    .map((list) => list.length);
}

// Stream com join
Stream<List<DiagnosticoEnriched>> watchEnrichedByUserId(String userId) {
  final query = select(diagnosticos).join([
    leftOuterJoin(fitossanitarios, fitossanitarios.id.equalsExp(diagnosticos.defenisivoId)),
    leftOuterJoin(culturas, culturas.id.equalsExp(diagnosticos.culturaId)),
  ])
    ..where(diagnosticos.userId.equals(userId));

  return query.watch().map((rows) => rows.map(mapJoinedRow).toList());
}

// ✅ UI reage automaticamente a mudanças
@riverpod
Stream<List<Diagnostico>> diagnosticosStream(DiagnosticosStreamRef ref, String userId) {
  final db = ref.watch(databaseProvider);
  return db.watchDiagnosticos(userId);
}

Widget build(BuildContext context, WidgetRef ref) {
  final diagnosticosAsync = ref.watch(diagnosticosStreamProvider(userId));

  return diagnosticosAsync.when(
    data: (diagnosticos) => ListView.builder(...),
    loading: () => CircularProgressIndicator(),
    error: (err, _) => Text('Erro: $err'),
  );
}
```

---

## 💾 CRUD Operations

### 1. **INSERT**

```dart
// Insert único
Future<int> insertDiagnostico(DiagnosticoData data) async {
  return into(diagnosticos).insert(
    DiagnosticosCompanion.insert(
      userId: data.userId,
      idReg: data.idReg,
      defenisivoId: data.defenisivoId,
      culturaId: data.culturaId,
      pragaId: data.pragaId,
      dsMax: data.dsMax,
      um: data.um,
      isDirty: const Value(true),  // Marca para sync
    ),
  );
}

// Insert ou ignore (skip duplicados)
Future<int> insertOrIgnore(DiagnosticoData data) async {
  return into(diagnosticos).insert(
    toCompanion(data),
    mode: InsertMode.insertOrIgnore,
  );
}

// Insert ou replace (update se existir)
Future<int> insertOrReplace(DiagnosticoData data) async {
  return into(diagnosticos).insert(
    toCompanion(data),
    mode: InsertMode.insertOrReplace,
  );
}

// Batch insert (performático)
Future<void> insertMany(List<DiagnosticoData> diagnosticos) async {
  await batch((batch) {
    batch.insertAll(
      this.diagnosticos,
      diagnosticos.map(toCompanion).toList(),
      mode: InsertMode.insertOrIgnore,
    );
  });
}
```

### 2. **UPDATE**

```dart
// Update único
Future<bool> updateDiagnostico(int id, DiagnosticoData data) async {
  final rowsAffected = await (update(diagnosticos)..where((tbl) => tbl.id.equals(id)))
    .write(DiagnosticosCompanion(
      dsMax: Value(data.dsMax),
      um: Value(data.um),
      updatedAt: Value(DateTime.now()),
      isDirty: const Value(true),
    ));

  return rowsAffected > 0;
}

// Update múltiplos
Future<int> markAllAsDirty(String userId) async {
  return (update(diagnosticos)..where((tbl) => tbl.userId.equals(userId)))
    .write(DiagnosticosCompanion(
      isDirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
}

// Replace (update completo)
Future<void> replaceDiagnostico(DiagnosticoData data) async {
  await update(diagnosticos).replace(toCompanion(data));
}
```

### 3. **DELETE**

```dart
// Soft delete (recomendado)
Future<bool> softDeleteDiagnostico(int id) async {
  final rowsAffected = await (update(diagnosticos)..where((tbl) => tbl.id.equals(id)))
    .write(DiagnosticosCompanion(
      isDeleted: const Value(true),
      isDirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));

  return rowsAffected > 0;
}

// Hard delete (permanente - use com cuidado!)
Future<int> hardDeleteDiagnostico(int id) async {
  return (delete(diagnosticos)..where((tbl) => tbl.id.equals(id))).go();
}

// Delete múltiplos
Future<int> deleteByUserId(String userId) async {
  return (delete(diagnosticos)..where((tbl) => tbl.userId.equals(userId))).go();
}

// Delete all (limpar tabela)
Future<int> deleteAll() async {
  return delete(diagnosticos).go();
}
```

---

## 🔄 Transactions

### 1. **Transaction Básica**

```dart
Future<void> createDiagnosticoWithComentario(
  DiagnosticoData diagnostico,
  ComentarioData comentario,
) async {
  await executeTransaction(() async {
    // 1. Inserir diagnostico
    final diagnosticoId = await into(diagnosticos).insert(toCompanion(diagnostico));

    // 2. Inserir comentario relacionado
    await into(comentarios).insert(
      ComentariosCompanion.insert(
        userId: diagnostico.userId,
        itemId: diagnosticoId.toString(),
        texto: comentario.texto,
      ),
    );

    // Se qualquer operação falhar, ambas são revertidas (rollback)
  }, operationName: 'Create diagnostico with comentario');
}
```

### 2. **Batch Operations**

```dart
// Batch insert (mais rápido que loop)
Future<void> insertManyDiagnosticos(List<DiagnosticoData> items) async {
  await batch((batch) {
    batch.insertAll(
      diagnosticos,
      items.map(toCompanion).toList(),
      mode: InsertMode.insertOrIgnore,
    );
  });
}

// Batch update
Future<void> markManyAsSynced(List<int> ids) async {
  await batch((batch) {
    for (final id in ids) {
      batch.update(
        diagnosticos,
        DiagnosticosCompanion(
          isDirty: const Value(false),
          lastSyncAt: Value(DateTime.now()),
        ),
        where: (tbl) => tbl.id.equals(id),
      );
    }
  });
}

// Batch mixed operations
Future<void> syncBatch(List<DiagnosticoData> toInsert, List<int> toDelete) async {
  await batch((batch) {
    // Inserts
    batch.insertAll(diagnosticos, toInsert.map(toCompanion).toList());

    // Deletes
    for (final id in toDelete) {
      batch.delete(diagnosticos, (tbl) => tbl.id.equals(id));
    }
  });
}
```

---

## 🔄 Sync Patterns

### 1. **Dirty Tracking**

```dart
// Marcar como dirty ao modificar localmente
Future<void> updateLocal(int id, DiagnosticoData data) async {
  await (update(diagnosticos)..where((tbl) => tbl.id.equals(id)))
    .write(DiagnosticosCompanion(
      dsMax: Value(data.dsMax),
      isDirty: const Value(true),      // Precisa sincronizar
      updatedAt: Value(DateTime.now()),
    ));
}

// Buscar registros que precisam sincronizar
Future<List<Diagnostico>> findDirtyRecords() async {
  return (select(diagnosticos)..where((tbl) => tbl.isDirty.equals(true))).get();
}

// Marcar como sincronizado após upload
Future<void> markAsSynced(int id, String firebaseId) async {
  await (update(diagnosticos)..where((tbl) => tbl.id.equals(id)))
    .write(DiagnosticosCompanion(
      isDirty: const Value(false),
      firebaseId: Value(firebaseId),
      lastSyncAt: Value(DateTime.now()),
    ));
}
```

### 2. **Conflict Resolution (Last-Write-Wins)**

```dart
Future<void> syncFromFirebase(DiagnosticoFirebase remote) async {
  final local = await (select(diagnosticos)
    ..where((tbl) => tbl.firebaseId.equals(remote.id)))
    .getSingleOrNull();

  if (local == null) {
    // Novo registro do servidor
    await into(diagnosticos).insert(
      DiagnosticosCompanion.insert(
        firebaseId: Value(remote.id),
        userId: remote.userId,
        idReg: remote.idReg,
        // ... outros campos
        isDirty: const Value(false),
        lastSyncAt: Value(DateTime.now()),
      ),
    );
  } else {
    // Resolver conflito: last-write-wins
    final remoteUpdated = DateTime.fromMillisecondsSinceEpoch(remote.updatedAt);
    final localUpdated = local.updatedAt ?? local.createdAt;

    if (remoteUpdated.isAfter(localUpdated)) {
      // Servidor vence
      await (update(diagnosticos)..where((tbl) => tbl.id.equals(local.id)))
        .write(DiagnosticosCompanion(
          dsMax: Value(remote.dsMax),
          um: Value(remote.um),
          updatedAt: Value(remoteUpdated),
          isDirty: const Value(false),
          lastSyncAt: Value(DateTime.now()),
        ));
    } else {
      // Cliente vence - manter local e marcar como dirty para upload
      await (update(diagnosticos)..where((tbl) => tbl.id.equals(local.id)))
        .write(DiagnosticosCompanion(
          isDirty: const Value(true),
        ));
    }
  }
}
```

### 3. **Version-based Conflict Resolution**

```dart
Future<void> syncWithVersionControl(DiagnosticoFirebase remote) async {
  final local = await (select(diagnosticos)
    ..where((tbl) => tbl.firebaseId.equals(remote.id)))
    .getSingleOrNull();

  if (local == null) {
    // Novo registro
    await into(diagnosticos).insert(...);
  } else {
    if (remote.version > local.version) {
      // Servidor tem versão mais nova - aceitar
      await (update(diagnosticos)..where((tbl) => tbl.id.equals(local.id)))
        .write(DiagnosticosCompanion(
          // ... campos do remote
          version: Value(remote.version),
          isDirty: const Value(false),
        ));
    } else if (local.isDirty) {
      // Cliente modificou - marcar para upload com versão incrementada
      await (update(diagnosticos)..where((tbl) => tbl.id.equals(local.id)))
        .write(DiagnosticosCompanion(
          version: Value(local.version + 1),
          isDirty: const Value(true),
        ));
    }
  }
}
```

---

## 🧪 Testing Patterns

### 1. **Test Setup**

```dart
void main() {
  late ReceituagroDatabase db;
  late DiagnosticoRepository repository;

  setUp(() {
    // Criar DB em memória para cada teste
    db = ReceituagroDatabase.test();
    repository = DiagnosticoRepository(db);
  });

  tearDown(() async {
    // Fechar DB após cada teste
    await db.close();
  });

  group('DiagnosticoRepository', () {
    // Testes aqui
  });
}
```

### 2. **Test Helpers**

```dart
// Helper para criar dados de teste
DiagnosticoData createTestDiagnostico({
  String? userId,
  String? idReg,
  int? defenisivoId,
}) {
  return DiagnosticoData(
    id: 0,
    userId: userId ?? 'test_user',
    idReg: idReg ?? 'diag_${DateTime.now().millisecondsSinceEpoch}',
    defenisivoId: defenisivoId ?? 1,
    culturaId: 1,
    pragaId: 1,
    dsMax: 'Test symptoms',
    um: 'L/ha',
    createdAt: DateTime.now(),
    isDirty: false,
    isDeleted: false,
    version: 1,
  );
}

// Helper para popular banco com dados de teste
Future<void> seedDatabase(ReceituagroDatabase db) async {
  // Popular tabelas estáticas
  await db.into(db.culturas).insertAll([
    CulturasCompanion.insert(idCultura: 'cult1', nome: 'Soja'),
    CulturasCompanion.insert(idCultura: 'cult2', nome: 'Milho'),
  ]);

  await db.into(db.fitossanitarios).insertAll([
    FitossanitariosCompanion.insert(idDefensivo: 'def1', nome: 'Herbicida A'),
    FitossanitariosCompanion.insert(idDefensivo: 'def2', nome: 'Fungicida B'),
  ]);

  await db.into(db.pragas).insertAll([
    PragasCompanion.insert(idPraga: 'praga1', nome: 'Ferrugem'),
    PragasCompanion.insert(idPraga: 'praga2', nome: 'Lagarta'),
  ]);
}
```

### 3. **Test Examples**

```dart
test('should insert and retrieve diagnostico', () async {
  await seedDatabase(db);

  final diagnostico = createTestDiagnostico();
  final id = await repository.insert(diagnostico);

  expect(id, greaterThan(0));

  final retrieved = await repository.findById(id);
  expect(retrieved, isNotNull);
  expect(retrieved!.idReg, diagnostico.idReg);
});

test('should watch diagnosticos stream', () async {
  await seedDatabase(db);

  final stream = repository.watchByUserId('user123');

  // Inserir diagnostico
  await repository.insert(createTestDiagnostico(userId: 'user123'));

  // Stream deve emitir lista com 1 item
  await expectLater(
    stream,
    emits(predicate<List<DiagnosticoData>>((list) => list.length == 1)),
  );
});

test('should soft delete diagnostico', () async {
  await seedDatabase(db);

  final diagnostico = createTestDiagnostico();
  final id = await repository.insert(diagnostico);

  // Soft delete
  await repository.softDelete(id);

  // Não deve aparecer em queries normais
  final active = await repository.findByUserId(diagnostico.userId);
  expect(active, isEmpty);

  // Mas ainda existe no banco (isDeleted = true)
  final deleted = await (db.select(db.diagnosticos)
    ..where((tbl) => tbl.id.equals(id)))
    .getSingle();
  expect(deleted.isDeleted, true);
});

test('should mark as dirty on local update', () async {
  await seedDatabase(db);

  final diagnostico = createTestDiagnostico();
  final id = await repository.insert(diagnostico);

  // Update local
  await repository.update(id, diagnostico.copyWith(dsMax: 'Updated symptoms'));

  // Deve estar marcado como dirty
  final updated = await repository.findById(id);
  expect(updated!.isDirty, true);
});
```

---

## ⚡ Performance Optimization

### 1. **Indexes**

```dart
// ✅ Criar índices para queries frequentes
@override
Future<void> onCreate(Migrator m) async {
  await m.createAll();

  // Query: WHERE user_id = ? ORDER BY created_at DESC
  await m.createIndex(Index(
    'idx_diagnosticos_user_date',
    'CREATE INDEX idx_diagnosticos_user_date ON diagnosticos (user_id, created_at DESC)',
  ));

  // Query: WHERE user_id = ? AND is_deleted = 0
  await m.createIndex(Index(
    'idx_diagnosticos_user_deleted',
    'CREATE INDEX idx_diagnosticos_user_deleted ON diagnosticos (user_id, is_deleted)',
  ));
}
```

### 2. **Batch Operations**

```dart
// ❌ LENTO: Loop de inserts individuais
for (final item in items) {
  await into(diagnosticos).insert(toCompanion(item));
}

// ✅ RÁPIDO: Batch insert
await batch((batch) {
  batch.insertAll(diagnosticos, items.map(toCompanion).toList());
});
```

### 3. **Pagination**

```dart
// Buscar em páginas ao invés de tudo de uma vez
Future<List<Diagnostico>> findPaginated(String userId, {
  required int page,
  int pageSize = 20,
}) async {
  final offset = page * pageSize;

  return (select(diagnosticos)
    ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
    ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
    ..limit(pageSize, offset: offset))
    .get();
}
```

### 4. **Avoid N+1 Queries**

```dart
// ❌ ERRADO: N+1 queries (1 query por diagnostico para buscar defensivo)
final diagnosticos = await select(diagnosticos).get();
for (final diag in diagnosticos) {
  final defensivo = await (select(fitossanitarios)
    ..where((tbl) => tbl.id.equals(diag.defenisivoId))).getSingle();
  // ... usar defensivo
}

// ✅ CORRETO: 1 query com JOIN
final query = select(diagnosticos).join([
  leftOuterJoin(fitossanitarios, fitossanitarios.id.equalsExp(diagnosticos.defenisivoId)),
]);

final results = await query.get();
for (final row in results) {
  final diag = row.readTable(diagnosticos);
  final defensivo = row.readTableOrNull(fitossanitarios);
  // ... usar diag e defensivo
}
```

---

## 🚫 Antipadrões (O que NÃO fazer)

### 1. ❌ **Strings como Foreign Keys**

```dart
// ❌ ERRADO
class Diagnosticos extends Table {
  TextColumn get fkDefensivo => text()();  // Sem validação de integridade
}

// ✅ CORRETO
class Diagnosticos extends Table {
  IntColumn get defenisivoId => integer().references(Fitossanitarios, #id)();
}
```

### 2. ❌ **Cache em Memória Desacoplado**

```dart
// ❌ ERRADO: Cache pode ficar desatualizado
class DiagnosticoService {
  List<Diagnostico> _cache = [];

  Future<List<Diagnostico>> getAll() async {
    if (_cache.isEmpty) {
      _cache = await db.select(diagnosticos).get();
    }
    return _cache;  // Cache pode estar desatualizado!
  }
}

// ✅ CORRETO: Usar streams (sempre atualizado)
Stream<List<Diagnostico>> watchAll() {
  return db.select(diagnosticos).watch();
}
```

### 3. ❌ **Hard Deletes sem Backup**

```dart
// ❌ ERRADO: Delete permanente (não pode reverter)
Future<void> deleteForever(int id) async {
  await (delete(diagnosticos)..where((tbl) => tbl.id.equals(id))).go();
}

// ✅ CORRETO: Soft delete
Future<void> softDelete(int id) async {
  await (update(diagnosticos)..where((tbl) => tbl.id.equals(id)))
    .write(DiagnosticosCompanion(
      isDeleted: const Value(true),
      isDirty: const Value(true),
    ));
}
```

### 4. ❌ **Queries sem Filtro de Soft Delete**

```dart
// ❌ ERRADO: Retorna registros deletados
Future<List<Diagnostico>> findAll() async {
  return select(diagnosticos).get();
}

// ✅ CORRETO: Sempre filtrar isDeleted
Future<List<Diagnostico>> findAll() async {
  return (select(diagnosticos)
    ..where((tbl) => tbl.isDeleted.equals(false)))
    .get();
}
```

### 5. ❌ **Dynamic Types sem Necessidade**

```dart
// ❌ ERRADO
Future<dynamic> getData(int id) async {
  return await (select(diagnosticos)..where((tbl) => tbl.id.equals(id))).getSingle();
}

// ✅ CORRETO
Future<Diagnostico> getData(int id) async {
  return (select(diagnosticos)..where((tbl) => tbl.id.equals(id))).getSingle();
}
```

---

## 📚 Recursos Adicionais

### Documentação Oficial
- [Drift Documentation](https://drift.simonbinder.eu/)
- [Drift GitHub](https://github.com/simolus3/drift)
- [SQL Reference](https://www.sqlite.org/lang.html)

### Exemplos do Monorepo
- `app-gasometer-drift/lib/database/` - Implementação completa
- `packages/core/lib/drift/` - Utilitários compartilhados

### Tools
```bash
# Visualizar banco em desenvolvimento
sqlite3 ~/.app_receituagro/receituagro_drift.db
.schema diagnosticos
SELECT * FROM diagnosticos LIMIT 10;

# Analisar query plan (performance)
EXPLAIN QUERY PLAN SELECT * FROM diagnosticos WHERE user_id = 'user123';
```

---

**Última atualização**: 2025-11-10
**Autor**: Claude Code Migration Team
**Status**: Reference Guide
