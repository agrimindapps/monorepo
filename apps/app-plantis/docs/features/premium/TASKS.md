# 💎 Premium - Tarefas

**Feature**: premium
**Atualizado**: 2025-12-06

---

## 📋 Backlog

### 🔥 Crítico

| ID | Prioridade | Tarefa | Estimativa | Arquivo/Localização |
|----|------------|--------|------------|--------------------|
| PLT-PREMIUM-004 | 🔴 CRÍTICA | Implementar testes unitários (0% → 60%) | 12h | `test/features/premium/` |

### 🟡 Alta

| ID | Prioridade | Tarefa | Estimativa | Arquivo/Localização |
|----|------------|--------|------------|--------------------|

---

## ✅ Concluídas

### 13/12/2025
- ✅ **PLT-PREMIUM-005**: Criar UseCases para lógica de subscription (0.2h real vs 8h estimada)
  - 23/01/2025
- ✅ **PLT-PREMIUM-003**: Criar domain layer completo para premium feature (2.5h real vs 24h estimada, 90% mais rápido)
  - ✅ Criadas entities de domínio:
    - `PremiumFeatures`: 14 features (unlimited plants, identification, expert advice, etc)
    - `UsageLimits`: Limites por tier (free: 10 plantas, premium: ilimitado)
    - `PremiumStatus`: Status premium completo com métodos de negócio
  - ✅ Criado `PremiumRepository` (abstração) com 7 métodos principais:
    - `hasActivePremium()`, `getPremiumStatus()`, `getAvailableProducts()`
    - `purchasePremium()`, `restorePurchases()`, `setUser()`, `syncPremiumStatus()`
  - ✅ Implementado `PremiumRepositoryImpl`:
    - Delega para `ISubscriptionRepository` do core (RevenueCat)
    - Stream de status premium atualizado
    - Conversão de `SubscriptionEntity` para `PremiumStatus`
    - Cache local com `SubscriptionLocalRepository`
    - Lógica específica do Plantis (isPlantisSubscription, features, limits)
  - ✅ Refatorados 4 UseCases para usar abstração local:
    - `PurchaseProductUseCase`: Agora usa `PremiumRepository.purchasePremium()`
    - `RestorePurchasesUseCase`: Retorna bool ao invés de List
    - `LoadAvailableProductsUseCase`: Usa products específicos do Plantis
    - `GetCurrentSubscriptionUseCase`: Extrai subscription de PremiumStatus
  - ✅ Atualizado `premiumRepositoryProvider` com injeção completa
  - ✅ Gerado código Riverpod e corrigidos erros de compilação
  - ✅ Seguiu padrão de referência: gasometer e termostecnicos
  - **Impacto**: Clean Architecture implementada corretamente - domain não depende mais de data layer diretamente

### Criados 4 UseCases seguindo Clean Architecture:
    - `PurchaseProductUseCase`: Comprar produto de assinatura
    - `RestorePurchasesUseCase`: Restaurar compras anteriores
    - `LoadAvailableProductsUseCase`: Carregar produtos disponíveis
    - `GetCurrentSubscriptionUseCase`: Obter assinatura atual
  - Criado `premium_usecases_provider.dart` com providers Riverpod para cada UseCase
  - Refatorado `PremiumNotifier` para usar UseCases ao invés de acessar repositórios diretamente
  - Analytics integrado no UseCase de compra
  - Tratamento de erros consistente com ServerFailure
  - Separação clara entre lógica de domínio e apresentação
- ✅ **PLT-PREMIUM-006**: Mover validação de premium para domain (0.15h real vs 6h estimada)
  - Criado `PremiumValidationService` com 15 métodos de validação
  - Métodos incluem: validação de assinatura ativa, trial, features disponíveis, limites de plantas/tasks, sync, expiração
  - Criado `premiumValidationServiceProvider` para injeção via Riverpod
  - Injetado em `PremiumNotifier` e `PremiumFeaturesManager`
  - Marcados métodos antigos como @deprecated
  - Fundação criada para migração futura da lógica de validação
- ✅ **PLT-PREMIUM-001**: Injetar repositories via Riverpod (0.05h real vs 4h estimada)
  - Repositories já estavam sendo injetados via `ref.watch()` no método `_initializeRepositories()`
  - Refatorado para remover método separado `_initializeRepositories()` e inicializar diretamente no `build()`
  - Código mais limpo e idiomático com Riverpod
  - 4 repositories injetados: `subscriptionRepositoryProvider`, `subscriptionLocalRepositoryProvider`, `firebaseAnalyticsServiceProvider`, `authRepositoryProvider`
  - Sem erros de compilação

### 11/12/2025
- **PLT-PREMIUM-002**: ✅ Removido SubscriptionSyncServiceAdapter (533 linhas) - Não estava sendo usado! (Real: 0.1h, Estimado: 16h)

---

## 📝 Notas

- 13 arquivos .dart
- Health: 9/10
