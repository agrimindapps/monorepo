# Estratégia de Sincronização - Monorepo Flutter

## 🎯 Decisão de Arquitetura

### Quando usar cada estratégia:

| Critério | Full Sync | Delta Sync |
|----------|-----------|------------|
| Registros por usuário | < 100 | > 100 |
| Frequência de updates | Baixa | Alta |
| Tamanho dos dados | Pequeno | Grande |
| Complexidade aceitável | Baixa | Alta |
| Offline-first crítico | Não | Sim |

---

## 📱 Apps do Monorepo

### **Full Sync** (Recomendado para apps simples)
- ✅ app-plantis (plantas, ~20-50 por usuário)
- ✅ app-petiveti (pets, ~1-10 por usuário)
- ✅ app-taskolist (tarefas, ~50-100 por usuário)
- ✅ app-nutrituti (refeições, limpeza periódica)

### **Delta Sync** (Para apps com muitos dados)
- ✅ app-gasometer (abastecimentos, manutenções, pode ter 1000+ registros)
- ✅ app-receituagro (defensivos, 3000+ registros estáticos)
- ✅ app-agrihurbi (dados agrícolas extensos)

---

## 🔧 Implementação Recomendada

### 1. Full Sync (Padrão Plantis)

```dart
class SimpleSyncService<T> {
  final LocalDatasource<T> local;
  final RemoteDatasource<T> remote;
  
  Future<void> sync(String userId) async {
    // 1. Pull: Baixa tudo do remoto
    final remoteData = await remote.getAll(userId);
    
    // 2. Merge: Atualiza local (upsert)
    for (final item in remoteData) {
      await local.upsert(item);
    }
    
    // 3. Push: Envia dirty locais
    final dirtyItems = await local.getDirty();
    for (final item in dirtyItems) {
      await remote.save(item);
      await local.markAsSynced(item.id);
    }
    
    // 4. Delete: Sincroniza exclusões
    final deletedIds = await local.getDeleted();
    for (final id in deletedIds) {
      await remote.delete(id);
      await local.hardDelete(id);
    }
  }
}
```

### 2. Delta Sync (Padrão Gasometer)

```dart
class DeltaSyncService<T extends BaseSyncEntity> {
  final DriftDatabase db;
  final FirebaseFirestore firestore;
  
  Future<void> sync(String userId) async {
    // 1. Get last sync timestamp
    final lastSync = await getLastSyncTimestamp(userId);
    
    // 2. Pull: Apenas mudanças recentes
    final query = firestore
        .collection('users/$userId/items')
        .where('updated_at', isGreaterThan: lastSync?.toIso8601String());
    
    final snapshot = await query.get();
    
    // 3. Resolve conflicts & merge
    for (final doc in snapshot.docs) {
      final remote = fromFirestore(doc.data());
      final local = await db.getById(remote.id);
      
      if (local != null) {
        final resolved = resolveConflict(local, remote);
        await db.upsert(resolved);
      } else {
        await db.insert(remote);
      }
    }
    
    // 4. Push dirty records
    final dirty = await db.getDirty(userId);
    await pushBatch(dirty);
    
    // 5. Update sync timestamp
    await saveLastSyncTimestamp(userId, DateTime.now());
  }
}
```

---

## 🚀 Sync após Login (CRÍTICO)

### Fluxo recomendado:

```dart
Future<void> onLoginSuccess(User user) async {
  // 1. Full sync inicial (primeira vez no dispositivo)
  if (!await hasLocalData(user.id)) {
    await fullSync(user.id); // Baixa TUDO
  } else {
    // 2. Delta sync (syncs subsequentes)
    await deltaSync(user.id); // Só mudanças
  }
  
  // 3. Notificar UI
  notifyListeners();
}
```

### Implementação no AuthNotifier:

```dart
void _triggerPostLoginSync() async {
  final userId = state.currentUser?.id;
  if (userId == null) return;
  
  final hasData = await _checkHasLocalData(userId);
  
  if (!hasData) {
    // Primeiro login neste dispositivo = Full Sync
    debugPrint('🔄 First login - performing FULL sync');
    await _performFullSync(userId);
  } else {
    // Login subsequente = Delta Sync
    debugPrint('🔄 Returning user - performing DELTA sync');
    await BackgroundSyncManager.instance.triggerSync(
      'gasometer',
      force: true,
    );
  }
}
```

---

## ⚠️ Índices Firestore (Delta Sync)

Para Delta Sync funcionar, você PRECISA dos índices:

```json
{
  "indexes": [
    {
      "collectionGroup": "vehicles",
      "queryScope": "COLLECTION",
      "fields": [{"fieldPath": "updated_at", "order": "ASCENDING"}]
    }
  ]
}
```

Deploy:
```bash
firebase deploy --only firestore:indexes --project PROJECT_ID
```

---

## 🔐 Resolução de Conflitos

### Estratégia padrão: Last Write Wins (LWW)

```dart
T resolveConflict<T extends BaseSyncEntity>(T local, T remote) {
  // 1. Se versões diferentes, maior vence
  if (local.version != remote.version) {
    return local.version > remote.version ? local : remote;
  }
  
  // 2. Se versões iguais, timestamp mais recente vence
  final localTime = local.updatedAt ?? local.createdAt;
  final remoteTime = remote.updatedAt ?? remote.createdAt;
  
  return localTime.isAfter(remoteTime) ? local : remote;
}
```

---

## 📊 Métricas de Sync

Monitore:
- Tempo médio de sync
- Quantidade de registros por sync
- Taxa de conflitos
- Erros de sync

```dart
analytics.logEvent('sync_completed', {
  'duration_ms': duration.inMilliseconds,
  'records_pulled': pullCount,
  'records_pushed': pushCount,
  'conflicts_resolved': conflictCount,
  'sync_type': isFullSync ? 'full' : 'delta',
});
```
