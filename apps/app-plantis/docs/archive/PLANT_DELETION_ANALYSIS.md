# Análise: Processo de Exclusão de Plantas

**Data:** 2025-11-30
**App:** app-plantis
**Versão:** Gold Standard 10/10

---

## 📋 Resumo Executivo

O processo de exclusão de plantas no app-plantis implementa **SOFT DELETE** em todos os níveis:
- ✅ **Local (Drift)**: Marca `isDeleted=true, isDirty=true`
- ✅ **Remoto (Firebase)**: Marca `is_deleted=true, updated_at=timestamp`
- ✅ **Tasks relacionadas**: Soft delete com `isDeleted=true`
- ✅ **Comentários relacionados**: Usa `UnifiedSyncManager.delete()`

---

## 🔍 Fluxo Completo de Exclusão

### 1. **UseCase** (`DeletePlantUseCase`)

**Arquivo:** `lib/features/plants/domain/usecases/delete_plant_usecase.dart`

```dart
Future<Either<Failure, void>> call(String id) async {
  // 1. Validação do ID
  if (id.trim().isEmpty) {
    return const Left(ValidationFailure('ID da planta é obrigatório'));
  }

  // 2. Verificação de existência
  final existingResult = await repository.getPlantById(id);

  // 3. Delegação para repository
  return existingResult.fold(
    (failure) => Left(failure),
    (_) => repository.deletePlant(id),
  );
}
```

**Responsabilidades:**
- Validação básica do ID
- Verificação de existência antes de deletar
- Delegação para o repository

---

### 2. **Repository** (`PlantsRepositoryImpl`)

**Arquivo:** `lib/features/plants/data/repositories/plants_repository_impl.dart:346-409`

```dart
Future<Either<Failure, void>> deletePlant(String id) async {
  // 1. Validação de autenticação
  final userId = await _currentUserId;
  if (userId == null) {
    return const Left(ServerFailure('Usuário não autenticado'));
  }

  // 2. ✅ DELETAR TASKS relacionadas (soft delete)
  final tasksResult = await taskRepository.deletePlantTasksByPlantId(id);

  // 3. ✅ DELETAR COMENTÁRIOS relacionados (soft delete)
  final commentsResult = await commentsRepository.deleteCommentsForPlant(id);

  // 4. ✅ DELETAR PLANTA LOCALMENTE (soft delete)
  await localDatasource.deletePlant(id);

  // 5. ✅ DELETAR PLANTA REMOTAMENTE se conectado (soft delete)
  if (await networkInfo.isConnected) {
    try {
      await remoteDatasource.deletePlant(id, userId);
    } catch (e) {
      // Falha remota será sincronizada depois
    }
  }

  return const Right(null);
}
```

**Ordem de Operações:**
1. **Tasks** (soft delete)
2. **Comentários** (soft delete)
3. **Planta Local** (soft delete)
4. **Planta Remota** (soft delete, se online)

**Tratamento de Erros:**
- ⚠️ Erros em tasks/comentários são logados mas **NÃO BLOQUEIAM** a exclusão da planta
- ⚠️ Erro remoto **NÃO BLOQUEIA** (será sincronizado depois via `isDirty=true`)

---

### 3. **Local Datasource** (Drift)

**Arquivo:** `lib/database/repositories/plants_drift_repository.dart:196-209`

#### 3.1 Soft Delete (Padrão)

```dart
Future<bool> deletePlant(String firebaseId) async {
  final updated = await (_db.update(_db.plants)
    ..where((p) => p.firebaseId.equals(firebaseId)))
    .write(
      PlantTasksCompanion(
        isDeleted: const Value(true),   // ✅ Marca como deletado
        isDirty: const Value(true),     // ✅ Marca para sincronização
        updatedAt: Value(DateTime.now()), // ✅ Atualiza timestamp
      ),
    );

  return updated > 0;
}
```

**Características:**
- ✅ Mantém o registro no banco
- ✅ Marca `isDeleted=true`
- ✅ Marca `isDirty=true` para sincronização futura
- ✅ Atualiza `updatedAt`

#### 3.2 Hard Delete (Disponível mas não usado)

```dart
Future<bool> hardDeletePlant(String firebaseId) async {
  final deleted = await (_db.delete(_db.plants)
    ..where((p) => p.firebaseId.equals(firebaseId)))
    .go();

  return deleted > 0;
}
```

