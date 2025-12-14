import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../domain/entities/subscription_entity.dart' as core_entities;
import '../../domain/interfaces/i_disposable_service.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../../shared/config/environment_config.dart';
import '../../shared/utils/failure.dart';
import '../../shared/utils/subscription_failures.dart';

/// Implementação concreta do repositório de assinaturas usando RevenueCat
///
/// Serviço responsável por gerenciar assinaturas através da plataforma RevenueCat.
/// Suporta múltiplas apps do monorepo com configuração específica por aplicativo.
///
/// Implements [IDisposableService] to ensure proper cleanup of StreamControllers
/// and RevenueCat listeners when the service is no longer needed.
class RevenueCatService implements ISubscriptionRepository, IDisposableService {
  final StreamController<core_entities.SubscriptionEntity?> _subscriptionController =
      StreamController<core_entities.SubscriptionEntity?>.broadcast();

  bool _isInitialized = false;
  bool _isDisabled = false; // For web/dev environments
  bool _isDisposed = false; // Track disposal state

  /// Construtor do RevenueCat service
  /// 
  /// Inicializa automaticamente o serviço conforme a configuração do ambiente
  RevenueCatService() {
    _initialize();
  }

  @override
  Stream<core_entities.SubscriptionEntity?> get subscriptionStatus =>
      _subscriptionController.stream;

  /// Inicializa o RevenueCat
  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      if (kIsWeb) {
        if (kDebugMode) {
          debugPrint('[RevenueCat] Skipped - Web environment detected');
        }
        _isDisabled = true;
        _isInitialized = true;
        return;
      }

