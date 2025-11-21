# 🔍 Violações SOLID - Detalhamento Técnico (Packages/Core)

## 🚨 PRIORIDADE P0 - VIOLAÇÕES CRÍTICAS (Ação Imediata)

### Violação Crítica #1: UnifiedSyncManager - God Class
**Arquivo:** `packages/core/src/sync/unified_sync_manager.dart`  
**Linhas:** 1-1014  
**Severidade:** 🔴 P0 Crítico  
**Impacto:** 100% dos apps do monorepo

**Problema:**
```dart
class UnifiedSyncManager {
  // Responsabilidade 1: Orquestração de Sync
  Future<void> syncAll() { ... }
  
  // Responsabilidade 2: Cache Management
  void clearCache() { ... }
  void warmupCache() { ... }
  
  // Responsabilidade 3: Network Handling  
  Future<bool> checkConnectivity() { ... }
  void retryFailedRequests() { ... }
  
  // Responsabilidade 4: Error Handling
  void handleSyncError(Exception e) { ... }
  void reportErrors() { ... }
  
  // Responsabilidade 5: App-Specific Logic
  void syncGasometerData() { ... }
  void syncPlantisData() { ... }
  void syncReceituagroData() { ... }
  
  // Responsabilidade 6: Analytics
  void trackSyncMetrics() { ... }
  
  // Responsabilidade 7: State Management
  void notifyListeners() { ... }
}
```

**Refatoração Sugerida:**
```dart
// Separar em responsabilidades específicas
abstract class ISyncOrchestrator {
  Future<void> orchestrateSync(List<ISyncService> services);
}

abstract class ISyncService {
  Future<SyncResult> sync();
  String get serviceId;
}

abstract class ICacheManager {
  void clear();
  Future<void> warmup();
}

abstract class INetworkMonitor {
  Future<bool> isConnected();
  Stream<bool> get connectivityStream;
}

class AppSyncServiceFactory {
  ISyncService createForApp(String appId) {
    switch (appId) {
      case 'gasometer': return GasometerSyncService();
      case 'plantis': return PlantisSyncService();
      // etc...
    }
  }
}
```

**Esforço:** 5 dias  
**Prioridade:** 🔴 Emergencial

---

### Violação Crítica #2: ISubscriptionRepository - Interface Segregation
**Arquivo:** `packages/core/src/domain/repositories/i_subscription_repository.dart`  
**Linhas:** 1-156  
**Severidade:** 🔴 P0 Crítico  
**Impacto:** 100% dos apps (força implementações desnecessárias)

**Problema:**
```dart
abstract class ISubscriptionRepository {
  // Gasometer specific - força outros apps a implementar
  Future<VehicleSubscription> getVehicleSubscription();
  Future<void> updateVehicleLimit(int limit);
  
  // Plantis specific - força outros apps a implementar  
  Future<PlantSubscription> getPlantSubscription();
  Future<void> updatePlantCareSchedule();
  
  // TaskOlist specific - força outros apps a implementar
  Future<TaskSubscription> getTaskSubscription();
  Future<void> updateTaskCategories();
  
  // ReceitaAgro specific - força outros apps a implementar
  Future<AgroSubscription> getAgroSubscription();
  Future<void> updateDiagnosticLimit();
  
  // Métodos comuns (únicos corretos)
  Future<bool> hasActiveSubscription();
  Future<void> cancelSubscription();
}
```

**Refatoração Sugerida:**
```dart
// Interface base - apenas responsabilidades comuns
abstract class IBaseSubscriptionRepository {
  Future<bool> hasActiveSubscription();
  Future<void> cancelSubscription();
  Future<SubscriptionStatus> getStatus();
}

// Interfaces específicas por domínio
abstract class IVehicleSubscriptionRepository extends IBaseSubscriptionRepository {
  Future<VehicleSubscription> getVehicleSubscription();
  Future<void> updateVehicleLimit(int limit);
}

abstract class IPlantSubscriptionRepository extends IBaseSubscriptionRepository {
  Future<PlantSubscription> getPlantSubscription();
  Future<void> updatePlantCareSchedule();
}

// Factory para criação baseada no app
class SubscriptionRepositoryFactory {
  IBaseSubscriptionRepository createForApp(String appId) {
    switch (appId) {
      case 'gasometer': 
        return getIt<IVehicleSubscriptionRepository>();
      case 'plantis':
        return getIt<IPlantSubscriptionRepository>();
      // etc...
    }
  }
}
```

**Esforço:** 3 dias  
**Prioridade:** 🔴 Emergencial

---

### Violação Crítica #3: Dependency Inversion - Hard Dependencies
**Arquivo:** `packages/core/src/shared/di/injection_container.dart`  
**Linhas:** 45-78  
**Severidade:** 🔴 P0 Crítico  
**Impacto:** 100% dos apps (acoplamento com implementações concretas)

