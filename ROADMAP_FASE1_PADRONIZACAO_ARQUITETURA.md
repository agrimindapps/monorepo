# 🏗️ ROADMAP FASE 1: Padronização de Arquitetura

**Objetivo**: Elevar ReceitaAgro e Plantis ao nível arquitetural do Gasometer
**Template de Referência**: app-gasometer (Score 9.9/10)
**Duração Estimada**: 5-7 dias de desenvolvimento
**Impacto Esperado**: +1.5 a +2.0 pontos no score de cada app

---

## 📊 Estado Atual vs Estado Desejado

| Aspecto | Gasometer (9.9) | ReceitaAgro (8.7) | Plantis (8.5) | META |
|---------|-----------------|-------------------|---------------|------|
| Arquitetura | Clean + Injectable | Clean + Singleton | Provider | Clean + Injectable |
| UseCases | 11 ✅ | 0 ❌ | 0 ❌ | 8-12 por app |
| DI Pattern | Injectable | GetIt manual | GetIt manual | Injectable |
| Testabilidade | Alta (UseCases) | Média (Services) | Baixa (Providers) | Alta |
| Separation of Concerns | Perfeita | Boa | Média | Perfeita |

---

## 🎯 FASE 1 - Objetivos Específicos

### 1.1 Migrar para Clean Architecture (ReceitaAgro e Plantis)
- ✅ ReceitaAgro: **JÁ TEM Clean Architecture** (apenas melhorar)
- 🔧 Plantis: **PRECISA migrar de Provider para Clean**

### 1.2 Criar UseCases em TODOS os Apps
- 🔧 ReceitaAgro: Criar 8-10 UseCases
- 🔧 Plantis: Criar 10-12 UseCases

### 1.3 Migrar GetIt → Injectable
- 🔧 ReceitaAgro: Substituir Singleton + GetIt manual por Injectable
- 🔧 Plantis: Substituir GetIt manual por Injectable

### 1.4 Padronizar Structure de Camadas
- Domain / Data / Presentation
- Entities / UseCases / Repositories
- DataSources / Models / Providers

---

## 📦 PARTE 1: ReceitaAgro - Evolução Arquitetural

### ✅ Pontos Fortes Existentes
```
✅ Clean Architecture implementada
✅ Domain layer com entities
✅ Repository pattern funcionando
✅ Cache Hive robusto
✅ Cloud Functions integration
✅ Remote Config feature flags
```

### 🔧 Gaps a Preencher

#### 1.1.1 Criar UseCases Layer (8-10 UseCases)

**UseCases Necessários**:

```dart
// Premium/Subscription UseCases
1. check_premium_status.dart
   → Future<Either<Failure, PremiumStatus>> call()

2. purchase_premium.dart
   → Future<Either<Failure, SubscriptionEntity>> call(PurchaseParams)

3. restore_purchases.dart
   → Future<Either<Failure, bool>> call()

4. start_free_trial.dart
   → Future<Either<Failure, bool>> call()

5. is_eligible_for_trial.dart
   → Future<Either<Failure, bool>> call()

6. get_available_products.dart
   → Future<Either<Failure, List<ProductInfo>>> call()

// Feature Access UseCases
7. can_use_feature.dart
   → Future<Either<Failure, bool>> call(FeatureParams)

8. has_feature_access.dart
   → Future<Either<Failure, bool>> call(String featureKey)

// Cache UseCases (opcional, pode manter no repository)
9. cache_premium_status.dart
10. clear_premium_cache.dart
```

**Estrutura de Arquivos**:
```
lib/features/subscription/
├── domain/
│   ├── entities/
│   │   └── premium_status.dart (já existe)
│   ├── repositories/
│   │   └── i_subscription_repository.dart (já existe)
│   └── usecases/                    ← CRIAR
│       ├── check_premium_status.dart
│       ├── purchase_premium.dart
│       ├── restore_purchases.dart
│       ├── start_free_trial.dart
│       ├── is_eligible_for_trial.dart
│       ├── get_available_products.dart
│       ├── can_use_feature.dart
│       └── has_feature_access.dart
```

#### 1.1.2 Migrar Singleton → Injectable

**Problema Atual** (premium_service.dart):
```dart
❌ ANTI-PATTERN
class ReceitaAgroPremiumService extends ChangeNotifier {
  static ReceitaAgroPremiumService? _instance;

  static ReceitaAgroPremiumService get instance {
    _instance ??= ReceitaAgroPremiumService._internal();
    return _instance!;
  }

  ReceitaAgroPremiumService._internal();
}
```

