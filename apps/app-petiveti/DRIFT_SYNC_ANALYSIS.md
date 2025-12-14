# 📊 ANÁLISE: Drift + Firebase Sync - app-petiveti

**Data da Análise:** 2025-12-14
**Referência:** app-gasometer (padrão estabelecido)

---

## ✅ STATUS GERAL

### **Database Principal**
- ✅ `PetivetiDatabase` implementado com padrão correto
- ✅ Extends `BaseDriftDatabase` do core
- ✅ Factory methods: `production()`, `development()`, `test()`, `withPath()`
- ✅ Schema version: 2 (com migrations implementadas)
- ✅ Migration strategy com onCreate, onUpgrade e beforeOpen
- ✅ Foreign keys habilitados (`PRAGMA foreign_keys = ON`)

### **Tabelas (10 total)**
1. ✅ **Animals** - Cadastro de pets
2. ✅ **Medications** - Medicamentos e tratamentos
3. ✅ **Vaccines** - Vacinação
4. ✅ **Appointments** - Consultas veterinárias
5. ✅ **WeightRecords** - Histórico de peso
6. ✅ **Expenses** - Despesas com pets
7. ✅ **Reminders** - Lembretes e notificações
8. ✅ **CalculationHistory** - Histórico de calculadoras
9. ✅ **PromoContent** - Conteúdo promocional
10. ✅ **UserSubscriptions** - Assinaturas premium (cache local)

---

## 🔍 ANÁLISE POR COMPONENTE

### **1. Campos de Sincronização (Sync Fields)**

#### ✅ **Campos Implementados nas Tabelas**
Todas as tabelas possuem os campos necessários:

```dart
// Firebase reference
TextColumn get firebaseId => text().nullable()();

// User ownership
TextColumn get userId => text()();

// Sync metadata
DateTimeColumn get lastSyncAt => dateTime().nullable()();
BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
IntColumn get version => integer().withDefault(const Constant(1))();

// Soft delete
BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

// Timestamps
DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
DateTimeColumn get updatedAt => dateTime().nullable()();
```

**Status:** ✅ **COMPLETO** - Todas as tabelas têm os campos necessários

---

### **2. DAOs (Data Access Objects)**

#### ✅ **DAOs Implementados (9 total)**
1. `AnimalDao` - CRUD de animais
2. `MedicationDao` - CRUD de medicamentos
3. `VaccineDao` - CRUD de vacinas
4. `AppointmentDao` - CRUD de consultas
5. `WeightDao` - CRUD de peso
6. `ExpenseDao` - CRUD de despesas
7. `ReminderDao` - CRUD de lembretes
8. `CalculatorDao` - CRUD de histórico de cálculos
9. `PromoDao` - CRUD de conteúdo promocional

**Padrão dos DAOs:**
- ✅ Extends `BaseDriftDao<TTable, TData>` do core
- ✅ Implementa operações CRUD com soft delete
- ✅ Streams reativos para UI (`watch()`)
- ✅ Marca `isDirty = true` em operações de escrita
- ✅ Filtra `isDeleted = false` em leituras

**Status:** ✅ **COMPLETO**

---

### **3. Sync Adapters**

#### ⚠️ **Adapters Implementados mas COM ERROS**

Os adapters estão criados mas apresentam erros de implementação:

**Arquivos com problemas:**
1. ❌ `animal_drift_sync_adapter.dart`
2. ❌ `appointment_drift_sync_adapter.dart`
3. ❌ `expense_drift_sync_adapter.dart`
4. ❌ `medication_drift_sync_adapter.dart`
5. ❌ `promo_content_drift_sync_adapter.dart`
6. ❌ `reminder_drift_sync_adapter.dart`
7. ❌ `vaccine_drift_sync_adapter.dart`
8. ❌ `weight_record_drift_sync_adapter.dart`

**Problemas Identificados:**

1. **Erro de conversão de Entities:**
   - `SyncAnimalEntity` não implementa método `toAnimal()`
   - `SyncAppointmentEntity` não implementa método `toAppointment()`
   - Pattern incorreto de conversão Entity → DriftData

