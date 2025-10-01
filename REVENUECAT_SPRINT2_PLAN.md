# RevenueCat Standardization - Sprint 2: Plan

**Data de Início**: 2025-10-01
**Estimativa**: 2-3 horas
**Apps Target**: app-gasometer, app-plantis, app-taskolist

---

## 📋 Objetivo

Refatorar os 3 apps restantes para usar **core ISubscriptionRepository** como única fonte de verdade para RevenueCat, seguindo o padrão estabelecido no Sprint 1.

---

## 🎯 Apps para Refatorar

### **1. app-plantis** (PRIORIDADE 1 - Mais Simples)

**Status Atual**: ✅ **JÁ USA CORE** - Apenas precisa ajustes

**Implementação Existente**:
- ✅ Usa `core ISubscriptionRepository` via wrapper `SubscriptionService`
- ✅ Estrutura limpa e simples
- ⚠️ Pode ter alguns imports diretos ou lógica duplicada

**Ações Necessárias**:
- [ ] Verificar imports diretos de `purchases_flutter`
- [ ] Remover lógica duplicada se houver
- [ ] Garantir 100% das chamadas via core
- [ ] Adicionar documentação store-level operations

**Estimativa**: 30 minutos

---

### **2. app-taskolist** (PRIORIDADE 2 - Riverpod já implementado)

**Status Atual**: ✅ **JÁ USA CORE** + Riverpod

**Implementação Existente**:
- ✅ Usa `core ISubscriptionRepository` via `TaskManagerSubscriptionService`
- ✅ Riverpod StateNotifier já implementado
- ✅ Feature gates robustos com `UserLimits` entity
- ⚠️ Pode ter imports diretos ou type inconsistencies

**Ações Necessárias**:
- [ ] Verificar imports diretos de `purchases_flutter`
- [ ] Padronizar type mapping com padrão Sprint 1
- [ ] Adicionar documentação store-level operations
- [ ] Verificar DI module consistency

**Estimativa**: 45 minutos

---

### **3. app-gasometer** (PRIORIDADE 3 - Mais Complexo)

**Status Atual**: ⚠️ **ARQUITETURA COMPLETA** - Precisa refatoração moderada

**Implementação Existente**:
- ✅ Clean Architecture completa (10 use cases)
- ✅ Usa core package como abstração
- ⚠️ 4 datasources (remote, local, firebase, webhook) - complexidade alta
- ⚠️ Premium sync service com múltiplas responsabilidades

**Arquitetura Atual**:
```
features/premium/
├── domain/
│   ├── entities/
│   │   ├── premium_status.dart
│   │   └── premium_features.dart
│   ├── repositories/premium_repository.dart
│   └── usecases/ (10 use cases)
├── data/
│   ├── datasources/
│   │   ├── premium_remote_data_source.dart    → RevenueCat via core
│   │   ├── premium_local_data_source.dart     → Cache Hive
│   │   ├── premium_firebase_data_source.dart  → Sync Firestore
│   │   └── premium_webhook_data_source.dart   → Webhooks RevenueCat
│   ├── repositories/premium_repository_impl.dart
│   └── services/premium_sync_service.dart     → Multi-source sync
└── presentation/
    └── providers/premium_provider.dart         → Provider pattern
```

**Ações Necessárias**:
- [ ] Simplificar 4 datasources → 2 (remote + local)
- [ ] Mover webhook logic para core package (se possível)
- [ ] Refatorar premium_sync_service para SRP compliance
- [ ] Padronizar type mapping com padrão Sprint 1
- [ ] Considerar migração para Riverpod (opcional)
- [ ] Adicionar documentação store-level operations

**Estimativa**: 1-1.5 horas

---

## 📊 Comparação de Complexidade

| App | Arquitetura | State Mgmt | Datasources | Use Cases | Complexidade |
|-----|-------------|-----------|-------------|-----------|--------------|
| **app-plantis** | Service Wrapper | Provider | 1 (wrapper) | ~3 | ⭐ Baixa |
| **app-taskolist** | Clean Arch | Riverpod | 1 (wrapper) | 7 | ⭐⭐ Média |
| **app-gasometer** | Clean Arch | Provider | 4 | 10 | ⭐⭐⭐ Alta |

---

## 🔄 Padrão de Refatoração

### **Para Service Wrapper (plantis, taskolist)**

