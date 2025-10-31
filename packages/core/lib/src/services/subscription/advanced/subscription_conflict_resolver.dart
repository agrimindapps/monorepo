import '../../../domain/entities/subscription_entity.dart';
import '../subscription_sync_models.dart';

/// Serviço para resolução de conflitos entre múltiplas fontes de subscription
///
/// Segue o princípio SRP (Single Responsibility Principle) lidando apenas
/// com lógica de resolução de conflitos.
///
/// Baseado no PremiumConflictResolver do GasOMeter, mas generalizado
/// para funcionar com qualquer app do monorepo.
class SubscriptionConflictResolver {
  /// Estratégia de resolução configurada
  final ConflictResolutionStrategy strategy;

  const SubscriptionConflictResolver({
    this.strategy = ConflictResolutionStrategy.priorityBased,
  });

  /// Resolve conflito entre duas subscriptions
  ///
  /// Aplica a estratégia configurada para decidir qual subscription prevalece
  SubscriptionEntity? resolve(
    SubscriptionEntity? subscription1,
    SubscriptionEntity? subscription2, {
    int? priority1,
    int? priority2,
  }) {
    // Se uma é null, retorna a outra
    if (subscription1 == null) return subscription2;
    if (subscription2 == null) return subscription1;

    switch (strategy) {
      case ConflictResolutionStrategy.priorityBased:
        return _resolveByPriority(
          subscription1,
          subscription2,
          priority1,
          priority2,
        );
      case ConflictResolutionStrategy.timestampBased:
        return _resolveByTimestamp(subscription1, subscription2);
      case ConflictResolutionStrategy.mostPermissive:
        return _resolveByMostPermissive(subscription1, subscription2);
      case ConflictResolutionStrategy.mostRestrictive:
        return _resolveByMostRestrictive(subscription1, subscription2);
      case ConflictResolutionStrategy.manualOverride:
        // Para manual, retorna a primeira (app deve implementar lógica própria)
        return subscription1;
    }
  }

  /// Resolve conflito entre múltiplas subscriptions
  ///
  /// Útil quando há 3+ fontes de dados
  SubscriptionEntity? resolveMultiple(
    List<SubscriptionEntity?> subscriptions, {
    List<int>? priorities,
  }) {
    // Filtra nulls
    final validSubscriptions = subscriptions
        .whereType<SubscriptionEntity>()
        .toList();

    if (validSubscriptions.isEmpty) return null;
    if (validSubscriptions.length == 1) return validSubscriptions.first;

    // Aplica resolução em pares
    SubscriptionEntity result = validSubscriptions.first;
    int? resultPriority = priorities?.isNotEmpty == true
        ? priorities![0]
        : null;

    for (int i = 1; i < validSubscriptions.length; i++) {
      final subscription = validSubscriptions[i];
      final priority = (priorities?.length ?? 0) > i ? priorities![i] : null;

      result = resolve(
        result,
        subscription,
        priority1: resultPriority,
        priority2: priority,
      )!;

      // Atualiza priority do resultado
      if (resultPriority != null && priority != null) {
        resultPriority = resultPriority > priority ? resultPriority : priority;
      }
    }

    return result;
  }

  /// Verifica se duas subscriptions são efetivamente iguais
  bool areEqual(SubscriptionEntity? a, SubscriptionEntity? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;

    // Compara status e tier
    if (a.status != b.status) return false;
    if (a.tier != b.tier) return false;
    if (a.store != b.store) return false;

    // Compara expiration dates (com tolerância de 1 segundo para clock skew)
    if (a.expirationDate != null && b.expirationDate != null) {
      final diff = a.expirationDate!.difference(b.expirationDate!).abs();
      return diff.inSeconds <= 1;
    }

    return a.expirationDate == b.expirationDate;
  }

  /// Verifica se subscription precisa de atualização
  bool needsUpdate(SubscriptionEntity? current, SubscriptionEntity? newSub) {
    return !areEqual(current, newSub);
  }

  /// Valida consistência de uma subscription
  ///
  /// Retorna true se a subscription está válida e consistente
  bool isValid(SubscriptionEntity subscription) {
    // Check: Status expired deve ter expirationDate no passado
    if (subscription.isExpired) {
      if (subscription.expirationDate == null) return false;
      if (DateTime.now().isBefore(subscription.expirationDate!)) return false;
    }

    // Check: Status active deve ter expirationDate no futuro (se houver)
    if (subscription.isActive && subscription.expirationDate != null) {
      if (DateTime.now().isAfter(subscription.expirationDate!)) return false;
    }

    // Check: productId não deve estar vazio para subscriptions ativas
    if (subscription.isActive && subscription.productId.isEmpty) {
      return false;
    }

    return true;
  }

