# Implementação do Sistema de Sincronização - ReceitaAgro

## Status: ✅ IMPLEMENTADO E ATIVADO

Data: Janeiro 2025

---

## 📋 Resumo

Implementado sistema de sincronização bidirecional (local ↔ Firebase) para tabelas de dados de usuário no app ReceitaAgro usando Drift como banco de dados local.

### Tabelas Sincronizadas

1. **Favoritos** - Itens marcados como favoritos pelo usuário
2. **Comentários** - Comentários adicionados em defensivos, pragas, culturas
3. **AppSettings** - Configurações do aplicativo (tema, idioma, notificações, etc.)

---

## 🏗️ Arquitetura

### Componentes Principais

#### 1. ReceituagroDriftStorageAdapter
**Localização:** `lib/core/sync/receituagro_drift_storage_adapter.dart`

**Função:** Adapter que traduz entre as tabelas Drift específicas do ReceitaAgro e o sistema de sync genérico do UnifiedSyncManager.

**Características:**
- Implementa `ILocalStorageRepository` do core package
- Roteia operações para as tabelas corretas (favoritos, comentarios, app_settings)
- Converte entidades Drift ↔ Maps para sync
- Métodos implementados:
  - ✅ `save()` - Salvar registro local
  - ✅ `get()` - Obter registro por firebaseId
  - ✅ `getValues()` - Obter todos os registros
  - ✅ `remove()` - Deletar registro
  - ✅ `clear()` - Limpar tabela
  - ⚠️ Outros métodos: Stubs (não usados pelo sync)

**Mapeamentos por Tabela:**

```dart
// FAVORITOS
Map<String, dynamic> _favoritoToMap(Favorito favorito) {
  return {
    'id': favorito.id,
    'firebaseId': favorito.firebaseId,
    'userId': favorito.userId,
    'moduleName': favorito.moduleName,
    'tipo': favorito.tipo,
    'itemId': favorito.itemId,
    'itemData': favorito.itemData,
    // Campos de sync
    'createdAt': favorito.createdAt.toIso8601String(),
    'updatedAt': favorito.updatedAt?.toIso8601String(),
    'lastSyncAt': favorito.lastSyncAt?.toIso8601String(),
    'isDirty': favorito.isDirty,
    'isDeleted': favorito.isDeleted,
    'version': favorito.version,
  };
}

// COMENTARIOS
Map<String, dynamic> _comentarioToMap(Comentario comentario) {
  return {
    'id': comentario.id,
    'firebaseId': comentario.firebaseId,
    'userId': comentario.userId,
    'moduleName': comentario.moduleName,
    'itemId': comentario.itemId,
    'texto': comentario.texto,
    // Campos de sync
    'createdAt': comentario.createdAt.toIso8601String(),
    'updatedAt': comentario.updatedAt?.toIso8601String(),
    'lastSyncAt': comentario.lastSyncAt?.toIso8601String(),
    'isDirty': comentario.isDirty,
    'isDeleted': comentario.isDeleted,
    'version': comentario.version,
  };
}

// APP SETTINGS
Map<String, dynamic> _appSettingsToMap(AppSetting settings) {
  return {
    'id': settings.id,
    'firebaseId': settings.firebaseId,
    'userId': settings.userId,
    'moduleName': settings.moduleName,
    // Campos específicos
    'theme': settings.theme,
    'language': settings.language,
    'enableNotifications': settings.enableNotifications,
    'enableSync': settings.enableSync,
    'featureFlags': settings.featureFlags,
    // Campos de sync
    'createdAt': settings.createdAt.toIso8601String(),
    'updatedAt': settings.updatedAt?.toIso8601String(),
    'lastSyncAt': settings.lastSyncAt?.toIso8601String(),
    'isDirty': settings.isDirty,
    'isDeleted': settings.isDeleted,
    'version': settings.version,
  };
}
```

#### 2. ReceitaAgroSyncConfig
**Localização:** `lib/core/sync/receituagro_sync_config.dart`

**Função:** Configuração do UnifiedSyncManager para o app ReceitaAgro.

