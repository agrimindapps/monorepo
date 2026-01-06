import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../database/repositories/subscription_local_repository.dart';
import '../../domain/entities/premium_status.dart';
import '../datasources/premium_firebase_data_source.dart';
import '../datasources/premium_remote_data_source.dart';
import '../datasources/premium_webhook_data_source.dart';

/// Serviço responsável pela sincronização avançada do status premium
///
/// Combina múltiplas fontes de dados (RevenueCat, Firebase, Webhooks)
/// para fornecer sincronização em tempo real e cross-device

class PremiumSyncService {
  PremiumSyncService(
    this._remoteDataSource,
    this._firebaseDataSource,
    this._webhookDataSource,
    this._authService, {
    SubscriptionLocalRepository? localRepository,
  }) : _localRepository = localRepository {
    _initializeStreams();
  }
  final PremiumRemoteDataSource _remoteDataSource;
  final PremiumFirebaseDataSource _firebaseDataSource;
  final PremiumWebhookDataSource _webhookDataSource;
  final core.IAuthRepository _authService;
  final SubscriptionLocalRepository? _localRepository;
  final BehaviorSubject<PremiumStatus> _masterStatusController =
      BehaviorSubject<PremiumStatus>.seeded(PremiumStatus.free);

  final PublishSubject<PremiumSyncEvent> _syncEventController =
      PublishSubject<PremiumSyncEvent>();
  late StreamSubscription<core.SubscriptionEntity?> _revenueCatSubscription;
  late StreamSubscription<PremiumStatus> _firebaseSubscription;
  late StreamSubscription<Map<String, dynamic>> _webhookSubscription;
  late StreamSubscription<core.UserEntity?> _authSubscription;
  Timer? _debounceTimer;
  final Duration _debounceDuration = const Duration(seconds: 2);
  int _retryCount = 0;
  final int _maxRetries = 3;
  Timer? _retryTimer;
  Stream<PremiumStatus> get premiumStatusStream =>
      _masterStatusController.stream.distinct();
  Stream<PremiumSyncEvent> get syncEvents => _syncEventController.stream;
  PremiumStatus get currentStatus => _masterStatusController.value;

  /// Inicializa todos os streams e listeners
  void _initializeStreams() {
    _authSubscription = _authService.currentUser.listen(_onAuthStateChanged);
    _revenueCatSubscription = _remoteDataSource.subscriptionStatus.listen(
      _onRevenueCatStatusChanged,
      onError: _onRevenueCatError,
    );
    _firebaseSubscription = _firebaseDataSource.premiumStatusStream.listen(
      _onFirebaseStatusChanged,
      onError: _onFirebaseError,
    );
    _webhookSubscription = _webhookDataSource.webhookEvents.listen(
      _onWebhookEvent,
      onError: _onWebhookError,
    );
  }

  /// Handler para mudanças de autenticação
  void _onAuthStateChanged(core.UserEntity? user) {
    if (user != null) {
      debugPrint('[PremiumSyncService] Usuário logado: ${user.id}');
      _syncEventController.add(PremiumSyncEvent.userLoggedIn(user.id));
      _performInitialSync(user.id);
    } else {
      debugPrint('[PremiumSyncService] Usuário deslogado');
      _masterStatusController.add(PremiumStatus.free);
      _syncEventController.add(PremiumSyncEvent.userLoggedOut());
    }
  }

  /// Handler para mudanças do RevenueCat
  void _onRevenueCatStatusChanged(core.SubscriptionEntity? subscription) {
    debugPrint(
      '[PremiumSyncService] RevenueCat atualizado: ${subscription?.isActive}',
    );

    if (subscription != null && _localRepository != null) {
      _localRepository.saveSubscription(subscription).catchError((Object e) {
        debugPrint('[PremiumSyncService] Erro ao salvar localmente: $e');
      });
    }

    _debounceStatusUpdate(() async {
      final status = await _buildPremiumStatusFromSubscription(subscription);
      await _updateMasterStatus(
        newStatus: status,
        source: PremiumSyncSource.revenueCat,
      );
    });
  }

  /// Handler para mudanças do Firebase
  void _onFirebaseStatusChanged(PremiumStatus status) {
    debugPrint('[PremiumSyncService] Firebase atualizado: ${status.isPremium}');

    _debounceStatusUpdate(() async {
      await _updateMasterStatus(
        newStatus: status,
        source: PremiumSyncSource.firebase,
      );
    });
  }

  /// Handler para eventos de webhook
  void _onWebhookEvent(Map<String, dynamic> event) {
    final eventType = event['event_type'] as String?;
    final userId = event['app_user_id'] as String?;

    debugPrint(
      '[PremiumSyncService] Webhook recebido: $eventType para $userId',
    );

    _syncEventController.add(
      PremiumSyncEvent.webhookReceived(eventType ?? 'unknown'),
    );
    _scheduleForceSync();
  }

