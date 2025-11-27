# Drift Implementation Guide - Monorepo

> **Padrão Oficial** para persistência SQL em todos os apps do monorepo.

---

## 📚 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura no Core](#arquitetura-no-core)
3. [Criando Database em Novo App](#criando-database-em-novo-app)
4. [Criando Repository](#criando-repository)
5. [Providers Riverpod](#providers-riverpod)
6. [Padrões de Código](#padrões-de-código)
7. [Migrations](#migrations)
8. [Exemplos por App](#exemplos-por-app)

---

## Visão Geral

### Por que Drift?

- ✅ **Type-safe queries** - Erros de SQL em compile-time
- ✅ **Reactive streams** - `watchAll()`, `watchById()` built-in
- ✅ **Migrations automáticas** - Controle de versão de schema
- ✅ **Performance SQLite** - Nativo em mobile/desktop
- ✅ **Transações ACID** - Consistência garantida
- ✅ **Foreign keys** - Integridade referencial

### Estrutura no Monorepo

```
packages/core/lib/
├── services/drift/                    # Camada 1: Base
│   ├── base_drift_database.dart       # Mixin com utils
│   ├── base_drift_repository.dart     # Repository simples
│   └── drift_database_config.dart     # Config multiplataforma
│
└── src/infrastructure/storage/drift/  # Camada 2: Avançada
    ├── interfaces/
    │   ├── i_drift_manager.dart       # Gerenciador singleton
    │   └── i_drift_repository.dart    # Interface completa
    ├── repositories/
    │   └── drift_repository_base.dart # Repository com Result/Error
    ├── services/
    │   ├── drift_manager.dart
    │   └── drift_storage_service.dart
    └── exceptions/
        └── drift_exceptions.dart      # Exceções tipadas
```

---

## Arquitetura no Core

### Imports Disponíveis

```dart
// Core exporta automaticamente:
import 'package:core/core.dart';

// Inclui:
// - BaseDriftDatabase (mixin)
// - BaseDriftRepositoryImpl (repository simples)
// - DriftDatabaseConfig (config)
// - DriftRepositoryBase (repository avançado com Result)
// - IDriftManager, IDriftRepository (interfaces)
// - DriftException e derivadas
```

### Qual Repository Usar?

| Classe | Quando Usar | Complexidade |
|--------|-------------|--------------|
| `BaseDriftRepositoryImpl` | Apps simples, CRUD básico | ⭐ Baixa |
| `DriftRepositoryBase` | Apps completos, error handling | ⭐⭐⭐ Alta |
| Custom (direto no DB) | Queries muito específicas | ⭐⭐ Média |

**Recomendação:** Use `DriftRepositoryBase` para novos apps.

---

## Criando Database em Novo App

### 1. Estrutura de Pastas

```
apps/app-myapp/lib/
├── database/
│   ├── myapp_database.dart        # Database principal
│   ├── myapp_database.g.dart      # Gerado (build_runner)
│   ├── tables/
│   │   └── myapp_tables.dart      # Definição das tabelas
│   ├── repositories/
│   │   └── item_repository.dart   # Repositories
│   └── providers/
│       └── database_providers.dart # Riverpod providers
```

### 2. Definir Tabelas

```dart
// lib/database/tables/myapp_tables.dart
import 'package:drift/drift.dart';

/// Tabela de Items
/// 
/// Campos de sync (obrigatórios para sincronização):
/// - isDirty: precisa sincronizar
/// - isDeleted: soft delete
/// - lastSyncAt: última sincronização
/// - version: controle de conflitos
class Items extends Table {
  // PK
  IntColumn get id => integer().autoIncrement()();
  
  // Firebase reference (para sync)
  TextColumn get firebaseId => text().nullable()();
  
  // User reference
  TextColumn get userId => text()();
  
  // Business fields
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  // Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  
  // Sync fields (PADRÃO DO MONOREPO)
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  
  // Module identification
  TextColumn get moduleName => text().withDefault(const Constant('myapp'))();
}

/// Tabela de Categories (com FK para Items)
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  
  // FK para Item (opcional)
  IntColumn get itemId => integer().nullable().references(Items, #id)();
  
  // Sync fields
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
}
```

### 3. Criar Database

```dart
// lib/database/myapp_database.dart
import 'package:core/core.dart';
import 'package:drift/drift.dart';

import 'tables/myapp_tables.dart';

part 'myapp_database.g.dart';

@DriftDatabase(tables: [Items, Categories])
class MyAppDatabase extends _$MyAppDatabase with BaseDriftDatabase {
  MyAppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  /// Factory para produção
  factory MyAppDatabase.production() {
    return MyAppDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'myapp_drift.db',
        logStatements: false,
      ),
    );
  }

  /// Factory para desenvolvimento (com logs SQL)
  factory MyAppDatabase.development() {
    return MyAppDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'myapp_drift_dev.db',
        logStatements: true,
      ),
    );
  }

  /// Factory para testes (in-memory)
  factory MyAppDatabase.test() {
    return MyAppDatabase(
      DriftDatabaseConfig.createInMemoryExecutor(logStatements: true),
    );
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      print('✅ MyApp Database schema created');
    },
    beforeOpen: (details) async {
      // ⚠️ OBRIGATÓRIO: Habilitar foreign keys
      await customStatement('PRAGMA foreign_keys = ON');
      
      if (details.wasCreated) {
        print('🎉 MyApp Database criado v${details.versionNow}');
      }
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Migrations futuras aqui
      // if (from < 2) {
      //   await m.addColumn(items, items.newColumn);
      // }
    },
  );
}
```

### 4. Gerar Código

```bash
cd apps/app-myapp
dart run build_runner build --delete-conflicting-outputs
```

---

## Criando Repository

### Opção A: Repository Avançado (Recomendado)

```dart
// lib/database/repositories/item_repository.dart
import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../myapp_database.dart';
import '../tables/myapp_tables.dart';

/// Repository de Items usando DriftRepositoryBase
/// 
/// Inclui:
/// - CRUD completo com Result<T>
/// - Error handling automático
/// - Cache opcional
/// - Streams reativos
class ItemRepository extends DriftRepositoryBase<Item, Items> {
  ItemRepository(this._db);

  final MyAppDatabase _db;

  @override
  GeneratedDatabase get database => _db;

  @override
  TableInfo<Items, Item> get table => _db.items;

  @override
  String get tableName => 'items';

  @override
  GeneratedColumn get idColumn => _db.items.id;

  // ==================== QUERIES CUSTOMIZADAS ====================

  /// Busca items ativos do usuário
  Future<Result<List<Item>>> getActiveItemsByUser(String userId) async {
    return findWhere((t) => 
      t.userId.equals(userId) & 
      t.isActive.equals(true) & 
      t.isDeleted.equals(false)
    );
  }

  /// Stream de items do usuário
  Stream<List<Item>> watchItemsByUser(String userId) {
    return (_db.select(_db.items)
      ..where((t) => 
        t.userId.equals(userId) & 
        t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();
  }

  /// Busca items dirty (pendentes de sync)
  Future<Result<List<Item>>> getDirtyItems() async {
    return findWhere((t) => t.isDirty.equals(true));
  }

  /// Marca item como sincronizado
  Future<Result<int>> markAsSynced(int itemId) async {
    return updateWhere(
      (t) => t.id.equals(itemId),
      ItemsCompanion(
        isDirty: const Value(false),
        lastSyncAt: Value(DateTime.now()),
      ),
    );
  }

  /// Soft delete
  Future<Result<int>> softDelete(int itemId) async {
    return updateWhere(
      (t) => t.id.equals(itemId),
      ItemsCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
```

### Opção B: Repository Simples

```dart
// Para apps mais simples
class SimpleItemRepository extends BaseDriftRepositoryImpl<Item, ItemData> {
  SimpleItemRepository(this._db);

  final MyAppDatabase _db;

  @override
  TableInfo<Items, Item> get table => _db.items;

  @override
  GeneratedDatabase get database => _db;

  @override
  ItemData fromData(Item data) => ItemData.fromDrift(data);

  @override
  Insertable<Item> toCompanion(ItemData entity) => entity.toCompanion();

  @override
  Expression<int> idColumn(Items tbl) => tbl.id;
}
```

---

## Providers Riverpod

```dart
// lib/database/providers/database_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../myapp_database.dart';
import '../repositories/item_repository.dart';

/// Provider do Database (singleton)
final myAppDatabaseProvider = Provider<MyAppDatabase>((ref) {
  final db = MyAppDatabase.production();
  
  ref.onDispose(() {
    print('🗑️ MyAppDatabase disposed');
    db.close();
  });
  
  return db;
});

/// Provider do ItemRepository
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final db = ref.watch(myAppDatabaseProvider);
  return ItemRepository(db);
});

// ==================== PROVIDERS DERIVADOS ====================

/// Items do usuário (stream reativo)
final userItemsProvider = StreamProvider.family<List<Item>, String>((ref, userId) {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.watchItemsByUser(userId);
});

/// Contagem de items ativos
final activeItemsCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  final repo = ref.watch(itemRepositoryProvider);
  final result = await repo.getActiveItemsByUser(userId);
  return result.isSuccess ? result.data!.length : 0;
});

/// Items dirty (pendentes de sync)
final dirtyItemsProvider = FutureProvider<List<Item>>((ref) async {
  final repo = ref.watch(itemRepositoryProvider);
  final result = await repo.getDirtyItems();
  return result.isSuccess ? result.data! : [];
});
```

---

## Padrões de Código

### Campos Obrigatórios para Sync

```dart
// SEMPRE incluir em tabelas sincronizáveis:
BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
DateTimeColumn get lastSyncAt => dateTime().nullable()();
IntColumn get version => integer().withDefault(const Constant(1))();
TextColumn get userId => text()();
TextColumn get firebaseId => text().nullable()();
TextColumn get moduleName => text().withDefault(const Constant('appname'))();
```

### Naming Conventions

| Tipo | Convenção | Exemplo |
|------|-----------|---------|
| Database class | `{App}Database` | `PlantisDatabase` |
| Table class | PascalCase plural | `Plants`, `FuelSupplies` |
| Repository | `{Entity}Repository` | `PlantRepository` |
| Provider | `{entity}Provider` | `plantsProvider` |
| DB file | `{app}_drift.db` | `plantis_drift.db` |

### Factory Methods (Obrigatórios)

```dart
factory MyDatabase.production() { ... }  // Produção
factory MyDatabase.development() { ... } // Dev com logs
factory MyDatabase.test() { ... }        // In-memory
```

---

## Migrations

### Exemplo de Migration

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (Migrator m) async {
    await m.createAll();
  },
  onUpgrade: (Migrator m, int from, int to) async {
    // v1 → v2: Adicionar coluna
    if (from < 2) {
      await m.addColumn(items, items.priority);
    }
    
    // v2 → v3: Nova tabela
    if (from < 3) {
      await m.createTable(categories);
    }
    
    // v3 → v4: Renomear coluna (via SQL direto)
    if (from < 4) {
      await customStatement(
        'ALTER TABLE items RENAME COLUMN old_name TO new_name',
      );
    }
  },
  beforeOpen: (details) async {
    await customStatement('PRAGMA foreign_keys = ON');
  },
);
```

### Checklist de Migration

- [ ] Incrementar `schemaVersion`
- [ ] Adicionar lógica em `onUpgrade`
- [ ] Testar migration com dados existentes
- [ ] Documentar mudanças

---

## Exemplos por App

### app-gasometer (Gold Standard)

```dart
// Usa BaseDriftRepositoryImpl
class VehicleRepository extends BaseDriftRepositoryImpl<Vehicle, VehicleData> {
  // ... implementação completa
}
```

### app-plantis

```dart
// Custom repositories sem herança
class PlantsDriftRepository {
  final PlantisDatabase _db;
  // ... queries diretas
}
```

### app-nebulalist

```dart
// Usa DAOs nativos Drift
@DriftDatabase(tables: [Lists, Items], daos: [ListDao, ItemDao])
class NebulalistDatabase extends _$NebulalistDatabase { ... }
```

---

## Checklist para Novo App

- [ ] Criar pasta `database/` com estrutura padrão
- [ ] Definir tabelas em `tables/`
- [ ] Criar database com factory methods
- [ ] Criar repositories usando `DriftRepositoryBase`
- [ ] Criar providers Riverpod
- [ ] Rodar `build_runner`
- [ ] Testar CRUD básico
- [ ] Configurar streams reativos
- [ ] Implementar sync helpers se necessário

---

## Links Úteis

- [Drift Documentation](https://drift.simonbinder.eu/)
- [Core README - Drift Service](/packages/core/lib/services/drift/README.md)
- [Core README - Drift Storage](/packages/core/lib/src/infrastructure/storage/drift/README.md)

---

**Atualizado:** 2025-11-27  
**Versão:** 1.0.0  
**Autor:** Monorepo Team
