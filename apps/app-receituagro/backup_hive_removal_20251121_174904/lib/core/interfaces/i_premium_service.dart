import 'dart:async';

/// Interface unificada para o sistema de assinaturas Premium
/// Integra todas as funcionalidades necessárias do app ReceitaAgro
/// Implementada por PremiumServiceReal com integração RevenueCat + Drift
abstract class IPremiumService {
  /// Verificação rápida de acesso premium (cached)
  bool get isPremium;

  /// Status completo do premium do usuário
  PremiumStatus get status;

  /// Se deve mostrar dialogs premium (não para usuários anônimos)
  bool get shouldShowPremiumDialogs;

  /// Verifica status premium online (força sincronização)
  Future<void> checkPremiumStatus();

  /// Obtém status premium de forma assíncrona (mais preciso)
  Future<bool> isPremiumUser();

  /// Obtém tipo da assinatura atual
  Future<String?> getSubscriptionType();

  /// Obtém data de expiração da assinatura
  Future<DateTime?> getSubscriptionExpiry();

  /// Verifica se assinatura está ativa
  Future<bool> isSubscriptionActive();

  /// Obtém dias restantes da assinatura
  Future<int> getRemainingDays();

  /// Force refresh do cache (limpa e recarrega)
  Future<void> refreshPremiumStatus();

  /// Verifica se pode usar uma feature específica
  bool canUseFeature(String featureName);

  /// Verifica acesso a feature específica de forma assíncrona
  Future<bool> hasFeatureAccess(String featureId);

  /// Obtém limite para feature específica
  int getFeatureLimit(String featureName);

  /// Verifica se atingiu limite de uma feature
  bool hasReachedLimit(String featureName, int currentUsage);

  /// Lista de features premium disponíveis
  Future<List<String>> getPremiumFeatures();

  /// Verifica se trial está disponível
  Future<bool> isTrialAvailable();

  /// Inicia período de trial
  Future<bool> startTrial();

  /// Gera assinatura de teste (desenvolvimento)
  Future<void> generateTestSubscription();

  /// Remove assinatura de teste
  Future<void> removeTestSubscription();

  /// Navegar para página de assinatura/premium
  Future<void> navigateToPremium();

  /// URL para upgrade (usuários não-premium)
  String? get upgradeUrl;

  /// Stream de mudanças no status premium
  Stream<bool> get premiumStatusStream;
}

/// Status completo do premium do usuário
class PremiumStatus {
  final bool isActive;
  final bool isTestSubscription;
  final DateTime? expiryDate;
  final String? planType;

  const PremiumStatus({
    required this.isActive,
    this.isTestSubscription = false,
    this.expiryDate,
    this.planType,
  });

  PremiumStatus copyWith({
    bool? isActive,
    bool? isTestSubscription,
    DateTime? expiryDate,
    String? planType,
  }) {
    return PremiumStatus(
      isActive: isActive ?? this.isActive,
      isTestSubscription: isTestSubscription ?? this.isTestSubscription,
      expiryDate: expiryDate ?? this.expiryDate,
      planType: planType ?? this.planType,
    );
  }

  @override
  String toString() =>
      'PremiumStatus(isActive: $isActive, planType: $planType, expires: $expiryDate)';
}