**Solução com Injectable**:
```dart
✅ CLEAN PATTERN
@injectable
class ReceitaAgroPremiumService extends ChangeNotifier {
  ReceitaAgroPremiumService({
    required ReceitaAgroAnalyticsService analytics,
    required ReceitaAgroCloudFunctionsService cloudFunctions,
    required ReceitaAgroRemoteConfigService remoteConfig,
  }) : _analytics = analytics,
       _cloudFunctions = cloudFunctions,
       _remoteConfig = remoteConfig;

  final ReceitaAgroAnalyticsService _analytics;
  final ReceitaAgroCloudFunctionsService _cloudFunctions;
  final ReceitaAgroRemoteConfigService _remoteConfig;
}
```

**Migração GetIt → Injectable**:

```dart
// ANTES (injection_container.dart)
void setupLocator() {
  // Analytics
  sl.registerLazySingleton<ReceitaAgroAnalyticsService>(
    () => ReceitaAgroAnalyticsService(),
  );

  // Premium Service
  sl.registerLazySingleton<ReceitaAgroPremiumService>(
    () {
      final service = ReceitaAgroPremiumService(
        analytics: sl<ReceitaAgroAnalyticsService>(),
        cloudFunctions: sl<ReceitaAgroCloudFunctionsService>(),
        remoteConfig: sl<ReceitaAgroRemoteConfigService>(),
      );
      return service;
    },
  );
}

// DEPOIS (Com Injectable)
@module
abstract class AppModule {
  // Nenhuma configuração manual necessária!
  // Injectable gera tudo automaticamente
}

// No main.dart
void main() async {
  await configureDependencies(); // Injectable auto-wiring
  runApp(MyApp());
}
```

#### 1.1.3 Atualizar Presentation Layer para Usar UseCases

**Antes** (subscription_provider.dart):
```dart
class SubscriptionProvider extends ChangeNotifier {
  final ReceitaAgroPremiumService _premiumService;

  Future<void> checkPremiumStatus() async {
    _isLoading = true;
    notifyListeners();

    // Lógica direta no provider ❌
    final status = await _premiumService.getPremiumStatus();
    // ...
  }
}
```

**Depois** (Com UseCases):
```dart
@injectable
class SubscriptionProvider extends ChangeNotifier {
  final CheckPremiumStatus _checkPremiumStatus;
  final PurchasePremium _purchasePremium;
  final RestorePurchases _restorePurchases;

  SubscriptionProvider({
    required CheckPremiumStatus checkPremiumStatus,
    required PurchasePremium purchasePremium,
    required RestorePurchases restorePurchases,
  }) : _checkPremiumStatus = checkPremiumStatus,
       _purchasePremium = purchasePremium,
       _restorePurchases = restorePurchases;

  Future<void> checkPremiumStatus() async {
    _isLoading = true;
    notifyListeners();

    // UseCase com Either<Failure, Success> ✅
    final result = await _checkPremiumStatus(const NoParams());
    result.fold(
      (failure) => _handleError(failure),
      (status) => _handleSuccess(status),
    );
  }
}
```

---

## 📦 PARTE 2: Plantis - Migração Completa para Clean Architecture

### ❌ Problemas Atuais

```
❌ Provider pattern direto (sem camadas)
❌ Lógica de negócio misturada com UI
❌ Sem UseCases
❌ Testabilidade limitada
❌ Acoplamento alto
```

### 🎯 Nova Estrutura (Template: Gasometer)

```
lib/features/premium/
├── domain/                          ← CRIAR TUDO
│   ├── entities/
│   │   ├── premium_status.dart
│   │   └── subscription_plan.dart
│   ├── repositories/
│   │   └── premium_repository.dart  (interface)
│   └── usecases/
│       ├── check_premium_status.dart
│       ├── purchase_premium.dart
│       ├── restore_purchases.dart
│       ├── start_free_trial.dart
│       ├── is_eligible_for_trial.dart
│       ├── get_available_products.dart
│       ├── can_use_feature.dart
│       ├── can_add_plant.dart
│       ├── can_use_advanced_reminders.dart
│       └── can_export_data.dart
│
├── data/                            ← REORGANIZAR
│   ├── datasources/
│   │   ├── premium_remote_data_source.dart  (RevenueCat)
│   │   ├── premium_local_data_source.dart   (Cache)
│   │   └── premium_sync_data_source.dart    (Sync simples)
│   ├── models/
│   │   ├── premium_status_model.dart
│   │   └── subscription_plan_model.dart
│   ├── repositories/
│   │   └── premium_repository_impl.dart
│   └── services/
│       └── subscription_sync_service.dart   (já existe, mover)
│
└── presentation/                    ← REFATORAR
    ├── providers/
    │   └── premium_provider.dart    (usar UseCases)
    ├── pages/
    │   └── premium_page.dart
    └── widgets/
        └── premium_banner.dart
```