      // Determina a API Key baseada na plataforma
      String apiKey;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        apiKey = 'appl_QXSaVxUhpIkHBdHyBHAGvjxTxTR'; // iOS API Key
        debugPrint('[RevenueCat] Usando API Key do iOS');
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        apiKey = 'goog_JYcfxEUeRnReVEdsLkShLQnzCmf'; // Android API Key
        debugPrint('[RevenueCat] Usando API Key do Android');
      } else {
        // Fallback para variável de ambiente se não for iOS nem Android
        apiKey = EnvironmentConfig.getApiKey('REVENUE_CAT_API_KEY');
        if (apiKey.isEmpty) {
          throw PlatformException(
            code: 'MISSING_API_KEY',
            message: 'RevenueCat API key not configured. Please set REVENUE_CAT_API_KEY in environment.',
          );
        }
      }

      debugPrint('[RevenueCat] Configurando SDK...');

      await Purchases.setLogLevel(
        EnvironmentConfig.isDebugMode ? LogLevel.debug : LogLevel.info,
      );

      final configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      _isInitialized = true;
      debugPrint('[RevenueCat] SDK configurado com sucesso');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RevenueCat] Initialization error: $e');
      }
    }
  }

  /// Callback chamado quando informações do cliente são atualizadas
  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    final subscription = _mapCustomerInfoToSubscription(customerInfo);
    _subscriptionController.add(subscription);
  }

  @override
  Future<Either<Failure, bool>> hasActiveSubscription() async {
    if (kIsWeb) return const Right(false);

    try {
      await _ensureInitialized();

      final customerInfo = await Purchases.getCustomerInfo();
      final hasActive = customerInfo.activeSubscriptions.isNotEmpty ||
          customerInfo.nonSubscriptionTransactions.isNotEmpty;

      return Right(hasActive);
    } on PlatformException catch (e) {
      return Left(e.code.toSubscriptionFailure(e.message));
    } catch (e) {
      return Left(SubscriptionUnknownFailure('Erro ao verificar assinatura: $e'));
    }
  }

  @override
  Future<Either<Failure, core_entities.SubscriptionEntity?>> getCurrentSubscription() async {
    if (kIsWeb) return const Right(null);

    try {
      await _ensureInitialized();

      final customerInfo = await Purchases.getCustomerInfo();
      final subscription = _mapCustomerInfoToSubscription(customerInfo);

      return Right(subscription);
    } on PlatformException catch (e) {
      return Left(e.code.toSubscriptionFailure(e.message));
    } catch (e) {
      return Left(SubscriptionUnknownFailure('Erro ao obter assinatura: $e'));
    }
  }

  @override
  Future<Either<Failure, List<core_entities.SubscriptionEntity>>> getUserSubscriptions() async {
    if (kIsWeb) return const Right([]);

    try {
      await _ensureInitialized();
      
      final customerInfo = await Purchases.getCustomerInfo();
      final subscriptions = <core_entities.SubscriptionEntity>[];
      for (final entry in customerInfo.entitlements.active.entries) {
        final entitlement = entry.value;
        final subscription = _mapEntitlementToSubscription(entitlement);
        if (subscription != null) {
          subscriptions.add(subscription);
        }
      }
      for (final entry in customerInfo.entitlements.all.entries) {
        final entitlement = entry.value;
        if (!entitlement.isActive) {
          final subscription = _mapEntitlementToSubscription(entitlement);
          if (subscription != null) {
            subscriptions.add(subscription);
          }
        }
      }

      return Right(subscriptions);
    } on PlatformException catch (e) {
      return Left(RevenueCatFailure(_mapRevenueCatError(e)));
    } catch (e) {
      return Left(RevenueCatFailure('Erro ao obter histórico: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProductInfo>>> getAvailableProducts({
    required List<String> productIds,
  }) async {
    if (kIsWeb) return const Right([]);

    try {
      debugPrint('🔍 [RevenueCat] Buscando produtos: ${productIds.join(", ")}');

      await _ensureInitialized();
      debugPrint('✅ [RevenueCat] SDK inicializado');

      final offerings = await Purchases.getOfferings();
      debugPrint('📦 [RevenueCat] ${offerings.all.length} offering(s) disponível(is)');

      final products = <ProductInfo>[];
      int totalPackages = 0;

      for (final offering in offerings.all.values) {
        debugPrint('   🏷️  Offering: ${offering.identifier}');
        for (final package in offering.availablePackages) {
          totalPackages++;
          final identifier = package.storeProduct.identifier;
          debugPrint('      - Package: $identifier (${package.storeProduct.priceString})');

          if (productIds.contains(identifier)) {
            debugPrint('         ✓ MATCH! Adicionando produto');
            final productInfo = _mapStoreProductToProductInfo(
              package.storeProduct,
            );
            products.add(productInfo);
          }
        }
      }

      debugPrint('📊 [RevenueCat] Resumo:');
      debugPrint('   - Total packages verificados: $totalPackages');
      debugPrint('   - Produtos encontrados: ${products.length}');

      if (products.isEmpty) {
        debugPrint('⚠️ [RevenueCat] ATENÇÃO: Nenhum produto encontrado!');
        debugPrint('   Produtos procurados: ${productIds.join(", ")}');
        debugPrint('   Verifique se os product IDs estão corretos no RevenueCat Dashboard');
      }

      return Right(products);
    } on PlatformException catch (e) {
      debugPrint('❌ [RevenueCat] PlatformException: ${e.code} - ${e.message}');
      return Left(RevenueCatFailure(_mapRevenueCatError(e)));
    } catch (e) {
      debugPrint('❌ [RevenueCat] Erro inesperado: $e');
      return Left(RevenueCatFailure('Erro ao obter produtos: $e'));
    }
  }

  @override
  Future<Either<Failure, core_entities.SubscriptionEntity>> purchaseProduct({
    required String productId,
  }) async {
    if (kIsWeb) {
      return const Left(SubscriptionPaymentFailure('Compras não disponíveis na web'));
    }

    try {
      await _ensureInitialized();

      final offerings = await Purchases.getOfferings();
      Package? targetPackage;
      for (final offering in offerings.all.values) {
        for (final package in offering.availablePackages) {
          if (package.storeProduct.identifier == productId) {
            targetPackage = package;
            break;
          }
        }
        if (targetPackage != null) break;
      }

      if (targetPackage == null) {
        return const Left(SubscriptionPaymentFailure.productUnavailable());
      }

      // ignore: deprecated_member_use
      final purchaseResult = await Purchases.purchasePackage(targetPackage);

      if (purchaseResult.customerInfo.activeSubscriptions.isEmpty) {
        return const Left(SubscriptionPaymentFailure('Compra não foi processada corretamente'));
      }

      final subscription = _mapCustomerInfoToSubscription(
        purchaseResult.customerInfo,
      );

      if (subscription == null) {
        return const Left(SubscriptionPaymentFailure('Erro ao processar compra'));
      }

      return Right(subscription);
    } on PlatformException catch (e) {
      return Left(e.code.toSubscriptionFailure(e.message));
    } catch (e) {
      return Left(SubscriptionUnknownFailure('Erro na compra: $e'));
    }
  }

  @override
  Future<Either<Failure, List<core_entities.SubscriptionEntity>>> restorePurchases() async {
    if (kIsWeb) return const Right([]);

    try {
      await _ensureInitialized();
      
      final customerInfo = await Purchases.restorePurchases();
      final subscriptions = <core_entities.SubscriptionEntity>[];

      for (final entry in customerInfo.entitlements.all.entries) {
        final entitlement = entry.value;
        final subscription = _mapEntitlementToSubscription(entitlement);
        if (subscription != null) {
          subscriptions.add(subscription);
        }
      }

      return Right(subscriptions);
    } on PlatformException catch (e) {
      return Left(RevenueCatFailure(_mapRevenueCatError(e)));
    } catch (e) {
      return Left(RevenueCatFailure('Erro ao restaurar compras: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setUser({
    required String userId,
    Map<String, String>? attributes,
  }) async {
    if (kIsWeb) return const Right(null);

    try {
      await _ensureInitialized();
      
      await Purchases.logIn(userId);

      if (attributes != null) {
        await setUserAttributes(attributes: attributes);
      }

      return const Right(null);
    } on PlatformException catch (e) {
      return Left(RevenueCatFailure(_mapRevenueCatError(e)));
    } catch (e) {
      return Left(RevenueCatFailure('Erro ao definir usuário: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setUserAttributes({
    required Map<String, String> attributes,
  }) async {
    if (kIsWeb) return const Right(null);

    try {
      await _ensureInitialized();
      
      await Purchases.setAttributes(attributes);
      return const Right(null);
    } on PlatformException catch (e) {
      return Left(RevenueCatFailure(_mapRevenueCatError(e)));
    } catch (e) {
      return Left(RevenueCatFailure('Erro ao definir atributos: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isEligibleForTrial({
    required String productId,
  }) async {
    if (kIsWeb) return const Right(false);

    try {
      await _ensureInitialized();
      final hasActive = await hasActiveSubscription();
      
      return hasActive.fold(
        (failure) => Left(failure),
        (hasActiveSubscription) => Right(!hasActiveSubscription),
      );
    } catch (e) {
      return Left(RevenueCatFailure('Erro ao verificar elegibilidade: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getManagementUrl() async {
    if (kIsWeb) return const Right(null);

    try {
      await _ensureInitialized();
      
      final customerInfo = await Purchases.getCustomerInfo();
      final managementUrl = customerInfo.managementURL;

      return Right(managementUrl);
    } on PlatformException catch (e) {
      return Left(RevenueCatFailure(_mapRevenueCatError(e)));
    } catch (e) {
      return Left(RevenueCatFailure('Erro ao obter URL de gerenciamento: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getSubscriptionManagementUrl() async {
    return getManagementUrl();
  }

  @override
  Future<Either<Failure, void>> cancelSubscription({
    String? reason,
  }) async {
    return const Left(RevenueCatFailure(
      'Cancelamento deve ser feito nas configurações da App Store/Play Store'
    ));
  }

  @override
  Future<Either<Failure, bool>> hasPlantisSubscription() async {
    return _hasAppSubscription('plantis');
  }

  @override
  Future<Either<Failure, bool>> hasReceitaAgroSubscription() async {
    return _hasAppSubscription('receituagro');
  }

  @override
  Future<Either<Failure, List<ProductInfo>>> getPlantisProducts() async {
    return getAvailableProducts(productIds: [
      EnvironmentConfig.getProductId('plantis_monthly'),
      EnvironmentConfig.getProductId('plantis_yearly'),
    ]);
  }

  @override
  Future<Either<Failure, List<ProductInfo>>> getReceitaAgroProducts() async {
    return getAvailableProducts(productIds: [
      'receituagro_ass_mensal2',    // Plano mensal
      'receituagro_ass_semestral',  // Plano semestral
      'receituagro_ass_anual',      // Plano anual
    ]);
  }

  @override
  Future<Either<Failure, bool>> hasGasometerSubscription() async {
    return _hasAppSubscription('gasometer');
  }

  @override
  Future<Either<Failure, List<ProductInfo>>> getGasometerProducts() async {
    return getAvailableProducts(productIds: [
      EnvironmentConfig.getProductId('gasometer_monthly'),
      EnvironmentConfig.getProductId('gasometer_yearly'),
    ]);
  }

  @override
  Future<Either<Failure, bool>> hasPetivetiSubscription() async {
    return _hasAppSubscription('petiveti');
  }

  @override
  Future<Either<Failure, List<ProductInfo>>> getPetivetiProducts() async {
    return getAvailableProducts(productIds: [
      'petiveti_premium_monthly',   // Plano mensal - R$ 9,90/mês
      'petiveti_premium_yearly',    // Plano anual - R$ 99,90/ano
      'petiveti_lifetime',          // Compra única vitalícia - R$ 299,90
    ]);
  }

  /// Verifica se tem assinatura ativa para um app específico
  Future<Either<Failure, bool>> _hasAppSubscription(String appName) async {
    try {
      final subscriptionResult = await getCurrentSubscription();
      
      return subscriptionResult.fold(
        (failure) => Left(failure),
        (subscription) {
          if (subscription == null) return const Right(false);
          
          final productId = subscription.productId.toLowerCase();
          final hasApp = productId.contains(appName.toLowerCase());
          final isActive = subscription.isActive;
          
          return Right(hasApp && isActive);
        },
      );
    } catch (e) {
      return Left(RevenueCatFailure('Erro ao verificar assinatura do $appName: $e'));
    }
  }

  /// Garante que o RevenueCat está inicializado
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initialize();
    }
    if (_isDisabled) {
      throw PlatformException(
        code: 'NOT_AVAILABLE', 
        message: 'RevenueCat não disponível nesta plataforma',
      );
    }
    if (!_isInitialized) {
      throw PlatformException(
        code: 'INITIALIZATION_ERROR',
        message: 'Falha ao inicializar RevenueCat',
      );
    }
  }

  /// Mapeia CustomerInfo para SubscriptionEntity
  core_entities.SubscriptionEntity? _mapCustomerInfoToSubscription(CustomerInfo customerInfo) {
    if (customerInfo.activeSubscriptions.isEmpty) return null;

    final activeEntitlement = customerInfo.entitlements.active.values.firstOrNull;
    if (activeEntitlement == null) return null;

    return _mapEntitlementToSubscription(activeEntitlement);
  }

  /// Mapeia EntitlementInfo para SubscriptionEntity
  core_entities.SubscriptionEntity? _mapEntitlementToSubscription(EntitlementInfo entitlement) {
    return core_entities.SubscriptionEntity(
      id: entitlement.identifier,
      userId: entitlement.originalPurchaseDate.toString(),
      productId: entitlement.productIdentifier,
      status: entitlement.isActive 
          ? core_entities.SubscriptionStatus.active 
          : core_entities.SubscriptionStatus.expired,
      tier: _getTierFromProductId(entitlement.productIdentifier),
      expirationDate: _parseDate(entitlement.expirationDate),
      purchaseDate: _parseDate(entitlement.latestPurchaseDate),
      originalPurchaseDate: _parseDate(entitlement.originalPurchaseDate),
      store: _mapRevenueCatStore(entitlement.store.toString()),
      isInTrial: entitlement.periodType == PeriodType.trial,
      isSandbox: entitlement.isSandbox,
      createdAt: _parseDate(entitlement.originalPurchaseDate),
      updatedAt: DateTime.now(),
    );
  }

  /// Mapeia StoreProduct para ProductInfo
  ProductInfo _mapStoreProductToProductInfo(StoreProduct storeProduct) {
    return ProductInfo(
      productId: storeProduct.identifier,
      title: storeProduct.title,
      description: storeProduct.description,
      price: storeProduct.price,
      priceString: storeProduct.priceString,
      currencyCode: storeProduct.currencyCode,
      subscriptionPeriod: storeProduct.subscriptionPeriod?.toString(),
    );
  }

  /// Mapeia Store do RevenueCat para enum Store
  core_entities.Store _mapRevenueCatStore(String store) {
    switch (store.toLowerCase()) {
      case 'app_store':
        return core_entities.Store.appStore;
      case 'play_store':
        return core_entities.Store.playStore;
      case 'stripe':
        return core_entities.Store.stripe;
      case 'promotional':
        return core_entities.Store.promotional;
      default:
        return core_entities.Store.unknown;
    }
  }

  /// Determina o tier baseado no productId
  core_entities.SubscriptionTier _getTierFromProductId(String productId) {
    final id = productId.toLowerCase();
    if (id.contains('premium')) return core_entities.SubscriptionTier.premium;
    if (id.contains('pro')) return core_entities.SubscriptionTier.pro;
    return core_entities.SubscriptionTier.free;
  }

  /// Converte String para DateTime, lidando com formatos do RevenueCat
  DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        try {
          return DateTime.parse(date.replaceAll('Z', ''));
        } catch (e2) {
          return null;
        }
      }
    }
    return null;
  }

  /// Mapeia erros do RevenueCat para mensagens user-friendly
  String _mapRevenueCatError(PlatformException e) {
    switch (e.code) {
      case 'user_cancelled':
        return 'Compra cancelada pelo usuário.';
      case 'store_problem':
        return 'Problema na loja. Tente novamente mais tarde.';
      case 'purchase_not_allowed':
        return 'Compras não permitidas neste dispositivo.';
      case 'purchase_invalid':
        return 'Compra inválida.';
      case 'product_not_available':
        return 'Produto não disponível.';
      case 'product_already_purchased':
        return 'Produto já foi comprado.';
      case 'receipt_already_in_use':
        return 'Recibo já está em uso.';
      case 'invalid_receipt':
        return 'Recibo inválido.';
      case 'missing_receipt_file':
        return 'Arquivo de recibo não encontrado.';
      case 'network_error':
        return 'Erro de rede. Verifique sua conexão.';
      case 'invalid_credentials':
        return 'Credenciais inválidas.';
      case 'unexpected_backend_response':
        return 'Resposta inesperada do servidor.';
      case 'invalid_app_user_id':
        return 'ID do usuário inválido.';
      case 'operation_already_in_progress':
        return 'Operação já em andamento.';
      case 'unknown_backend_error':
        return 'Erro desconhecido no servidor.';
      default:
        return e.message ?? 'Erro desconhecido na assinatura.';
    }
  }

  /// Limpa recursos do serviço
  ///
  /// Implementa [IDisposableService.dispose] para cleanup adequado.
  /// Deve ser chamado quando o serviço não for mais utilizado para evitar memory leaks.
  ///
  /// Called automatically by [InjectionContainer] on app lifecycle events.
  @override
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;
    try {
      if (_isInitialized && !_isDisabled) {
        Purchases.removeCustomerInfoUpdateListener(_onCustomerInfoUpdated);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RevenueCat] Error removing listener: $e');
      }
    }

    // Close StreamController
    try {
      await _subscriptionController.close();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RevenueCat] Error closing subscription controller: $e');
      }
    }

    if (kDebugMode) {
      debugPrint('[RevenueCat] Service disposed successfully');
    }
  }

  @override
  bool get isDisposed => _isDisposed;
}
