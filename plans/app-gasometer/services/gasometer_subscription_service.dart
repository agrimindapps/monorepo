// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import '../../core/services/firebase_subscription_service.dart' hide SubscriptionStatus;
import '../../core/services/revenuecat_service.dart';
import '../../core/services/subscription_config_service.dart';
import '../constants/subscription_constants.dart';
import '../models/purchase_result.dart';
import '../models/restore_result.dart';
import '../models/subscription_status.dart';
import 'gasometer_firebase_service.dart';
import 'gasometer_test_service.dart';

/// Service específico para gerenciamento de assinaturas do Gasometer
class GasometerSubscriptionService extends GetxService {
  static GasometerSubscriptionService get instance => Get.find();

  // Services dependentes
  final RevenuecatService _revenueCatService = RevenuecatService.instance;
  final FirebaseSubscriptionService _firebaseService = FirebaseSubscriptionService();

  // Estado reativo
  final _subscriptionStatus = SubscriptionStatus.loading().obs;
  final _isInitialized = false.obs;
  final _customerInfo = Rxn<CustomerInfo>();

  // Getters
  SubscriptionStatus get subscriptionStatus => _subscriptionStatus.value;
  bool get isPremium => _subscriptionStatus.value.isPremium;
  bool get isLoading => _subscriptionStatus.value.isLoading;
  bool get isInitialized => _isInitialized.value;
  CustomerInfo? get customerInfo => _customerInfo.value;
  
  // Getter para produtos disponíveis
  List<Map<String, dynamic>> get availableProducts => GasometerSubscriptionConstants.productIds;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  /// Inicializar o serviço de assinaturas
  Future<void> _initializeService() async {
    try {
      print('🚀 Inicializando GasometerSubscriptionService...');
      
      // 1. Configurar RevenueCat para gasometer
      SubscriptionConfigService.initializeForApp('gasometer');
      
      // 2. Verificar se as configurações são válidas
      if (!GasometerSubscriptionConstants.hasValidApiKeys) {
        print('⚠️ API Keys do RevenueCat não configuradas para o Gasometer');
        _subscriptionStatus.value = SubscriptionStatus.error(
          'Configuração de API keys pendente'
        );
        return;
      }

      // 3. Verificar status atual
      await checkSubscriptionStatus();

      // 4. Setup listeners do RevenueCat
      _setupRevenueCatListeners();

      _isInitialized.value = true;
      print('✅ GasometerSubscriptionService inicializado com sucesso');

    } catch (e, stackTrace) {
      print('❌ Erro ao inicializar GasometerSubscriptionService: $e');
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      
      _subscriptionStatus.value = SubscriptionStatus.error(
        'Erro na inicialização: $e'
      );
    }
  }

