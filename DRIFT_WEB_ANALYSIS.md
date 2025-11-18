# Análise: Implementação Drift para Web no Monorepo
**Data:** 18 de novembro de 2025  
**Objetivo:** Consolidar implementação Drift WASM para web em todos os apps

---

## 📊 Status Atual da Implementação

### ✅ **Apps com Implementação COMPLETA** (3)

#### 1. **app-gasometer** ⭐ (Referência)
- ✅ **Drift:** 2.28.0
- ✅ **sqlite3_flutter_libs:** 0.5.24
- ✅ **DriftDatabaseConfig:** Usa do core package
- ✅ **BaseDriftDatabase:** Mixin do core
- ✅ **WASM Assets:** sqlite3.wasm + drift_worker.dart
- ✅ **pubspec.yaml:** Assets configurados
- ✅ **Factory Methods:** production(), development(), test()
- ✅ **Injectable:** @lazySingleton + @factoryMethod
- ✅ **Documentação:** Comentários completos

**Arquivos-chave:**
```
lib/database/
├── gasometer_database.dart         # Database principal com BaseDriftDatabase
├── tables/gasometer_tables.dart    # Definição de tabelas
├── providers/database_providers.dart  # Riverpod providers
└── repositories/                   # Repositories usando database

web/
├── sqlite3.wasm                    # WASM binary
└── drift_worker.dart               # Worker para threading
```

**pubspec.yaml:**
```yaml
dependencies:
  drift: ^2.28.0
  sqlite3_flutter_libs: ^0.5.24

dev_dependencies:
  drift_dev: ^2.28.0

flutter:
  assets:
    - web/sqlite3.wasm
```

---

#### 2. **app-plantis** ✅
- ✅ **Drift:** 2.28.2 (via core)
- ✅ **sqlite3_flutter_libs:** 0.5.24 (via core)
- ✅ **DriftDatabaseConfig:** Usa do core package
- ✅ **BaseDriftDatabase:** Mixin do core
- ✅ **WASM Assets:** sqlite3.wasm + drift_worker.dart
- ✅ **pubspec.yaml:** Assets configurados
- ✅ **Factory Methods:** production(), development(), test()
- ✅ **Injectable:** @lazySingleton + @factoryMethod

**Diferenças vs gasometer:**
- Usa versões via `core` package (any)
- Estrutura similar mas com tabelas específicas de plantas

---

#### 3. **app-receituagro** ✅
- ✅ **Drift:** 2.28.0
- ✅ **sqlite3_flutter_libs:** 0.5.0
- ✅ **DriftDatabaseConfig:** Usa do core package
- ✅ **BaseDriftDatabase:** Mixin do core
- ✅ **WASM Assets:** sqlite3.wasm + drift_worker.dart
- ⚠️ **Nota:** Comentário indica "not using Drift" mas implementação está completa

**Observação:** pubspec.yaml tem comentário obsoleto sobre não usar Drift, mas implementação está funcional.

---

### ⚠️ **Apps com Implementação PARCIAL** (6)

#### 1. **app-petiveti** 🔶
**Status:** 60% completo

✅ **Tem:**
- Drift 2.28.0 + sqlite3_flutter_libs
- drift_worker.dart + sqlite3.wasm na pasta web
- PetivetiDatabase com 9 tabelas
- DAOs implementados

❌ **Falta:**
- **DriftDatabaseConfig:** Ainda usa `database_connection_web.dart` antigo
- **BaseDriftDatabase:** Não usa mixin do core
- **Factory Methods:** Não tem production(), development(), test()
- **Injectable:** Não usa @lazySingleton
- **WASM Moderno:** Usa `drift/web.dart` (deprecated) ao invés de `drift/wasm.dart`

**Código atual (DESATUALIZADO):**
```dart
// database_connection_web.dart
import 'package:drift/web.dart';  // ❌ DEPRECATED

LazyDatabase driftDatabase() {
  return LazyDatabase(() async {
    return WebDatabase('petiveti_database');  // ❌ API antiga
  });
}
```

