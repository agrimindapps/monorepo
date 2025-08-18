import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../repositories/premium_hive_repository.dart';
import '../models/premium_status_hive.dart';
import '../../features/settings/services/premium_service.dart';

/// Service premium real que integra RevenueCat com cache Hive local
/// Unifica todas as interfaces IPremiumService fragmentadas do projeto
class PremiumServiceReal extends ChangeNotifier implements IPremiumService {
  final PremiumHiveRepository _hiveRepository;
  final ISubscriptionRepository _subscriptionRepository;
  
  PremiumStatus _cachedStatus = const PremiumStatus(isActive: false);
  bool _isCheckingStatus = false;
  
  PremiumServiceReal({
    required PremiumHiveRepository hiveRepository,
    required ISubscriptionRepository subscriptionRepository,
  }) : _hiveRepository = hiveRepository,
       _subscriptionRepository = subscriptionRepository {
    _initializePremiumStatus();
  }

  /// Inicializa status premium do cache local
  void _initializePremiumStatus() {
    final hiveStatus = _hiveRepository.getCurrentUserPremiumStatus();
    if (hiveStatus != null) {
      _cachedStatus = _convertHiveToStatus(hiveStatus);
      
      // Se precisa sincronizar online, faz em background
      if (hiveStatus.shouldSyncOnline) {
        _syncOnlineInBackground();
      }
    } else {
      // Primeira vez - busca online
      _syncOnlineInBackground();
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
    
    _isCheckingStatus = true;
    try {
      await _syncWithRevenueCat();
    } finally {
      _isCheckingStatus = false;
    }
  }

  /// Sincronização em background
  void _syncOnlineInBackground() {
    Future.delayed(Duration.zero, () async {
      try {
        await _syncWithRevenueCat();
      } catch (e) {
        debugPrint('Background sync failed: $e');
      }
    });
  }

  /// Sincroniza com RevenueCat e atualiza cache local
  Future<void> _syncWithRevenueCat() async {
    try {
      // Verifica se tem assinatura ativa
      final hasActiveResult = await _subscriptionRepository.hasActiveSubscription();
      
      bool hasActive = false;
      SubscriptionEntity? subscription;
      
      hasActiveResult.fold(
        (failure) {
          debugPrint('Error checking subscription: ${failure.message}');
          return; // Mantém cache atual se falhar
        },
        (active) => hasActive = active,
      );

      // Se tem assinatura ativa, obtém detalhes
      if (hasActive) {
        final subscriptionResult = await _subscriptionRepository.getCurrentSubscription();
        subscriptionResult.fold(
          (failure) => debugPrint('Error getting subscription details: ${failure.message}'),
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
        // TODO: Ajustar propriedades conforme SubscriptionEntity real
        expiryDateTimestamp: null, // subscription?.expiryDate?.millisecondsSinceEpoch,
        planType: null, // subscription?.planType,
        subscriptionId: subscription?.toString(), // subscription?.id,
        productId: null, // subscription?.productId,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      
      hiveStatus.markAsSynced();
      await _hiveRepository.saveCurrentUserPremiumStatus(hiveStatus);

      // Atualiza status em memória e notifica listeners
      _cachedStatus = _convertHiveToStatus(hiveStatus);
      notifyListeners();

      debugPrint('Premium status synced successfully: isPremium=$isPremium');
      
    } catch (e) {
      debugPrint('Error syncing premium status: $e');
      // Em caso de erro, marca para tentar novamente
      await _hiveRepository.markCurrentUserNeedsSync();
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
      
      notifyListeners();
      debugPrint('Test subscription generated successfully');
      
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
      
      notifyListeners();
      debugPrint('Test subscription removed successfully');
      
    } catch (e) {
      debugPrint('Error removing test subscription: $e');
      throw Exception('Falha ao remover assinatura teste: $e');
    }
  }

  @override
  Future<void> navigateToPremium() async {
    // TODO: Implementar navegação para página de premium
    // Pode usar Navigator ou sistema de rotas do app
    debugPrint('Navigate to premium page requested');
  }

  /// Força nova sincronização (limpa cache)
  Future<void> forceRefresh() async {
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
    notifyListeners();
  }

  /// Verifica se pode usar feature premium
  bool canUseFeature(String featureName) {
    if (isPremium) return true;
    
    // Features gratuitas específicas
    const freeFeatures = {
      'basic_search',
      'view_details',
      'basic_favorites',
    };
    
    return freeFeatures.contains(featureName);
  }

  /// Obtém limite para feature específica
  int getFeatureLimit(String featureName) {
    if (isPremium) {
      // Limites premium
      switch (featureName) {
        case 'comments': return 100;
        case 'favorites': return 500;
        case 'searches_per_day': return 1000;
        default: return -1; // Ilimitado
      }
    } else {
      // Limites gratuitos
      switch (featureName) {
        case 'comments': return 5;
        case 'favorites': return 20;
        case 'searches_per_day': return 10;
        default: return 0;
      }
    }
  }

  /// Verifica se atingiu limite de uma feature
  bool hasReachedLimit(String featureName, int currentUsage) {
    final limit = getFeatureLimit(featureName);
    return limit > 0 && currentUsage >= limit;
  }

  @override
  void dispose() {
    super.dispose();
  }
}