import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../entities/subscription_entity.dart';

/// Interface para serviços de sincronização de subscription
///
/// Define o contrato para serviços que sincronizam o status de subscription
/// entre múltiplas fontes de dados (RevenueCat, Firebase, Webhooks, etc)
///
/// Implementações:
/// - [SimpleSubscriptionSyncService]: Versão básica com cache local
/// - [AdvancedSubscriptionSyncService]: Versão avançada com multi-source sync
abstract class ISubscriptionSyncService {
  /// Stream reativo com o status atual da subscription
  ///
  /// Emite novos valores quando a subscription é atualizada de qualquer fonte
  Stream<SubscriptionEntity?> get subscriptionStream;

  /// Status atual da subscription em cache
  ///
  /// Retorna o último valor conhecido sem fazer novas requisições.
  /// Útil para verificações síncronas rápidas.
  SubscriptionEntity? get currentSubscription;

  /// Se há uma subscription ativa no momento
  bool get hasActiveSubscription;

  /// Se o serviço está sincronizando no momento
  bool get isSyncing;

  /// Força uma sincronização completa de todas as fontes
  ///
  /// Útil quando o usuário faz uma compra ou quer atualizar manualmente.
  /// Ignora cache e debounce, forçando fetch de todas as fontes.
  Future<Either<Failure, SubscriptionEntity?>> forceSync();

  /// Inicializa o serviço de sincronização
  ///
  /// Deve ser chamado antes de usar o serviço.
  /// Carrega cache local e inicia listeners se aplicável.
  Future<void> initialize();

  /// Verifica se tem subscription ativa para um app específico
  ///
  /// [appName]: Nome do app (ex: 'plantis', 'receituagro', 'gasometer')
  Future<Either<Failure, bool>> hasActiveSubscriptionForApp(String appName);

  /// Dispose de recursos (streams, timers, listeners)
  ///
  /// Deve ser chamado quando o serviço não for mais usado
  Future<void> dispose();

  /// Se o serviço foi disposed
  bool get isDisposed;
}