**Deve ser:**
```dart
// petiveti_database.dart
@lazySingleton
class PetivetiDatabase extends _$PetivetiDatabase with BaseDriftDatabase {
  @factoryMethod
  factory PetivetiDatabase.injectable() {
    return PetivetiDatabase.production();
  }
  
  factory PetivetiDatabase.production() {
    return PetivetiDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'petiveti_drift.db',
        logStatements: false,
      ),
    );
  }
  // ...
}
```

---

#### 2. **app-taskolist** 🔶
**Status:** 70% completo

✅ **Tem:**
- Drift 2.20.3 (versão antiga)
- sqlite3.wasm + drift_worker.dart
- Database implementado

❌ **Falta:**
- **Versão Drift:** Desatualizada (2.20.3 vs 2.28.0)
- **DriftDatabaseConfig:** Usa WASM mas API antiga
- **BaseDriftDatabase:** Não usa mixin do core
- **Factory Methods:** Não padronizado

**Código atual (PARCIALMENTE DESATUALIZADO):**
```dart
// database_connection_web.dart
import 'package:drift/wasm.dart';  // ✅ Correto
import 'package:sqlite3/wasm.dart';  // ⚠️ API de baixo nível

LazyDatabase driftDatabase() {
  return LazyDatabase(() async {
    final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('/sqlite3.wasm'));
    return WasmDatabase(path: 'taskolist_database', sqlite3: sqlite3);
  });
}
```

**Deve usar DriftDatabaseConfig do core.**

---

#### 3. **app-calculei** 🔶
**Status:** 50% completo

✅ **Tem:**
- Drift configurado (any)
- sqlite3.wasm + drift_worker.dart

❌ **Falta:**
- **Database:** Pode não ter implementação completa
- **DriftDatabaseConfig:** Não usa do core
- **drift_dev:** Comentado como "desabilitado temporariamente"

---

#### 4. **app-nutrituti** 🔶
**Status:** 60% completo

✅ **Tem:**
- Drift configurado (any via core)
- sqlite3_web: any (adicional)
- sqlite3.wasm + drift_worker.dart

❌ **Falta:**
- **DriftDatabaseConfig:** Verificar implementação
- **BaseDriftDatabase:** Verificar se usa mixin

---

#### 5. **app-nebulalist** 🔶
**Status:** 50% completo

✅ **Tem:**
- sqlite3.wasm + drift_worker.dart

❌ **Falta:**
- **pubspec.yaml:** Verificar dependências
- **Database:** Verificar implementação

---

#### 6. **app-termostecnicos** 🔶
**Status:** 40% completo

✅ **Tem:**
- sqlite3.wasm + drift_worker.dart

❌ **Falta:**
- **Comentário:** "Web support can be added later with drift/wasm.dart"
- Indica que suporte web não está completo

---

### ❌ **Apps SEM Drift** (2)

#### 1. **app-agrihurbi**
- Não usa Drift
- Pode usar outra solução de persistência

#### 2. **app-minigames**
- Não usa Drift
- Provavelmente não precisa de persistência local complexa

---

## 🏗️ Arquitetura de Referência (app-gasometer)

### Estrutura de Arquivos

```
app-gasometer/
├── lib/
│   └── database/
│       ├── gasometer_database.dart          # ⭐ Database principal
│       ├── tables/
│       │   └── gasometer_tables.dart        # Definição de tabelas
│       ├── providers/
│       │   ├── database_providers.dart      # Riverpod providers
│       │   └── sync_providers.dart
│       ├── repositories/                    # Repositories
│       └── adapters/                        # Strategy pattern
├── web/
│   ├── sqlite3.wasm                         # ⭐ WASM binary
│   └── drift_worker.dart                    # ⭐ Worker thread
└── pubspec.yaml                             # ⭐ Configuração
```

### gasometer_database.dart (Padrão)

