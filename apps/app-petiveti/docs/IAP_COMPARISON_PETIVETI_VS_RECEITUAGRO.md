# Comparação: In-App Purchase Implementation

## app-petiveti vs app-receituagro

---

## 📊 RESUMO EXECUTIVO

| Aspecto | app-petiveti | app-receituagro |
|---------|--------------|-----------------|
| **Implementação IAP** | ❌ Mock/Local (Sem RevenueCat) | ✅ RevenueCat (Core Package) |
| **Maturidade** | 🟡 Básica/Simulada | 🟢 Completa/Produção |
| **Dependências** | Local datasources apenas | Core ISubscriptionRepository |
| **Plataformas** | iOS/Android/Web (Mock) | iOS/Android (RevenueCat real) |
| **Sincronização** | ❌ Não implementada | ✅ Drift + Firebase |
| **Security** | ⚠️ Básica | ✅ Server-side validation |

---

## 🏗️ ARQUITETURA

### app-petiveti (Mock Implementation)

```
lib/features/subscription/
├── data/
│   ├── datasources/
│   │   ├── subscription_local_datasource.dart  ← Hive/SharedPrefs
│   │   └── subscription_remote_datasource.dart ← Mock Firebase
│   ├── models/
│   │   └── subscription_plan_model.dart
│   ├── repositories/
│   │   └── subscription_repository_impl.dart    ← Repository local
│   └── services/
│       └── subscription_error_handling_service.dart
├── domain/
│   ├── entities/
│   │   ├── subscription_plan.dart
│   │   └── user_subscription.dart               ← Entidade local
│   ├── repositories/
│   │   └── subscription_repository.dart         ← Interface local
│   └── usecases/
│       └── subscription_usecases.dart
└── presentation/
    ├── pages/
    │   └── subscription_page.dart               ← UI completa
    ├── providers/
    │   └── subscription_providers.dart
    └── widgets/
        ├── subscription_plan_card.dart
        ├── subscription_feature_comparison.dart
        └── subscription_page_coordinator.dart
```

**Características:**
- ✅ Arquitetura Clean completa (Data/Domain/Presentation)
- ✅ UI rica e detalhada com coordinator pattern
- ❌ Sem integração real com stores (App Store/Google Play)
- ❌ Sem RevenueCat
- ⚠️ Validação apenas local (insegura)

### app-receituagro (RevenueCat Implementation)

```
lib/features/subscription/
├── data/
│   └── repositories/
│       └── subscription_repository_impl.dart    ← Wrapper do Core
├── domain/
│   ├── entities/
│   │   ├── index.dart                           ← Re-export core entities
│   │   ├── billing_issue_entity.dart
│   │   ├── pricing_tier_entity.dart
│   │   ├── purchase_history_entity.dart
│   │   └── trial_info_entity.dart
│   ├── repositories/
│   │   └── i_subscription_repository.dart       ← Interface app-specific
│   └── usecases/
│       ├── get_purchase_history.dart
│       └── refresh_subscription_status.dart
└── presentation/
    ├── pages/
    │   ├── subscription_page.dart               ← UI simplificada
    │   └── sections/
    │       └── subscription_status_section.dart
    ├── providers/
    │   ├── subscription_notifier.dart
    │   ├── subscription_provider.dart
    │   └── subscription_providers.dart
    ├── services/
    │   └── subscription_error_message_service.dart
    └── widgets/
        ├── subscription_benefits_widget.dart
        ├── subscription_plans_widget.dart
        └── subscription_info_card.dart
```

**Características:**
- ✅ Usa `core/ISubscriptionRepository` (RevenueCat)
- ✅ Integração real com App Store/Google Play
- ✅ Server-side receipt validation
- ✅ Drift sync para cache local
- ✅ Multi-app support (Plantis/ReceitaAgro/Gasometer)
- ⚠️ Menos widgets customizados que Petiveti

---

## 🔑 COMPONENTES PRINCIPAIS

### 1. Repository Pattern

