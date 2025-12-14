import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../../shared/utils/failure.dart';

/// Mock implementation of ISubscriptionRepository for testing on Web/Localhost
class MockSubscriptionService implements ISubscriptionRepository {
  final _controller = StreamController<SubscriptionEntity?>.broadcast();
  SubscriptionEntity? _currentSubscription;
  static const String _storageKey = 'mock_subscription_data';
  final Completer<void> _initCompleter = Completer<void>();

  MockSubscriptionService() {
    _loadPersistedSubscription();
  }

  Future<void> _loadPersistedSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        try {
          _currentSubscription = SubscriptionEntity.fromFirebaseMap(jsonMap);
          _controller.add(_currentSubscription);
          debugPrint('✅ MockSubscriptionService: Loaded persisted subscription: ${_currentSubscription?.productId}');
        } catch (e) {
          debugPrint('❌ MockSubscriptionService: Failed to parse persisted subscription: $e');
          _controller.add(null);
        }
      } else {
        _controller.add(null);
      }
    } catch (e) {
      debugPrint('❌ MockSubscriptionService: Error loading persistence: $e');
      _controller.add(null);
    } finally {
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    }
  }

  Future<void> _persistSubscription(SubscriptionEntity? subscription) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (subscription == null) {
        await prefs.remove(_storageKey);
      } else {
        final jsonMap = subscription.toFirebaseMap();
        await prefs.setString(_storageKey, json.encode(jsonMap));
      }
    } catch (e) {
      debugPrint('❌ MockSubscriptionService: Error saving persistence: $e');
    }
  }

  @override
  Stream<SubscriptionEntity?> get subscriptionStatus => _controller.stream;

  @override
  Future<Either<Failure, bool>> hasActiveSubscription() async {
    await _initCompleter.future;
    return Right(_currentSubscription?.isActive ?? false);
  }

  @override
  Future<Either<Failure, SubscriptionEntity?>> getCurrentSubscription() async {
    await _initCompleter.future;
    return Right(_currentSubscription);
  }

  @override
  Future<Either<Failure, List<SubscriptionEntity>>> getUserSubscriptions() async {
    await _initCompleter.future;
    return Right(_currentSubscription != null ? [_currentSubscription!] : []);
  }

  @override
  Future<Either<Failure, List<ProductInfo>>> getAvailableProducts({
    required List<String> productIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return Right(_getMockProducts());
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> purchaseProduct({
    required String productId,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    
    final now = DateTime.now();
    final expirationDate = now.add(const Duration(days: 365)); // Default to 1 year
    
    final newSubscription = SubscriptionEntity(
      id: 'mock_sub_${now.millisecondsSinceEpoch}',
      productId: productId,
      status: SubscriptionStatus.active,
      tier: SubscriptionTier.premium,
      expirationDate: expirationDate,
      purchaseDate: now,
      originalPurchaseDate: now,
      store: Store.promotional,
      userId: 'mock_user',
      isSandbox: true,
      isDirty: true,
      isDeleted: false,
      version: 1,
      createdAt: now,
      updatedAt: now,
    );

    _currentSubscription = newSubscription;
    _controller.add(newSubscription);
    await _persistSubscription(newSubscription);
    
    return Right(newSubscription);
  }

  @override
  Future<Either<Failure, List<SubscriptionEntity>>> restorePurchases() async {
    await Future.delayed(const Duration(seconds: 1));
    if (_currentSubscription != null) {
      return Right([_currentSubscription!]);
    }
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> setUser({
    required String userId,
    Map<String, String>? attributes,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setUserAttributes({
    required Map<String, String> attributes,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> isEligibleForTrial({
    required String productId,
  }) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, String?>> getManagementUrl() async {
    return const Right('https://localhost/manage-subscription');
  }

  @override
  Future<Either<Failure, String?>> getSubscriptionManagementUrl() async {
    return const Right('https://localhost/manage-subscription');
  }

  @override
  Future<Either<Failure, void>> cancelSubscription({String? reason}) async {
    _currentSubscription = null;
    _controller.add(null);
    await _persistSubscription(null);
    return const Right(null);
  }

  // App specific methods
  @override
  Future<Either<Failure, bool>> hasPlantisSubscription() async {
    return hasActiveSubscription();
  }

  @override
  Future<Either<Failure, bool>> hasReceitaAgroSubscription() async {
    return hasActiveSubscription();
  }

  @override
  Future<Either<Failure, bool>> hasGasometerSubscription() async {
    return hasActiveSubscription();
  }

  @override
  Future<Either<Failure, List<ProductInfo>>> getPlantisProducts() async {
    return getAvailableProducts(productIds: []);
  }

  @override
  Future<Either<Failure, List<ProductInfo>>> getReceitaAgroProducts() async {
    return getAvailableProducts(productIds: []);
  }

  @override
  Future<Either<Failure, List<ProductInfo>>> getGasometerProducts() async {
    return getAvailableProducts(productIds: []);
  }

  @override
  Future<Either<Failure, bool>> hasPetivetiSubscription() async {
    return hasActiveSubscription();
  }

  @override
  Future<Either<Failure, List<ProductInfo>>> getPetivetiProducts() async {
    return Right(_getMockPetivetiProducts());
  }

  List<ProductInfo> _getMockPetivetiProducts() {
    return [
      const ProductInfo(
        productId: 'petiveti_premium_monthly',
        title: 'Petiveti Premium Mensal',
        description: 'Animais ilimitados, sync na nuvem, sem anúncios',
        price: 9.90,
        priceString: 'R\$ 9,90',
        currencyCode: 'BRL',
        subscriptionPeriod: 'P1M',
        freeTrialPeriod: 'P7D',
      ),
      const ProductInfo(
        productId: 'petiveti_premium_yearly',
        title: 'Petiveti Premium Anual',
        description: 'Economize 17% com o plano anual',
        price: 99.90,
        priceString: 'R\$ 99,90',
        currencyCode: 'BRL',
        subscriptionPeriod: 'P1Y',
        freeTrialPeriod: 'P7D',
      ),
      const ProductInfo(
        productId: 'petiveti_lifetime',
        title: 'Petiveti Vitalício',
        description: 'Acesso premium para sempre',
        price: 299.90,
        priceString: 'R\$ 299,90',
        currencyCode: 'BRL',
        subscriptionPeriod: null, // One-time purchase
      ),
    ];
  }

  List<ProductInfo> _getMockProducts() {
    return [
      // ReceitaAgro Products
      const ProductInfo(
        productId: 'receituagro_premium_monthly',
        title: 'Premium Mensal (Mock)',
        description: 'Acesso completo por 1 mês',
        price: 19.90,
        priceString: 'R\$ 19,90',
        currencyCode: 'BRL',
        subscriptionPeriod: 'P1M',
      ),
      const ProductInfo(
        productId: 'receituagro_premium_semiannual',
        title: 'Premium Semestral (Mock)',
        description: 'Acesso completo por 6 meses',
        price: 99.90,
        priceString: 'R\$ 99,90',
        currencyCode: 'BRL',
        subscriptionPeriod: 'P6M',
      ),
      const ProductInfo(
        productId: 'receituagro_premium_annual',
        title: 'Premium Anual (Mock)',
        description: 'Acesso completo por 1 ano',
        price: 179.90,
        priceString: 'R\$ 179,90',
        currencyCode: 'BRL',
        subscriptionPeriod: 'P1Y',
        freeTrialPeriod: 'P7D',
      ),
      // Plantis Products
      const ProductInfo(
        productId: 'plantis_premium_monthly',
        title: 'Plantis Premium Mensal (Mock)',
        description: 'Acesso completo por 1 mês',
        price: 9.90,
        priceString: 'R\$ 9,90',
        currencyCode: 'BRL',
        subscriptionPeriod: 'P1M',
      ),
      const ProductInfo(
        productId: 'plantis_premium_annual',
        title: 'Plantis Premium Anual (Mock)',
        description: 'Acesso completo por 1 ano',
        price: 89.90,
        priceString: 'R\$ 89,90',
        currencyCode: 'BRL',
        subscriptionPeriod: 'P1Y',
        freeTrialPeriod: 'P7D',
      ),
      // Gasometer Products
      const ProductInfo(
        productId: 'gasometer_premium_monthly',
        title: 'Gasometer Premium Mensal (Mock)',
        description: 'Acesso completo por 1 mês',
        price: 4.90,
        priceString: 'R\$ 4,90',
        currencyCode: 'BRL',
        subscriptionPeriod: 'P1M',
      ),
      const ProductInfo(
        productId: 'gasometer_premium_annual',
        title: 'Gasometer Premium Anual (Mock)',
        description: 'Acesso completo por 1 ano',
        price: 49.90,
        priceString: 'R\$ 49,90',
        currencyCode: 'BRL',
        subscriptionPeriod: 'P1Y',
        freeTrialPeriod: 'P7D',
      ),
    ];
  }
}
