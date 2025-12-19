# 🔄 Firebase Sync Implementation - App Nebulalist

## ✅ Implementação Completa

### 📋 Resumo
Implementação de sincronização bidirecional Firebase/Drift seguindo o padrão do app-plantis, com suporte offline-first e resolução de conflitos.

---

## 🏗️ Estrutura Criada

### **1. Domain Layer** (`features/sync/domain/`)
```
domain/
├── entities/
│   ├── sync_status.dart          # Status de sincronização (pending, syncing, synced, error)
│   └── conflict_resolution.dart  # Estratégias de resolução (server_wins, client_wins, merge)
└── repositories/
    └── sync_repository.dart      # Interface para sincronização
```

**Entidades:**
- `SyncStatus`: Rastreia estado de sincronização de cada entidade
- `ConflictResolution`: Define estratégias para resolver conflitos

---

### **2. Data Layer** (`features/sync/data/`)
```
data/
├── models/
│   └── sync_metadata_model.dart  # Modelo de metadados (lastSyncAt, version, hash)
├── datasources/
│   └── sync_metadata_local_data_source.dart  # Armazenamento local de metadados
├── repositories/
│   └── sync_repository_impl.dart  # Implementação do repositório
└── services/
    ├── task_sync_service.dart     # Sincronização de Tasks
    └── list_sync_service.dart     # Sincronização de Lists
```

**Componentes:**

#### **SyncMetadataModel**
Armazena metadados de sincronização:
- `entityId`: ID da entidade
- `entityType`: Tipo (task, list, etc)
- `lastSyncedAt`: Timestamp da última sincronização
- `version`: Versão da entidade
- `hash`: Hash para detecção de mudanças

#### **TaskSyncService**
Responsável por sincronizar Tasks:
- `syncAll()`: Sincroniza todas as tasks
- `syncTask(taskId)`: Sincroniza uma task específica
- `_pushToFirebase()`: Envia mudanças locais
- `_pullFromFirebase()`: Baixa mudanças remotas
- `_resolveConflict()`: Resolve conflitos (última atualização vence)

#### **ListSyncService**
Responsável por sincronizar Lists:
- Mesma estrutura do TaskSyncService
- Sincroniza listas antes das tasks (dependência)

---

### **3. Presentation Layer** (`features/sync/presentation/`)
```
presentation/
└── providers/
    └── sync_providers.dart       # Riverpod providers
```

**Providers:**

```dart
@riverpod
TaskSyncService taskSyncService(ref) { ... }

@riverpod
ListSyncService listSyncService(ref) { ... }

@riverpod
class SyncState extends _$SyncState {
  Future<void> syncAll() async { ... }
  Future<void> syncTasks() async { ... }
  Future<void> syncLists() async { ... }
}

@riverpod
class AutoSync extends _$AutoSync {
  void enable() { ... }  // Ativa sync automático (5 em 5 min)
  void disable() { ... } // Desativa sync automático
}
```

---

### **4. Core Integration** (`core/widgets/`)
```
widgets/
└── auth_sync_listener.dart       # Listener de autenticação
```

**AuthSyncListener:**
- Monitora mudanças no estado de autenticação
- Inicia sincronização automática ao fazer login
- Para sincronização ao fazer logout
- Reinicia sincronização ao trocar de usuário

---

## 🔄 Fluxo de Sincronização

### **1. Login do Usuário**
```
User Login → AuthSyncListener detecta → 
  → AutoSync.enable() → 
  → SyncState.syncAll() →
    → ListSyncService.syncAll() → 
    → TaskSyncService.syncAll()
```

### **2. Sincronização Automática**
```
A cada 5 minutos:
  → AutoSync verifica se está ativo →
  → SyncState.syncAll() →
  → Sincroniza Lists →
  → Sincroniza Tasks
```

### **3. Sincronização de Task**
```
TaskSyncService.syncTask(taskId):
  1. Busca task local (Drift)
  2. Busca metadados de sync
  3. Busca task remota (Firebase)
  4. Compara timestamps/versões
  5. Resolve conflito se necessário
  6. Atualiza local ou remoto
  7. Salva metadados
```

### **4. Resolução de Conflitos**
```
Estratégia: Last-Write-Wins
  - Compara `updatedAt` local vs remoto
  - Versão mais recente vence
  - Atualiza a outra fonte
  - Incrementa version
  - Atualiza hash
```