#### app-petiveti: Local Mock Repository

```dart
// SubscriptionRepositoryImpl
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDataSource localDataSource;   // Hive/SharedPrefs
  final SubscriptionRemoteDataSource remoteDataSource; // Mock Firebase
  final SubscriptionErrorHandlingService errorHandlingService;

  // Métodos principais:
  Future<Either<Failure, List<SubscriptionPlan>>> getAvailablePlans();
  Future<Either<Failure, UserSubscription?>> getCurrentSubscription(String userId);
  Future<Either<Failure, UserSubscription>> subscribeToPlan(String userId, String planId);
  Future<Either<Failure, void>> cancelSubscription(String userId);
  Future<Either<Failure, void>> pauseSubscription(String userId);
  Future<Either<Failure, void>> resumeSubscription(String userId);
  Future<Either<Failure, UserSubscription>> upgradePlan(String userId, String newPlanId);
  Future<Either<Failure, void>> restorePurchases(String userId);
  Future<Either<Failure, bool>> validateReceipt(String receiptData);
  Stream<Either<Failure, UserSubscription?>> watchSubscription(String userId);
}
```

**Problemas:**
- ❌ `validateReceipt()` sempre retorna `true` (simulado)
- ❌ `restorePurchases()` apenas delay de 1 segundo (fake)
- ❌ Não valida com stores reais
- ❌ Vulnerável a fraudes

#### app-receituagro: Core Package (RevenueCat)

```dart
// Wrapper sobre core ISubscriptionRepository
class SubscriptionRepositoryImpl implements IAppSubscriptionRepository {
  final ISubscriptionRepository _coreRepository;           // RevenueCat!
  final ILocalStorageRepository _localStorageRepository;
  final SubscriptionLocalRepository _subscriptionLocalRepository; // Drift
  final IAuthRepository _authRepository;

  // Métodos app-specific:
  Future<Either<Failure, bool>> hasReceitaAgroSubscription();
  Future<Either<Failure, List<ProductInfo>>> getReceitaAgroProducts();
  Future<Either<Failure, bool>> hasFeatureAccess(String featureKey);
  Future<Either<Failure, bool>> hasActiveTrial();
  
  // Cache multi-layer:
  Future<Either<Failure, void>> cachePremiumStatus(bool isPremium);
  Future<Either<Failure, bool?>> getCachedPremiumStatus();  // Drift + SharedPrefs
}
```

**Vantagens:**
- ✅ Delegação para `core/RevenueCatService`
- ✅ Cache em 3 camadas (Drift → SharedPrefs → RevenueCat)
- ✅ Validação real com stores
- ✅ Suporte a trial, grace period, refunds
- ✅ Cross-platform (iOS/Android)

### 2. Core Package Integration

#### RevenueCat Service (packages/core)

```dart
// packages/core/lib/src/infrastructure/services/revenue_cat_service.dart
class RevenueCatService implements ISubscriptionRepository, IDisposableService {
  // API Keys hardcoded (production ready):
  // iOS:     'appl_QXSaVxUhpIkHBdHyBHAGvjxTxTR'
  // Android: 'goog_JYcfxEUeRnReVEdsLkShLQnzCmf'

  @override
  Future<Either<Failure, bool>> hasActiveSubscription() async {
    final customerInfo = await Purchases.getCustomerInfo();
    return Right(customerInfo.activeSubscriptions.isNotEmpty);
  }

  @override
  Future<Either<Failure, SubscriptionEntity?>> getCurrentSubscription() async {
    final customerInfo = await Purchases.getCustomerInfo();
    return Right(_mapCustomerInfoToSubscription(customerInfo));
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> purchaseProduct({
    required String productId,
  }) async {
    final result = await Purchases.purchaseProduct(productId);
    return Right(_mapPurchaseResultToSubscription(result));
  }

  @override
  Future<Either<Failure, List<SubscriptionEntity>>> restorePurchases() async {
    final customerInfo = await Purchases.restorePurchases();
    // Real restore from App Store/Google Play
  }
}
```