**Problema:**
```dart
class CoreDIContainer {
  void configure() {
    // ❌ PROBLEMA - Dependencies diretas com implementações concretas
    final firebaseAuth = FirebaseAuth.instance;
    final revenueCat = RevenueCat.instance;
    final hive = HiveService(); // Concrete class
    
    getIt.registerSingleton<FirebaseAuth>(firebaseAuth);
    getIt.registerSingleton<RevenueCat>(revenueCat);
    getIt.registerSingleton<HiveService>(hive); // Should be interface
  }
}
```

**Refatoração Sugerida:**
```dart
// Criar abstrações para external dependencies
abstract class IAuthService {
  Future<User?> getCurrentUser();
  Future<void> signOut();
  Stream<User?> get authStateChanges;
}

abstract class ISubscriptionService {
  Future<CustomerInfo> getCustomerInfo();
  Future<void> purchaseProduct(String productId);
}

abstract class IStorageService {
  Future<T?> get<T>(String key);
  Future<void> put<T>(String key, T value);
}

class CoreDIContainer {
  void configure() {
    // ✅ CORRETO - Registrar abstrações
    getIt.registerLazySingleton<IAuthService>(
      () => FirebaseAuthService(FirebaseAuth.instance),
    );
    
    getIt.registerLazySingleton<ISubscriptionService>(
      () => RevenueCatService(RevenueCat.instance),
    );
    
    getIt.registerLazySingleton<IStorageService>(
      () => HiveStorageService(),
    );
  }
}
```

**Esforço:** 2 dias  
**Prioridade:** 🔴 Emergencial

---

### Violação Crítica #4: App-Specific Logic no Core
**Arquivo:** `packages/core/src/infrastructure/services/base_service.dart`  
**Linhas:** 89-134  
**Severidade:** 🔴 P0 Crítico  
**Impacto:** 100% dos apps (viola principio de responsabilidade do core)

**Problema:**
```dart
class BaseService {
  ConfigModel getAppConfig() {
    // ❌ PROBLEMA - Core não deveria conhecer apps específicos
    final appName = Platform.environment['APP_NAME'];
    
    switch (appName) {
      case 'gasometer':
        return GasometerConfig(
          features: ['vehicle_tracking', 'fuel_economy'],
          limits: {'vehicles': 10},
        );
      case 'plantis':
        return PlantisConfig(
          features: ['plant_care', 'watering_schedule'],
          limits: {'plants': 50},
        );
      case 'receituagro':
        return ReceituagroConfig(
          features: ['diagnostics', 'crop_analysis'],
          limits: {'diagnostics': 100},
        );
      default:
        return DefaultConfig();
    }
  }
}
```

**Refatoração Sugerida:**
```dart
// Core define apenas contratos
abstract class IAppConfigProvider {
  ConfigModel getConfig();
  List<String> getSupportedFeatures();
  Map<String, int> getLimits();
}

// Core fornece factory pattern
class AppConfigFactory {
  static IAppConfigProvider? _provider;
  
  static void register(IAppConfigProvider provider) {
    _provider = provider;
  }
  
  static ConfigModel getConfig() {
    if (_provider == null) {
      throw Exception('App config provider not registered');
    }
    return _provider!.getConfig();
  }
}

// Cada app registra sua implementação
// Em gasometer/main.dart:
AppConfigFactory.register(GasometerConfigProvider());

// Em plantis/main.dart:
AppConfigFactory.register(PlantisConfigProvider());
```

**Esforço:** 2 dias  
**Prioridade:** 🔴 Emergencial

---

## 🟡 PRIORIDADE P1 - VIOLAÇÕES ALTAS (Sprint 3-4)

### Violação Alta #1: FirebaseAuthService - Single Responsibility
**Arquivo:** `packages/core/src/infrastructure/services/firebase_auth_service.dart`  
**Linhas:** 1-387  
**Severidade:** 🟡 P1 Alto  
**Impacto:** 83% dos apps

**Problema:**
```dart
class FirebaseAuthService {
  // Responsabilidade 1: Authentication
  Future<User?> signIn(String email, String password) { ... }
  
  // Responsabilidade 2: User Management  
  Future<void> updateProfile(UserProfile profile) { ... }
  
  // Responsabilidade 3: Session Management
  void refreshToken() { ... }
  
  // Responsabilidade 4: Analytics Tracking
  void trackSignInEvent() { ... }
  
  // Responsabilidade 5: Error Handling
  void handleAuthError(FirebaseAuthException e) { ... }
  
  // Responsabilidade 6: Cache Management
  void cacheUserData() { ... }
}
```

