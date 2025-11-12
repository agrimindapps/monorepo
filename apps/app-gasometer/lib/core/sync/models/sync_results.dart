import 'package:equatable/equatable.dart';

/// Resultado de operação Push (local → Firestore)
///
/// Encapsula estatísticas e status de uma operação de upload de
/// registros dirty locais para o Firestore.
///
/// Use cases:
/// - Feedback ao usuário (ex: "5 veículos sincronizados")
/// - Logging e debugging (identificar falhas parciais)
/// - Métricas de performance (tempo de sincronização)
/// - Retry logic (se recordsFailed > 0)
class SyncPushResult extends Equatable {
  const SyncPushResult({
    required this.recordsPushed,
    this.recordsFailed = 0,
    this.errors = const [],
    required this.duration,
  });

  /// Número de registros enviados com sucesso para Firestore
  final int recordsPushed;

  /// Número de registros que falharam durante upload
  ///
  /// Pode ocorrer por:
  /// - Validação falhou no servidor (Firestore security rules)
  /// - Network timeout parcial
  /// - Dados inválidos (malformed JSON)
  final int recordsFailed;

  /// Lista de mensagens de erro (uma por registro falho)
  ///
  /// Útil para debugging e logging detalhado.
  /// Cada string deve identificar o registro e o erro:
  /// Ex: "Vehicle 'abc-123': Firestore permission denied"
  final List<String> errors;

  /// Tempo total da operação de push
  ///
  /// Útil para:
  /// - Métricas de performance
  /// - Detecção de operações lentas
  /// - Tuning de batch size
  final Duration duration;

  /// Verifica se operação foi 100% bem-sucedida
  ///
  /// true apenas se TODOS os registros foram enviados sem erros
  bool get isSuccess => recordsFailed == 0;

  /// Verifica se houve falha total (nenhum registro enviado)
  bool get isFailure => recordsPushed == 0 && recordsFailed > 0;

  /// Verifica se houve falha parcial (alguns enviados, outros falharam)
  bool get isPartialSuccess => recordsPushed > 0 && recordsFailed > 0;

  /// Total de registros processados (sucesso + falhas)
  int get totalRecords => recordsPushed + recordsFailed;

  /// Taxa de sucesso (0.0 a 1.0)
  ///
  /// Útil para métricas:
  /// - 1.0 = 100% sucesso
  /// - 0.5 = 50% sucesso
  /// - 0.0 = 0% sucesso
  double get successRate {
    if (totalRecords == 0) return 0.0;
    return recordsPushed / totalRecords;
  }

  /// Mensagem resumo para logging
  String get summary {
    if (isSuccess) {
      return 'Push successful: $recordsPushed records in ${duration.inMilliseconds}ms';
    } else if (isFailure) {
      return 'Push failed: $recordsFailed errors';
    } else {
      return 'Push partial: $recordsPushed OK, $recordsFailed failed';
    }
  }

  @override
  List<Object?> get props => [recordsPushed, recordsFailed, errors, duration];

  @override
  String toString() {
    return 'SyncPushResult('
        'pushed: $recordsPushed, '
        'failed: $recordsFailed, '
        'duration: ${duration.inMilliseconds}ms)';
  }

  /// Cria resultado vazio (nenhum registro processado)
  factory SyncPushResult.empty() {
    return const SyncPushResult(
      recordsPushed: 0,
      recordsFailed: 0,
      duration: Duration.zero,
    );
  }

  /// Cria resultado de sucesso total
  factory SyncPushResult.success({
    required int recordsPushed,
    required Duration duration,
  }) {
    return SyncPushResult(
      recordsPushed: recordsPushed,
      recordsFailed: 0,
      duration: duration,
    );
  }

  /// Cria resultado de falha total
  factory SyncPushResult.failure({
    required int recordsFailed,
    required List<String> errors,
    required Duration duration,
  }) {
    return SyncPushResult(
      recordsPushed: 0,
      recordsFailed: recordsFailed,
      errors: errors,
      duration: duration,
    );
  }

  /// Combina múltiplos resultados (útil para batch operations)
  static SyncPushResult combine(List<SyncPushResult> results) {
    if (results.isEmpty) return SyncPushResult.empty();

    return SyncPushResult(
      recordsPushed: results.fold(0, (sum, r) => sum + r.recordsPushed),
      recordsFailed: results.fold(0, (sum, r) => sum + r.recordsFailed),
      errors: results.expand((r) => r.errors).toList(),
      duration: results.fold(
        Duration.zero,
        (sum, r) => sum + r.duration,
      ),
    );
  }
}