**Entidades Registradas:**
```dart
EntitySyncRegistration<FavoritoSyncEntity>.simple(
  entityType: FavoritoSyncEntity,
  collectionName: 'favoritos',
  fromMap: _favoritoFromFirebaseMap,
  toMap: _favoritoToFirebaseMap,
),
EntitySyncRegistration<ComentarioSyncEntity>.simple(
  entityType: ComentarioSyncEntity,
  collectionName: 'comentarios',
  fromMap: _comentarioFromFirebaseMap,
  toMap: _comentarioToFirebaseMap,
),
EntitySyncRegistration<UserSettingsSyncEntity>.simple(
  entityType: UserSettingsSyncEntity,
  collectionName: 'user_settings',
  fromMap: _userSettingsFromFirebaseMap,
  toMap: _userSettingsToFirebaseMap,
),
```

**Configurações:**
- Sync a cada 2 minutos
- Estratégia de conflito: timestamp (mais recente vence)
- Orquestração desabilitada (sync independente)

#### 3. Injection Container
**Localização:** `lib/core/di/injection_container.dart`

**Modificação:** Registra `ReceituagroDriftStorageAdapter` ao invés do genérico `DriftStorageService`:

```dart
sl.registerLazySingleton<core.ILocalStorageRepository>(
  () => ReceituagroDriftStorageAdapter(sl<ReceituagroDatabase>()),
);
```

---

## 🗄️ Estrutura das Tabelas Drift

Todas as tabelas de sync têm a mesma estrutura base de campos:

```dart
// Campos de identificação
IntColumn id; // Auto incremento, primary key
TextColumn firebaseId nullable; // ID no Firebase Firestore
TextColumn userId; // ID do usuário dono do registro
TextColumn moduleName default 'receituagro';

// Campos de sync
DateTimeColumn createdAt default now;
DateTimeColumn updatedAt nullable;
DateTimeColumn lastSyncAt nullable;
BoolColumn isDirty default true; // Marcador de "precisa sincronizar"
BoolColumn isDeleted default false; // Soft delete
IntColumn version default 1; // Versionamento para conflitos

// + Campos específicos da entidade
```

### Favoritos
```dart
TextColumn tipo; // 'fitossanitario', 'praga', 'cultura', etc.
TextColumn itemId; // ID do item favoritado
TextColumn itemData; // JSON com dados extras
```

### Comentarios
```dart
TextColumn itemId; // ID do item comentado
TextColumn texto; // Texto do comentário
```

### AppSettings
```dart
TextColumn theme default 'system'; // 'light', 'dark', 'system'
TextColumn language default 'pt'; // 'pt', 'en', 'es'
BoolColumn enableNotifications default true;
BoolColumn enableSync default true;
TextColumn featureFlags default '{}'; // JSON de feature flags
```

---

## 🔄 Fluxo de Sincronização

### 1. Inicialização (main.dart)

```dart
await ReceitaAgroSyncConfig.configure();
SyncDIModule.init(di.sl);
await SyncDIModule.initializeSyncService(di.sl);
await ReceitaAgroRealtimeService.instance.initialize();
```

### 2. Operação Local → Firebase

#### Passo a Passo:

1. **Usuário cria/edita um favorito:**
   ```dart
   // FavoritoRepository (via Drift)
   await db.into(db.favoritos).insert(
     FavoritosCompanion(
       userId: Value(currentUserId),
       tipo: Value('fitossanitario'),
       itemId: Value('123'),
       isDirty: Value(true), // ← Marca para sync
     ),
   );
   ```

2. **Adapter detecta registro dirty:**
   - `ReceituagroDriftStorageAdapter.save()` salva no Drift
   - Campo `isDirty=true` indica que precisa ser sincronizado

3. **UnifiedSyncManager detecta mudanças:**
   - Timer periódico (2 minutos) ou sync manual
   - Busca registros com `isDirty=true`

4. **Sync para Firebase:**
   - Converte Drift entity → Map via `_favoritoToMap()`
   - Converte Map → SyncEntity via `_favoritoFromFirebaseMap()`
   - Envia para Firebase Firestore collection `favoritos`
   - Atualiza registro local:
     - `isDirty = false`
     - `lastSyncAt = now`
     - `firebaseId = documentId`

### 3. Operação Firebase → Local

#### Passo a Passo:

1. **Firebase Firestore notifica mudança** (via listeners ou pull)

