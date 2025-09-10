import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../interfaces/i_premium_service.dart';
import '../models/premium_status_hive.dart';
import '../repositories/premium_hive_repository.dart';
import 'navigation_service.dart';
import 'premium_status_notifier.dart';

/// Service premium real que integra RevenueCat com cache Hive local
/// Unifica todas as interfaces IPremiumService fragmentadas do projeto
class PremiumServiceReal extends ChangeNotifier implements IPremiumService {
  final PremiumHiveRepository _hiveRepository;
  final ISubscriptionRepository _subscriptionRepository;
  final INavigationService _navigationService;

  PremiumStatus _cachedStatus = const PremiumStatus(isActive: false);
  bool _isCheckingStatus = false;

  // Stream controller para premiumStatusStream
  final StreamController<bool> _statusStreamController =
      StreamController<bool>.broadcast();
  
  Timer? _syncDebounceTimer;
  DateTime? _lastSyncTime;
  static const Duration _syncCooldown = Duration(minutes: 5);

  // Circuit breaker pattern para prevenir loops infinitos
  int _failureCount = 0;
  DateTime? _lastFailureTime;
  static const int _maxFailures = 3;
  static const Duration _circuitBreakerTimeout = Duration(minutes: 15);
  bool _circuitBreakerOpen = false;

  PremiumServiceReal({
    required PremiumHiveRepository hiveRepository,
    required ISubscriptionRepository subscriptionRepository,
    required INavigationService navigationService,
  }) : _hiveRepository = hiveRepository,
       _subscriptionRepository = subscriptionRepository,
       _navigationService = navigationService {
    _initializePremiumStatus();
  }

  /// Inicializa status premium do cache local
  void _initializePremiumStatus() {
    final hiveStatus = _hiveRepository.getCurrentUserPremiumStatus();
    if (hiveStatus != null) {
      _cachedStatus = _convertHiveToStatus(hiveStatus);

      // Se precisa sincronizar online, faz em background (respeitando circuit breaker)
      if (hiveStatus.shouldSyncOnline && !_isCircuitBreakerOpen()) {
        _syncOnlineInBackground();
      }
    } else {
      // Primeira vez - busca online (respeitando circuit breaker)
      if (!_isCircuitBreakerOpen()) {
        _syncOnlineInBackground();
      }
    }
  }

  @override
  bool get isPremium => _cachedStatus.isActive && _isValidPremium();

  @override
  PremiumStatus get status => _cachedStatus;

  @override
  bool get shouldShowPremiumDialogs {
    // Não mostrar dialogs premium para usuários anônimos
    final currentUser = _hiveRepository.getCurrentUserPremiumStatus();
    return currentUser?.userId != 'anonymous';
  }

  /// Verifica se premium não expirou
  bool _isValidPremium() {
    if (!_cachedStatus.isActive) return false;
    if (_cachedStatus.expiryDate == null) return true;
    return DateTime.now().isBefore(_cachedStatus.expiryDate!);
  }

  @override
  Future<void> checkPremiumStatus() async {
    if (_isCheckingStatus) return;
    
    // Respeita circuit breaker
    if (_isCircuitBreakerOpen()) {
      debugPrint('🚫 Skipping premium check - circuit breaker is open');
      return;
    }

    _isCheckingStatus = true;
    try {
      await _syncWithRevenueCat();
      _resetCircuitBreaker(); // Reset on success
    } catch (e) {
      _recordFailure();
      rethrow;
    } finally {
      _isCheckingStatus = false;
    }
  }

