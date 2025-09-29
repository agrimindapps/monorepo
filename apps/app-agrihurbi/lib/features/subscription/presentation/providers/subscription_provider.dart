import 'package:app_agrihurbi/core/error/failures.dart';
import 'package:app_agrihurbi/features/subscription/domain/entities/subscription_entity.dart';
import 'package:app_agrihurbi/features/subscription/domain/usecases/manage_subscription.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Subscription Provider for Premium Features Management
/// 
/// Manages subscription status, premium features access,
/// and billing information using Provider pattern
@injectable
class SubscriptionProvider with ChangeNotifier {
  final ManageSubscription _manageSubscription;
  final ManagePaymentMethods _managePaymentMethods;

  SubscriptionProvider(
    this._manageSubscription,
    this._managePaymentMethods,
  );

  // === STATE VARIABLES ===

  SubscriptionEntity? _currentSubscription;
  final List<SubscriptionTier> _availableTiers = SubscriptionTier.values;
  List<PaymentMethod> _paymentMethods = [];

  bool _isLoadingSubscription = false;
  bool _isProcessingPayment = false;
  bool _isUpdatingSubscription = false;

  String? _errorMessage;
  String? _successMessage;

  // === GETTERS ===

  SubscriptionEntity? get currentSubscription => _currentSubscription;
  List<SubscriptionTier> get availableTiers => _availableTiers;
  List<PaymentMethod> get paymentMethods => _paymentMethods;

  bool get isLoadingSubscription => _isLoadingSubscription;
  bool get isProcessingPayment => _isProcessingPayment;
  bool get isUpdatingSubscription => _isUpdatingSubscription;

  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool get hasError => _errorMessage != null;
  bool get hasSuccess => _successMessage != null;

  // Subscription status checks
  bool get hasActiveSubscription => _currentSubscription?.isActive ?? false;
  bool get isSubscriptionExpired => _currentSubscription?.isExpired ?? false;
  bool get isInTrial => _currentSubscription?.isTrial ?? false;
  bool get isFreeUser => _currentSubscription?.tier == SubscriptionTier.free;

  // Current tier and features
  SubscriptionTier get currentTier => _currentSubscription?.tier ?? SubscriptionTier.free;
  List<PremiumFeature> get availableFeatures => _currentSubscription?.features ?? [];

  // Subscription info
  int? get daysUntilExpiry => _currentSubscription?.daysUntilExpiry;
  DateTime? get nextBillingDate => _currentSubscription?.nextBillingDate;
  double get monthlyPrice => _currentSubscription?.price ?? 0.0;

  // === SUBSCRIPTION OPERATIONS ===

