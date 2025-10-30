import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/index.dart';
import '../services/subscription_error_message_service.dart';

/// Estado dos problemas de cobrança
class BillingState {
  final List<BillingIssueEntity> issues;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const BillingState({
    this.issues = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  factory BillingState.initial() {
    return const BillingState(
      issues: [],
      isLoading: false,
      error: null,
      lastUpdated: null,
    );
  }

  /// Cópia com atualizações seletivas
  BillingState copyWith({
    List<BillingIssueEntity>? issues,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return BillingState(
      issues: issues ?? this.issues,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Obtém apenas os problemas críticos
  List<BillingIssueEntity> get criticalIssues =>
      issues.where((issue) => issue.isCritical).toList();

  /// Obtém apenas os problemas não resolvidos
  List<BillingIssueEntity> get activeIssues =>
      issues.where((issue) => !issue.isResolved).toList();

  /// Obtém apenas os problemas que precisam de atenção
  List<BillingIssueEntity> get issuesThatNeedAttention =>
      issues.where((issue) => issue.needsAttention).toList();

  /// Indica se existem problemas de cobrança
  bool get hasIssues => issues.isNotEmpty;

  /// Indica se existem problemas críticos
  bool get hasCriticalIssues => criticalIssues.isNotEmpty;

  /// Conta de problemas que precisam de retry
  int get retryableIssueCount => issues.where((issue) => issue.canRetry).length;

  /// Indicador se precisa de atualização (> 5 minutos)
  bool get needsRefresh {
    if (lastUpdated == null) return true;
    final diff = DateTime.now().difference(lastUpdated!);
    return diff.inMinutes > 5;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingState &&
          runtimeType == other.runtimeType &&
          issues == other.issues &&
          isLoading == other.isLoading &&
          error == other.error &&
          lastUpdated == other.lastUpdated;

  @override
  int get hashCode =>
      issues.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      lastUpdated.hashCode;

  @override
  String toString() =>
      'BillingState(issues: ${issues.length}, isLoading: $isLoading, error: $error, lastUpdated: $lastUpdated)';
}

/// Notifier que gerencia problemas de cobrança
///
/// Responsabilidades:
/// - Carregar lista de problemas de cobrança
/// - Detectar e classificar novos problemas
/// - Gerenciar retry de cobranças falhadas
/// - Rastrear métodos de pagamento
/// - Resolução de problemas
class BillingNotifier extends StateNotifier<BillingState> {
  BillingNotifier(this._errorService) : super(BillingState.initial());

  final SubscriptionErrorMessageService _errorService;

  /// Carrega a lista de problemas de cobrança
  ///
  /// Busca dados de:
  /// - Banco de dados local
  /// - API remota
  /// - Sistema de pagamento
  Future<void> loadBillingIssues() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 700));

      // TODO: Substituir por chamada real ao repositório
      // final issues = await _billingRepository.getBillingIssues();

      // Dados de exemplo (remover em produção)
      final exampleIssues = <BillingIssueEntity>[
        BillingIssueEntity(
          id: 'issue_001',
          billingIssueCode: 'PAYMENT_FAILED_001',
          type: BillingIssueType.paymentFailed,
          message: 'A cobrança foi recusada pelo banco',
          localizedMessage:
              'Seu pagamento foi recusado. Por favor, atualize seu método de pagamento.',
          detectedAt: DateTime.now().subtract(const Duration(hours: 2)),
          resolvedAt: null,
          resolutionAction: 'update_payment_method',
          retryCount: 1,
          nextRetryAt: DateTime.now().add(const Duration(hours: 1)),
          lastUpdated: DateTime.now(),
        ),
      ];

      state = state.copyWith(
        issues: exampleIssues,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _errorService.getLoadBillingIssuesError(error.toString()),
      );
    }
  }

  /// Atualiza a lista de problemas de cobrança
  /// Chamado periodicamente para sincronizar
  Future<void> refreshBillingStatus() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // TODO: Fazer refresh real contra backend
      // final updated = await _billingRepository.refreshBillingStatus();

      state = state.copyWith(isLoading: false, lastUpdated: DateTime.now());
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _errorService.getUpdateBillingStatusError(error.toString()),
      );
    }
  }

  /// Tenta fazer retry de uma cobrança falhada
  ///
  /// Parâmetros:
  /// - [issueId]: ID do problema a fazer retry
  Future<void> retryFailedBilling({required String issueId}) async {
    final issue = state.issues.firstWhere(
      (i) => i.id == issueId,
      orElse: () => throw Exception('Problema não encontrado'),
    );

    if (!issue.canRetry) {
      state = state.copyWith(
        error:
            'Este problema não pode mais ser reprocessado (máx 3 tentativas)',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      // TODO: Chamar backend/API de retry
      // final retried = await _billingRepository.retryBilling(issueId: issueId);

      // Atualizar issue com novo retry
      final updated = issue.copyWith(
        retryCount: issue.retryCount + 1,
        nextRetryAt: DateTime.now().add(const Duration(hours: 1)),
        lastUpdated: DateTime.now(),
      );

      final newIssues = state.issues
          .map((i) => i.id == issueId ? updated : i)
          .toList();

      state = state.copyWith(
        issues: newIssues,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      // TODO: Log event de retry
      // _analyticsService.logEvent('billing_retry', {
      //   'issue_id': issueId,
      //   'retry_count': updated.retryCount,
      // });
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _errorService.getRetryPaymentError(error.toString()),
      );
    }
  }

  /// Resolve um problema de cobrança manualmente
  ///
  /// Parâmetros:
  /// - [issueId]: ID do problema a resolver
  /// - [resolutionNotes]: Notas de resolução (opcional)
  Future<void> resolveBillingIssue({
    required String issueId,
    String? resolutionNotes,
  }) async {
    final issue = state.issues.firstWhere(
      (i) => i.id == issueId,
      orElse: () => throw Exception('Problema não encontrado'),
    );

    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 800));

      // TODO: Chamar backend/API para resolver
      // await _billingRepository.resolveBillingIssue(
      //   issueId: issueId,
      //   notes: resolutionNotes,
      // );

      final resolved = issue.copyWith(
        resolvedAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      final newIssues = state.issues
          .map((i) => i.id == issueId ? resolved : i)
          .toList();

      state = state.copyWith(
        issues: newIssues,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      // TODO: Log event de resolução
      // _analyticsService.logEvent('billing_issue_resolved', {
      //   'issue_id': issueId,
      //   'issue_type': issue.type.toString(),
      // });
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao resolver problema: ${error.toString()}',
      );
    }
  }

  /// Atualiza o método de pagamento para resolver problemas
  ///
  /// Parâmetros:
  /// - [paymentMethodToken]: Token do novo método de pagamento
  Future<void> updatePaymentMethod({required String paymentMethodToken}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      // TODO: Chamar backend/API para atualizar método
      // await _paymentService.updatePaymentMethod(paymentMethodToken);

      // Resolver todos os problemas relacionados a método de pagamento
      final updatedIssues = <BillingIssueEntity>[];

      for (var issue in state.issues) {
        if (issue.type == BillingIssueType.paymentMethodExpired ||
            issue.type == BillingIssueType.paymentFailed) {
          updatedIssues.add(
            issue.copyWith(
              resolvedAt: DateTime.now(),
              lastUpdated: DateTime.now(),
            ),
          );
        } else {
          updatedIssues.add(issue);
        }
      }

      state = state.copyWith(
        issues: updatedIssues,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      // TODO: Log event de atualização
      // _analyticsService.logEvent('payment_method_updated');
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao atualizar método de pagamento: ${error.toString()}',
      );
    }
  }

  /// Descarta um aviso de cobrança
  ///
  /// Parâmetros:
  /// - [issueId]: ID do problema a descartar
  /// - [dismissReason]: Motivo do descarte
  Future<void> dismissWarning({
    required String issueId,
    required String dismissReason,
  }) async {
    try {
      // Log do descarte
      // _analyticsService.logEvent('billing_warning_dismissed', {
      //   'issue_id': issueId,
      //   'reason': dismissReason,
      // });

      // Remover da lista
      final newIssues = state.issues.where((i) => i.id != issueId).toList();
      state = state.copyWith(issues: newIssues);
    } catch (error) {
      state = state.copyWith(
        error: 'Erro ao descartar aviso: ${error.toString()}',
      );
    }
  }

  /// Adiciona um novo problema de cobrança
  /// Chamado pelo backend quando um novo problema é detectado
  void addBillingIssue(BillingIssueEntity issue) {
    // Evitar duplicatas
    final exists = state.issues.any(
      (i) => i.billingIssueCode == issue.billingIssueCode,
    );
    if (exists) return;

    final newIssues = [...state.issues, issue];
    state = state.copyWith(issues: newIssues);
  }

  /// Obtém o tempo até o próximo retry
  /// Retorna null se não há problemas com retry pendente
  Duration? getTimeUntilNextRetry() {
    final issuesWithRetry = state.issues
        .where((issue) => issue.canRetry)
        .toList();
    if (issuesWithRetry.isEmpty) return null;

    // Encontrar o problema com retry mais próximo
    DateTime? nextRetry;
    for (var issue in issuesWithRetry) {
      if (issue.nextRetryAt != null) {
        if (nextRetry == null || issue.nextRetryAt!.isBefore(nextRetry)) {
          nextRetry = issue.nextRetryAt;
        }
      }
    }

    if (nextRetry == null) return null;

    final diff = nextRetry.difference(DateTime.now());
    return diff.isNegative ? null : diff;
  }

  /// Sincroniza com backend
  /// Chamado periodicamente ou quando volta para foreground
  Future<void> syncWithBackend() async {
    if (state.needsRefresh) {
      await refreshBillingStatus();
    }
  }

  /// Limpa o estado e dados em cache
  void clearState() {
    state = BillingState.initial();
  }
}