---

## 📊 Comparação com app-plantis

| Aspecto | app-plantis | app-nebulalist |
|---------|-------------|----------------|
| **Entidades Sync** | Plants, Reminders | Tasks, Lists |
| **Storage Local** | Drift | Drift ✅ |
| **Storage Remoto** | Firestore | Firestore ✅ |
| **Conflict Resolution** | Last-Write-Wins | Last-Write-Wins ✅ |
| **Auto-sync** | Sim (5 min) | Sim (5 min) ✅ |
| **Auth Listener** | Sim | Sim ✅ |
| **Offline-first** | Sim | Sim ✅ |
| **Metadata Tracking** | Sim | Sim ✅ |

---

## 🎯 Próximos Passos

### **Fase 5.1: Testes de Integração** ⏳
- [ ] Testar sync de Tasks
- [ ] Testar sync de Lists
- [ ] Testar resolução de conflitos
- [ ] Testar cenários offline

### **Fase 5.2: UI de Sincronização** ⏳
- [ ] Indicador de sync na UI
- [ ] Botão manual de sync
- [ ] Exibir status de sincronização
- [ ] Feedback visual de erros

### **Fase 5.3: Otimizações** ⏳
- [ ] Sync incremental (apenas mudanças)
- [ ] Batch sync (múltiplas entidades)
- [ ] Retry com backoff exponencial
- [ ] Queue de operações offline

### **Fase 6: Firebase Rules** ⏳
- [ ] Regras de segurança para Tasks
- [ ] Regras de segurança para Lists
- [ ] Validação de schema
- [ ] Rate limiting

---

## 🔐 Segurança

### **Firebase Rules Sugeridas**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Tasks collection
    match /users/{userId}/tasks/{taskId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Lists collection
    match /users/{userId}/lists/{listId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 📝 Uso

### **Sincronizar Manualmente**
```dart
// Sincronizar tudo
await ref.read(syncStateProvider.notifier).syncAll();

// Sincronizar apenas tasks
await ref.read(syncStateProvider.notifier).syncTasks();

// Sincronizar apenas lists
await ref.read(syncStateProvider.notifier).syncLists();
```

### **Controlar Auto-sync**
```dart
// Ativar auto-sync
ref.read(autoSyncProvider.notifier).enable();

// Desativar auto-sync
ref.read(autoSyncProvider.notifier).disable();

// Verificar status
final isAutoSyncEnabled = ref.watch(autoSyncProvider);
```

### **Monitorar Estado de Sync**
```dart
final syncState = ref.watch(syncStateProvider);

syncState.when(
  data: (_) => Text('Sincronizado'),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Erro: $error'),
);
```

---

## ✅ Checklist de Implementação

### **Domain Layer** ✅
- [x] SyncStatus entity
- [x] ConflictResolution enum
- [x] SyncRepository interface

### **Data Layer** ✅
- [x] SyncMetadataModel
- [x] SyncMetadataLocalDataSource
- [x] SyncRepositoryImpl
- [x] TaskSyncService
- [x] ListSyncService

### **Presentation Layer** ✅
- [x] sync_providers.dart
- [x] SyncState provider
- [x] AutoSync provider

### **Core Integration** ✅
- [x] AuthSyncListener widget
- [x] Integração no app.dart

### **Próximos Passos** ⏳
- [ ] Gerar código Riverpod (`build_runner`)
- [ ] Implementar UI de sync
- [ ] Testes de integração
- [ ] Firebase Rules

---

## 🚀 Como Testar

1. **Gerar código Riverpod:**
```bash
cd apps/app-nebulalist
flutter pub run build_runner build --delete-conflicting-outputs
```

2. **Fazer login no app**
- O AuthSyncListener detectará automaticamente
- Sync será iniciado

3. **Criar/Editar Tasks offline**
- As mudanças serão salvas localmente (Drift)
- Quando conectar, serão enviadas ao Firebase

4. **Editar no Firebase diretamente**
- Na próxima sincronização, mudanças serão baixadas

5. **Testar conflitos**
- Editar mesma task offline e no Firebase
- Última atualização vencerá

---

## 📚 Referências

- **app-plantis**: Padrão base de sincronização
- **Drift**: Banco local SQLite
- **Firestore**: Backend Firebase
- **Riverpod**: State management

---

**Status:** ✅ Implementação completa - Pronto para testes
**Data:** 2025-12-19