### 🔨 Passos de Migração (Plantis)

#### 2.1 Criar Domain Layer (PASSO 1)

**Entities** (copiar estrutura do Gasometer):
```dart
// lib/features/premium/domain/entities/premium_status.dart
class PremiumStatus {
  final bool isPremium;
  final DateTime? expirationDate;
  final String? planId;
  final bool isInTrial;
  final DateTime? trialEndDate;
  final Map<String, bool> features;

  // Métodos de conveniência
  bool canUseFeature(String featureId) =>
      isPremium || features[featureId] == true;

  bool canAddPlant(int currentCount) =>
      isPremium || currentCount < 5; // Free limit

  bool canUseAdvancedReminders() => isPremium;
  bool canExportData() => isPremium;
}
```

**Repository Interface**:
```dart
// lib/features/premium/domain/repositories/premium_repository.dart
abstract class PremiumRepository {
  Stream<PremiumStatus> get premiumStatus;

  Future<Either<Failure, bool>> hasActivePremium();
  Future<Either<Failure, PremiumStatus>> getPremiumStatus();
  Future<Either<Failure, List<ProductInfo>>> getAvailableProducts();
  Future<Either<Failure, SubscriptionEntity>> purchasePremium({
    required String productId,
  });
  Future<Either<Failure, bool>> restorePurchases();
  Future<Either<Failure, bool>> startFreeTrial();
  Future<Either<Failure, bool>> isEligibleForTrial();

  // Feature checks
  Future<Either<Failure, bool>> canUseFeature(String featureId);
  Future<Either<Failure, bool>> canAddPlant(int currentCount);
  Future<Either<Failure, bool>> canUseAdvancedReminders();
  Future<Either<Failure, bool>> canExportData();
}
```

**UseCases** (template do Gasometer):
```dart
// lib/features/premium/domain/usecases/check_premium_status.dart
@injectable
class CheckPremiumStatus implements UseCase<PremiumStatus, NoParams> {
  CheckPremiumStatus(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<Failure, PremiumStatus>> call(NoParams params) {
    return repository.getPremiumStatus();
  }
}

// lib/features/premium/domain/usecases/can_add_plant.dart
@injectable
class CanAddPlant implements UseCase<bool, CanAddPlantParams> {
  CanAddPlant(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<Failure, bool>> call(CanAddPlantParams params) {
    return repository.canAddPlant(params.currentCount);
  }
}

// Params
class CanAddPlantParams extends UseCaseParams {
  const CanAddPlantParams({required this.currentCount});
  final int currentCount;

  @override
  List<Object> get props => [currentCount];
}
```

#### 2.2 Criar Data Layer (PASSO 2)

**DataSources**:
```dart
// lib/features/premium/data/datasources/premium_remote_data_source.dart
abstract class PremiumRemoteDataSource {
  Future<Either<Failure, List<ProductInfo>>> getAvailableProducts();
  Future<Either<Failure, SubscriptionEntity>> purchaseProduct({
    required String productId,
  });
  Future<Either<Failure, List<SubscriptionEntity>>> restorePurchases();
  Future<Either<Failure, void>> setUser({
    required String userId,
    Map<String, String>? attributes,
  });
}

@LazySingleton(as: PremiumRemoteDataSource)
class PremiumRemoteDataSourceImpl implements PremiumRemoteDataSource {
  PremiumRemoteDataSourceImpl(this._revenueCatService);
  final RevenueCatService _revenueCatService;

  @override
  Future<Either<Failure, List<ProductInfo>>> getAvailableProducts() async {
    try {
      final products = await _revenueCatService.getAvailableProducts();
      return Right(products);
    } on PlatformException catch (e) {
      return Left(SubscriptionServerFailure(e.message));
    }
  }

  // ... outros métodos
}
```

