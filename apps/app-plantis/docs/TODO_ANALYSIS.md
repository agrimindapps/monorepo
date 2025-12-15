# 📝 Análise Detalhada de TODOs - app-plantis

**Data**: 15/12/2025  
**Análise Completa**: PLT-004

---

## 📊 Resumo Executivo

**TODOs Reais**: 11 (não 71 conforme reportado inicialmente)  
**Já Documentados**: 8/11 (73%)  
**Novos Documentados**: 3/11 (27%)  
**Estimativa Total**: 16-24h

---

## 🎯 TODOs por Prioridade

### 🔴 Críticos (3) - 9-13h

| ID | Tarefa | Local | Estimativa | Status |
|----|--------|-------|------------|--------|
| **PLT-ACCOUNT-001** | Verificar status premium via RevenueCat | [account_repository_impl.dart:36,157](../lib/features/account/data/repositories/account_repository_impl.dart) | 2-3h | ✅ Documentado |
| **PLT-HOME-001** | Firebase Remote Config integration | [landing_content_datasource.dart:70](../lib/features/home/data/datasources/landing_content_datasource.dart) | 4-6h | ✅ Documentado |
| **PLT-007** | Performance monitoring | [core_di_providers.dart:50](../lib/core/providers/core_di_providers.dart) | 3-4h | ✅ Documentado |

**Impacto**: 
- ❌ Premium não funciona (bloqueio de monetização)
- ⚠️ Sem A/B testing
- ⚠️ Zero observabilidade de performance

---

### 🟡 Melhorias de Arquitetura (3) - 5-9h

| ID | Tarefa | Local | Estimativa | Status |
|----|--------|-------|------------|--------|
| **PLT-006** | DI Factory - PlantsDataService | [solid_di_factory.dart:37](../lib/core/di/solid_di_factory.dart) | 1-2h | ✅ Documentado |
| **PLT-SYNC-003** | Refatorar ConflictHistoryRepository | [conflict_history_drift_repository.dart:10](../lib/database/repositories/conflict_history_drift_repository.dart) | 4-6h | ✅ Documentado |
| **PLT-SYNC-001** | Remover repositórios não utilizados | [plantis_sync_service.dart:14](../lib/core/services/plantis_sync_service.dart) | 30 min | ✅ Documentado |

---

### 🟢 Otimizações (5) - 3-5h

| ID | Tarefa | Local | Estimativa | Status |
|----|--------|-------|------------|--------|
| **PLT-SYNC-002** | Estatísticas de conflitos completas | [conflict_history_drift_service.dart:87-90](../lib/core/services/conflict_history_drift_service.dart) | 2-3h | ✅ Documentado |
| **PLT-SYNC-004** | Stream reativo de conflitos | [conflict_history_drift_service.dart:137](../lib/core/services/conflict_history_drift_service.dart) | 1-2h | ✅ Documentado |
| **PLT-SETTINGS-001** | Remover código morto _loadDeviceInfo | [settings_notifier.dart:576](../lib/features/settings/presentation/providers/settings_notifier.dart) | 30 min | ✅ Documentado |

---

## 🔍 Detalhamento Técnico

### 1. PLT-ACCOUNT-001: RevenueCat Integration ⚠️ CRÍTICO

**2 Instâncias**:
- L36: `getAccountInfo()` → sempre retorna `isPremium = false`
- L157: `watchAccountInfo()` → stream nunca atualiza status premium

**Código Atual**:
```dart
// TODO: Verificar status premium através do RevenueCat
const isPremium = false;
```

**Solução**:
```dart
final premiumStatus = await ref.read(premiumServiceProvider).checkStatus();
final isPremium = premiumStatus.isActive;
```

**Impacto**: Nenhum usuário consegue acessar features premium mesmo com assinatura válida.

**Referência**: [features/account/TASKS.md](features/account/TASKS.md)

---

### 2. PLT-HOME-001: Firebase Remote Config

**Objetivo**: Habilitar A/B testing de landing pages

**Código Atual**:
```dart
Future<LandingContentModel> getLandingContentRemote() async {
  // TODO: Implement Firebase Remote Config integration
  return getLandingContent(); // Retorna hardcoded
}
```