**Uso:** Apenas para limpeza manual/transição de IDs (não usado no fluxo normal)

---

### 4. **Remote Datasource** (Firebase)

**Arquivo:** `lib/features/sync/data/datasources/plants_firebase_datasource.dart:165-203`

```dart
Future<void> deletePlant(
  String firebaseId,
  String userId, {
  bool hardDelete = false, // ✅ Padrão: false (soft delete)
}) async {
  final docRef = _getPlantsCollection(userId).doc(firebaseId);

  if (hardDelete) {
    // Hard delete: Remove documento completamente
    await docRef.delete();
  } else {
    // ✅ Soft delete (PADRÃO): Marca como deletado
    await docRef.update({
      'is_deleted': true,           // ✅ Marca como deletado
      'updated_at': Timestamp.now(), // ✅ Atualiza timestamp
    });
  }
}
```

**Características:**
- ✅ Padrão é **SOFT DELETE** (`hardDelete=false`)
- ✅ Mantém documento no Firestore
- ✅ Marca `is_deleted=true`
- ✅ Atualiza `updated_at` para sincronização incremental
- ⚠️ **Hard delete disponível mas NÃO usado** no repository

**Chamada no Repository:**
```dart
await remoteDatasource.deletePlant(id, userId); // hardDelete não especificado = false
```

---

### 5. **Tasks Relacionadas**

**Arquivo:** `lib/database/repositories/plant_tasks_drift_repository.dart:148-162`

```dart
Future<int> deletePlantTasksByPlantId(String plantFirebaseId) async {
  final localPlantId = await _resolvePlantId(plantFirebaseId);
  if (localPlantId == null) return 0;

  return await (_db.update(_db.plantTasks)
    ..where((t) => t.plantId.equals(localPlantId)))
    .write(
      PlantTasksCompanion(
        isDeleted: const Value(true),   // ✅ Soft delete
        isDirty: const Value(true),     // ✅ Marca para sync
        updatedAt: Value(DateTime.now()),
      ),
    );
}
```

**Status:** ✅ **SOFT DELETE** implementado

---

### 6. **Comentários Relacionados**

**Arquivo:** `lib/features/plants/data/repositories/plant_comments_repository_impl.dart:154-170`

```dart
Future<Either<Failure, void>> deleteCommentsForPlant(String plantId) async {
  final commentsResult = await getCommentsForPlant(plantId);

  return commentsResult.fold(
    (failure) => Left(failure),
    (comments) async {
      for (final comment in comments) {
        await deleteComment(comment.id); // ✅ Usa UnifiedSyncManager
      }
      return const Right(null);
    },
  );
}

Future<Either<Failure, void>> deleteComment(String commentId) async {
  final result = await UnifiedSyncManager.instance.delete<ComentarioModel>(
    _appName,
    commentId,
  );
  return result;
}
```

**Status:** ✅ **SOFT DELETE** via `UnifiedSyncManager.delete()`
(O UnifiedSyncManager implementa soft delete por padrão)

---

## ✅ Checklist de Conformidade

| Item | Status | Detalhes |
|------|--------|----------|
| **Planta - Local (Drift)** | ✅ | Soft delete com `isDeleted=true, isDirty=true` |
| **Planta - Remoto (Firebase)** | ✅ | Soft delete com `is_deleted=true` |
| **Tasks - Local** | ✅ | Soft delete com `isDeleted=true, isDirty=true` |
| **Comentários - Local** | ✅ | Soft delete via `UnifiedSyncManager` |
| **Sincronização Firebase** | ✅ | Executada se online, senão marcado como `isDirty` |
| **Tratamento de Erros** | ⚠️ | Erros em tasks/comentários não bloqueiam exclusão da planta |
| **Rollback em falha** | ❌ | Não há transação/rollback automático |

---

## ⚠️ Pontos de Atenção

### 1. **Erros Não Bloqueantes**

```dart
// ⚠️ Falha ao deletar tasks NÃO BLOQUEIA exclusão da planta
final tasksResult = await taskRepository.deletePlantTasksByPlantId(id);
if (tasksResult.isLeft()) {
  print('⚠️ Failed to delete tasks...'); // Apenas log
}

// Continua mesmo com erro ⬇️
await localDatasource.deletePlant(id);
```