**Funcionalidades:**
- ✅ RevenueCat SDK (`purchases_flutter: ^9.2.0`)
- ✅ Real-time subscription status stream
- ✅ App Store/Google Play integration
- ✅ Server-side receipt validation
- ✅ Multi-app support (product IDs por app)
- ✅ Trial management
- ✅ Refund handling
- ✅ Family sharing (iOS)

### 3. Entities & Models

#### app-petiveti: Local Entities

```dart
// UserSubscription (local)
class UserSubscription extends Equatable {
  final String id;
  final String userId;
  final String planId;
  final SubscriptionPlan plan;
  final PlanStatus status;           // active/expired/cancelled/paused/pending
  final DateTime startDate;
  final DateTime? expirationDate;
  final DateTime? cancelledAt;
  final DateTime? pausedAt;
  final bool autoRenew;
  final String? transactionId;       // Mock
  final String? receiptData;         // Mock
  final bool isTrialPeriod;
  final DateTime? trialEndDate;
  
  // Computed properties
  bool get isActive => status == PlanStatus.active;
  bool get isValidPremium => isActive && (expirationDate == null || now < expirationDate);
}
```

#### app-receituagro: Core Package Entities

```dart
// SubscriptionEntity (from core package)
class SubscriptionEntity extends BaseSyncEntity {
  final String productId;                    // RevenueCat product ID
  final SubscriptionStatus status;           // Enum from RevenueCat
  final SubscriptionTier tier;               // free/premium/pro
  final DateTime? expirationDate;
  final DateTime? purchaseDate;
  final DateTime? originalPurchaseDate;      // For renewals
  final DateTime? renewalDate;
  final DateTime? trialEndDate;
  final String? cancellationReason;
  final Store store;                         // appStore/playStore
  final bool isInTrial;
  final bool isSandbox;                      // Production vs Test
  final bool isAutoRenewing;

  // Drift sync fields (from BaseSyncEntity)
  final String userId;
  final DateTime? lastSyncAt;
  final bool isDirty;
  final int version;

  // Computed properties
  bool get isActive => status == SubscriptionStatus.active && !isExpired;
  bool get isExpired => expirationDate != null && DateTime.now().isAfter(expirationDate!);
  bool get isInGracePeriod => status == SubscriptionStatus.gracePeriod;
  bool get isTrialActive => isInTrial && trialEndDate != null && DateTime.now().isBefore(trialEndDate!);
  int? get daysRemaining => expirationDate?.difference(DateTime.now()).inDays;
}
```

**Diferenças:**
- ✅ ReceitaAgro usa entities do core (sync com Drift/Firebase)
- ✅ Mais campos de metadata (store, sandbox, grace period)
- ✅ Integração com BaseSyncEntity para offline-first
- ❌ Petiveti não tem sync, apenas cache local

### 4. UI/UX Implementation

#### app-petiveti: Rich UI com Coordinator

```dart
// subscription_page.dart (335 linhas)
// Comentários extensos explicando lógica de negócio
// Coordinator pattern para orquestração

class SubscriptionPage extends ConsumerWidget {
  // Widgets especializados:
  - SubscriptionPageHeader      // Header com título/subtítulo
  - SubscriptionPlanCard        // Card de cada plano
  - SubscriptionFeatureComparison // Tabela comparativa
  - SubscriptionRestoreButton   // Botão restaurar compras
  - SubscriptionEmptyState      // Estado vazio
  - SubscriptionLoadingOverlay  // Overlay de loading
  - SubscriptionSkeletonLoaders // Skeleton screens
  - SubscriptionPageCoordinator // Orquestração de estados
}
```

**Características UI:**
- ✅ 8+ widgets customizados
- ✅ Skeleton loaders
- ✅ Feature comparison table
- ✅ Rich animations
- ✅ Documentação extensiva (comments)
- ⚠️ Complexidade alta

