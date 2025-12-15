# PLT-SYNC-003: Refatorar ConflictHistoryRepository

**Data**: 15/12/2025  
**Prioridade**: 🟢 Baixa (Média estimativa)  
**Estimativa**: 3-4h

---

## 🔍 Problemas Identificados

### 1. **Incompatibilidade Model ↔ Table Schema**
```dart
// ConflictHistoryModel (core/data/models/)
- ❌ NÃO tem: localVersion, remoteVersion
- ❌ NÃO tem: occurredAt, resolvedAt
- ✅ Tem: createdAtMs, updatedAtMs (mas não mapeado corretamente)

// ConflictHistory Table (database/tables/)
- ✅ Tem: localVersion, remoteVersion
- ✅ Tem: occurredAt, resolvedAt
- ⚠️  Hardcoded no repository: localVersion = 1, remoteVersion = 1
```

### 2. **Repository com Hardcoded Values**
```dart
// conflict_history_drift_repository.dart:18-22
localVersion: 1, // ❌ ConflictHistoryModel doesn't store versions
remoteVersion: 1,
```

### 3. **Service com TODOs e Métodos Incompletos**
```dart
// conflict_history_drift_service.dart:90-95
'resolved': 0, // TODO: Calculate when method available
'byModel': <String, int>{}, // TODO: Implement when method available
'resolutionRate': '0.0', // TODO: Calculate when resolved count available
```

### 4. **Modelo não reflete Schema Real**
O `ConflictHistoryModel` está simplificado e não contém:
- `localVersion` / `remoteVersion` (campos críticos para conflitos)
- `occurredAt` / `resolvedAt` (timestamps específicos de conflito)

---

## 🎯 Objetivos da Refatoração

1. ✅ **Alinhar Model com Table Schema**
   - Adicionar `localVersion`, `remoteVersion` ao model
   - Adicionar `occurredAt`, `resolvedAt` ao model
   - Remover hardcoded values do repository

2. ✅ **Completar Estatísticas**
   - Implementar contagem de resolvidos
   - Implementar agrupamento por tipo
   - Calcular taxa de resolução

3. ✅ **Melhorar Legibilidade**
   - Renomear métodos confusos
   - Adicionar documentação clara
   - Padronizar nomenclatura

---

## 📋 Plano de Implementação

### **Fase 1: Atualizar ConflictHistoryModel** (1h)

```dart
class ConflictHistoryModel extends BaseSyncModel {
  final String modelType;
  final String modelId;
  
  // ✨ NOVOS CAMPOS
  final int localVersion;
  final int remoteVersion;
  final int occurredAt;
  final int? resolvedAt;
  
  final String resolutionStrategy;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final Map<String, dynamic> resolvedData;
  final bool autoResolved;
  
  // ...
}
```

**Benefícios**:
- ✅ Model reflete schema real
- ✅ Remove necessidade de hardcoded values
- ✅ Permite rastreamento adequado de versões

---

### **Fase 2: Refatorar Repository** (1h)

```dart
class ConflictHistoryDriftRepository {
  // ✅ Remover hardcoded values
  Future<int> logConflict(ConflictHistoryModel model) async {
    final companion = db.ConflictHistoryCompanion.insert(
      firebaseId: Value(model.id),
      modelType: model.modelType,
      modelId: model.modelId,
      localVersion: model.localVersion,        // ✨ do model
      remoteVersion: model.remoteVersion,      // ✨ do model
      resolutionStrategy: model.resolutionStrategy,
      localData: jsonEncode(model.localData),
      remoteData: jsonEncode(model.remoteData),
      resolvedData: jsonEncode(model.resolvedData),
      occurredAt: model.occurredAt,            // ✨ do model
      resolvedAt: Value(model.resolvedAt),     // ✨ do model
      autoResolved: Value(model.autoResolved),
      // ... resto dos campos
    );
    return await _db.into(_db.conflictHistory).insert(companion);
  }
  
  // ✨ NOVO: Contagem de resolvidos
  Future<int> getResolvedCount() async { ... }
  
  // ✨ NOVO: Agrupamento por tipo
  Future<Map<String, int>> getConflictCountByType() async { ... }
}
```

---

### **Fase 3: Completar Service** (1h)

```dart
class ConflictHistoryDriftService {
  /// ✅ Estatísticas completas
  Future<ConflictStats> getStats() async {
    final unresolved = await _repository.getUnresolvedCount();
    final resolved = await _repository.getResolvedCount();
    final byModel = await _repository.getConflictCountByType();
    
    final total = unresolved + resolved;
    final resolutionRate = total > 0 
        ? ((resolved / total) * 100).toStringAsFixed(1)
        : '0.0';
    
    return ConflictStats(
      unresolved: unresolved,
      resolved: resolved,
      total: total,
      byModel: byModel,
      resolutionRate: resolutionRate,
    );
  }
}

/// ✨ NOVO: Model para estatísticas
class ConflictStats {
  final int unresolved;
  final int resolved;
  final int total;
  final Map<String, int> byModel;
  final String resolutionRate;
  
  ConflictStats({
    required this.unresolved,
    required this.resolved,
    required this.total,
    required this.byModel,
    required this.resolutionRate,
  });
}
```

---

### **Fase 4: Testes e Validação** (0.5-1h)

- ✅ Testar migração de dados existentes
- ✅ Validar estatísticas
- ✅ Verificar queries de performance
- ✅ Garantir backward compatibility

---

## 📊 Impacto

### Breaking Changes
- ⚠️ **ConflictHistoryModel constructor mudou**
  - Precisa atualizar chamadas de `ConflictHistoryModel.create()`
  - Adicionar parâmetros `localVersion`, `remoteVersion`, `occurredAt`

### Non-Breaking
- ✅ Repository API mantida (apenas internals mudam)
- ✅ Service API expandida (novos métodos, velhos mantidos)

### Performance
- ✅ Queries otimizadas com índices existentes
- ✅ Estatísticas em queries agregadas (não loops)

---

## ✅ Checklist de Conclusão

- [ ] ConflictHistoryModel atualizado com novos campos
- [ ] Repository remove hardcoded values
- [ ] Repository implementa getResolvedCount()
- [ ] Repository implementa getConflictCountByType()
- [ ] Service implementa getStats() completo
- [ ] ConflictStats model criado
- [ ] Testes de migração passam
- [ ] Documentação atualizada
- [ ] TODO removido do repository
- [ ] TODOs removidos do service

---

## 🎯 Resultado Esperado

**ANTES**:
```dart
// ❌ Hardcoded
localVersion: 1,
remoteVersion: 1,

// ❌ TODOs
'resolved': 0, // TODO: Calculate when method available
```

**DEPOIS**:
```dart
// ✅ Do model
localVersion: model.localVersion,
remoteVersion: model.remoteVersion,

// ✅ Implementado
final stats = await service.getStats();
print('Resolved: ${stats.resolved}');
print('Resolution Rate: ${stats.resolutionRate}%');
```

---

**Status**: 📋 Plano aprovado, pronto para implementação