```dart
import 'package:drift/drift.dart';
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

@DriftDatabase(tables: [/* ... */])
@lazySingleton
class GasometerDatabase extends _$GasometerDatabase with BaseDriftDatabase {
  GasometerDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  // ⭐ Factory Injectable (DI)
  @factoryMethod
  factory GasometerDatabase.injectable() {
    return GasometerDatabase.production();
  }

  // ⭐ Factory Production (usa DriftDatabaseConfig)
  factory GasometerDatabase.production() {
    return GasometerDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'gasometer_drift.db',
        logStatements: false,
      ),
    );
  }

  // ⭐ Factory Development (logging habilitado)
  factory GasometerDatabase.development() {
    return GasometerDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'gasometer_drift_dev.db',
        logStatements: true,
      ),
    );
  }

  // ⭐ Factory Test (in-memory)
  factory GasometerDatabase.test() {
    return GasometerDatabase(
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
    },
  );
}
```

### drift_worker.dart (Padrão Universal)

```dart
import 'package:drift/wasm.dart';

void main() => WasmDatabase.workerMainForOpen();
```

### pubspec.yaml (Padrão)

```yaml
name: app_name
dependencies:
  drift: ^2.28.0
  sqlite3_flutter_libs: ^0.5.24
  core:
    path: ../../packages/core

dev_dependencies:
  drift_dev: ^2.28.0

flutter:
  assets:
    - web/sqlite3.wasm
```

---

## 🔧 Core Package (Infraestrutura Compartilhada)

### DriftDatabaseConfig

**Implementação Platform-Specific:**
- `drift_database_config_web.dart` - Web (WASM)
- `drift_database_config_mobile.dart` - Mobile/Desktop (Native)
- `drift_database_config_stub.dart` - Stub para conditional imports

**Exports:**
```dart
// core/lib/services/drift_disabled/drift.dart
export 'drift_database_config_stub.dart'
  if (dart.library.io) 'drift_database_config_mobile.dart'
  if (dart.library.html) 'drift_database_config_web.dart';
```

### BaseDriftDatabase Mixin

```dart
mixin BaseDriftDatabase on GeneratedDatabase {
  // Métodos compartilhados entre todos os databases
  // Exemplos: transaction helpers, query builders, etc.
}
```

---

## 📋 Checklist de Migração

### Para cada app:

#### 1️⃣ **pubspec.yaml**
```yaml
✅ drift: ^2.28.0
✅ sqlite3_flutter_libs: ^0.5.24
✅ drift_dev: ^2.28.0 (dev_dependencies)
✅ assets: - web/sqlite3.wasm
```

#### 2️⃣ **web/drift_worker.dart**
```dart
✅ import 'package:drift/wasm.dart';
✅ void main() => WasmDatabase.workerMainForOpen();
```

#### 3️⃣ **web/sqlite3.wasm**
```
✅ Arquivo binário presente (cópia de gasometer ou core)
```

#### 4️⃣ **lib/database/app_database.dart**
```dart
✅ @lazySingleton
✅ extends _$AppDatabase with BaseDriftDatabase
✅ @factoryMethod factory AppDatabase.injectable()
✅ factory AppDatabase.production() usando DriftDatabaseConfig
✅ factory AppDatabase.development()
✅ factory AppDatabase.test()
✅ MigrationStrategy com onCreate e beforeOpen
```

#### 5️⃣ **Remover arquivos antigos**
```
❌ database_connection_web.dart (deprecated)
❌ database_connection_native.dart (deprecated)
❌ database_connection_stub.dart (deprecated)
❌ database_connection.dart (deprecated)
```

#### 6️⃣ **Providers/DI**
```dart
✅ Usar gasometerDatabaseProvider pattern
✅ GetIt.I<AppDatabase>() para singleton
✅ ref.keepAlive() no provider
```

---

## 🎯 Plano de Ação

### **Prioridade 1: Apps em Produção**
1. **app-petiveti** (60% → 100%)
   - Substituir database_connection_web.dart
   - Adicionar factory methods
   - Implementar BaseDriftDatabase mixin
   - Adicionar @lazySingleton

2. **app-taskolist** (70% → 100%)
   - Atualizar Drift 2.20.3 → 2.28.0
   - Substituir por DriftDatabaseConfig
   - Padronizar factory methods