#### app-receituagro: Simplified UI

```dart
// subscription_page.dart (265 linhas)
// UI simplificada, foco em funcionalidade

class SubscriptionPage extends ConsumerStatefulWidget {
  // Widgets principais:
  - ModernHeaderWidget          // Header reutilizável (core)
  - SubscriptionStatusWidget    // Status da assinatura
  - SubscriptionPlansWidget     // Lista de planos
  - SubscriptionBenefitsWidget  // Benefícios premium
  - PaymentActionsWidget        // Ações de pagamento
  - SubscriptionInfoCard        // Info card
}
```

**Características UI:**
- ✅ 6 widgets (mais simples)
- ✅ Reutilização de widgets do core
- ✅ Gradient background
- ✅ SnackBar messaging
- ✅ Loading states
- ⚠️ Menos customização que Petiveti

---

## 🔄 SINCRONIZAÇÃO & CACHE

### app-petiveti: Sem Sync

```dart
// Apenas cache local (Hive/SharedPrefs)
// Sem Drift
// Sem Firebase sync
// Sem offline-first

Future<Either<Failure, List<SubscriptionPlan>>> getAvailablePlans() async {
  // 1. Tenta buscar remote (mock)
  final remotePlans = await remoteDataSource.getAvailablePlans();
  
  // 2. Cacheia localmente
  await localDataSource.cachePlans(remotePlans);
  
  // 3. Fallback se erro
  return localDataSource.getAvailablePlans();
}
```

### app-receituagro: Multi-Layer Cache

```dart
// 3 camadas de cache:
// 1. Drift (SQLite) - Secure & Offline
// 2. SharedPreferences - Fast access
// 3. RevenueCat SDK - Source of truth

Future<Either<Failure, bool?>> getCachedPremiumStatus() async {
  // Layer 1: Try Drift database (most secure)
  try {
    final user = await _authRepository.currentUser.first;
    if (user != null) {
      final localSub = await _subscriptionLocalRepository.getActiveSubscription(user.id);
      if (localSub != null && !localSub.isExpired) {
        return const Right(true);
      }
    }
  } catch (e) {
    // Fall through to layer 2
  }

  // Layer 2: Try SharedPreferences (fallback)
  final result = await _localStorageRepository.get<Map<String, dynamic>>(key: _cacheKey);
  
  return result.fold((failure) => Left(failure), (data) {
    // Check cache expiration (5 minutes)
    if (data != null && !isCacheExpired(data['timestamp'])) {
      return Right(data['isPremium'] as bool?);
    }
    return const Right(null); // Cache expired, fetch fresh
  });
}
```

**Vantagens ReceitaAgro:**
- ✅ Offline-first com Drift
- ✅ Cache expiration (5 minutos)
- ✅ Graceful fallback entre camadas
- ✅ Sync com Firebase via Drift adapters

---

## 📦 DEPENDÊNCIAS

### app-petiveti

```yaml
dependencies:
  # Sem purchases_flutter
  # Sem RevenueCat
  
  # Storage local:
  hive: any
  hive_flutter: any
  shared_preferences: any
  
  # Drift (database):
  drift: any
  
  # Core package (mas não usa ISubscriptionRepository):
  core:
    path: ../../packages/core
```

### app-receituagro

```yaml
dependencies:
  # Core package com RevenueCat:
  core:
    path: ../../packages/core
    # Inclui:
    #   - purchases_flutter: ^9.2.0
    #   - ISubscriptionRepository
    #   - RevenueCatService
  
  # Drift para sync:
  drift: any
  sqlite3_flutter_libs: any
```

### packages/core

```yaml
dependencies:
  # RevenueCat SDK:
  purchases_flutter: ^9.2.0  ← REAL IAP
  
  # Outras:
  dartz: any
  equatable: any
  cloud_firestore: any
  shared_preferences: any
```

---

## 🔐 SEGURANÇA

### app-petiveti: ⚠️ Insegura

