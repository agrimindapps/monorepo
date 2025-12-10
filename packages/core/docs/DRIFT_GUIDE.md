# Guia de Implementação com Drift (SQLite)

Este guia detalha o passo a passo para implementar persistência de dados local utilizando o Drift no monorepo.

## 1. Definindo uma Tabela

As tabelas são definidas como classes Dart que estendem `Table`.

**Localização:** `lib/features/[feature]/data/datasources/local/tables/` ou `packages/core/lib/tables/` (se compartilhado).

```dart
import 'package:drift/drift.dart';

class Items extends Table {
  // Definição das colunas
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 50)();
  TextColumn get content => text().named('body')();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // Chaves estrangeiras e índices
  @override
  Set<Column> get primaryKey => {id};
}
```

## 2. Criando um DAO (Data Access Object)

DAOs encapsulam as queries para uma ou mais tabelas específicas.

**Localização:** `lib/features/[feature]/data/datasources/local/daos/`

```dart
import 'package:drift/drift.dart';
import 'package:my_app/database/database.dart';
import 'package:my_app/features/items/data/datasources/local/tables/items_table.dart';

part 'items_dao.g.dart';

@DriftAccessor(tables: [Items])
class ItemsDao extends DatabaseAccessor<MyDatabase> with _$ItemsDaoMixin {
  ItemsDao(MyDatabase db) : super(db);

  // Queries
  Future<List<Item>> getAllItems() => select(items).get();
  
  Stream<List<Item>> watchAllItems() => select(items).watch();
  
  Future<int> insertItem(ItemsCompanion entry) => into(items).insert(entry);
  
  Future<bool> updateItem(Item entry) => update(items).replace(entry);
  
  Future<int> deleteItem(int id) => 
      (delete(items)..where((tbl) => tbl.id.equals(id))).go();
}
```

## 3. Registrando no Banco de Dados

Adicione a tabela e o DAO na definição do banco de dados principal do app.

**Localização:** `lib/core/database/database.dart`

```dart
@DriftDatabase(
  tables: [
    Items, // 1. Adicione a tabela aqui
    UserSubscriptions,
  ],
  daos: [
    ItemsDao, // 2. Adicione o DAO aqui
  ],
)
class MyDatabase extends _$MyDatabase {
  // ...
}
```

## 4. Gerando Código

Após criar ou modificar tabelas/DAOs, execute o build runner para gerar o código SQL e Dart.

```bash
# No diretório do app ou package
flutter pub run build_runner build --delete-conflicting-outputs
```

## 5. Gerenciando Migrações

Se você alterou uma tabela existente ou adicionou uma nova em um app já publicado, você **DEVE** incrementar a versão e criar uma migração.

**Arquivo:** `lib/core/database/database.dart`

```dart
@override
int get schemaVersion => 2; // Incremente este número

@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Se a versão anterior era menor que 2, crie a nova tabela
        await m.createTable(items);
      }
    },
  );
}
```

## 6. Utilizando no Repositório

Injete o DAO no seu repositório (ou datasource local) para acessar os dados.

```dart
class ItemsLocalDataSource {
  final ItemsDao _dao;

  ItemsLocalDataSource(this._dao);

  Future<List<ItemModel>> getItems() async {
    final items = await _dao.getAllItems();
    return items.map((i) => ItemModel.fromDrift(i)).toList();
  }
}
```

## Dicas Importantes

*   **Companions:** Use `ItemsCompanion` para inserts/updates parciais (onde alguns campos podem ser nulos ou default).
*   **Streams:** Drift brilha com Streams. Use `watch()` para manter a UI reativa a mudanças no banco.
*   **Transações:** Use `transaction(() async { ... })` para operações atômicas complexas.
*   **Web:** Lembre-se que na web usamos `sqlite3_web` e WASM. O setup é diferente do mobile (já configurado no core).
