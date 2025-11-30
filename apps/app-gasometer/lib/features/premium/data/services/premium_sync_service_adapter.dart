import 'dart:async';

import 'package:core/core.dart';

import '../../domain/entities/premium_status.dart';

/// Adapter para manter compatibilidade com código existente do GasOMeter
///
/// Envolve o AdvancedSubscriptionSyncService do Core e expõe a interface
/// legacy do PremiumSyncService, permitindo migração gradual sem quebrar
/// o código existente.
///
/// Migration path:
/// 1. Deploy com adapter (zero breaking changes)
/// 2. Gradualmente migrar features para usar Core diretamente
/// 3. Deprecar adapter quando todas features migrarem

class PremiumSyncServiceAdapter {
  PremiumSyncServiceAdapter(this._advancedSyncService);

  final AdvancedSubscriptionSyncService _advancedSyncService;

  /// Stream com status premium (legacy)
  ///
  /// Converte SubscriptionEntity do Core para PremiumStatus do GasOMeter
  Stream<PremiumStatus> get premiumStatusStream {
    return _advancedSyncService.subscriptionStream.map(_toPremiumStatus);
  }

  /// Status premium atual (legacy)
  PremiumStatus get currentStatus {
    return _toPremiumStatus(_advancedSyncService.currentSubscription);
  }

  /// Força sincronização
  Future<Either<Failure, void>> forceSync() async {
    final result = await _advancedSyncService.forceSync();
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  /// Inicializa o serviço
  Future<void> initialize() async {
    await _advancedSyncService.initialize();
  }

  /// Dispose recursos
  Future<void> dispose() async {
    await _advancedSyncService.dispose();
  }

  // ==================== Conversão ====================

  /// Converte SubscriptionEntity do Core para PremiumStatus do GasOMeter
  PremiumStatus _toPremiumStatus(SubscriptionEntity? subscription) {
    if (subscription == null || !subscription.isActive) {
      return PremiumStatus.free;
    }

    return PremiumStatus.premium(
      subscription: subscription,
      expirationDate: subscription.expirationDate,
      isInTrial: subscription.isInTrial,
      trialDaysRemaining: subscription.daysRemaining,
    );
  }
}
