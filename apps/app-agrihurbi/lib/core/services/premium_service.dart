import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Service para gerenciar funcionalidades premium do app
/// 
/// Integra com RevenueCat para verificação de assinaturas
/// Implementa gating de funcionalidades avançadas
@singleton
class PremiumService {
  final RevenueCatService _revenueCatService;
  final FirebaseAnalyticsService _analyticsService;
  
  const PremiumService(
    this._revenueCatService,
    this._analyticsService,
  );
  
  /// Verifica se o usuário tem acesso premium ativo
  Future<bool> hasActiveSubscription() async {
    try {
      final result = await _revenueCatService.hasActiveSubscription();
      
      // Handle Either<Failure, bool> return type
      final hasSubscription = result.fold(
        (failure) => false, // Return false on failure
        (success) => success, // Return the boolean result
      );
      
      await _analyticsService.logEvent(
        'premium_status_checked',
        parameters: {
          'has_subscription': hasSubscription,
        },
      );
      
      return hasSubscription;
    } catch (e) {
      debugPrint('PremiumService: Erro ao verificar assinatura - $e');
      
      await _analyticsService.logEvent(
        'premium_status_check_error',
        parameters: {
          'error': e.toString(),
        },
      );
      
      // Default to false on error
      return false;
    }
  }
  
  /// Verifica se uma calculadora específica requer acesso premium
  bool isCalculatorPremium(String calculatorId) {
    const premiumCalculators = {
      'advanced_irrigation_calculator',
      'livestock_nutrition_optimizer',
      'yield_prediction_ai',
      'pest_management_advanced',
      'financial_roi_analyzer',
      'weather_impact_calculator',
      'soil_health_comprehensive',
      'crop_rotation_optimizer',
      'fertilizer_recommendation_ai',
      'harvest_timing_predictor',
    };
    
    return premiumCalculators.contains(calculatorId);
  }
  
  /// Verifica se uma feature específica requer acesso premium
  bool isFeaturePremium(String featureId) {
    const premiumFeatures = {
      'unlimited_calculations',
      'advanced_analytics',
      'export_data',
      'historical_comparison',
      'weather_integration',
      'ai_recommendations',
      'bulk_operations',
      'custom_formulas',
      'priority_support',
      'offline_sync',
    };
    
    return premiumFeatures.contains(featureId);
  }
  
  /// Verifica acesso a uma calculadora e retorna resultado
  Future<PremiumAccessResult> checkCalculatorAccess(String calculatorId) async {
    try {
      final isPremium = isCalculatorPremium(calculatorId);
      
      if (!isPremium) {
        return PremiumAccessResult.allowed();
      }
      
      final hasSubscription = await hasActiveSubscription();
      
      await _analyticsService.logEvent(
        'premium_calculator_access_check',
        parameters: {
          'calculator_id': calculatorId,
          'is_premium': isPremium,
          'has_subscription': hasSubscription,
          'access_granted': hasSubscription,
        },
      );
      
      if (hasSubscription) {
        return PremiumAccessResult.allowed();
      } else {
        return PremiumAccessResult.blocked(
          'Esta calculadora avançada requer assinatura AgriHurbi Premium',
          calculatorId,
        );
      }
    } catch (e) {
      debugPrint('PremiumService: Erro ao verificar acesso à calculadora - $e');
      
      await _analyticsService.logEvent(
        'premium_calculator_access_error',
        parameters: {
          'calculator_id': calculatorId,
          'error': e.toString(),
        },
      );
      
      // Default to blocked on error for premium features
      return PremiumAccessResult.blocked(
        'Erro ao verificar acesso. Tente novamente.',
        calculatorId,
      );
    }
  }
  