2. **UnifiedSyncManager recebe dados:**
   - Firebase Map → `_favoritoFromFirebaseMap()` → `FavoritoSyncEntity`

3. **Adapter salva localmente:**
   - `ReceituagroDriftStorageAdapter.save()`
   - `FavoritoSyncEntity` → Map → Drift `FavoritosCompanion`
   - Insert/update no banco Drift local
   - Marca `isDirty=false` (já está sincronizado)
   - Atualiza `lastSyncAt`

### 4. Resolução de Conflitos

**Estratégia:** `ConflictStrategy.timestamp` (mais recente vence)

```dart
if (firebase.updatedAt > local.updatedAt) {
  // Firebase é mais recente → sobrescrever local
  await adapter.save(firebaseData);
} else {
  // Local é mais recente → enviar para Firebase
  await firebaseService.update(localData);
}
```

**Versionamento:** Campo `version` incrementa a cada modificação para detectar conflitos concorrentes.

---

## 🧪 Testando o Sistema

### Teste 1: Criar Favorito e Sincronizar

```dart
// 1. Criar favorito local
await favoritoRepository.create(
  userId: 'user123',
  tipo: 'fitossanitario',
  itemId: '456',
  itemData: jsonEncode({'nome': 'Glifosato'}),
);

// 2. Verificar se foi marcado como dirty
final favorito = await favoritoRepository.getById(id);
expect(favorito.isDirty, true);

// 3. Executar sync
await UnifiedSyncManager.instance.syncNow('receituagro');

// 4. Verificar se foi sincronizado
final favoritoSynced = await favoritoRepository.getById(id);
expect(favoritoSynced.isDirty, false);
expect(favoritoSynced.firebaseId, isNotNull);
expect(favoritoSynced.lastSyncAt, isNotNull);
```

### Teste 2: Receber Mudança do Firebase

```dart
// 1. Criar favorito direto no Firebase
await FirebaseFirestore.instance.collection('favoritos').add({
  'userId': 'user123',
  'tipo': 'praga',
  'itemId': '789',
  'createdAt': Timestamp.now(),
  'isDirty': false,
});

// 2. Executar sync
await UnifiedSyncManager.instance.syncNow('receituagro');

// 3. Verificar se foi salvo localmente
final favoritos = await favoritoRepository.getAll();
final novoFavorito = favoritos.firstWhere((f) => f.itemId == '789');
expect(novoFavorito, isNotNull);
expect(novoFavorito.isDirty, false);
```

### Teste 3: Edição Offline + Sync Posterior

```dart
// 1. Desconectar internet
await setNetworkEnabled(false);

// 2. Editar favorito
await favoritoRepository.update(
  id: favoritoId,
  itemData: jsonEncode({'nome': 'Novo Nome'}),
);

// 3. Verificar que foi marcado como dirty
final favorito = await favoritoRepository.getById(favoritoId);
expect(favorito.isDirty, true);

// 4. Reconectar e sincronizar
await setNetworkEnabled(true);
await UnifiedSyncManager.instance.syncNow('receituagro');

// 5. Verificar que foi sincronizado
final favoritoSynced = await favoritoRepository.getById(favoritoId);
expect(favoritoSynced.isDirty, false);

// 6. Verificar no Firebase
final doc = await FirebaseFirestore.instance
    .collection('favoritos')
    .doc(favoritoSynced.firebaseId)
    .get();
expect(doc.data()['itemData'], contains('Novo Nome'));
```

---

## 🚨 Problemas Resolvidos

### ❌ Problema Original: "no such column: value"

**Causa:** O `DriftStorageService` genérico do core package esperava tabelas com estrutura key-value:
```sql
CREATE TABLE favoritos (
  key TEXT PRIMARY KEY,
  value TEXT  -- JSON serializado
);
```

Mas as tabelas Drift do ReceitaAgro têm estrutura normalizada:
```sql
CREATE TABLE favoritos (
  id INTEGER PRIMARY KEY,
  firebase_id TEXT,
  user_id TEXT,
  tipo TEXT,
  item_id TEXT,
  item_data TEXT,
  is_dirty BOOLEAN,
  ...
);
```