```dart
// Validação de recibo FAKE:
@override
Future<Either<Failure, bool>> validateReceipt(String receiptData) async {
  return errorHandlingService.executeOperation<bool>(
    operation: () async {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return true;  // SEMPRE RETORNA TRUE! 🚨
    },
    errorMessage: 'Erro ao validar recibo',
  );
}
```

**Vulnerabilidades:**
- ❌ Sem server-side validation
- ❌ Qualquer "receipt" é válido
- ❌ Fácil bypass (modificar código local)
- ❌ Sem proteção contra fraudes
- ❌ Não valida com App Store/Google Play

### app-receituagro: ✅ Segura

```dart
// RevenueCat faz validação server-side:
@override
Future<Either<Failure, SubscriptionEntity>> purchaseProduct({
  required String productId,
}) async {
  try {
    // 1. SDK RevenueCat comunica com store
    final result = await Purchases.purchaseProduct(productId);
    
    // 2. RevenueCat server valida receipt com Apple/Google
    // 3. Retorna CustomerInfo apenas se válido
    final customerInfo = result.customerInfo;
    
    // 4. Mapeia para entity
    return Right(_mapPurchaseResultToSubscription(result));
  } on PlatformException catch (e) {
    // Trata erros específicos (cancelled, network, etc)
    return Left(e.code.toSubscriptionFailure(e.message));
  }
}
```

**Proteções:**
- ✅ Server-side receipt validation (RevenueCat servers)
- ✅ Comunicação direta com App Store/Google Play APIs
- ✅ Webhook support para eventos de assinatura
- ✅ Fraud detection
- ✅ Sandbox vs Production separation

---

## 🎯 RECOMENDAÇÕES

### Para app-petiveti migrar para RevenueCat:

#### 1. Adicionar dependência no pubspec.yaml
```yaml
# Remover:
# dependencies:
#   hive: any
#   hive_flutter: any

# Manter core package (já tem RevenueCat):
dependencies:
  core:
    path: ../../packages/core
```

#### 2. Criar interface app-specific (como ReceitaAgro)
```dart
// lib/features/subscription/domain/repositories/i_app_subscription_repository.dart
abstract class IAppSubscriptionRepository {
  Future<Either<Failure, bool>> hasPetivetiSubscription();
  Future<Either<Failure, List<ProductInfo>>> getPetivetiProducts();
  Future<Either<Failure, bool>> hasFeatureAccess(String featureKey);
  Future<Either<Failure, void>> cachePremiumStatus(bool isPremium);
  Future<Either<Failure, bool?>> getCachedPremiumStatus();
}
```

#### 3. Implementar wrapper sobre core
```dart
// lib/features/subscription/data/repositories/subscription_repository_impl.dart
class SubscriptionRepositoryImpl implements IAppSubscriptionRepository {
  final ISubscriptionRepository _coreRepository; // ← Inject do core
  final SubscriptionLocalRepository _localRepo;  // ← Drift cache
  
  @override
  Future<Either<Failure, bool>> hasPetivetiSubscription() {
    return _coreRepository.hasPetivetiSubscription();
  }
  
  // Cache multi-layer (copiar de ReceitaAgro)
  @override
  Future<Either<Failure, bool?>> getCachedPremiumStatus() async {
    // 1. Try Drift
    // 2. Fallback SharedPrefs
    // 3. Fetch from RevenueCat
  }
}
```

#### 4. Adicionar Drift sync para subscriptions
```dart
// lib/database/sync/entities/sync_subscription_entity.dart
class SyncSubscriptionEntity extends Equatable {
  final int? id;
  final String? firebaseId;
  final String userId;
  final String productId;
  final SubscriptionStatus status;
  final DateTime? expirationDate;
  // ... outros campos
  
  Map<String, dynamic> toFirestore() { /* ... */ }
  factory SyncSubscriptionEntity.fromFirestore(DocumentSnapshot snapshot) { /* ... */ }
}

// lib/database/sync/adapters/subscription_drift_sync_adapter.dart
class SubscriptionDriftSyncAdapter extends DriftSyncAdapterBase<
    SyncSubscriptionEntity, SubscriptionEntry> {
  // Implementar métodos de sync
}
```