  /// Verifica acesso a uma feature e retorna resultado
  Future<PremiumAccessResult> checkFeatureAccess(String featureId) async {
    try {
      final isPremium = isFeaturePremium(featureId);
      
      if (!isPremium) {
        return PremiumAccessResult.allowed();
      }
      
      final hasSubscription = await hasActiveSubscription();
      
      await _analyticsService.logEvent(
        'premium_feature_access_check',
        parameters: {
          'feature_id': featureId,
          'is_premium': isPremium,
          'has_subscription': hasSubscription,
          'access_granted': hasSubscription,
        },
      );
      
      if (hasSubscription) {
        return PremiumAccessResult.allowed();
      } else {
        return PremiumAccessResult.blocked(
          'Esta funcionalidade avançada requer assinatura AgriHurbi Premium',
          featureId,
        );
      }
    } catch (e) {
      debugPrint('PremiumService: Erro ao verificar acesso à feature - $e');
      
      await _analyticsService.logEvent(
        'premium_feature_access_error',
        parameters: {
          'feature_id': featureId,
          'error': e.toString(),
        },
      );
      
      // Default to blocked on error for premium features
      return PremiumAccessResult.blocked(
        'Erro ao verificar acesso. Tente novamente.',
        featureId,
      );
    }
  }
  
  /// Registra tentativa de uso de feature premium bloqueada
  Future<void> logPremiumFeatureBlocked(String itemId, String itemType) async {
    await _analyticsService.logEvent(
      'premium_feature_blocked',
      parameters: {
        'item_id': itemId,
        'item_type': itemType, // 'calculator' ou 'feature'
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  /// Obtém informações sobre assinatura
  Future<SubscriptionInfo> getSubscriptionInfo() async {
    try {
      final result = await _revenueCatService.hasActiveSubscription();
      
      // Handle Either<Failure, bool> return type
      final hasSubscription = result.fold(
        (failure) => false,
        (success) => success,
      );
      
      // Se não tem assinatura, retorna informações básicas
      if (!hasSubscription) {
        return SubscriptionInfo(
          hasActiveSubscription: false,
          subscriptionType: 'free',
          expirationDate: null,
          features: _getFreeFeatures(),
        );
      }
      
      // TODO: Implementar obtenção de detalhes da assinatura do RevenueCat
      return SubscriptionInfo(
        hasActiveSubscription: true,
        subscriptionType: 'premium',
        expirationDate: null, // Seria obtido do RevenueCat
        features: _getPremiumFeatures(),
      );
    } catch (e) {
      debugPrint('PremiumService: Erro ao obter info da assinatura - $e');
      
      // Default to free on error
      return SubscriptionInfo(
        hasActiveSubscription: false,
        subscriptionType: 'free',
        expirationDate: null,
        features: _getFreeFeatures(),
      );
    }
  }
  
  List<String> _getFreeFeatures() {
    return [
      'basic_calculators',
      'limited_history',
      'basic_analytics',
      'community_support',
    ];
  }
  
  List<String> _getPremiumFeatures() {
    return [
      'all_calculators',
      'unlimited_history',
      'advanced_analytics',
      'export_data',
      'weather_integration',
      'ai_recommendations',
      'priority_support',
      'offline_sync',
    ];
  }
}

/// Resultado da verificação de acesso premium
class PremiumAccessResult {
  final bool isAllowed;
  final String? blockMessage;
  final String? itemId;
  
  const PremiumAccessResult._({
    required this.isAllowed,
    this.blockMessage,
    this.itemId,
  });
  
  factory PremiumAccessResult.allowed() {
    return const PremiumAccessResult._(isAllowed: true);
  }
  
  factory PremiumAccessResult.blocked(String message, String itemId) {
    return PremiumAccessResult._(
      isAllowed: false,
      blockMessage: message,
      itemId: itemId,
    );
  }
}

/// Informações sobre a assinatura do usuário
class SubscriptionInfo {
  final bool hasActiveSubscription;
  final String subscriptionType;
  final DateTime? expirationDate;
  final List<String> features;
  
  const SubscriptionInfo({
    required this.hasActiveSubscription,
    required this.subscriptionType,
    required this.expirationDate,
    required this.features,
  });
}