**SQL gerado pelo DriftStorageService:**
```sql
SELECT value FROM favoritos WHERE key = ?  -- ❌ ERRO: column 'value' not found
```

### ✅ Solução: ReceituagroDriftStorageAdapter

Criamos um adapter específico que:
1. Entende a estrutura das tabelas Drift do ReceitaAgro
2. Mapeia operações genéricas para queries específicas
3. Implementa a interface `ILocalStorageRepository` esperada pelo sync

**Queries corretas geradas:**
```sql
-- Salvar favorito
INSERT INTO favoritos (firebase_id, user_id, tipo, item_id, ...) VALUES (?, ?, ?, ?, ...);

-- Obter favorito por firebaseId
SELECT * FROM favoritos WHERE firebase_id = ?;

-- Obter todos os favoritos
SELECT * FROM favoritos;
```

---

## 📊 Monitoramento e Debug

### Logs de Sync

O UnifiedSyncManager emite logs detalhados:

```dart
developer.log('Initializing unified sync for app: receituagro', name: 'UnifiedSync');
developer.log('App receituagro initialized with 3 entities', name: 'UnifiedSync');
developer.log('Syncing entity: favoritos', name: 'UnifiedSync');
```

### Status de Sync

```dart
final status = await UnifiedSyncManager.instance.getAppSyncStatus('receituagro');
print('Status: ${status.state}'); // idle, syncing, error, offline
print('Last sync: ${status.lastSyncAt}');
print('Pending: ${status.pendingCount}');
```

### Verificar Registros Pendentes

```dart
// Query direto no Drift
final pendentes = await db.select(db.favoritos)
  .where((f) => f.isDirty.equals(true))
  .get();
  
print('Favoritos pendentes de sync: ${pendentes.length}');
```

---

## 🔮 Próximos Passos (Opcional)

### 1. Adicionar Mais Tabelas

Para sincronizar outras tabelas (ex: Subscriptions, UserHistory):

1. Adicionar suporte no `ReceituagroDriftStorageAdapter`:
```dart
case 'subscriptions':
  return await _saveSubscription(key, data);
```

2. Adicionar entity registration em `ReceitaAgroSyncConfig`:
```dart
EntitySyncRegistration<SubscriptionSyncEntity>.simple(
  entityType: SubscriptionSyncEntity,
  collectionName: 'subscriptions',
  fromMap: _subscriptionFromFirebaseMap,
  toMap: _subscriptionToFirebaseMap,
),
```

### 2. Melhorar Performance

- **Batch Sync:** Sincronizar múltiplos registros em uma única operação
- **Sync Seletivo:** Sincronizar apenas tipos específicos de entidades
- **Compression:** Comprimir dados antes de enviar para Firebase

### 3. Funcionalidades Avançadas

- **Conflict Resolution UI:** Interface para usuário resolver conflitos manualmente
- **Sync History:** Histórico de sincronizações realizadas
- **Retry Strategy:** Tentativas automáticas em caso de falha
- **Background Sync:** Sincronizar em background via WorkManager

---

## 📚 Referências

- **Drift Documentation:** https://drift.simonbinder.eu/
- **Firebase Firestore:** https://firebase.google.com/docs/firestore
- **Core Package Sync:** `/packages/core/lib/src/sync/unified_sync_manager.dart`
- **GetIt Dependency Injection:** https://pub.dev/packages/get_it

---

## ✅ Checklist de Implementação

- [x] Criar `ReceituagroDriftStorageAdapter`
- [x] Implementar métodos essenciais (save, get, getValues, remove, clear)
- [x] Mapear conversões Drift Entity ↔ Map para cada tabela
- [x] Registrar adapter no GetIt (`injection_container.dart`)
- [x] Ativar sync em `ReceitaAgroSyncConfig.configure()`
- [x] Verificar chamada do sync no `main.dart`
- [x] Testar compilação sem erros
- [ ] Testar sync manual (criar favorito → verificar no Firebase)
- [ ] Testar sync bidirecional (Firebase → Local)
- [ ] Testar resolução de conflitos
- [ ] Testar modo offline + sync posterior
- [ ] Documentar uso para desenvolvedores

---

**Status Final:** ✅ Implementação completa e pronta para testes
**Próximo Passo:** Testes manuais e validação do fluxo de sync
