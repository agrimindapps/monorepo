import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/index.dart';

part 'trial_notifier.g.dart';

/// Estado das informações de período experimental
class TrialState {
  final TrialInfoEntity? trial;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const TrialState({
    this.trial,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  factory TrialState.initial() {
    return const TrialState(
      trial: null,
      isLoading: false,
      error: null,
      lastUpdated: null,
    );
  }

  /// Cópia com atualizações seletivas
  TrialState copyWith({
    TrialInfoEntity? trial,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return TrialState(
      trial: trial ?? this.trial,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Indicador se trial está ativo
  bool get isTrialActive => trial != null && trial!.isActive;

  /// Indicador se trial precisa de atualização (> 30 minutos)
  bool get needsRefresh {
    if (lastUpdated == null) return true;
    final diff = DateTime.now().difference(lastUpdated!);
    return diff.inMinutes > 30;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrialState &&
          runtimeType == other.runtimeType &&
          trial == other.trial &&
          isLoading == other.isLoading &&
          error == other.error &&
          lastUpdated == other.lastUpdated;

  @override
  int get hashCode =>
      trial.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      lastUpdated.hashCode;

  @override
  String toString() =>
      'TrialState(trial: $trial, isLoading: $isLoading, error: $error, lastUpdated: $lastUpdated)';
}

/// Notifier que gerencia as informações e estado do período experimental
///
/// Responsabilidades:
/// - Carregar informações do período experimental
/// - Monitorar dias restantes
/// - Iniciar novo período experimental
/// - Cancelar período experimental
/// - Rastrear progresso do período
@riverpod
class TrialNotifier extends _$TrialNotifier {
  @override
  TrialState build() => TrialState.initial();

  /// Carrega informações do período experimental ativo
  ///
  /// Busca dados de:
  /// - Banco de dados local (Hive)
  /// - API remota
  /// - Sistema de assinatura
  Future<void> loadTrialInfo() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simula latência de rede
      await Future<void>.delayed(const Duration(milliseconds: 600));

      // TODO: Substituir por chamada real ao repositório
      // final trial = await _trialRepository.getActiveTrialInfo();

      // Dados de exemplo (remover em produção)
      final exampleTrial = TrialInfoEntity(
        id: 'trial_123456',
        productId: 'com.receituagro.trial.14days',
        isActive: true,
        totalTrialDays: 14,
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 9)),
        expirationReason: null,
        lastUpdated: DateTime.now(),
      );

      state = state.copyWith(
        trial: exampleTrial,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar trial: ${error.toString()}',
      );
    }
  }

  /// Atualiza as informações do período experimental
  /// Chamado periodicamente para sincronizar com backend
  Future<void> refreshTrialInfo() async {
    if (state.trial == null) {
      await loadTrialInfo();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));

      // TODO: Fazer refresh real contra backend
      // final updated = await _trialRepository.refreshTrialInfo();

      state = state.copyWith(isLoading: false, lastUpdated: DateTime.now());
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao atualizar trial: ${error.toString()}',
      );
    }
  }

  /// Inicia um novo período experimental para o usuário
  ///
  /// Parâmetros:
  /// - [productId]: ID do produto para período experimental
  /// - [durationInDays]: Duração do período em dias (padrão: 14)
  Future<void> startNewTrial({
    required String productId,
    int durationInDays = 14,
  }) async {
    // Validar se já existe trial ativo
    if (state.trial != null && state.trial!.isActive) {
      state = state.copyWith(error: 'Já existe um período experimental ativo');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 900));

      // TODO: Chamar backend/API para iniciar trial
      // final newTrial = await _trialRepository.startNewTrial(
      //   productId: productId,
      //   durationInDays: durationInDays,
      // );

      final now = DateTime.now();
      final newTrial = TrialInfoEntity(
        id: 'trial_${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        isActive: true,
        totalTrialDays: durationInDays,
        startDate: now,
        endDate: now.add(Duration(days: durationInDays)),
        expirationReason: null,
        lastUpdated: now,
      );

      state = state.copyWith(
        trial: newTrial,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      // TODO: Log event de novo trial
      // _analyticsService.logEvent('trial_started', {
      //   'product_id': productId,
      //   'duration_days': durationInDays,
      // });
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao iniciar período experimental: ${error.toString()}',
      );
    }
  }

  /// Cancela o período experimental atual
  ///
  /// Parâmetros:
  /// - [reason]: Motivo do cancelamento (para analytics)
  Future<void> cancelTrial({required String reason}) async {
    final currentTrial = state.trial;
    if (currentTrial == null || !currentTrial.isActive) {
      state = state.copyWith(
        error: 'Nenhum período experimental ativo para cancelar',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 700));

      // TODO: Chamar backend/API de cancelamento
      // await _trialRepository.cancelTrial();

      final cancelled = currentTrial.copyWith(
        isActive: false,
        expirationReason: 'cancelled_by_user',
        lastUpdated: DateTime.now(),
      );

      state = state.copyWith(
        trial: cancelled,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      // TODO: Log event de cancelamento
      // _analyticsService.logEvent('trial_cancelled', {
      //   'reason': reason,
      //   'days_used': currentTrial.daysUsed.inDays,
      // });
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao cancelar período experimental: ${error.toString()}',
      );
    }
  }

  /// Verifica e atualiza o status de expiração do trial
  /// Chamado periodicamente para detectar expiração
  Future<void> checkTrialExpiry() async {
    final trial = state.trial;
    if (trial == null || !trial.isActive) return;

    // Se trial expirou
    if (trial.isExpired) {
      await handleTrialExpired();
      return;
    }

    // Se trial está prestes a expirar (< 3 dias)
    if (trial.isExpiringSoon && trial.daysRemaining != null) {
      // TODO: Disparar notificação de expiração iminente
      // _notificationService.showTrialExpiringWarning(
      //   daysRemaining: trial.daysRemaining!.inDays,
      // );
    }
  }

  /// Manipula a expiração do período experimental
  /// Chamado automaticamente quando trial expira
  Future<void> handleTrialExpired() async {
    final currentTrial = state.trial;
    if (currentTrial == null) return;

    state = state.copyWith(isLoading: true);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // TODO: Chamar backend para finalizar trial
      // await _trialRepository.finalizeExpiredTrial();

      final expired = currentTrial.copyWith(
        isActive: false,
        expirationReason: 'expired_naturally',
        lastUpdated: DateTime.now(),
      );

      state = state.copyWith(
        trial: expired,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      // TODO: Disparar actions pós-expiração
      // - Remover acesso a features
      // - Mostrar upsell
      // - Oferecer conversão para assinatura

      // TODO: Log event de expiração
      // _analyticsService.logEvent('trial_expired', {
      //   'total_days': currentTrial.totalTrialDays,
      //   'days_used': currentTrial.daysUsed.inDays,
      // });
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao processar expiração do trial: ${error.toString()}',
      );
    }
  }

  /// Obtém o progresso visual do período experimental
  /// Retorna um valor de 0.0 a 1.0
  double getTrialProgressPercentage() {
    final trial = state.trial;
    if (trial == null) return 0.0;
    return trial.progressPercentage / 100.0;
  }

  /// Obtém representação textual dos dias restantes
  /// Exemplo: "5 dias restantes", "Expira amanhã", "Expirado"
  String getTrialRemainingText() {
    final trial = state.trial;
    if (trial == null) return 'Sem período experimental';

    if (!trial.isActive) {
      return 'Período experimental finalizado';
    }

    final daysRemaining = trial.daysRemaining;
    if (daysRemaining == null) {
      return 'Período experimental ativo';
    }

    final days = daysRemaining.inDays;
    if (days > 1) {
      return '$days dias restantes';
    } else if (days == 1) {
      return 'Expira amanhã';
    } else {
      final hours = daysRemaining.inHours;
      if (hours > 0) {
        return 'Expira em $hours horas';
      } else {
        return 'Expira em poucos minutos';
      }
    }
  }

  /// Sincroniza status com backend
  /// Chamado periodicamente ou quando volta para foreground
  Future<void> syncWithBackend() async {
    if (state.needsRefresh) {
      await refreshTrialInfo();
    }

    // Também verifica expiração
    await checkTrialExpiry();
  }

  /// Limpa o estado e dados em cache
  void clearState() {
    state = TrialState.initial();
  }
}