**Repository Implementation**:
```dart
// lib/features/premium/data/repositories/premium_repository_impl.dart
@LazySingleton(as: PremiumRepository)
class PremiumRepositoryImpl implements PremiumRepository {
  PremiumRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.syncService,
  });

  final PremiumRemoteDataSource remoteDataSource;
  final PremiumLocalDataSource localDataSource;
  final SubscriptionSyncService syncService;

  @override
  Stream<PremiumStatus> get premiumStatus => syncService.premiumStatusStream;

  @override
  Future<Either<Failure, PremiumStatus>> getPremiumStatus() async {
    try {
      final status = syncService.currentStatus;
      return Right(status);
    } catch (e) {
      return Left(SubscriptionUnknownFailure(e.toString()));
    }
  }

  // ... implementar todos os métodos
}
```

#### 2.3 Refatorar Presentation Layer (PASSO 3)

**Provider com UseCases**:
```dart
// lib/features/premium/presentation/providers/premium_provider.dart
@injectable
class PremiumProvider extends ChangeNotifier {
  PremiumProvider({
    required CheckPremiumStatus checkPremiumStatus,
    required PurchasePremium purchasePremium,
    required RestorePurchases restorePurchases,
    required GetAvailableProducts getAvailableProducts,
    required CanAddPlant canAddPlant,
    required CanUseAdvancedReminders canUseAdvancedReminders,
  }) : _checkPremiumStatus = checkPremiumStatus,
       _purchasePremium = purchasePremium,
       _restorePurchases = restorePurchases,
       _getAvailableProducts = getAvailableProducts,
       _canAddPlant = canAddPlant,
       _canUseAdvancedReminders = canUseAdvancedReminders;

  final CheckPremiumStatus _checkPremiumStatus;
  final PurchasePremium _purchasePremium;
  final RestorePurchases _restorePurchases;
  final GetAvailableProducts _getAvailableProducts;
  final CanAddPlant _canAddPlant;
  final CanUseAdvancedReminders _canUseAdvancedReminders;

  PremiumStatus? _status;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  PremiumStatus? get status => _status;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPremium => _status?.isPremium ?? false;

  // Methods usando UseCases
  Future<void> checkStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _checkPremiumStatus(const NoParams());
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (status) {
        _status = status;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> canAddPlant(int currentCount) async {
    final result = await _canAddPlant(
      CanAddPlantParams(currentCount: currentCount),
    );
    return result.fold(
      (failure) => false,
      (canAdd) => canAdd,
    );
  }

  // ... outros métodos
}
```

#### 2.4 Setup Injectable (PASSO 4)

**Adicionar dependências** (pubspec.yaml):
```yaml
dependencies:
  injectable: ^2.3.2
  get_it: ^7.6.4

dev_dependencies:
  injectable_generator: ^2.4.1
  build_runner: ^2.4.6
```

**Criar injection config**:
```dart
// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async => getIt.init();
```