  /// Load current subscription
  Future<void> loadSubscription() async {
    if (_isLoadingSubscription) return;

    _setLoadingSubscription(true);
    _clearMessages();

    try {
      final result = await _manageSubscription.getCurrentSubscription();
      
      result.fold(
        (Failure failure) => _setError('Erro ao carregar assinatura: ${failure.message}'),
        (SubscriptionEntity? subscription) {
          _currentSubscription = subscription;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoadingSubscription(false);
    }
  }

  /// Subscribe to a new plan
  Future<bool> subscribeToPlan({
    required SubscriptionTier tier,
    required BillingPeriod billingPeriod,
    PaymentMethod? paymentMethod,
  }) async {
    if (_isProcessingPayment) return false;

    _setProcessingPayment(true);
    _clearMessages();

    try {
      final result = await _manageSubscription.createSubscription(
        tier: tier,
        billingPeriod: billingPeriod,
        paymentMethod: paymentMethod!,
      );
      
      return result.fold(
        (Failure failure) {
          _setError('Erro ao processar assinatura: ${failure.message}');
          return false;
        },
        (SubscriptionEntity subscription) {
          _currentSubscription = subscription;
          _setSuccess('Assinatura ${tier.displayName} ativada com sucesso!');
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _setProcessingPayment(false);
    }
  }

  /// Upgrade subscription
  Future<bool> upgradeSubscription(SubscriptionTier newTier) async {
    if (_isUpdatingSubscription) return false;
    if (_currentSubscription == null) return false;

    _setUpdatingSubscription(true);
    _clearMessages();

    try {
      final result = await _manageSubscription.upgradeSubscription(
        newTier: newTier,
      );
      
      return result.fold(
        (failure) {
          _setError('Erro ao fazer upgrade: ${failure.message}');
          return false;
        },
        (subscription) {
          _currentSubscription = subscription;
          _setSuccess('Upgrade para ${newTier.displayName} realizado com sucesso!');
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _setUpdatingSubscription(false);
    }
  }

  /// Downgrade subscription
  Future<bool> downgradeSubscription(SubscriptionTier newTier) async {
    if (_isUpdatingSubscription) return false;
    if (_currentSubscription == null) return false;

    _setUpdatingSubscription(true);
    _clearMessages();

    try {
      final result = await _manageSubscription.downgradeSubscription(
        newTier: newTier,
      );
      
      return result.fold(
        (failure) {
          _setError('Erro ao fazer downgrade: ${failure.message}');
          return false;
        },
        (subscription) {
          _currentSubscription = subscription;
          _setSuccess('Plano alterado para ${newTier.displayName}');
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _setUpdatingSubscription(false);
    }
  }

  /// Cancel subscription
  Future<bool> cancelSubscription({String? reason}) async {
    if (_isUpdatingSubscription) return false;
    if (_currentSubscription == null) return false;

    _setUpdatingSubscription(true);
    _clearMessages();

    try {
      final result = await _manageSubscription.cancelSubscription(
        cancelImmediately: false,
      );
      
      return result.fold(
        (failure) {
          _setError('Erro ao cancelar assinatura: ${failure.message}');
          return false;
        },
        (_) {
          // Reload subscription to get updated status
          loadSubscription();
          _setSuccess('Assinatura cancelada. Acesso premium até ${_formatDate(nextBillingDate)}');
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _setUpdatingSubscription(false);
    }
  }

  /// Resume subscription
  Future<bool> resumeSubscription() async {
    if (_isUpdatingSubscription) return false;
    if (_currentSubscription == null) return false;

    _setUpdatingSubscription(true);
    _clearMessages();

    try {
      final result = await _manageSubscription.reactivateSubscription();
      
      return result.fold(
        (failure) {
          _setError('Erro ao reativar assinatura: ${failure.message}');
          return false;
        },
        (subscription) {
          _currentSubscription = subscription;
          _setSuccess('Assinatura reativada com sucesso!');
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _setUpdatingSubscription(false);
    }
  }

  // === PAYMENT METHODS ===

  /// Load payment methods
  Future<void> loadPaymentMethods() async {
    try {
      final result = await _managePaymentMethods.getPaymentMethods();
      
      result.fold(
        (failure) => _setError('Erro ao carregar métodos de pagamento: ${failure.message}'),
        (methods) {
          _paymentMethods = methods;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    }
  }

  /// Add payment method
  Future<bool> addPaymentMethod(PaymentMethod paymentMethod) async {
    try {
      final result = await _managePaymentMethods.addPaymentMethod(
        type: paymentMethod.type,
        token: paymentMethod.id,
      );
      
      return result.fold(
        (failure) {
          _setError('Erro ao adicionar método de pagamento: ${failure.message}');
          return false;
        },
        (_) {
          loadPaymentMethods(); // Reload payment methods
          _setSuccess('Método de pagamento adicionado com sucesso!');
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    }
  }

  /// Remove payment method
  Future<bool> removePaymentMethod(String paymentMethodId) async {
    try {
      final result = await _managePaymentMethods.removePaymentMethod(paymentMethodId);
      
      return result.fold(
        (failure) {
          _setError('Erro ao remover método de pagamento: ${failure.message}');
          return false;
        },
        (_) {
          loadPaymentMethods(); // Reload payment methods
          _setSuccess('Método de pagamento removido');
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    }
  }

  /// Set default payment method
  Future<bool> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      final result = await _managePaymentMethods.setDefaultPaymentMethod(paymentMethodId);
      
      return result.fold(
        (failure) {
          _setError('Erro ao definir método padrão: ${failure.message}');
          return false;
        },
        (_) {
          loadPaymentMethods(); // Reload payment methods
          _setSuccess('Método de pagamento padrão atualizado');
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    }
  }

  // === FEATURE ACCESS ===

  /// Check if user has access to a premium feature
  bool hasFeatureAccess(PremiumFeature feature) {
    return _currentSubscription?.hasFeature(feature) ?? false;
  }

  /// Get features available for a tier
  List<PremiumFeature> getFeaturesForTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return [];
      case SubscriptionTier.basic:
        return [
          PremiumFeature.advancedCalculators,
          PremiumFeature.exportData,
        ];
      case SubscriptionTier.premium:
        return [
          PremiumFeature.advancedCalculators,
          PremiumFeature.premiumNews,
          PremiumFeature.exportData,
          PremiumFeature.cloudSync,
          PremiumFeature.customReports,
        ];
      case SubscriptionTier.professional:
        return PremiumFeature.values; // All features
    }
  }

  /// Get price for tier and billing period
  double getPriceForTier(SubscriptionTier tier, BillingPeriod period) {
    final monthlyPrice = tier.monthlyPrice;
    
    switch (period) {
      case BillingPeriod.monthly:
        return monthlyPrice;
      case BillingPeriod.quarterly:
        return monthlyPrice * 3 * 0.9; // 10% discount
      case BillingPeriod.yearly:
        return monthlyPrice * 12 * 0.8; // 20% discount
    }
  }

  // === SUBSCRIPTION ANALYTICS ===

  /// Get subscription status summary
  Map<String, dynamic> getSubscriptionSummary() {
    if (_currentSubscription == null) {
      return {
        'tier': 'Free',
        'status': 'Não assinante',
        'features': 0,
        'daysLeft': 0,
        'nextBilling': null,
      };
    }

    return {
      'tier': _currentSubscription!.tier.displayName,
      'status': _currentSubscription!.status.displayName,
      'features': _currentSubscription!.features.length,
      'daysLeft': daysUntilExpiry ?? 0,
      'nextBilling': nextBillingDate,
      'autoRenew': _currentSubscription!.autoRenew,
    };
  }

  /// Check if subscription needs attention (expiring soon, failed payment, etc.)
  bool get needsAttention {
    if (_currentSubscription == null) return false;
    
    final daysLeft = daysUntilExpiry;
    return (daysLeft != null && daysLeft <= 7) || 
           _currentSubscription!.status == SubscriptionStatus.suspended;
  }

  /// Get attention message
  String get attentionMessage {
    if (_currentSubscription == null) return '';
    
    if (_currentSubscription!.status == SubscriptionStatus.suspended) {
      return 'Sua assinatura está suspensa. Verifique seu método de pagamento.';
    }
    
    final daysLeft = daysUntilExpiry;
    if (daysLeft != null && daysLeft <= 7) {
      return 'Sua assinatura expira em $daysLeft dias.';
    }
    
    return '';
  }

  // === UTILITY METHODS ===

  /// Initialize provider
  Future<void> initialize() async {
    await Future.wait([
      loadSubscription(),
      loadPaymentMethods(),
    ]);
  }

  /// Clear messages
  void clearMessages() {
    _clearMessages();
  }

  // === PRIVATE METHODS ===

  void _setLoadingSubscription(bool loading) {
    _isLoadingSubscription = loading;
    notifyListeners();
  }

  void _setProcessingPayment(bool processing) {
    _isProcessingPayment = processing;
    notifyListeners();
  }

  void _setUpdatingSubscription(bool updating) {
    _isUpdatingSubscription = updating;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

}