2. **Falta de implementação de métodos:**
   ```dart
   @override
   Future<SyncAnimalEntity> toSyncEntity(Animal data) async {
     // ❌ Não implementado corretamente
   }
   
   @override
   Future<Animal> fromSyncEntity(SyncAnimalEntity entity) async {
     // ❌ Chamando entity.toAnimal() que não existe
   }
   ```

**Referência Correta (gasometer):**
```dart
// Em gasometer, os sync adapters são simples:
class SubscriptionDriftSyncAdapter 
    extends DriftSyncAdapter<UserSubscription, UserSubscriptionsCompanion> {
  
  final PetivetiDatabase db;
  
  SubscriptionDriftSyncAdapter(this.db);

  @override
  String get collectionPath => 'subscriptions';
  
  @override
  Future<void> upsertLocal(UserSubscriptionsCompanion companion) async {
    await db.into(db.userSubscriptions).insertOnConflictUpdate(companion);
  }
  
  @override
  Future<void> deleteLocal(String firebaseId) async {
    await (db.delete(db.userSubscriptions)
      ..where((t) => t.firebaseId.equals(firebaseId))).go();
  }
  
  @override
  UserSubscriptionsCompanion toCompanion(Map<String, dynamic> data) {
    return UserSubscriptionsCompanion(
      firebaseId: Value(data['id'] as String),
      userId: Value(data['userId'] as String),
      // ... outros campos
    );
  }
}
```

**Status:** ❌ **INCOMPLETO** - Precisa refatoração completa

---

### **4. Sync Entities**

#### ❌ **Entities com Problemas**

**Arquivos:**
- `sync_animal_entity.dart`
- `sync_appointment_entity.dart`
- Outros entities similares

**Problema:**
As entities estão tentando ter métodos de conversão para tipos Drift, mas isso viola a separação de responsabilidades:

```dart
// ❌ ERRADO (atual)
class SyncAnimalEntity {
  Animal toAnimal() { ... } // Entity não deve conhecer Drift
}

// ✅ CORRETO (padrão)
// Entities devem ser apenas DTOs puros
class SyncAnimalEntity {
  final String id;
  final String userId;
  final String name;
  // ...
  
  Map<String, dynamic> toJson() { ... }
  factory SyncAnimalEntity.fromJson(Map<String, dynamic> json) { ... }
}
```

**Status:** ❌ **INCOMPLETO** - Precisa simplificação

---

### **5. UnifiedSyncManager**

#### ⚠️ **Status: Implementado mas NÃO HABILITADO**

**Arquivo:** `lib/database/providers/unified_sync_manager_provider.dart`

**Situação Atual:**
- ✅ Provider criado
- ✅ Estrutura básica implementada
- ❌ Adapters não registrados corretamente
- ❌ Não está sendo inicializado no app
- ❌ Sem listeners de conectividade
- ❌ Sem auto-sync periódico

**Referência (gasometer):**
```dart
@riverpod
UnifiedSyncManager unifiedSyncManager(UnifiedSyncManagerRef ref) {
  final db = ref.watch(gasometerDatabaseProvider);
  final firebase = ref.watch(firebaseFirestoreProvider);
  final auth = ref.watch(firebaseAuthServiceProvider);
  
  final manager = UnifiedSyncManager(
    firestore: firebase,
    getAuthToken: () async => await auth.currentUser?.getIdToken(),
  );
  
  // Registrar adapters
  manager.registerAdapter(VehicleDriftSyncAdapter(db));
  manager.registerAdapter(FuelSupplyDriftSyncAdapter(db));
  // ...
  
  return manager;
}
```

**O que falta:**
1. Registrar todos os 8 adapters
2. Inicializar no app startup
3. Configurar auto-sync
4. Adicionar listeners de conectividade

**Status:** ❌ **INCOMPLETO** - Precisa ativação

---

## 📋 CHECKLIST DE CORREÇÕES NECESSÁRIAS

### **Prioridade ALTA (Bloqueantes)**

- [ ] **1. Refatorar Sync Entities**
  - Remover métodos de conversão para Drift
  - Manter apenas `toJson()` e `fromJson()`
  - Tornar entities DTOs puros