**Refatoração Sugerida:**
```dart
abstract class IAuthService {
  Future<AuthResult> signIn(String email, String password);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
}

abstract class IUserManagementService {
  Future<void> updateProfile(UserProfile profile);
  Future<UserProfile> getProfile();
}

abstract class ISessionService {
  Future<void> refreshToken();
  bool isSessionValid();
}

class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _firebaseAuth;
  final IAnalyticsService _analytics;
  final IUserCacheService _cache;
  
  // Apenas responsabilidades de autenticação
}
```

**Esforço:** 3 dias  
**Prioridade:** 🟡 Alto

---

### Violação Alta #2: RevenueCatService - Open/Closed Principle
**Arquivo:** `packages/core/src/infrastructure/services/revenue_cat_service.dart`  
**Linhas:** 67-145  
**Severidade:** 🟡 P1 Alto  
**Impacto:** 83% dos apps

**Problema:**
```dart
class RevenueCatService {
  Future<void> purchaseProduct(String productId) async {
    // ❌ PROBLEMA - Hardcoded product logic
    if (productId.contains('gasometer')) {
      await _handleGasometerPurchase(productId);
    } else if (productId.contains('plantis')) {
      await _handlePlantisPurchase(productId);
    } else if (productId.contains('receituagro')) {
      await _handleReceituagroPurchase(productId);
    }
  }
}
```

**Refatoração Sugerida:**
```dart
abstract class IPurchaseHandler {
  bool canHandle(String productId);
  Future<PurchaseResult> handle(String productId);
}

class RevenueCatService {
  final List<IPurchaseHandler> _handlers = [];
  
  void registerHandler(IPurchaseHandler handler) {
    _handlers.add(handler);
  }
  
  Future<void> purchaseProduct(String productId) async {
    final handler = _handlers.firstWhere(
      (h) => h.canHandle(productId),
      orElse: () => DefaultPurchaseHandler(),
    );
    
    await handler.handle(productId);
  }
}

// Cada app registra seu handler
class GasometerPurchaseHandler implements IPurchaseHandler {
  bool canHandle(String productId) => productId.contains('gasometer');
  Future<PurchaseResult> handle(String productId) { ... }
}
```

**Esforço:** 2 dias  
**Prioridade:** 🟡 Alto

---

## 🟢 PRIORIDADE P2 - VIOLAÇÕES MÉDIAS (Sprint 5-6)

### Violação Média #1: Utils com Static Dependencies
**Arquivo:** `packages/core/src/shared/utils/date_utils.dart`  
**Linhas:** 23-67  
**Severidade:** 🟢 P2 Médio  
**Impacto:** 67% dos apps

**Problema:**
```dart
class DateUtils {
  // ❌ PROBLEMA - Dependency estática na localização
  static String formatDate(DateTime date) {
    final locale = Platform.localeName; // Hard dependency
    return DateFormat.yMd(locale).format(date);
  }
}
```

**Refatoração Sugerida:**
```dart
abstract class IDateFormatter {
  String formatDate(DateTime date);
  String formatTime(DateTime date);
}

class LocalizedDateFormatter implements IDateFormatter {
  final String locale;
  
  LocalizedDateFormatter(this.locale);
  
  String formatDate(DateTime date) {
    return DateFormat.yMd(locale).format(date);
  }
}
```

**Esforço:** 1 dia  
**Prioridade:** 🟢 Médio

---

## 📊 Resumo de Impacto por Violação

| Violação | Severidade | Apps Afetados | Esforço | Risco |
|----------|------------|---------------|---------|-------|
| **UnifiedSyncManager God Class** | P0 | 6/6 (100%) | 5 dias | Catastrófico |
| **ISubscriptionRepository ISP** | P0 | 6/6 (100%) | 3 dias | Catastrófico |
| **Hard Dependencies DI** | P0 | 6/6 (100%) | 2 dias | Alto |
| **App-Specific Logic** | P0 | 6/6 (100%) | 2 dias | Alto |
| **FirebaseAuthService SRP** | P1 | 5/6 (83%) | 3 dias | Médio |
| **RevenueCatService OCP** | P1 | 5/6 (83%) | 2 dias | Médio |
| **Utils Static Dependencies** | P2 | 4/6 (67%) | 1 dia | Baixo |

**Total estimado P0:** 12 dias de desenvolvimento crítico  
**Total estimado P1:** 8 dias de desenvolvimento  
**Total estimado P2:** 5 dias de melhorias  

---

## 🎯 Ordem de Implementação Recomendada

1. **UnifiedSyncManager** - Maior impacto, maior complexidade
2. **ISubscriptionRepository** - Menor complexidade, alto impacto
3. **Hard Dependencies** - Foundation para outras refatorações
4. **App-Specific Logic** - Limpar responsabilidades do core
5. **FirebaseAuthService** - Melhorar manutenibilidade
6. **RevenueCatService** - Adicionar extensibilidade
7. **Utils** - Polimentos finais

Esta ordem minimiza breaking changes e estabelece fundações sólidas para as refatorações subsequentes.