  /// Atualiza o status master com resolução de conflitos
  Future<void> _updateMasterStatus({
    required PremiumStatus newStatus,
    required PremiumSyncSource source,
  }) async {
    try {
      final currentStatus = _masterStatusController.value;
      final resolvedStatus = await _resolveStatusConflict(
        current: currentStatus,
        newStatus: newStatus,
        source: source,
      );
      if (!_areStatusesEqual(currentStatus, resolvedStatus)) {
        _masterStatusController.add(resolvedStatus);

        _syncEventController.add(
          PremiumSyncEvent.statusUpdated(
            oldStatus: currentStatus,
            newStatus: resolvedStatus,
            source: source,
          ),
        );
        await _propagateStatusChange(resolvedStatus, source);

        _retryCount = 0; // Reset retry count em caso de sucesso
      }
    } catch (e) {
      debugPrint('[PremiumSyncService] Erro ao atualizar status: $e');
      _handleSyncError(e, source);
    }
  }

  /// Resolve conflitos entre diferentes status
  Future<PremiumStatus> _resolveStatusConflict({
    required PremiumStatus current,
    required PremiumStatus newStatus,
    required PremiumSyncSource source,
  }) async {
    switch (source) {
      case PremiumSyncSource.revenueCat:
        return newStatus;

      case PremiumSyncSource.firebase:
        if (current.premiumSource == 'free' ||
            current.premiumSource == 'local_license') {
          return newStatus;
        }
        return current;

      case PremiumSyncSource.local:
        if (current.premiumSource == 'free') {
          return newStatus;
        }
        return current;

      case PremiumSyncSource.webhook:
        _scheduleForceSync();
        return current;
    }
  }

  /// Propaga mudanças para outras fontes
  Future<void> _propagateStatusChange(
    PremiumStatus status,
    PremiumSyncSource excludeSource,
  ) async {
    try {
      final user = await _authService.currentUser.first;
      if (user == null) return;
      if (excludeSource != PremiumSyncSource.firebase) {
        await _firebaseDataSource.syncPremiumStatus(
          userId: user.id,
          status: status,
        );
      }
    } catch (e) {
      debugPrint('[PremiumSyncService] Erro na propagação: $e');
    }
  }