  /// Sincronização em background com debounce e circuit breaker
  void _syncOnlineInBackground() {
    // Verifica circuit breaker primeiro
    if (_isCircuitBreakerOpen()) {
      debugPrint('🚫 Circuit breaker open - skipping sync for ${_getTimeUntilReset().inMinutes} minutes');
      return;
    }

    // Cancela timer anterior se existe
    _syncDebounceTimer?.cancel();
    
    // Verifica se precisa respeitar cooldown
    final now = DateTime.now();
    if (_lastSyncTime != null && 
        now.difference(_lastSyncTime!) < _syncCooldown) {
      debugPrint('⏳ Premium sync em cooldown, pulando...');
      return;
    }
    
    // Agenda nova sincronização com debounce
    _syncDebounceTimer = Timer(const Duration(seconds: 2), () async {
      try {
        _lastSyncTime = DateTime.now();
        await _syncWithRevenueCat();
        _resetCircuitBreaker(); // Reset on success
      } catch (e) {
        debugPrint('Background sync failed: $e');
        _recordFailure();
      }
    });
  }

  /// Sincroniza com RevenueCat e atualiza cache local
  Future<void> _syncWithRevenueCat() async {
    try {
      // Verifica se tem assinatura ativa
      final hasActiveResult =
          await _subscriptionRepository.hasActiveSubscription();

      bool hasActive = false;
      SubscriptionEntity? subscription;

      hasActiveResult.fold((failure) {
        debugPrint('Error checking subscription: ${failure.message}');
        throw Exception('Subscription check failed: ${failure.message}');
      }, (active) => hasActive = active);

      // Se tem assinatura ativa, obtém detalhes
      if (hasActive) {
        final subscriptionResult =
            await _subscriptionRepository.getCurrentSubscription();
        subscriptionResult.fold(
          (failure) => debugPrint(
            'Error getting subscription details: ${failure.message}',
          ),
          (sub) => subscription = sub,
        );
      }

      // Atualiza cache Hive
      final currentStatus = _hiveRepository.getCurrentUserPremiumStatus();
      final userId = currentStatus?.userId ?? 'anonymous';

      final hiveStatus = PremiumStatusHive(
        userId: userId,
        isActive: hasActive,
        isTestSubscription: false,
        // Mapeamento das propriedades do SubscriptionEntity
        expiryDateTimestamp:
            subscription != null
                ? DateTime.now()
                    .add(const Duration(days: 30))
                    .millisecondsSinceEpoch // Default 30 days for active subscription
                : null,
        planType:
            hasActive
                ? 'monthly'
                : null, // Default plan type for active subscriptions
        subscriptionId: subscription?.toString(),
        productId:
            hasActive
                ? 'receituagro_premium_monthly'
                : null, // Default product ID
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      hiveStatus.markAsSynced();
      await _hiveRepository.saveCurrentUserPremiumStatus(hiveStatus);

      // Atualiza status em memória e notifica listeners
      _cachedStatus = _convertHiveToStatus(hiveStatus);
      _notifyStatusChange();

      debugPrint('Premium status synced successfully: isPremium=$isPremium');
    } catch (e) {
      debugPrint('Error syncing premium status: $e');
      // NÃO marca para tentar novamente se circuit breaker estiver ativo
      if (!_isCircuitBreakerOpen()) {
        await _hiveRepository.markCurrentUserNeedsSync();
      }
      rethrow; // Propaga erro para ativar circuit breaker
    }
  }

  /// Converte PremiumStatusHive para PremiumStatus
  PremiumStatus _convertHiveToStatus(PremiumStatusHive hiveStatus) {
    return PremiumStatus(
      isActive: hiveStatus.isActive,
      isTestSubscription: hiveStatus.isTestSubscription,
      expiryDate: hiveStatus.expiryDate,
      planType: hiveStatus.planType,
    );
  }

  @override
  Future<void> generateTestSubscription() async {
    try {
      await _hiveRepository.activateTestPremium(
        planType: 'test_monthly',
        duration: const Duration(days: 30),
      );

      // Atualiza status em memória
      _cachedStatus = const PremiumStatus(
        isActive: true,
        isTestSubscription: true,
        planType: 'test_monthly',
      );

      _notifyStatusChange();
      debugPrint('✅ Test subscription generated successfully - Broadcasting to all screens');
      
      // Força refresh imediato em todas as telas
      await Future<void>.delayed(const Duration(milliseconds: 100));
      _broadcastPremiumStatusChange();
    } catch (e) {
      debugPrint('Error generating test subscription: $e');
      throw Exception('Falha ao gerar assinatura teste: $e');
    }
  }

  @override
  Future<void> removeTestSubscription() async {
    try {
      await _hiveRepository.removeTestPremium();

      // Atualiza status em memória
      _cachedStatus = const PremiumStatus(isActive: false);

      _notifyStatusChange();
      debugPrint('❌ Test subscription removed successfully - Broadcasting to all screens');
      
      // Força refresh imediato em todas as telas
      await Future<void>.delayed(const Duration(milliseconds: 100));
      _broadcastPremiumStatusChange();
    } catch (e) {
      debugPrint('Error removing test subscription: $e');
      throw Exception('Falha ao remover assinatura teste: $e');
    }
  }

  @override
  Future<void> navigateToPremium() async {
    try {
      debugPrint('Navigating to premium page via NavigationService');
      await _navigationService.navigateToPremium();
    } catch (e) {
      debugPrint('Error navigating to premium page: $e');

      // Fallback: show snackbar message
      _navigationService.showSnackBar(
        'Erro ao abrir página premium. Tente novamente.',
        backgroundColor: Colors.red,
      );
    }
  }

  /// Força nova sincronização (limpa cache)
  Future<void> forceRefresh() async {
    // Force refresh bypasses circuit breaker but resets it first
    _resetCircuitBreaker();
    await _hiveRepository.clearPremiumCache();
    await checkPremiumStatus();
  }

  /// Obtém informações detalhadas do cache
  Map<String, dynamic> getCacheInfo() {
    return _hiveRepository.getCurrentUserPremiumInfo();
  }

  /// Obtém estatísticas do cache (para debug)
  Map<String, dynamic> getCacheStats() {
    return _hiveRepository.getCacheStats();
  }

  /// Limpa todos os dados premium (desenvolvimento)
  Future<void> clearAllData() async {
    await _hiveRepository.clearAllPremiumData();
    _cachedStatus = const PremiumStatus(isActive: false);
    _notifyStatusChange();
  }

  /// Verifica se pode usar feature premium
  @override
  bool canUseFeature(String featureName) {
    if (isPremium) return true;

    // Features gratuitas específicas
    const freeFeatures = {'basic_search', 'view_details', 'basic_favorites'};

    return freeFeatures.contains(featureName);
  }

  /// Obtém limite para feature específica
  @override
  int getFeatureLimit(String featureName) {
    if (isPremium) {
      // Limites premium
      switch (featureName) {
        case 'comments':
          return 100;
        case 'favorites':
          return 500;
        case 'searches_per_day':
          return 1000;
        default:
          return -1; // Ilimitado
      }
    } else {
      // Limites gratuitos
      switch (featureName) {
        case 'comments':
          return 5;
        case 'favorites':
          return 20;
        case 'searches_per_day':
          return 10;
        default:
          return 0;
      }
    }
  }

  /// Verifica se atingiu limite de uma feature
  @override
  bool hasReachedLimit(String featureName, int currentUsage) {
    final limit = getFeatureLimit(featureName);
    return limit > 0 && currentUsage >= limit;
  }

  // ============ NOVOS MÉTODOS REQUERIDOS PELA INTERFACE UNIFICADA ============

  @override
  Future<bool> isPremiumUser() async {
    await checkPremiumStatus();
    return isPremium;
  }

  @override
  Future<String?> getSubscriptionType() async {
    try {
      final subscriptionResult =
          await _subscriptionRepository.getCurrentSubscription();
      return subscriptionResult.fold(
        (failure) => null,
        (subscription) => _cachedStatus.planType,
      );
    } catch (e) {
      debugPrint('Error getting subscription type: $e');
      return null;
    }
  }

  @override
  Future<DateTime?> getSubscriptionExpiry() async {
    try {
      await _syncWithRevenueCat();
      return _cachedStatus.expiryDate;
    } catch (e) {
      debugPrint('Error getting subscription expiry: $e');
      return null;
    }
  }

  @override
  Future<bool> isSubscriptionActive() async {
    return await isPremiumUser();
  }

  @override
  Future<int> getRemainingDays() async {
    final expiryDate = await getSubscriptionExpiry();
    if (expiryDate == null) return -1; // Ilimitado ou erro

    final now = DateTime.now();
    return expiryDate.isAfter(now) ? expiryDate.difference(now).inDays : 0;
  }

  @override
  Future<void> refreshPremiumStatus() async {
    await forceRefresh();
  }

  @override
  Future<bool> hasFeatureAccess(String featureId) async {
    if (await isPremiumUser()) return true;

    // Features gratuitas específicas
    const freeFeatures = {'basic_search', 'view_details', 'basic_favorites'};

    return freeFeatures.contains(featureId);
  }

  @override
  Future<List<String>> getPremiumFeatures() async {
    return [
      'unlimited_comments',
      'unlimited_favorites',
      'advanced_search',
      'offline_mode',
      'priority_support',
      'ad_free_experience',
    ];
  }

  @override
  Future<bool> isTrialAvailable() async {
    // Por enquanto sempre disponível - TODO: implementar lógica específica
    return true;
  }

  @override
  Future<bool> startTrial() async {
    try {
      // Implementar lógica específica do RevenueCat para trial
      await generateTestSubscription();
      return true;
    } catch (e) {
      debugPrint('Error starting trial: $e');
      return false;
    }
  }

  @override
  String? get upgradeUrl =>
      'https://apps.apple.com/app/receituagro/id6738924932'; // App Store URL real

  @override
  Stream<bool> get premiumStatusStream => _statusStreamController.stream;

  /// Notifica mudanças no status premium via stream e força refresh em todas as telas
  void _notifyStatusChange() {
    notifyListeners();
    _statusStreamController.add(isPremium);
    
    // Força refresh em todas as telas que dependem do status premium
    _broadcastPremiumStatusChange();
  }
  
  /// Broadcasta mudanças de status premium para todas as telas do app
  void _broadcastPremiumStatusChange() {
    debugPrint('🔄 Broadcasting premium status change: isPremium=$isPremium');
    
    // Envia notificação global via NotificationCenter ou similar
    // Para simplificar, vamos usar um event bus simples
    PremiumStatusNotifier.instance.notifyStatusChanged(isPremium);
  }

  // ============ CIRCUIT BREAKER METHODS ============

  /// Verifica se circuit breaker está aberto
  bool _isCircuitBreakerOpen() {
    if (!_circuitBreakerOpen) return false;
    
    // Verifica se timeout expirou
    if (_lastFailureTime != null) {
      final timeElapsed = DateTime.now().difference(_lastFailureTime!);
      if (timeElapsed > _circuitBreakerTimeout) {
        _resetCircuitBreaker();
        return false;
      }
    }
    
    return true;
  }

  /// Registra uma falha no circuit breaker
  void _recordFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();
    
    if (_failureCount >= _maxFailures) {
      _circuitBreakerOpen = true;
      debugPrint('🔴 Circuit breaker opened after $_failureCount failures. Will retry in ${_circuitBreakerTimeout.inMinutes} minutes.');
    }
  }

  /// Reseta o circuit breaker após sucesso
  void _resetCircuitBreaker() {
    _failureCount = 0;
    _lastFailureTime = null;
    _circuitBreakerOpen = false;
    debugPrint('🟢 Circuit breaker reset - sync operations resumed');
  }

  /// Obtém tempo até próximo reset do circuit breaker
  Duration _getTimeUntilReset() {
    if (_lastFailureTime == null) return Duration.zero;
    
    final elapsed = DateTime.now().difference(_lastFailureTime!);
    final remaining = _circuitBreakerTimeout - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  void dispose() {
    _syncDebounceTimer?.cancel();
    _statusStreamController.close();
    super.dispose();
  }
}