### **Prioridade 2: Apps com Drift Parcial**
3. **app-nutrituti** (60% → 100%)
4. **app-calculei** (50% → 100%)
5. **app-nebulalist** (50% → 100%)

### **Prioridade 3: Apps sem Drift Completo**
6. **app-termostecnicos** (40% → 100%)

---

## 📊 Resumo Executivo

| App | Drift | WASM | Config | Mixin | Injectable | Status |
|-----|-------|------|--------|-------|------------|--------|
| **gasometer** | 2.28.0 | ✅ | ✅ | ✅ | ✅ | 100% ⭐ |
| **plantis** | 2.28.2 | ✅ | ✅ | ✅ | ✅ | 100% ✅ |
| **receituagro** | 2.28.0 | ✅ | ✅ | ✅ | ✅ | 100% ✅ |
| **petiveti** | 2.28.0 | ✅ | ❌ | ❌ | ❌ | 60% 🔶 |
| **taskolist** | 2.20.3 | ✅ | ⚠️ | ❌ | ❌ | 70% 🔶 |
| **nutrituti** | any | ✅ | ⚠️ | ⚠️ | ⚠️ | 60% 🔶 |
| **calculei** | any | ✅ | ⚠️ | ⚠️ | ⚠️ | 50% 🔶 |
| **nebulalist** | ? | ✅ | ⚠️ | ⚠️ | ⚠️ | 50% 🔶 |
| **termostecnicos** | ? | ✅ | ❌ | ❌ | ❌ | 40% 🔶 |
| **agrihurbi** | - | - | - | - | - | N/A |
| **minigames** | - | - | - | - | - | N/A |

**Legenda:**
- ✅ Implementado e testado
- ⚠️ Parcialmente implementado
- ❌ Não implementado
- ? Precisa verificação

---

## 🔑 Pontos-Chave da Solução Consolidada

### 1. **DriftDatabaseConfig (Core Package)**
- ✅ Platform-specific: web (WASM) vs mobile (Native)
- ✅ Métodos unificados: createExecutor(), test(), development()
- ✅ Cache busting automático para WASM
- ✅ Logging configurável
- ✅ Tratamento de erros padronizado

### 2. **BaseDriftDatabase Mixin**
- ✅ Funcionalidades compartilhadas entre databases
- ✅ Evita duplicação de código
- ✅ Extensível por cada app

### 3. **Factory Pattern**
- ✅ injectable() - DI via GetIt/Injectable
- ✅ production() - Configuração otimizada
- ✅ development() - Logging habilitado
- ✅ test() - In-memory database

### 4. **WASM Assets**
- ✅ sqlite3.wasm - Binary SQLite compilado para WebAssembly
- ✅ drift_worker.dart - Worker thread para operações em background
- ✅ Cache busting via timestamp query params

### 5. **Vantagens da Implementação**
- ✅ **Performance:** WASM mais rápido que JS puro
- ✅ **Compatibilidade:** Funciona em Chrome, Firefox, Safari
- ✅ **Offline-first:** IndexedDB persistente
- ✅ **Type-safe:** Drift gera código type-safe
- ✅ **Sincronização:** Base para sync com Firebase

---

## 🚀 Próximos Passos

### Imediato
1. Validar análise com testes em cada app
2. Criar script de migração automatizado
3. Documentar processo de migração step-by-step

### Curto Prazo (1-2 semanas)
1. Migrar app-petiveti para padrão consolidado
2. Migrar app-taskolist para Drift 2.28.0
3. Criar template generator para novos apps

### Médio Prazo (1 mês)
1. Migrar todos os apps restantes
2. Criar testes de integração web para cada app
3. Documentar best practices no README

---

## 📚 Referências

- [Drift Documentation](https://drift.simonbinder.eu/)
- [Drift Web Support](https://drift.simonbinder.eu/web/)
- [WASM in Dart](https://dart.dev/web/wasm)
- [app-gasometer (Referência)](./apps/app-gasometer/)