  /// Debounce para evitar múltiplas atualizações
  void _debounceStatusUpdate(VoidCallback updateFunction) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, updateFunction);
  }

  /// Força sincronização imediata
  Future<Either<Failure, void>> forceSync() async {
    try {
      _syncEventController.add(PremiumSyncEvent.syncStarted());
      final revenueCatResult = await _remoteDataSource.getCurrentSubscription();
      await revenueCatResult.fold(
        (failure) async {
          debugPrint(
            '[PremiumSyncService] RevenueCat falhou: ${failure.message}',
          );
        },
        (subscription) async {
          final status = await _buildPremiumStatusFromSubscription(
            subscription,
          );
          await _updateMasterStatus(
            newStatus: status,
            source: PremiumSyncSource.revenueCat,
          );
          
          // Se tivermos uma assinatura válida, salvar localmente e propagar
          if (subscription != null && _localRepository != null) {
            await _localRepository.saveSubscription(subscription);
            
            // Propagar para Firebase explicitamente se necessário
            // A propagação já acontece em _updateMasterStatus -> _propagateStatusChange
            // mas aqui garantimos que o registro local está atualizado antes
          }
        },
      );

      _syncEventController.add(PremiumSyncEvent.syncCompleted());
      return const Right(null);
    } catch (e) {
      _syncEventController.add(PremiumSyncEvent.syncFailed(e.toString()));
      return Left(ServerFailure('Erro na sincronização: ${e.toString()}'));
    }
  }

  /// Sincronização inicial quando usuário faz login
  Future<void> _performInitialSync(String userId) async {
    try {
      // 1. Try local repository first
      if (_localRepository != null) {
        try {
          final localSub = await _localRepository.getActiveSubscription(userId);
          if (localSub != null) {
             final status = await _buildPremiumStatusFromSubscription(localSub);
             _masterStatusController.add(status);
             debugPrint('[PremiumSyncService] Status carregado do banco local');
          }
        } catch (e) {
          debugPrint('[PremiumSyncService] Erro ao carregar do banco local: $e');
        }
      }

      final cacheResult = await _firebaseDataSource.getCachedPremiumStatus(
        userId: userId,
      );

      cacheResult.fold(
        (failure) => debugPrint(
          '[PremiumSyncService] Erro no cache: ${failure.message}',
        ),
        (cachedStatus) {
          if (cachedStatus != null) {
            _masterStatusController.add(cachedStatus);
            debugPrint('[PremiumSyncService] Status carregado do cache');
          }
        },
      );
      await forceSync();
    } catch (e) {
      debugPrint('[PremiumSyncService] Erro na sincronização inicial: $e');
    }
  }

  /// Agenda força sincronização após delay
  void _scheduleForceSync() {
    Timer(const Duration(seconds: 5), () {
      forceSync();
    });
  }

  /// Constrói PremiumStatus a partir de SubscriptionEntity
  Future<PremiumStatus> _buildPremiumStatusFromSubscription(
    core.SubscriptionEntity? subscription,
  ) async {
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

  /// Compara se dois status são efetivamente iguais
  bool _areStatusesEqual(PremiumStatus status1, PremiumStatus status2) {
    return status1.isPremium == status2.isPremium &&
        status1.isExpired == status2.isExpired &&
        status1.premiumSource == status2.premiumSource &&
        status1.expirationDate == status2.expirationDate;
  }

  /// Manipula erros de sincronização com retry
  void _handleSyncError(dynamic error, PremiumSyncSource source) {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      final delay = Duration(seconds: _retryCount * 2); // Backoff exponencial

      debugPrint(
        '[PremiumSyncService] Retry $_retryCount/$_maxRetries em ${delay.inSeconds}s',
      );

      _retryTimer?.cancel();
      _retryTimer = Timer(delay, () {
        forceSync();
      });

      _syncEventController.add(PremiumSyncEvent.retryScheduled(_retryCount));
    } else {
      _syncEventController.add(PremiumSyncEvent.syncFailed(error.toString()));
      _retryCount = 0; // Reset para próximas tentativas
    }
  }
  void _onRevenueCatError(dynamic error) {
    debugPrint('[PremiumSyncService] Erro RevenueCat: $error');
    _handleSyncError(error, PremiumSyncSource.revenueCat);
  }

  void _onFirebaseError(dynamic error) {
    debugPrint('[PremiumSyncService] Erro Firebase: $error');
    _handleSyncError(error, PremiumSyncSource.firebase);
  }

  void _onWebhookError(dynamic error) {
    debugPrint('[PremiumSyncService] Erro Webhook: $error');
  }

  /// Limpa recursos
  void dispose() {
    _revenueCatSubscription.cancel();
    _firebaseSubscription.cancel();
    _webhookSubscription.cancel();
    _authSubscription.cancel();

    _debounceTimer?.cancel();
    _retryTimer?.cancel();

    _masterStatusController.close();
    _syncEventController.close();
  }
}

/// Fontes de sincronização de premium status
enum PremiumSyncSource { revenueCat, firebase, local, webhook }

/// Eventos de sincronização premium
sealed class PremiumSyncEvent {
  const PremiumSyncEvent();

  factory PremiumSyncEvent.userLoggedIn(String userId) = _UserLoggedIn;
  factory PremiumSyncEvent.userLoggedOut() = _UserLoggedOut;
  factory PremiumSyncEvent.statusUpdated({
    required PremiumStatus oldStatus,
    required PremiumStatus newStatus,
    required PremiumSyncSource source,
  }) = _StatusUpdated;
  factory PremiumSyncEvent.webhookReceived(String eventType) = _WebhookReceived;
  factory PremiumSyncEvent.syncStarted() = _SyncStarted;
  factory PremiumSyncEvent.syncCompleted() = _SyncCompleted;
  factory PremiumSyncEvent.syncFailed(String error) = _SyncFailed;
  factory PremiumSyncEvent.retryScheduled(int attempt) = _RetryScheduled;
}

class _UserLoggedIn extends PremiumSyncEvent {
  const _UserLoggedIn(this.userId);
  final String userId;
}

class _UserLoggedOut extends PremiumSyncEvent {
  const _UserLoggedOut();
}

class _StatusUpdated extends PremiumSyncEvent {
  const _StatusUpdated({
    required this.oldStatus,
    required this.newStatus,
    required this.source,
  });
  final PremiumStatus oldStatus;
  final PremiumStatus newStatus;
  final PremiumSyncSource source;
}

class _WebhookReceived extends PremiumSyncEvent {
  const _WebhookReceived(this.eventType);
  final String eventType;
}

class _SyncStarted extends PremiumSyncEvent {
  const _SyncStarted();
}

class _SyncCompleted extends PremiumSyncEvent {
  const _SyncCompleted();
}

class _SyncFailed extends PremiumSyncEvent {
  const _SyncFailed(this.error);
  final String error;
}

class _RetryScheduled extends PremiumSyncEvent {
  const _RetryScheduled(this.attempt);
  final int attempt;
}