- [ ] **2. Corrigir Sync Adapters**
  - Implementar conversão correta em `toCompanion()`
  - Remover dependência de métodos inexistentes
  - Seguir padrão do gasometer

- [ ] **3. Habilitar UnifiedSyncManager**
  - Registrar todos os adapters
  - Inicializar no app startup
  - Configurar auto-sync

### **Prioridade MÉDIA**

- [ ] **4. Adicionar Queries Úteis no Database**
  - Métodos auxiliares como `getAnimalsByUser()`
  - Streams reativos `watchAnimalsByUser()`
  - Queries agregadas (totais, médias)

- [ ] **5. Implementar Batch Operations**
  - Soft delete em lote
  - Clear user data
  - Export/Import de dados

### **Prioridade BAIXA**

- [ ] **6. Otimizações**
  - Índices compostos para queries frequentes
  - Índices em `firebaseId` para sync rápido
  - Índices em `userId` para multi-tenancy

---

## 🎯 PLANO DE AÇÃO RECOMENDADO

### **Fase 1: Corrigir Fundação (1-2 dias)**

1. **Simplificar Sync Entities**
   ```dart
   // Remover métodos de conversão
   // Manter apenas toJson/fromJson
   ```

2. **Refatorar todos os 8 Sync Adapters**
   ```dart
   // Seguir padrão simples do gasometer
   // Usar toCompanion() para conversão
   ```

### **Fase 2: Habilitar Sincronização (1 dia)**

1. **Configurar UnifiedSyncManager**
   ```dart
   // Registrar adapters
   // Inicializar no app
   ```

2. **Testar Sync Manual**
   ```dart
   // Criar animal → verificar Firebase
   // Modificar animal → verificar sync
   // Deletar animal → soft delete
   ```

### **Fase 3: Auto-Sync e Polimento (1 dia)**

1. **Configurar Auto-Sync**
   - Listeners de conectividade
   - Sync periódico (a cada X minutos)
   - Sync on app resume

2. **Adicionar Queries Úteis**
   - Métodos helper no database
   - Streams para UI reativa

---

## 📊 COMPARAÇÃO: Petiveti vs Gasometer

| Componente | Gasometer | Petiveti | Status |
|------------|-----------|----------|--------|
| Database Setup | ✅ Completo | ✅ Completo | ✅ OK |
| Tabelas com Sync Fields | ✅ 9 tabelas | ✅ 10 tabelas | ✅ OK |
| DAOs | ✅ Funcionais | ✅ Funcionais | ✅ OK |
| Sync Entities | ✅ DTOs puros | ❌ Com métodos drift | ❌ CORRIGIR |
| Sync Adapters | ✅ Simples | ❌ Com erros | ❌ CORRIGIR |
| UnifiedSyncManager | ✅ Habilitado | ❌ Não habilitado | ❌ HABILITAR |
| Queries Úteis | ✅ 15+ métodos | ⚠️ 5 métodos | ⚠️ EXPANDIR |
| Migrations | ✅ v1→v4 | ✅ v1→v2 | ✅ OK |

---

## 💡 CONCLUSÃO

### **Pontos Positivos:**
1. ✅ Estrutura base do Drift está **correta e completa**
2. ✅ Todas as tabelas têm campos de sync necessários
3. ✅ DAOs implementados seguindo o padrão do core
4. ✅ Migrations funcionando corretamente

### **Pontos de Atenção:**
1. ❌ Sync Adapters com **erros de implementação**
2. ❌ Sync Entities com **design incorreto**
3. ❌ UnifiedSyncManager **não habilitado**
4. ⚠️ Falta de queries auxiliares no database

### **Esforço Estimado para Correção:**
- **Tempo Total:** 3-4 dias
- **Complexidade:** Média
- **Risco:** Baixo (padrão já estabelecido no gasometer)

### **Próximos Passos:**
1. 🔴 **URGENTE:** Corrigir Sync Adapters e Entities
2. 🟡 **IMPORTANTE:** Habilitar UnifiedSyncManager
3. 🟢 **MELHORIA:** Adicionar queries auxiliares

---

**Relatório gerado em:** 2025-12-14T18:03:00Z
**Autor:** Claude Code (Drift Sync Analysis)