**Atualizar main.dart**:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup Injectable
  await configureDependencies();

  runApp(const MyApp());
}
```

**Gerar código**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📋 Checklist de Execução

### ReceitaAgro (3-4 dias)

**DIA 1: Criar UseCases Layer**
- [ ] Criar diretório `domain/usecases/`
- [ ] Implementar 8-10 UseCases (copiar template do Gasometer)
- [ ] Criar UseCase params classes
- [ ] Adicionar annotations `@injectable`

**DIA 2: Migrar para Injectable**
- [ ] Adicionar dependencies (injectable, injectable_generator)
- [ ] Criar `injection.dart` e `injection.config.dart`
- [ ] Remover Singleton pattern do PremiumService
- [ ] Adicionar `@injectable` annotations em todos os services
- [ ] Run build_runner
- [ ] Atualizar main.dart para usar `configureDependencies()`

**DIA 3: Refatorar Providers para Usar UseCases**
- [ ] Injetar UseCases no SubscriptionProvider
- [ ] Substituir chamadas diretas ao service por UseCases
- [ ] Remover lógica de negócio do provider
- [ ] Testar todos os fluxos

**DIA 4: Testing & Polish**
- [ ] Criar testes unitários para UseCases
- [ ] Testar integração completa
- [ ] Flutter analyze
- [ ] Documentar mudanças

---

### Plantis (4-5 dias)

**DIA 1: Criar Domain Layer**
- [ ] Criar estrutura de diretórios (domain/entities, domain/repositories, domain/usecases)
- [ ] Migrar/criar entities (PremiumStatus, SubscriptionPlan)
- [ ] Criar repository interface
- [ ] Implementar 10-12 UseCases

**DIA 2: Criar Data Layer**
- [ ] Criar datasources (remote, local)
- [ ] Criar models com fromJson/toJson
- [ ] Implementar repository implementation
- [ ] Mover/refatorar SubscriptionSyncService

**DIA 3: Setup Injectable**
- [ ] Adicionar dependencies
- [ ] Criar injection setup
- [ ] Adicionar @injectable annotations
- [ ] Run build_runner
- [ ] Atualizar main.dart

**DIA 4: Refatorar Presentation**
- [ ] Refatorar PremiumProvider para usar UseCases
- [ ] Atualizar UI para usar novo provider
- [ ] Remover código legado
- [ ] Testar todos os fluxos

**DIA 5: Testing & Polish**
- [ ] Criar testes para UseCases
- [ ] Testar integração
- [ ] Flutter analyze
- [ ] Documentar arquitetura

---

## 📊 Métricas de Sucesso (FASE 1)

### ReceitaAgro
- **Score Atual**: 8.7/10
- **Score Esperado**: 9.2-9.4/10
- **Ganhos**:
  - ✅ UseCases implementados (+0.3)
  - ✅ Injectable migration (+0.2)
  - ✅ Testabilidade melhorada (+0.2)

### Plantis
- **Score Atual**: 8.5/10
- **Score Esperado**: 9.0-9.3/10
- **Ganhos**:
  - ✅ Clean Architecture (+0.5)
  - ✅ UseCases implementados (+0.3)
  - ✅ Injectable setup (+0.2)
  - ✅ Repository pattern (+0.2)

### Monorepo Total
- **3 apps com Clean Architecture + Injectable** ✅
- **30+ UseCases totais** (11 Gasometer + 8-10 ReceitaAgro + 10-12 Plantis)
- **Testabilidade maximizada** em todos os apps
- **Padronização completa** de arquitetura

---

## 🚨 Riscos e Mitigações

### Risco 1: Breaking Changes em Produção
**Mitigação**:
- Implementar feature flags para novo código
- Manter código legado durante transição
- Testes extensivos antes de deploy
- Rollout gradual (10% → 50% → 100%)

### Risco 2: Tempo de Desenvolvimento Estoura
**Mitigação**:
- Focar em ReceitaAgro primeiro (menor impacto)
- Template pronto do Gasometer acelera processo
- Pair programming para pontos críticos
- Buffer de 1-2 dias no cronograma

### Risco 3: Performance Degradation
**Mitigação**:
- UseCases são lightweight (apenas delegates)
- Injectable tem overhead mínimo
- Monitorar métricas de performance
- Rollback plan se necessário

---

## 🎯 Critérios de Conclusão (FASE 1)

### ✅ ReceitaAgro COMPLETO quando:
- [ ] 8-10 UseCases implementados e funcionando
- [ ] Injectable configurado e build_runner rodando
- [ ] Singleton pattern removido completamente
- [ ] Providers usando UseCases (sem chamadas diretas)
- [ ] Flutter analyze: 0 errors
- [ ] Testes unitários para UseCases críticos
- [ ] Score ≥ 9.2/10

### ✅ Plantis COMPLETO quando:
- [ ] Clean Architecture completa (domain/data/presentation)
- [ ] 10-12 UseCases implementados
- [ ] Repository pattern funcionando
- [ ] Injectable configurado
- [ ] Código legado removido
- [ ] Flutter analyze: 0 errors
- [ ] Testes unitários básicos
- [ ] Score ≥ 9.0/10

### ✅ FASE 1 COMPLETA quando:
- [ ] ReceitaAgro ✅
- [ ] Plantis ✅
- [ ] Documentação atualizada
- [ ] Commit + PR criado
- [ ] Code review aprovado
- [ ] Deploy em staging testado
- [ ] Pronto para FASE 2 (Sync Avançado)

---

## 💡 Próximos Passos

Após aprovação deste plano:

1. **Revisão final** do roadmap com stakeholders
2. **Escolher app para começar** (recomendado: ReceitaAgro)
3. **Setup inicial** (dependencies, estrutura de pastas)
4. **Execução iterativa** dia a dia
5. **Code review contínuo**
6. **Testing paralelo**

**Estimativa Total FASE 1**: 5-7 dias de desenvolvimento focado

**ROI**: +1.5 pontos de score, testabilidade 3x melhor, base sólida para FASE 2-4

---

Pronto para começar? 🚀