#### 5. Configurar RevenueCat product IDs
```dart
// Adicionar em core/environment_config.dart ou constants
class PetivetiProducts {
  static const String monthlyPremium = 'petiveti_premium_monthly';
  static const String yearlyPremium = 'petiveti_premium_yearly';
  static const String lifetime = 'petiveti_lifetime';
}
```

#### 6. Atualizar UI para usar novo repository
```dart
// Providers
@riverpod
IAppSubscriptionRepository subscriptionRepository(Ref ref) {
  final coreRepo = ref.watch(subscriptionRepositoryProvider); // ← Do core
  final localRepo = ref.watch(subscriptionLocalRepositoryProvider);
  return SubscriptionRepositoryImpl(coreRepo, localRepo);
}

// Usage
final hasSubscription = await ref.read(subscriptionRepositoryProvider)
    .hasPetivetiSubscription();
```

#### 7. Testing
- ✅ Configurar sandbox testing (iOS TestFlight / Android Internal Testing)
- ✅ Testar purchase flow completo
- ✅ Testar restore purchases
- ✅ Testar subscription renewal
- ✅ Testar cancellation
- ✅ Validar receipt validation

---

## 📊 COMPARATIVO FINAL

| Feature | app-petiveti | app-receituagro | Winner |
|---------|--------------|-----------------|--------|
| **IAP Real** | ❌ Mock | ✅ RevenueCat | 🏆 ReceitaAgro |
| **Security** | ⚠️ Insegura | ✅ Server-side | 🏆 ReceitaAgro |
| **Offline Support** | ⚠️ Limited | ✅ Drift Multi-layer | 🏆 ReceitaAgro |
| **UI Quality** | ✅ Rich & Detailed | ⚠️ Simplified | 🏆 Petiveti |
| **Code Organization** | ✅ Clean Architecture | ✅ Clean Architecture | 🤝 Empate |
| **Documentation** | ✅ Extensive Comments | ⚠️ Basic | 🏆 Petiveti |
| **Production Ready** | ❌ No (Mock) | ✅ Yes | 🏆 ReceitaAgro |
| **Trial Support** | ⚠️ Simulated | ✅ Real | 🏆 ReceitaAgro |
| **Refund Handling** | ❌ No | ✅ Yes | 🏆 ReceitaAgro |
| **Cross-platform** | ⚠️ Web (Mock) | ✅ iOS/Android | 🏆 ReceitaAgro |
| **Widget Library** | ✅ 8+ custom | ⚠️ 6 simple | 🏆 Petiveti |
| **Complexity** | ⚠️ High | ✅ Moderate | 🏆 ReceitaAgro |

---

## 🎬 CONCLUSÃO

### app-petiveti:
- ✅ **Melhor UI/UX** com coordinator pattern e widgets customizados
- ✅ **Melhor documentação** com comentários extensivos
- ❌ **Não production-ready** - mock implementation
- ❌ **Insegura** - sem validação real
- ❌ **Sem sync** - apenas cache local

### app-receituagro:
- ✅ **Production-ready** com RevenueCat
- ✅ **Segura** com server-side validation
- ✅ **Offline-first** com Drift multi-layer cache
- ✅ **Real IAP** integrado com stores
- ⚠️ **UI mais simples** que Petiveti

### Recomendação:
**Migrar app-petiveti para usar RevenueCat do core package**, mantendo a UI rica que já possui. A melhor solução seria:

1. Manter os widgets customizados do Petiveti
2. Substituir o repository mock pelo wrapper do ReceitaAgro
3. Adicionar Drift sync como ReceitaAgro
4. Configurar product IDs específicos do Petiveti

Resultado: **Best of both worlds** - UI do Petiveti + IAP real do ReceitaAgro.