**Solução**:
```dart
final remoteConfig = FirebaseRemoteConfig.instance;
await remoteConfig.setConfigSettings(RemoteConfigSettings(
  fetchTimeout: const Duration(seconds: 10),
  minimumFetchInterval: const Duration(hours: 1),
));
await remoteConfig.fetchAndActivate();

final variant = remoteConfig.getString('landing_variant');
return _getContentForVariant(variant);
```

**Benefícios**: 
- Testar diferentes CTAs
- Otimizar conversão
- Personalizar conteúdo por região

**Referência**: [features/home/TASKS.md](features/home/TASKS.md)

---

### 3. PLT-007: Performance Monitoring

**Código Atual**:
```dart
@riverpod
IPerformanceRepository performanceRepository(Ref ref) {
  return _StubPerformanceRepository(); // No-op
}
```

**Solução**:
```dart
@riverpod
IPerformanceRepository performanceRepository(Ref ref) {
  return FirebasePerformanceRepository(
    performance: FirebasePerformance.instance,
  );
}
```

**Métricas Perdidas**:
- ❌ Tempo de carregamento de telas
- ❌ Queries lentas do Drift
- ❌ Network requests
- ❌ Custom traces

**Referência**: [backlog/README.md](backlog/README.md)

---

### 4. PLT-SYNC-002: Estatísticas de Conflitos

**3 TODOs relacionados**:
```dart
return {
  'resolved': 0, // TODO: Calculate when method available
  'byModel': <String, int>{}, // TODO: Implement when method available
  'resolutionRate': '0.0', // TODO: Calculate when resolved count available
};
```

**Implementação Necessária**:
```dart
// Adicionar ao repository:
Future<int> getResolvedCount();
Future<Map<String, int>> getConflictsByModel();

// No service:
final resolved = await _repository.getResolvedCount();
final byModel = await _repository.getConflictsByModel();
final resolutionRate = ((resolved / total) * 100).toStringAsFixed(1);
```

**Referência**: [features/sync/TASKS.md](features/sync/TASKS.md)

---

### 5. PLT-SYNC-003: ConflictHistory Repository Refactoring

**Problema Atual**:
```dart
/// TODO: This repository needs significant refactoring to align ConflictHistoryModel
/// with the ConflictHistory table schema. Temporarily simplified for migration.

final companion = db.ConflictHistoryCompanion.insert(
  localVersion: 1, // Hardcoded - deveria vir do model
  remoteVersion: 1,
  // ...
);
```

**Mapeamento Incompleto**:
- `ConflictHistoryModel` não tem campos de versão
- Timestamps podem estar incorretos
- Dados JSON podem não ser deserializados corretamente

**Solução**:
1. Adicionar campos ao `ConflictHistoryModel`:
   - `localVersion: int`
   - `remoteVersion: int`
   - `conflictTimestamp: DateTime`
2. Atualizar todos os usages
3. Migrar dados existentes

**Referência**: [features/sync/TASKS.md](features/sync/TASKS.md)

---

### 6. PLT-SYNC-004: Stream Reativo de Conflitos

**Implementação Atual (Polling)**:
```dart
/// TODO: Implement watchUnresolvedConflicts in repository
Stream<List<ConflictHistoryModel>> watchUnresolvedConflicts() {
  return Stream.periodic(
    const Duration(seconds: 5), // Poll a cada 5s
    (_) => getUnresolved(),
  ).asyncMap((future) => future);
}
```

**Solução Reativa**:
```dart
// No repository Drift:
Stream<List<ConflictHistoryModel>> watchUnresolvedConflicts() {
  return (select(conflictHistory)
    ..where((t) => t.resolved.equals(false)))
    .watch() // ✅ Reativo ao banco
    .map((rows) => rows.map(_toModel).toList());
}
```

**Benefícios**:
- ✅ Sem polling desnecessário
- ✅ Atualização instantânea na UI
- ✅ Menor consumo de CPU/bateria

**Referência**: [features/sync/TASKS.md](features/sync/TASKS.md)

---

### 7. PLT-SYNC-001: Repositórios Não Utilizados