  /// Verificar status atual da assinatura
  Future<void> checkSubscriptionStatus() async {
    try {
      _subscriptionStatus.value = _subscriptionStatus.value.copyWith(
        isLoading: true,
        error: null,
      );

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        _subscriptionStatus.value = SubscriptionStatus.free();
        return;
      }

      // 1. Verificar test subscription primeiro (apenas desenvolvimento)
      final testStatus = await _checkTestSubscription();
      if (testStatus != null) {
        _subscriptionStatus.value = testStatus;
        return;
      }

      // 2. Verificar Firebase primeiro (cache mais rápido)
      final firebaseActive = await GasometerFirebaseService.checkSubscriptionInFirebase(userId);
      
      if (firebaseActive) {
        _subscriptionStatus.value = const SubscriptionStatus(
          isPremium: true,
          isLoading: false,
        );
        return;
      }

      // 3. Verificar com RevenueCat (fonte da verdade)
      final customerInfo = await Purchases.getCustomerInfo();
      
      // 4. Verificar entitlements ativos
      final hasAccess = customerInfo.entitlements.active.containsKey(
        GasometerSubscriptionConstants.entitlementId,
      );
      
      // 5. Sincronizar com Firebase
      await GasometerFirebaseService.syncSubscriptionStatus(
        userId: userId,
        isActive: hasAccess,
        customerInfo: hasAccess ? customerInfo : null,
      );
      
      // 6. Atualizar status baseado no CustomerInfo
      _subscriptionStatus.value = SubscriptionStatus.fromCustomerInfo(
        customerInfo,
        entitlementId: GasometerSubscriptionConstants.entitlementId,
      );

      // 7. Atualizar customer info
      _customerInfo.value = customerInfo;

      print('✅ Status verificado: ${_subscriptionStatus.value.statusDescription}');

    } catch (e, stackTrace) {
      print('❌ Erro ao verificar status: $e');
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      
      _subscriptionStatus.value = SubscriptionStatus.error(e.toString());
    }
  }

  /// Comprar uma assinatura
  Future<PurchaseResult> purchaseSubscription(String productId) async {
    try {
      print('🛒 Iniciando compra: $productId');
      
      _subscriptionStatus.value = _subscriptionStatus.value.copyWith(
        isLoading: true,
      );

      // 1. Validar configuração
      if (!GasometerSubscriptionConstants.hasValidApiKeys) {
        return PurchaseResult.error('API keys não configuradas');
      }

      // 2. Buscar offerings do RevenueCat
      final offering = await _revenueCatService.getOfferings();
      if (offering == null) {
        return PurchaseResult.error('Nenhuma oferta disponível');
      }

      // 3. Encontrar o pacote específico
      final package = offering.availablePackages.firstWhereOrNull(
        (pkg) => pkg.storeProduct.identifier == productId,
      );

      if (package == null) {
        return PurchaseResult.error('Produto não encontrado: $productId');
      }

      // 4. Realizar a compra
      final success = await _revenueCatService.purchasePackage(package);
      
      if (success) {
        // 5. Atualizar status após compra bem-sucedida
        await checkSubscriptionStatus();
        
        // 6. Sincronizar com Firebase imediatamente
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null && _customerInfo.value != null) {
          await GasometerFirebaseService.syncSubscriptionStatus(
            userId: userId,
            isActive: true,
            customerInfo: _customerInfo.value,
          );
        }
        
        // 6. Extrair informações do produto
        final productData = availableProducts.firstWhereOrNull(
          (product) => product['productId'] == productId,
        );
        
        return PurchaseResult.success(
          productId: productId,
          price: productData?['price']?.toDouble(),
          currency: 'BRL',
        );
      } else {
        return PurchaseResult.error('Falha na compra');
      }

    } catch (e, stackTrace) {
      print('❌ Erro na compra: $e');
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      
      // Verificar se foi cancelamento
      if (e.toString().contains('cancelled') || 
          e.toString().contains('canceled')) {
        return PurchaseResult.cancelled();
      }
      
      return PurchaseResult.error('Erro ao processar compra: $e');
      
    } finally {
      // Sempre atualizar o status de loading
      _subscriptionStatus.value = _subscriptionStatus.value.copyWith(
        isLoading: false,
      );
    }
  }

  /// Restaurar compras
  Future<RestoreResult> restorePurchases() async {
    try {
      print('🔄 Restaurando compras...');
      
      _subscriptionStatus.value = _subscriptionStatus.value.copyWith(
        isLoading: true,
      );

      // 1. Chamar restore do RevenueCat
      final customerInfo = await Purchases.restorePurchases();
      
      // 2. Verificar se há assinaturas ativas
      final activeEntitlements = customerInfo.entitlements.active;
      
      if (activeEntitlements.isNotEmpty) {
        // 3. Atualizar status local
        await checkSubscriptionStatus();
        
        // 4. Extrair produtos restaurados
        final restoredProducts = activeEntitlements.values
            .map((entitlement) => entitlement.productIdentifier)
            .toList();
        
        return RestoreResult.success(restoredProducts: restoredProducts);
      } else {
        return RestoreResult.noSubscriptions();
      }

    } catch (e, stackTrace) {
      print('❌ Erro ao restaurar: $e');
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      
      return RestoreResult.error(e.toString());
      
    } finally {
      _subscriptionStatus.value = _subscriptionStatus.value.copyWith(
        isLoading: false,
      );
    }
  }

  /// Verificar test subscription (apenas desenvolvimento)
  Future<SubscriptionStatus?> _checkTestSubscription() async {
    try {
      final hasTestSub = await GasometerTestService.hasActiveTestSubscription();
      
      if (hasTestSub) {
        final timeLeft = await GasometerTestService.getTestSubscriptionTimeLeft();
        final expirationDate = timeLeft != null 
            ? DateTime.now().add(timeLeft)
            : DateTime.now().add(const Duration(hours: 24));
        
        return SubscriptionStatus.testSubscription(
          expirationDate: expirationDate,
        );
      }
      
      return null;
    } catch (e) {
      print('⚠️ Erro ao verificar test subscription: $e');
      return null;
    }
  }

  /// Configurar listeners do RevenueCat
  void _setupRevenueCatListeners() {
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      print('📡 CustomerInfo atualizado via listener');
      
      _subscriptionStatus.value = SubscriptionStatus.fromCustomerInfo(
        customerInfo,
        entitlementId: GasometerSubscriptionConstants.entitlementId,
      );
    });
  }

  /// Forçar refresh do status
  Future<void> refreshStatus() async {
    print('🔄 Forçando refresh do status...');
    await checkSubscriptionStatus();
  }

  /// Obter informações detalhadas para debug
  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': isInitialized,
      'isPremium': isPremium,
      'isLoading': isLoading,
      'hasValidApiKeys': GasometerSubscriptionConstants.hasValidApiKeys,
      'entitlementId': GasometerSubscriptionConstants.entitlementId,
      'availableProducts': availableProducts.length,
      'subscriptionStatus': subscriptionStatus.toString(),
    };
  }

  /// Cleanup ao destruir o service
  @override
  void onClose() {
    // Cleanup listeners se necessário
    super.onClose();
  }
}