  /// Obtém ação recomendada baseada no conflito
  ConflictResolutionAction getRecommendedAction(
    SubscriptionEntity? local,
    SubscriptionEntity? remote,
  ) {
    if (areEqual(local, remote)) {
      return ConflictResolutionAction.noAction;
    }

    if (local == null && remote != null) {
      return ConflictResolutionAction.syncToLocal;
    }

    if (local != null && remote == null) {
      return ConflictResolutionAction.syncToRemote;
    }

    // Ambos não-null neste ponto
    final localNonNull = local!;
    final remoteNonNull = remote!;

    if (localNonNull.isActive && !remoteNonNull.isActive) {
      return ConflictResolutionAction.syncToRemote;
    }

    if (!localNonNull.isActive && remoteNonNull.isActive) {
      return ConflictResolutionAction.syncToLocal;
    }

    // Ambas ativas - resolver por expiration
    final resolved = resolve(localNonNull, remoteNonNull);
    if (areEqual(resolved, localNonNull)) {
      return ConflictResolutionAction.syncToRemote;
    } else {
      return ConflictResolutionAction.syncToLocal;
    }
  }

  // ==================== Métodos Privados de Resolução ====================

  SubscriptionEntity _resolveByPriority(
    SubscriptionEntity sub1,
    SubscriptionEntity sub2,
    int? priority1,
    int? priority2,
  ) {
    // Se há priorities, usa a maior
    if (priority1 != null && priority2 != null) {
      return priority1 >= priority2 ? sub1 : sub2;
    }

    // Fallback: Prefere a ativa
    if (sub1.isActive && !sub2.isActive) return sub1;
    if (!sub1.isActive && sub2.isActive) return sub2;

    // Ambas ativas ou inativas: prefere expiration mais tarde
    return _resolveByExpiration(sub1, sub2);
  }

  SubscriptionEntity _resolveByTimestamp(
    SubscriptionEntity sub1,
    SubscriptionEntity sub2,
  ) {
    // Compara updatedAt - mais recente vence
    final updatedAt1 = sub1.updatedAt ?? DateTime.now();
    final updatedAt2 = sub2.updatedAt ?? DateTime.now();

    if (updatedAt1.isAfter(updatedAt2)) {
      return sub1;
    } else if (updatedAt2.isAfter(updatedAt1)) {
      return sub2;
    }

    // Timestamps iguais: fallback para expiration
    return _resolveByExpiration(sub1, sub2);
  }

  SubscriptionEntity _resolveByMostPermissive(
    SubscriptionEntity sub1,
    SubscriptionEntity sub2,
  ) {
    // Se qualquer uma é ativa, retorna a ativa
    if (sub1.isActive) return sub1;
    if (sub2.isActive) return sub2;

    // Se qualquer uma tem trial ativo, retorna com trial
    if (sub1.isTrialActive) return sub1;
    if (sub2.isTrialActive) return sub2;

    // Nenhuma ativa: prefere a com expiration mais tarde
    return _resolveByExpiration(sub1, sub2);
  }

  SubscriptionEntity _resolveByMostRestrictive(
    SubscriptionEntity sub1,
    SubscriptionEntity sub2,
  ) {
    // Se qualquer uma NÃO é ativa, retorna a não-ativa
    if (!sub1.isActive) return sub1;
    if (!sub2.isActive) return sub2;

    // Ambas ativas: prefere a com expiration mais cedo (mais conservador)
    if (sub1.expirationDate != null && sub2.expirationDate != null) {
      return sub1.expirationDate!.isBefore(sub2.expirationDate!) ? sub1 : sub2;
    }

    // Fallback
    return sub1;
  }

  SubscriptionEntity _resolveByExpiration(
    SubscriptionEntity sub1,
    SubscriptionEntity sub2,
  ) {
    if (sub1.expirationDate != null && sub2.expirationDate != null) {
      return sub1.expirationDate!.isAfter(sub2.expirationDate!) ? sub1 : sub2;
    }

    // Prefere a que tem expiration date
    if (sub1.expirationDate != null) return sub1;
    if (sub2.expirationDate != null) return sub2;

    // Nenhuma tem: retorna a primeira
    return sub1;
  }
}

/// Ação recomendada para resolução de conflito
enum ConflictResolutionAction {
  /// Nenhuma ação necessária (subscriptions são iguais)
  noAction,

  /// Sincronizar remote para local
  syncToLocal,

  /// Sincronizar local para remote
  syncToRemote,

  /// Requer resolução manual do app
  requiresManualResolution,
}