**Código Comentado**:
```dart
// TODO: Remove if confirmed unused - repositories not currently used in sync methods
// final PlantsRepository _plantsRepository;
// final SpacesRepository _spacesRepository;
// final PlantTasksRepository _plantTasksRepository;
// final PlantCommentsRepository _plantCommentsRepository;
```

**Ação**: 
1. Buscar referências no arquivo
2. Se não usados → remover completamente
3. Se usados → descomentar e documentar

**Referência**: [features/sync/TASKS.md](features/sync/TASKS.md)

---

### 8. PLT-006: DI Factory - PlantsDataService

**Código Atual**:
```dart
PlantsDataService createPlantsDataService({
  IAuthStateProvider? authProvider,
}) {
  // TODO: Implement proper dependency injection
  throw UnimplementedError(
    'PlantsDataService creation not implemented in DI factory',
  );
}
```

**Ação**:
1. Verificar se `PlantsDataService` é usado em algum lugar
2. Se usado via Riverpod → remover método da factory
3. Se usado via factory → implementar criação

**Referência**: [backlog/README.md](backlog/README.md)

---

### 9. PLT-SETTINGS-001: Device Loading (Dead Code)

**Código Atual**:
```dart
Future<void> _loadDeviceInfo() async {
  try {
    // TODO: Implementar carregamento de dispositivos
    // Requer obter userId do auth state/provider
    if (kDebugMode) {
      debugPrint('ℹ️ Settings: Device loading não implementado ainda');
    }
  } catch (e) {
    // ...
  }
}
```

**Observação**: Feature de device management já está implementada em `DeviceManagementProvider`

**Ação**: 
1. Buscar chamadas ao método `_loadDeviceInfo()`
2. Se não chamado → remover método completamente
3. Se chamado → redirecionar para `DeviceManagementProvider`

**Referência**: [features/settings/TASKS.md](features/settings/TASKS.md)

---

## 📈 Priorização Recomendada

### Sprint 1: Críticos (1 semana)
```
PLT-ACCOUNT-001 → PLT-HOME-001 → PLT-007
(2-3h)           (4-6h)         (3-4h)
Total: 9-13h
```

### Sprint 2: Arquitetura (1 semana)
```
PLT-SYNC-003 → PLT-006 → PLT-SYNC-001
(4-6h)        (1-2h)    (30min)
Total: 5.5-8.5h
```

### Sprint 3: Otimizações (3 dias)
```
PLT-SYNC-002 → PLT-SYNC-004 → PLT-SETTINGS-001
(2-3h)        (1-2h)         (30min)
Total: 3.5-5.5h
```

---

## ✅ Status de Documentação

| ID | Feature | Arquivo | Status |
|----|---------|---------|--------|
| PLT-ACCOUNT-001 | account | TASKS.md | ✅ Documentado |
| PLT-HOME-001 | home | TASKS.md | ✅ Documentado |
| PLT-007 | core | backlog/README.md | ✅ Documentado |
| PLT-006 | core | backlog/README.md | ✅ Documentado |
| PLT-SYNC-001 | sync | TASKS.md | ✅ Documentado |
| PLT-SYNC-002 | sync | TASKS.md | ✅ Documentado (novo) |
| PLT-SYNC-003 | sync | TASKS.md | ✅ Documentado (novo) |
| PLT-SYNC-004 | sync | TASKS.md | ✅ Documentado (novo) |
| PLT-SETTINGS-001 | settings | TASKS.md | ✅ Atualizado |

**Total**: 9/9 tarefas documentadas (100%) ✅

---

## 📝 Notas

1. **71 TODOs Originais**: Falso positivo - muitos matches em comentários com "todos" (ex: "todos os dispositivos")

2. **11 TODOs Técnicos Reais**: Confirmados por análise manual de código

3. **Impacto de Negócio**: 3 TODOs críticos bloqueiam features premium e observabilidade

4. **Código Morto**: 2 TODOs são potencialmente dead code (PLT-SYNC-001, PLT-SETTINGS-001)

5. **Próximo Passo**: Executar PLT-ACCOUNT-001 para desbloquear monetização
