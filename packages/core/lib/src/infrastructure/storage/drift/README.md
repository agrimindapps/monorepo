# Drift Storage - Core Package

Infraestrutura de storage usando Drift (SQLite) para o monorepo.

## 📁 Estrutura

```
drift/
├── interfaces/
│   ├── i_drift_manager.dart           # Interface do manager
│   └── i_drift_repository.dart        # Interfaces de repositories
├── services/
│   ├── drift_manager.dart             # Gerenciador de databases
│   ├── core_drift_storage_service.dart # Service alto nível
│   └── drift_storage_service.dart     # Service para apps (ILocalStorageRepository)
├── repositories/
│   └── base_drift_repository.dart     # Base para repositories
├── exceptions/
│   └── drift_exceptions.dart          # Exceções específicas Drift
└── drift_storage.dart                 # Barrel export
```

## 🎯 Componentes Principais

### 1. DriftManager
**Arquivo:** `services/drift_manager.dart`

Gerenciador singleton de databases Drift.

**Responsabilidades:**
- Inicialização do Drift
- Cache de databases abertas
- Estatísticas de uso
- VACUUM operations
- Database info (via PRAGMA SQLite)

**Uso:**
```dart
final manager = DriftManager.instance;
await manager.initialize('my_app');

final db = await manager.getDatabase('my_database');
await manager.vacuumDatabase('my_database');
```

---

### 2. CoreDriftStorageService
**Arquivo:** `services/core_drift_storage_service.dart`

Service de alto nível que implementa `IBoxStorageService`.

**Responsabilidades:**
- Health checks
- Estatísticas agregadas
- Backup/restore metadata
- Maintenance (vacuum all)
- Orquestração do DriftManager

**Uso:**
```dart
final service = CoreDriftStorageService();
await service.initialize({'appName': 'plantis'});

final health = await service.healthCheck();
final stats = await service.getStatistics();
```

---

### 3. DriftStorageService
**Arquivo:** `services/drift_storage_service.dart`

Service para uso pelos apps. Implementa `ILocalStorageRepository`.

**⚠️ IMPORTANTE:** Esta é uma implementação **bridge/adapter** que usa uma tabela key-value genérica para manter compatibilidade com a interface ILocalStorageRepository.

Para apps com Drift completo, prefira usar **repositories Drift nativos** ao invés desta abstração genérica.

**Responsabilidades:**
- CRUD operations (save, get, remove, clear)
- TTL support
- User settings
- Offline data
- Lists operations
- Compatibilidade com ILocalStorageRepository

**Uso:**
```dart
final service = DriftStorageService(database);
await service.initialize();

// Save data
await service.save(key: 'user_id', data: '12345');

// Get data
final userId = await service.get<String>(key: 'user_id');

// Save with TTL
await service.saveWithTTL(
  key: 'temp_data',
  data: {'value': 123},
  ttl: Duration(minutes: 30),
);
```

---

### 4. BaseDriftRepository
**Arquivo:** `repositories/base_drift_repository.dart`

Classe base para implementar repositories Drift tipados.

**Responsabilidades:**
- CRUD genérico (insert, update, delete, get)
- Queries paginadas
- Streams reativos (watch)
- Transações
- Cache opcional

**Uso:**
```dart
class PlantsRepository extends BaseDriftRepository<Plant, PlantsTable> {
  PlantsRepository(GeneratedDatabase db)
      : super(
          database: db,
          table: db.plants,
        );

  @override
  GeneratedColumn get idColumn => table.id;

  // Custom methods
  Future<List<Plant>> getActiveP lants() async {
    return (select(table)
      ..where((t) => t.isActive.equals(true)))
      .get();
  }
}
```

---

## 🔄 Mapeamento Hive → Drift

| Hive Concept | Drift Equivalent |
|--------------|------------------|
| Box | Database / Table |
| HiveObject | DataClass |
| TypeAdapter | -  (não necessário) |
| Box.put(key, value) | insert() / update() |
| Box.get(key) | select().where().get() |
| Box.delete(key) | delete().where() |
| Box.clear() | delete().go() |
| Box.compact() | VACUUM |
| Box.watch() | select().watch() |

---

## 📊 Comparação com Hive

### Vantagens Drift
✅ Type-safe queries
✅ Migrations automáticas
✅ Foreign keys e relações
✅ Transações ACID
✅ Performance SQLite
✅ Queries complexas
✅ Streaming reativo built-in

### Desvantagens Drift
❌ Curva de aprendizado maior
❌ Mais boilerplate (tables, DAOs)
❌ Code generation obrigatório
❌ Menos flexível que Hive

---

## 🚀 Migração de Hive para Drift

### Apps já usando Hive
Se seu app usa `HiveStorageService`:

```dart
// ANTES (Hive)
final storage = HiveStorageService(boxRegistry);

// DEPOIS (Drift)
final storage = DriftStorageService(database);
```

**Nota:** DriftStorageService usa tabela key-value genérica. Para melhor performance, migre para repositories Drift nativos.

### Apps novos
Para apps novos, crie repositories Drift nativos:

```dart
class MyRepository extends BaseDriftRepository<MyData, MyTable> {
  MyRepository(GeneratedDatabase db)
      : super(database: db, table: db.myTable);

  @override
  GeneratedColumn get idColumn => table.id;
}
```

---

## 🧪 Testes

### Unit Tests
```dart
test('DriftManager initializes successfully', () async {
  final manager = DriftManager.instance;
  final result = await manager.initialize('test_app');
  
  expect(result.isSuccess, true);
  expect(manager.isInitialized, true);
});
```

### Integration Tests
```dart
testWidgets('DriftStorageService saves and retrieves data', (tester) async {
  final service = DriftStorageService(testDatabase);
  await service.initialize();
  
  await service.save(key: 'test', data: 'value');
  final result = await service.get<String>(key: 'test');
  
  expect(result.isRight(), true);
});
```

---

## 📝 Notas de Implementação

### DriftStorageService - Limitações

Esta implementação usa **custom SQL statements** para manter compatibilidade com `ILocalStorageRepository`. 

**Limitações:**
- Usa tabela key-value genérica (não aproveita type-safety do Drift)
- Serialização JSON manual
- Menos performance que repositories nativos
- Não suporta queries complexas

**Recomendação:** Use apenas como bridge durante migração. Para produção, crie repositories Drift nativos.

### Requer Tabela Key-Value

Para usar `DriftStorageService`, crie esta tabela no seu database:

```dart
class KeyValueStorage extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  TextColumn get type => text().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {key};
}
```

---

## 🔗 Links Úteis

- [Drift Documentation](https://drift.simonbinder.eu/)
- [Drift Migrations](https://drift.simonbinder.eu/docs/advanced-features/migrations/)
- [Drift Streams](https://drift.simonbinder.eu/docs/getting-started/reactive_queries/)

---

**Criado:** 2025-11-12  
**Versão:** 1.0.0  
**Autor:** GitHub Copilot  
**Monorepo:** Plantis/ReceituAgro
