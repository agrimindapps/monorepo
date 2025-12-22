# 🚀 Plano de Implementação IAP - Nebulalist

**Data:** 20/12/2024  
**Status Atual:** UI Completa, Backend Não Implementado  
**Prioridade:** ALTA  
**Estimativa:** 8-12 horas de desenvolvimento

---

## 📋 Índice

1. [Análise da Situação Atual](#análise-da-situação-atual)
2. [Arquitetura Proposta](#arquitetura-proposta)
3. [Plano de Implementação](#plano-de-implementação)
4. [Código de Referência](#código-de-referência)
5. [Checklist de Execução](#checklist-de-execução)
6. [Testes](#testes)

---

## 📊 Análise da Situação Atual

### ✅ O Que Já Existe

#### 1. UI Completa e Funcional

**Arquivos:**
```
lib/features/premium/
├── presentation/
│   ├── pages/
│   │   └── premium_page.dart              ✅ UI completa
│   └── widgets/
│       ├── premium_plans_widget.dart      ✅ 3 planos mockados
│       └── premium_benefits_widget.dart   ✅ Lista de benefícios
```

**Funcionalidades UI:**
- ✅ Design moderno com gradiente (Deep Purple → Indigo)
- ✅ 3 planos mockados:
  - Monthly: R$ 9,99/mês
  - Semester: R$ 49,99/6 meses (POPULAR)
  - Annual: R$ 89,99/ano (MELHOR VALOR)
- ✅ Seleção visual de planos
- ✅ Badges de destaque (POPULAR, MELHOR VALOR)
- ✅ Botões de ação (Começar Agora, Restaurar Compras)
- ✅ Links de Termos e Privacidade
- ✅ Responsivo (mobile/desktop)

**Handlers Mockados:**
```dart
void _onStartNow() {
  if (_selectedPlanId == null) {
    _showSnackBar('Selecione um plano primeiro', Colors.orange);
    return;
  }
  
  _showSnackBar(
    'Compra em desenvolvimento - Plano selecionado: $_selectedPlanId',
    Colors.blue,
  );
}

void _onRestorePurchases() {
  _showSnackBar('Restauração em desenvolvimento', Colors.blue);
}
```

#### 2. Lógica de Negócio Preparada

**Controle de Limites (Free vs Premium):**

```dart
// lib/features/lists/data/repositories/list_repository.dart

static const int _freeListsLimit = 10; // ✅ Limite definido

@override
Future<Either<Failure, bool>> canCreateList() async {
  try {
    // TODO: Check if user is premium (RevenueCat integration)
    // Premium users should have unlimited lists
    
    // Check free tier limit
    final count = await _localDataSource.getActiveListsCount(_currentUserId);
    return Right(count < _freeListsLimit); // ⚠️ Sempre free tier
  }
}
```

**Use Case Documentado:**
```dart
// lib/features/lists/domain/usecases/check_list_limit_usecase.dart

/// For free tier users:
/// - Returns true if active lists < 10
/// - Returns false if limit reached
///
/// For premium users:
/// - Always returns true  // ⚠️ NÃO IMPLEMENTADO
```

#### 3. Integração com Core Package

**Dependência:**
```yaml
# pubspec.yaml
dependencies:
  core:
    path: ../../packages/core  # ✅ Core package disponível
```

**Core tem RevenueCat:**
```dart
// packages/core/lib/src/infrastructure/services/revenue_cat_service.dart
class RevenueCatService implements ISubscriptionRepository {
  // ✅ Implementação completa
  // ✅ iOS/Android support
  // ✅ Stream de status
  // ✅ Purchase/Restore
}
```

---

### ❌ O Que Falta Implementar

#### 1. Backend de Subscription
- ❌ Providers Riverpod
- ❌ Integração com RevenueCat
- ❌ Constants de produtos
- ❌ Lógica de verificação premium

#### 2. Verificação de Status Premium
- ❌ Stream de subscription status
- ❌ Checagem em `canCreateList()`
- ❌ UI indicador de status premium

#### 3. Fluxo de Compra
- ❌ Conectar botão "Começar Agora" ao RevenueCat
- ❌ Conectar botão "Restaurar Compras"
- ❌ Tratamento de erros
- ❌ Feedback de loading

---

## 🏗️ Arquitetura Proposta

### Estrutura de Arquivos (Clean Architecture)

```
lib/features/subscription/
├── domain/
│   ├── entities/
│   │   └── subscription_status.dart          # Entity de status
│   ├── repositories/
│   │   └── i_subscription_repository.dart    # Interface (do core)
│   └── usecases/
│       ├── get_subscription_status.dart      # UseCase de status
│       ├── purchase_subscription.dart        # UseCase de compra
│       └── restore_purchases.dart            # UseCase de restauração
├── data/
│   └── repositories/
│       └── subscription_repository_impl.dart # Wrapper do core
└── presentation/
    ├── providers/
    │   └── subscription_providers.dart       # Riverpod providers
    └── widgets/
        └── premium_status_badge.dart         # Badge de status UI

lib/core/
└── constants/
    └── revenuecat_constants.dart             # Product IDs e entitlements
```

### Fluxo de Dados

```
┌─────────────────┐
│   PremiumPage   │ (UI)
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│ subscriptionProvider    │ (Riverpod)
└────────┬────────────────┘
         │
         ▼
┌──────────────────────────┐
│ PurchaseSubscriptionUC   │ (Domain UseCase)
└────────┬─────────────────┘
         │
         ▼
┌──────────────────────────┐
│ SubscriptionRepository   │ (Data Layer)
└────────┬─────────────────┘
         │
         ▼
┌──────────────────────────┐
│ RevenueCatService (Core) │ (Infrastructure)
└────────┬─────────────────┘
         │
         ▼
┌──────────────────────────┐
│   RevenueCat SDK         │
└──────────────────────────┘
```

---

## 🛠️ Plano de Implementação

### FASE 1: Setup e Configuração (1-2 horas)

#### 1.1. Criar Constants

**Arquivo:** `lib/core/constants/revenuecat_constants.dart`

```dart
/// RevenueCat product identifiers e configurações para NebulaList
class RevenueCatConstants {
  RevenueCatConstants._();

  // ========== Product IDs ==========
  
  /// Plano mensal - R$ 9,99/mês
  static const String monthlyProductId = 'nebulalist_monthly';
  
  /// Plano semestral - R$ 49,99/6 meses (Economize 17%)
  static const String semesterProductId = 'nebulalist_semester';
  
  /// Plano anual - R$ 89,99/ano (Economize 25%)
  static const String annualProductId = 'nebulalist_annual';

  // ========== Entitlements ==========
  
  /// Entitlement ID para acesso premium
  /// Usuário com este entitlement ativo tem acesso ilimitado
  static const String premiumEntitlementId = 'premium';

  // ========== Offering IDs ==========
  
  /// Default offering ID (configurado no RevenueCat Dashboard)
  static const String defaultOfferingId = 'default';

  // ========== Package IDs ==========
  
  /// Package ID para plano mensal no RevenueCat
  static const String monthlyPackageId = '\$rc_monthly';
  
  /// Package ID para plano semestral no RevenueCat
  static const String semesterPackageId = '\$rc_six_month';
  
  /// Package ID para plano anual no RevenueCat
  static const String annualPackageId = '\$rc_annual';

  // ========== Feature Limits ==========
  
  /// Limite de listas ativas para usuários free
  static const int freeListsLimit = 10;
  
  /// Limite de listas para premium (ilimitado)
  static const int premiumListsLimit = -1; // -1 = ilimitado

  // ========== Helpers ==========
  
  /// Mapeia planId mockado para product ID real
  static String getProductId(String mockPlanId) {
    switch (mockPlanId) {
      case 'nebulalist_monthly':
        return monthlyProductId;
      case 'nebulalist_semester':
        return semesterProductId;
      case 'nebulalist_annual':
        return annualProductId;
      default:
        return monthlyProductId; // Default
    }
  }
  
  /// Mapeia product ID para package ID
  static String getPackageId(String productId) {
    switch (productId) {
      case monthlyProductId:
        return monthlyPackageId;
      case semesterProductId:
        return semesterPackageId;
      case annualProductId:
        return annualPackageId;
      default:
        return monthlyPackageId;
    }
  }
}
```

#### 1.2. Configurar RevenueCat Dashboard

**Passos:**
1. Acessar https://app.revenuecat.com/
2. Criar projeto "NebulaList"
3. Configurar 3 produtos:
   - `nebulalist_monthly` - R$ 9,99/mês
   - `nebulalist_semester` - R$ 49,99/6 meses
   - `nebulalist_annual` - R$ 89,99/ano
4. Criar entitlement "premium"
5. Vincular produtos ao entitlement
6. Copiar API Keys (iOS/Android)

---

### FASE 2: Domain Layer (1 hora)

#### 2.1. Subscription Status Entity

**Arquivo:** `lib/features/subscription/domain/entities/subscription_status.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_status.freezed.dart';

@freezed
class SubscriptionStatus with _$SubscriptionStatus {
  const factory SubscriptionStatus({
    required bool isPremium,
    required String? productId,
    required DateTime? expirationDate,
    required DateTime? purchaseDate,
    required bool isInTrialPeriod,
    required bool willRenew,
  }) = _SubscriptionStatus;

  factory SubscriptionStatus.free() => const SubscriptionStatus(
        isPremium: false,
        productId: null,
        expirationDate: null,
        purchaseDate: null,
        isInTrialPeriod: false,
        willRenew: false,
      );
}
```

#### 2.2. Use Cases

**Arquivo:** `lib/features/subscription/domain/usecases/get_subscription_status.dart`

```dart
import 'package:core/core.dart';
import '../entities/subscription_status.dart';

/// UseCase para obter status de assinatura
class GetSubscriptionStatus {
  final ISubscriptionRepository _repository;

  GetSubscriptionStatus(this._repository);

  /// Stream de status de assinatura
  Stream<SubscriptionStatus> call() {
    return _repository.subscriptionStatus.map((coreSubscription) {
      if (coreSubscription == null || !coreSubscription.isActive) {
        return SubscriptionStatus.free();
      }

      return SubscriptionStatus(
        isPremium: coreSubscription.isActive,
        productId: coreSubscription.productId,
        expirationDate: coreSubscription.expiresDate,
        purchaseDate: coreSubscription.purchaseDate,
        isInTrialPeriod: coreSubscription.isTrial,
        willRenew: coreSubscription.willRenew,
      );
    });
  }

  /// Verifica se usuário é premium (snapshot único)
  Future<bool> isPremium() async {
    final result = await _repository.hasActiveSubscription();
    return result.fold(
      (failure) => false,
      (isActive) => isActive,
    );
  }
}
```

**Arquivo:** `lib/features/subscription/domain/usecases/purchase_subscription.dart`

```dart
import 'package:core/core.dart';
import '../../core/constants/revenuecat_constants.dart';

/// UseCase para comprar assinatura
class PurchaseSubscription {
  final ISubscriptionRepository _repository;

  PurchaseSubscription(this._repository);

  /// Compra um plano específico
  /// 
  /// [planId] - ID do plano mockado (ex: 'nebulalist_monthly')
  Future<Either<Failure, bool>> call(String planId) async {
    try {
      // 1. Converter planId mockado para product ID real
      final productId = RevenueCatConstants.getProductId(planId);
      
      // 2. Obter offerings do RevenueCat
      final offeringsResult = await _repository.getAvailableOfferings();
      
      return await offeringsResult.fold(
        (failure) => Left(failure),
        (offerings) async {
          // 3. Encontrar o package correspondente
          final package = _findPackageForProduct(offerings, productId);
          
          if (package == null) {
            return Left(
              SubscriptionFailure('Plano não encontrado: $productId'),
            );
          }
          
          // 4. Realizar a compra
          final purchaseResult = await _repository.purchasePackage(package);
          
          return purchaseResult.fold(
            (failure) => Left(failure),
            (_) => const Right(true),
          );
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Erro na compra: $e'));
    }
  }
  
  /// Encontra o package específico nas offerings
  dynamic _findPackageForProduct(dynamic offerings, String productId) {
    // Implementação dependente do tipo de offerings do core
    // Normalmente: offerings.current.availablePackages
    return null; // Placeholder
  }
}
```

**Arquivo:** `lib/features/subscription/domain/usecases/restore_purchases.dart`

```dart
import 'package:core/core.dart';

/// UseCase para restaurar compras
class RestorePurchases {
  final ISubscriptionRepository _repository;

  RestorePurchases(this._repository);

  /// Restaura compras anteriores
  Future<Either<Failure, bool>> call() async {
    try {
      final result = await _repository.restorePurchases();
      
      return result.fold(
        (failure) => Left(failure),
        (customerInfo) {
          // Verifica se há alguma assinatura ativa após restaurar
          final hasActiveSubscription = customerInfo?.entitlements.active
              .containsKey(RevenueCatConstants.premiumEntitlementId) ?? false;
          
          return Right(hasActiveSubscription);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao restaurar: $e'));
    }
  }
}
```

---

### FASE 3: Presentation Layer (2-3 horas)

#### 3.1. Providers

**Arquivo:** `lib/features/subscription/presentation/providers/subscription_providers.dart`

```dart
import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/subscription_status.dart';
import '../../domain/usecases/get_subscription_status.dart';
import '../../domain/usecases/purchase_subscription.dart';
import '../../domain/usecases/restore_purchases.dart';
import '../../../core/constants/revenuecat_constants.dart';

part 'subscription_providers.g.dart';

// ========== Repository Provider ==========

@riverpod
ISubscriptionRepository subscriptionRepository(Ref ref) {
  return RevenueCatService(); // Do core package
}

// ========== UseCase Providers ==========

@riverpod
GetSubscriptionStatus getSubscriptionStatus(Ref ref) {
  return GetSubscriptionStatus(ref.watch(subscriptionRepositoryProvider));
}

@riverpod
PurchaseSubscription purchaseSubscription(Ref ref) {
  return PurchaseSubscription(ref.watch(subscriptionRepositoryProvider));
}

@riverpod
RestorePurchases restorePurchases(Ref ref) {
  return RestorePurchases(ref.watch(subscriptionRepositoryProvider));
}

// ========== State Providers ==========

/// Stream de status de assinatura
@riverpod
Stream<SubscriptionStatus> subscriptionStatus(Ref ref) {
  final useCase = ref.watch(getSubscriptionStatusProvider);
  return useCase.call();
}

/// Provider para verificar se usuário é premium (snapshot)
@riverpod
Future<bool> isPremium(Ref ref) async {
  final useCase = ref.watch(getSubscriptionStatusProvider);
  return useCase.isPremium();
}

// ========== Notifier para ações de compra ==========

@riverpod
class SubscriptionNotifier extends _$SubscriptionNotifier {
  @override
  AsyncValue<String?> build() {
    return const AsyncValue.data(null);
  }

  /// Compra um plano
  Future<void> purchasePlan(String planId) async {
    state = const AsyncValue.loading();
    
    final useCase = ref.read(purchaseSubscriptionProvider);
    final result = await useCase.call(planId);
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (_) => AsyncValue.data('Compra realizada com sucesso!'),
    );
  }

  /// Restaura compras
  Future<void> restorePurchases() async {
    state = const AsyncValue.loading();
    
    final useCase = ref.read(restorePurchasesProvider);
    final result = await useCase.call();
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (hasActive) => hasActive
          ? const AsyncValue.data('Compras restauradas!')
          : const AsyncValue.data('Nenhuma compra encontrada'),
    );
  }

  /// Limpa mensagem
  void clearMessage() {
    state = const AsyncValue.data(null);
  }
}
```

---

### FASE 4: Atualizar UI (2-3 horas)

#### 4.1. Atualizar PremiumPage

**Arquivo:** `lib/features/premium/presentation/pages/premium_page.dart`

```dart
// Adicionar import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../subscription/presentation/providers/subscription_providers.dart';

// Mudar para ConsumerStatefulWidget
class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({super.key});

  @override
  ConsumerState<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage> {
  String? _selectedPlanId;

  @override
  Widget build(BuildContext context) {
    // Observar estado de assinatura
    final subscriptionAsync = ref.watch(subscriptionStatusProvider);
    final notifierState = ref.watch(subscriptionNotifierProvider);

    return subscriptionAsync.when(
      data: (status) {
        // Se já é premium, mostrar tela diferente
        if (status.isPremium) {
          return _buildPremiumActive(status);
        }
        
        // Senão, mostrar tela de upgrade
        return _buildUpgradeScreen(notifierState);
      },
      loading: () => _buildLoading(),
      error: (e, s) => _buildError(e),
    );
  }

  Widget _buildUpgradeScreen(AsyncValue<String?> notifierState) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF673AB7),
              Color(0xFF5E35B1),
              Color(0xFF3F51B5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildContent(notifierState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (resto do código UI existente)

  /// Handler para começar agora (REAL)
  Future<void> _onStartNow() async {
    if (_selectedPlanId == null) {
      _showSnackBar('Selecione um plano primeiro', Colors.orange);
      return;
    }

    // Chamar o notifier para comprar
    await ref.read(subscriptionNotifierProvider.notifier)
        .purchasePlan(_selectedPlanId!);
    
    // Verificar resultado
    final state = ref.read(subscriptionNotifierProvider);
    state.whenOrNull(
      data: (message) {
        if (message != null) {
          _showSnackBar(message, Colors.green);
          // Fechar a tela após compra bem-sucedida
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.of(context).pop();
          });
        }
      },
      error: (e, s) {
        _showSnackBar('Erro na compra: ${e.toString()}', Colors.red);
      },
    );
  }

  /// Handler para restaurar compras (REAL)
  Future<void> _onRestorePurchases() async {
    await ref.read(subscriptionNotifierProvider.notifier)
        .restorePurchases();
    
    final state = ref.read(subscriptionNotifierProvider);
    state.whenOrNull(
      data: (message) {
        if (message != null) {
          _showSnackBar(message, Colors.blue);
        }
      },
      error: (e, s) {
        _showSnackBar('Erro ao restaurar: ${e.toString()}', Colors.red);
      },
    );
  }

  Widget _buildPremiumActive(SubscriptionStatus status) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NebulaList Premium'),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified,
                size: 100,
                color: Color(0xFF673AB7),
              ),
              const SizedBox(height: 24),
              Text(
                'Você é Premium!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Plano: ${status.productId ?? "Desconhecido"}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (status.expirationDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Expira em: ${_formatDate(status.expirationDate!)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildLoading() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Scaffold(
      body: Center(
        child: Text('Erro: $error'),
      ),
    );
  }
}
```

---

### FASE 5: Integrar com Limites de Lista (1 hora)

#### 5.1. Atualizar ListRepository

**Arquivo:** `lib/features/lists/data/repositories/list_repository.dart`

```dart
// Adicionar no construtor
final ISubscriptionRepository _subscriptionRepository;

ListRepository(
  this._localDataSource,
  this._remoteDataSource,
  this._authNotifier,
  this._syncQueueService,
  this._subscriptionRepository, // NOVO
);

// Atualizar canCreateList
@override
Future<Either<Failure, bool>> canCreateList() async {
  try {
    // Verificar se usuário é premium
    final isPremiumResult = await _subscriptionRepository.hasActiveSubscription();
    
    final isPremium = isPremiumResult.fold(
      (failure) => false, // Em caso de erro, assume free tier
      (isActive) => isActive,
    );
    
    // Premium users têm listas ilimitadas
    if (isPremium) {
      return const Right(true);
    }
    
    // Check free tier limit
    final count = await _localDataSource.getActiveListsCount(_currentUserId);
    return Right(count < _freeListsLimit);
  } on CacheException catch (e) {
    return Left(CacheFailure(e.message));
  } catch (e) {
    return Left(UnexpectedFailure('Failed to check list limit: $e'));
  }
}
```

#### 5.2. Atualizar Provider de ListRepository

**Arquivo:** `lib/features/lists/presentation/providers/list_providers.dart`

```dart
import '../../../subscription/presentation/providers/subscription_providers.dart';

@riverpod
ListRepository listRepository(Ref ref) {
  return ListRepository(
    ref.watch(listLocalDataSourceProvider),
    ref.watch(listRemoteDataSourceProvider),
    AuthStateNotifier.instance,
    ref.watch(syncQueueServiceProvider),
    ref.watch(subscriptionRepositoryProvider), // NOVO
  );
}
```

---

## 📝 Checklist de Execução

### Configuração
- [ ] Criar conta no RevenueCat Dashboard
- [ ] Configurar produtos (monthly, semester, annual)
- [ ] Criar entitlement "premium"
- [ ] Obter API Keys (iOS/Android)
- [ ] Configurar App Store Connect / Google Play Console

### Desenvolvimento
- [ ] Criar `revenuecat_constants.dart`
- [ ] Criar entities (`subscription_status.dart`)
- [ ] Criar use cases (get/purchase/restore)
- [ ] Criar providers (`subscription_providers.dart`)
- [ ] Executar `dart run build_runner build`
- [ ] Atualizar `premium_page.dart` (UI → Backend)
- [ ] Atualizar `list_repository.dart` (limite premium)
- [ ] Atualizar providers de lista

### Testes
- [ ] Testar compra em sandbox (iOS)
- [ ] Testar compra em sandbox (Android)
- [ ] Testar restauração de compras
- [ ] Testar limite de listas (free)
- [ ] Testar limite de listas (premium)
- [ ] Testar expiração de assinatura
- [ ] Testar cancelamento

### Analytics
- [ ] Adicionar tracking de `purchase_initiated`
- [ ] Adicionar tracking de `purchase_success`
- [ ] Adicionar tracking de `purchase_failed`
- [ ] Adicionar tracking de `restore_initiated`
- [ ] Adicionar tracking de `restore_success`

---

## 🧪 Testes

### Teste Manual - Fluxo de Compra

```markdown
1. Abrir app sem subscription
2. Criar 10 listas (atingir limite free)
3. Tentar criar 11ª lista → Deve mostrar erro/upgrade prompt
4. Navegar para PremiumPage
5. Selecionar plano
6. Clicar "Começar Agora"
7. Completar compra em sandbox
8. Verificar que status mudou para premium
9. Criar 11ª lista → Deve funcionar
```

### Teste Manual - Restauração

```markdown
1. Comprar subscription em device A
2. Desinstalar app
3. Reinstalar em device B (mesma Apple ID/Google Account)
4. Fazer login
5. Clicar "Restaurar Compras"
6. Verificar que premium foi restaurado
```

---

## 📊 Estimativa de Tempo

| Fase | Tarefa | Tempo Estimado |
|------|--------|----------------|
| 1 | Setup e Configuração | 1-2h |
| 2 | Domain Layer | 1h |
| 3 | Presentation Layer | 2-3h |
| 4 | Atualizar UI | 2-3h |
| 5 | Integrar com Limites | 1h |
| 6 | Testes | 1-2h |
| **TOTAL** | | **8-12h** |

---

## 🎯 Próximos Passos Imediatos

1. **Criar RevenueCatConstants** (15 min)
2. **Configurar RevenueCat Dashboard** (30 min)
3. **Criar Domain Layer** (1h)
4. **Criar Providers** (1h)
5. **Atualizar UI** (2h)

---

**Última Atualização:** 20/12/2024 13:30 UTC  
**Autor:** Equipe de Desenvolvimento  
**Revisão Necessária:** Após implementação