1. Verificar todos os imports:
```bash
grep -r "purchases_flutter" lib/
```

2. Garantir 100% via core:
```dart
// ❌ EVITAR
import 'package:purchases_flutter/purchases_flutter.dart';
final customerInfo = await Purchases.getCustomerInfo();

// ✅ USAR
final result = await _subscriptionRepository.getCurrentSubscription();
```

3. Adicionar documentação:
```dart
/// IMPORTANT: Cancel/Pause operations are store-level.
/// Users must manage through:
/// - iOS: Settings → Apple ID → Subscriptions
/// - Android: Play Store → Subscriptions
```

---

### **Para Clean Architecture (gasometer)**

1. Simplificar datasources:
```dart
// ANTES: 4 datasources
├── premium_remote_data_source.dart    (RevenueCat)
├── premium_local_data_source.dart     (Cache)
├── premium_firebase_data_source.dart  (Sync)
└── premium_webhook_data_source.dart   (Webhooks)

// DEPOIS: 2 datasources (padrão Sprint 1)
├── subscription_remote_datasource.dart (RevenueCat + Firestore sync)
└── subscription_local_datasource.dart  (Cache)
```

2. Mover webhook logic:
```dart
// Opção 1: Mover para core package (ideal)
// Opção 2: Integrar no remote datasource (aceitável)
// Opção 3: Manter separado mas simplificar (fallback)
```

3. Seguir padrão Sprint 1:
- Type mappers explícitos
- Firestore sync integrado no remote datasource
- Cache fallback no repository
- Store-level documentation

---

## ✅ Checklist de Validação

Para cada app refatorado, verificar:

- [ ] ✅ Nenhum import direto de `purchases_flutter`
- [ ] ✅ Todas as chamadas via core `ISubscriptionRepository`
- [ ] ✅ Type mappers implementados (se necessário)
- [ ] ✅ Documentação store-level operations presente
- [ ] ✅ DI module registra corretamente core dependency
- [ ] ✅ `flutter analyze` sem novos erros
- [ ] ✅ Compilation OK

---

## 📝 Ordem de Execução Recomendada

### **Fase 1: app-plantis** (30 min)
1. Analisar imports e verificar uso de core
2. Remover qualquer lógica duplicada
3. Adicionar documentação
4. Validar compilation

### **Fase 2: app-taskolist** (45 min)
1. Analisar imports e type mapping
2. Padronizar com padrão Sprint 1
3. Adicionar documentação
4. Validar Riverpod providers
5. Validar compilation

### **Fase 3: app-gasometer** (1-1.5h)
1. Análise arquitetural completa
2. Simplificar datasources (4→2)
3. Refatorar sync service
4. Padronizar type mapping
5. Adicionar documentação
6. Validar compilation

---

## 🎯 Critérios de Sucesso Sprint 2

- ✅ 3 apps (100%) usando core ISubscriptionRepository
- ✅ 0 imports diretos de purchases_flutter em features/
- ✅ Documentação store-level operations em todos os apps
- ✅ 0 novos erros de compilação
- ✅ Padrão arquitetural consistente (2 variações aceitáveis):
  - **Variação 1**: Service Wrapper (plantis, taskolist)
  - **Variação 2**: Clean Architecture (petiveti, agrihurbi, receituagro, gasometer)

---

## 📊 Métricas Esperadas

| Métrica | Antes Sprint 2 | Meta Sprint 2 |
|---------|---------------|---------------|
| **Apps usando core** | 3/6 (50%) | 6/6 (100%) |
| **Imports diretos SDK** | ~15-20 | 0 |
| **Duplicação de código** | ~500 linhas | ~100 linhas |
| **Documentação store-ops** | 3 apps | 6 apps |

---

## 🚀 Próximos Passos Pós-Sprint 2

### **Sprint 3: Padronização Avançada**
- [ ] Padronizar Product IDs entre todos os apps
- [ ] Documentar Product ID mapping
- [ ] Criar shared widgets de subscription UI
- [ ] Migrar apps Provider → Riverpod (opcional)

### **Sprint 4: Testes e Qualidade**
- [ ] Testes unitários para use cases
- [ ] Testes de integração para repository
- [ ] Testes E2E para fluxo de compra
- [ ] Code coverage > 80%

---

**Documento Criado**: 2025-10-01
**Status**: PLANEJAMENTO SPRINT 2
