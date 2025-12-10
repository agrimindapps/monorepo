# Banco de Dados Local (Drift)

Este documento descreve a estratégia de persistência local utilizando o pacote `drift`.

## Estrutura

Cada aplicativo possui seu próprio banco de dados Drift, mas compartilha definições de tabelas e padrões através do pacote `core`.

### Tabelas Compartilhadas

O pacote `core` pode fornecer definições de tabelas comuns (mixins ou classes base) para garantir consistência.

#### UserSubscriptions
Tabela responsável por armazenar o cache local das assinaturas.

```dart
class UserSubscriptions extends Table {
  TextColumn get id => text()(); // ID único (geralmente userId)
  TextColumn get userId => text()();
  TextColumn get status => text()(); // Status criptografado
  TextColumn get originalPurchaseDate => text().nullable()(); // Criptografado
  TextColumn get latestPurchaseDate => text().nullable()(); // Criptografado
  TextColumn get expirationDate => text().nullable()(); // Criptografado
  BoolColumn get isSandbox => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

## Migrações

O gerenciamento de esquema é feito através do sistema de migrações do Drift.
*   Sempre que uma tabela é alterada, o `schemaVersion` do banco de dados deve ser incrementado.
*   Uma estratégia de migração deve ser definida no método `migration` do banco de dados.

Exemplo de migração para adicionar `UserSubscriptions`:

```dart
@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Exemplo: Adicionando tabela de assinaturas na versão 2
        await m.createTable(userSubscriptions);
      }
    },
  );
}
```

## Sincronização (SyncAdapters)

Para manter os dados locais sincronizados com fontes remotas (Firebase, RevenueCat), utilizamos o padrão **SyncAdapter**.
*   Converte dados externos para DTOs do Drift.
*   Gerencia conflitos e atualizações.

## Web Support (WASM)

Para suporte à Web, utilizamos `sqlite3_web` com WebAssembly. Isso garante performance próxima à nativa e persistência confiável no navegador (via OPFS ou IndexedDB).