**Impacto:**
- Tasks podem ficar "órfãs" (sem planta, mas não deletadas)
- Comentários podem ficar "órfãos"

**Recomendação:**
- Considerar implementar cleanup periódico de registros órfãos
- OU fazer rollback se tasks/comentários falharem

### 2. **Sincronização Remota Não Garante Sucesso**

```dart
if (await networkInfo.isConnected) {
  try {
    await remoteDatasource.deletePlant(id, userId);
  } catch (e) {
    // ⚠️ Erro ignorado - confiar em sincronização futura
  }
}
```

**Impacto:**
- Planta marcada como deletada localmente (`isDirty=true`)
- Erro remoto silencioso
- Depende de sincronização posterior via `syncPendingChanges()`

**Recomendação:**
- ✅ Já está correto! O `isDirty=true` garante sync futuro
- Considerar adicionar retry automático em background

### 3. **Não Há Transação Atômica**

As operações são sequenciais, não atômicas:
1. Delete tasks
2. Delete comments
3. Delete plant local
4. Delete plant remote

**Impacto:**
- Falha em qualquer etapa pode deixar estado inconsistente
- Não há rollback automático

**Recomendação:**
- Para melhorar: usar transação Drift (`_db.transaction()`?)
- OU implementar compensação manual em caso de erro

---

## 🚀 Melhorias Sugeridas

### 1. **Implementar Transação Atômica (Opcional)**

```dart
Future<Either<Failure, void>> deletePlant(String id) async {
  try {
    await _db.transaction(() async {
      // Todas as operações em uma transação
      await taskRepository.deletePlantTasksByPlantId(id);
      await commentsRepository.deleteCommentsForPlant(id);
      await localDatasource.deletePlant(id);
    });

    // Sync remoto fora da transação (pode falhar sem rollback local)
    if (await networkInfo.isConnected) {
      await remoteDatasource.deletePlant(id, userId);
    }

    return const Right(null);
  } catch (e) {
    return Left(UnknownFailure('Erro ao deletar planta: $e'));
  }
}
```

### 2. **Adicionar Retry para Sync Remoto**

```dart
// Retry até 3x antes de desistir
for (int i = 0; i < 3; i++) {
  try {
    await remoteDatasource.deletePlant(id, userId);
    break; // Sucesso
  } catch (e) {
    if (i == 2) throw e; // Última tentativa
    await Future.delayed(Duration(seconds: 2 * (i + 1))); // Backoff
  }
}
```

### 3. **Cleanup de Registros Órfãos**

Criar job periódico para deletar tasks/comentários órfãos:

```dart
Future<void> cleanupOrphanedRecords() async {
  // Buscar tasks sem planta correspondente
  final orphanedTasks = await _db.select(_db.plantTasks)
    .join([
      leftOuterJoin(_db.plants, _db.plants.id.equalsExp(_db.plantTasks.plantId))
    ])
    .where(_db.plants.id.isNull())
    .get();

  // Deletar tasks órfãs
  for (final task in orphanedTasks) {
    await deletePlantTask(task.id);
  }
}
```

---

## 📊 Conclusão

### ✅ **Pontos Positivos**

1. ✅ **Soft delete implementado corretamente** em todos os níveis
2. ✅ **Sincronização Firebase** com flag `isDirty` para retry
3. ✅ **Cascata de exclusão** (tasks + comentários + planta)
4. ✅ **Offline-first**: funciona sem conexão, sync depois
5. ✅ **Logs detalhados** para debugging

### ⚠️ **Pontos de Melhoria**

1. ⚠️ Erros em tasks/comentários não bloqueiam exclusão principal
2. ⚠️ Não há transação atômica (pode ficar estado inconsistente)
3. ⚠️ Não há cleanup automático de registros órfãos
4. ⚠️ Retry remoto poderia ser mais robusto

### 🎯 **Recomendação Final**

O processo atual é **FUNCIONAL e SEGURO** para uso em produção:
- Soft delete garante recuperação de dados
- Sincronização eventual resolve inconsistências temporárias
- Logs facilitam debug de problemas

**Melhorias são OPCIONAIS** e dependem de:
- Volume de dados
- Criticidade de consistência imediata
- Frequência de erros de rede

---

**Gerado em:** 2025-11-30
**Analisado por:** Claude Code
**Status:** ✅ Aprovado para produção