/// Resultado de operação Pull (Firestore → local)
///
/// Encapsula estatísticas de uma operação de download de mudanças
/// remotas do Firestore para o banco Drift local.
///
/// Use cases:
/// - Feedback ao usuário (ex: "3 novos registros sincronizados")
/// - Logging de conflitos resolvidos
/// - Métricas de sincronização incremental
/// - Detecção de problemas (muitos conflitos = problema de UX)
class SyncPullResult extends Equatable {
  const SyncPullResult({
    required this.recordsPulled,
    this.recordsUpdated = 0,
    this.conflictsResolved = 0,
    this.warnings = const [],
    required this.duration,
  });

  /// Número de registros NOVOS baixados do Firestore
  ///
  /// Registros que não existiam localmente e foram inseridos.
  final int recordsPulled;

  /// Número de registros EXISTENTES que foram atualizados
  ///
  /// Registros que já existiam localmente mas mudaram remotamente.
  /// Não inclui conflitos (contados separadamente).
  final int recordsUpdated;

  /// Número de conflitos detectados e resolvidos
  ///
  /// Ocorre quando:
  /// - Registro existe local E remotamente
  /// - Local está dirty (pendente de push)
  /// - Versões diferem
  ///
  /// Alta contagem pode indicar:
  /// - Sync interval muito longo
  /// - Múltiplos dispositivos editando simultaneamente
  /// - Problemas de UX (usuário não percebe mudanças remotas)
  final int conflictsResolved;

  /// Lista de avisos (warnings) não críticos
  ///
  /// Exemplos:
  /// - "Record 'xyz' had missing optional field 'notes'"
  /// - "Timestamp drift detected: 5 minutes"
  /// - "Slow query: took 3.5 seconds"
  ///
  /// Warnings não impedem sync, mas indicam problemas potenciais.
  final List<String> warnings;

  /// Tempo total da operação de pull
  final Duration duration;

  /// Total de registros afetados (novos + atualizados + conflitos)
  int get totalRecords => recordsPulled + recordsUpdated + conflictsResolved;

  /// Verifica se houve mudanças (algum registro foi sincronizado)
  bool get hasChanges => totalRecords > 0;

  /// Verifica se houve conflitos
  bool get hasConflicts => conflictsResolved > 0;

  /// Verifica se houve avisos
  bool get hasWarnings => warnings.isNotEmpty;

  /// Mensagem resumo para logging
  String get summary {
    if (!hasChanges) {
      return 'Pull complete: no changes (${duration.inMilliseconds}ms)';
    }

    final parts = <String>[];
    if (recordsPulled > 0) parts.add('$recordsPulled new');
    if (recordsUpdated > 0) parts.add('$recordsUpdated updated');
    if (conflictsResolved > 0) parts.add('$conflictsResolved conflicts');

    return 'Pull complete: ${parts.join(", ")} (${duration.inMilliseconds}ms)';
  }

  @override
  List<Object?> get props => [
        recordsPulled,
        recordsUpdated,
        conflictsResolved,
        warnings,
        duration,
      ];

  @override
  String toString() {
    return 'SyncPullResult('
        'pulled: $recordsPulled, '
        'updated: $recordsUpdated, '
        'conflicts: $conflictsResolved, '
        'duration: ${duration.inMilliseconds}ms)';
  }

  /// Cria resultado vazio (nenhuma mudança detectada)
  factory SyncPullResult.empty() {
    return const SyncPullResult(
      recordsPulled: 0,
      recordsUpdated: 0,
      conflictsResolved: 0,
      duration: Duration.zero,
    );
  }

  /// Cria resultado com apenas novos registros (sem conflitos)
  factory SyncPullResult.newRecords({
    required int recordsPulled,
    required Duration duration,
  }) {
    return SyncPullResult(
      recordsPulled: recordsPulled,
      recordsUpdated: 0,
      conflictsResolved: 0,
      duration: duration,
    );
  }

  /// Cria resultado com apenas atualizações (sem conflitos)
  factory SyncPullResult.updatesOnly({
    required int recordsUpdated,
    required Duration duration,
  }) {
    return SyncPullResult(
      recordsPulled: 0,
      recordsUpdated: recordsUpdated,
      conflictsResolved: 0,
      duration: duration,
    );
  }

  /// Combina múltiplos resultados (útil para batch operations)
  static SyncPullResult combine(List<SyncPullResult> results) {
    if (results.isEmpty) return SyncPullResult.empty();

    return SyncPullResult(
      recordsPulled: results.fold(0, (sum, r) => sum + r.recordsPulled),
      recordsUpdated: results.fold(0, (sum, r) => sum + r.recordsUpdated),
      conflictsResolved: results.fold(
        0,
        (sum, r) => sum + r.conflictsResolved,
      ),
      warnings: results.expand((r) => r.warnings).toList(),
      duration: results.fold(
        Duration.zero,
        (sum, r) => sum + r.duration,
      ),
    );
  }
}
