# 🗑️ Fluxo de Soft Delete - Plants Feature

**Feature**: plants  
**Atualizado**: 13/12/2025

---

## 📖 Visão Geral

O app-plantis implementa **soft delete** para todas as plantas, preservando dados para:
- ✅ Sincronização offline/online
- ✅ Auditoria e histórico
- ✅ Possível recuperação futura
- ✅ Integridade referencial (tasks e comentários relacionados)

---

## 🔄 Fluxo Completo

```
User Action → DeletePlantUseCase → PlantsRepository → Local + Remote
                                          ↓
                        Cascata: Tasks + Comentários (soft delete)
```

### 1️⃣ UseCase: `DeletePlantUseCase`

**Arquivo**: [domain/usecases/delete_plant_usecase.dart](../../lib/features/plants/domain/usecases/delete_plant_usecase.dart)

```dart
Future<Either<Failure, void>> call(String id) async {
  // 1. Valida ID
  // 2. Verifica existência
  // 3. Chama repository.deletePlant(id)
}
```

**Responsabilidade**: Validação e orquestração

---

### 2️⃣ Repository: `PlantsRepositoryImpl.deletePlant()`

**Arquivo**: [data/repositories/plants_repository_impl.dart](../../lib/features/plants/data/repositories/plants_repository_impl.dart) (linhas 346-409)

**Ordem de Operações**:

```dart
1. ✅ Validar autenticação (userId não pode ser null)
2. ✅ Deletar tasks relacionadas (soft delete via TasksRepository)
3. ✅ Deletar comentários relacionados (soft delete via CommentsRepository)
4. ✅ Deletar planta LOCAL (marca isDeleted=true, isDirty=true)
5. ✅ Deletar planta REMOTE se online (marca is_deleted=true no Firestore)
```

**Tratamento de Erros**:
- ⚠️ Falhas em tasks/comentários são **logadas mas NÃO BLOQUEIAM** a exclusão
- ⚠️ Falha remota **NÃO BLOQUEIA** (será sincronizada depois via isDirty=true)

---

### 3️⃣ Local Datasource: `PlantsDriftRepository`

**Arquivo**: [database/repositories/plants_drift_repository.dart](../../lib/database/repositories/plants_drift_repository.dart) (linhas 196-209)

#### Soft Delete (Padrão)

```dart
Future<bool> deletePlant(String firebaseId) async {
  return await (_db.update(_db.plants)
    ..where((p) => p.firebaseId.equals(firebaseId)))
    .write(
      PlantsCompanion(
        isDeleted: const Value(true),      // Marca como deletado
        isDirty: const Value(true),        // Marca para sync
        updatedAt: Value(DateTime.now()), // Timestamp
      ),
    );
}
```

**Efeito**: Registro permanece no banco local, mas marcado como deletado.

#### Hard Delete (Não usado no fluxo normal)

```dart
Future<bool> hardDeletePlant(String firebaseId) async {
  return await (_db.delete(_db.plants)
    ..where((p) => p.firebaseId.equals(firebaseId)))
    .go();
}
```

**Uso**: Apenas para limpeza manual ou migração de dados.

---

### 4️⃣ Remote Datasource: `PlantsRemoteDatasource`

**Arquivo**: [data/datasources/remote/plants_remote_datasource.dart](../../lib/features/plants/data/datasources/remote/plants_remote_datasource.dart)

#### Soft Delete (Padrão)

```dart
Future<void> deletePlant(String firebaseId, String userId) async {
  await _firestore
    .collection('users')
    .doc(userId)
    .collection('plants')
    .doc(firebaseId)
    .update({
      'is_deleted': true,              // Marca como deletado
      'updated_at': FieldValue.serverTimestamp(),
    });
}
```

**Efeito**: Documento permanece no Firestore, mas marcado como deletado.

---

## 🔗 Exclusão em Cascata

Quando uma planta é deletada, os seguintes itens relacionados também são marcados como deletados:

### Tasks Relacionadas

**Via**: `TasksRepository.deletePlantTasksByPlantId(plantId)`

```dart
// Marca todas as tasks da planta como isDeleted=true
await localDatasource.deleteTasksByPlantId(plantId);
if (isConnected) {
  await remoteDatasource.deleteTasksByPlantId(plantId, userId);
}
```

### Comentários Relacionados

**Via**: `PlantCommentsRepository.deleteCommentsForPlant(plantId)`

```dart
// Usa UnifiedSyncManager para soft delete
await _unifiedSyncManager.delete(
  entityType: EntityType.comment,
  entityId: commentId,
  // ... soft delete para cada comentário
);
```

---

## 🔄 Sincronização

### Offline → Online

Quando o app fica online novamente:

1. Sync Service detecta registros com `isDirty=true` e `isDeleted=true`
2. Envia operação DELETE para Firestore
3. Marca `isDirty=false` após sucesso

### Online → Offline

Quando outro dispositivo deleta uma planta:

1. Realtime listeners detectam `is_deleted=true` no Firestore
2. Atualiza banco local com `isDeleted=true`
3. UI reage e remove planta da lista

---

## 🎯 Queries e Filtros

### Listar Plantas (Excluir deletadas)

```dart
// Local (Drift)
Future<List<PlantModel>> getActivePlants() {
  return (select(plants)
    ..where((p) => p.isDeleted.equals(false)))
    .get();
}

// Remote (Firestore)
_firestore
  .collection('users/$userId/plants')
  .where('is_deleted', isEqualTo: false)
  .snapshots();
```

### Listar Plantas Deletadas (Admin/Debug)

```dart
// Local (Drift)
Future<List<PlantModel>> getDeletedPlants() {
  return (select(plants)
    ..where((p) => p.isDeleted.equals(true)))
    .get();
}
```

---

## ⚠️ Considerações Importantes

### ✅ Vantagens do Soft Delete

- **Sincronização confiável**: Offline-first funciona perfeitamente
- **Auditoria**: Mantém histórico de quem/quando deletou
- **Recuperação**: Possível implementar "desfazer" ou "restaurar"
- **Integridade**: Tasks e comentários mantêm referências válidas

### ⚠️ Desvantagens

- **Espaço em disco**: Dados deletados ocupam espaço
- **Performance**: Queries devem sempre filtrar `isDeleted=false`
- **LGPD/Privacy**: Dados "deletados" ainda existem (considerar hard delete após período)

### 🧹 Limpeza Futura (Hard Delete)

Recomendação: Implementar job batch que:

1. Busca registros com `isDeleted=true` + `updatedAt > 90 dias`
2. Executa `hardDeletePlant()` local e remote
3. Remove permanentemente do banco

**Status**: Não implementado (PLT-PLANTS-009 - Futura)

---

## 📚 Arquivos Relacionados

| Arquivo | Descrição |
|---------|-----------|
| [delete_plant_usecase.dart](../../lib/features/plants/domain/usecases/delete_plant_usecase.dart) | UseCase de exclusão |
| [plants_repository_impl.dart](../../lib/features/plants/data/repositories/plants_repository_impl.dart) | Lógica de cascata |
| [plants_drift_repository.dart](../../lib/database/repositories/plants_drift_repository.dart) | Soft/Hard delete local |
| [plants_remote_datasource.dart](../../lib/features/plants/data/datasources/remote/plants_remote_datasource.dart) | Soft delete remoto |

---

## 🔍 Para Saber Mais

- Análise detalhada: [PLANT_DELETION_ANALYSIS.md](../../docs/archive/PLANT_DELETION_ANALYSIS.md)
- Sincronização: [SYNC_ARCHITECTURE.md](../sync/ARCHITECTURE.md)
- Offline-first: [OFFLINE_FIRST_STRATEGY.md](../../docs/OFFLINE_FIRST_STRATEGY.md)
