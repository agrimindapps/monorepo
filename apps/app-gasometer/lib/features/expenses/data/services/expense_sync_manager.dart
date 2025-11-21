
import '../../domain/entities/expense_entity.dart';
import '../models/expense_model.dart';

/// Serviço responsável por sincronizar despesas entre cache local e Firebase
///
/// Gerencia a estratégia de sincronização, detecção de conflitos
/// e resolução de dados desatualizados.

class ExpenseSyncManager {
  ExpenseSyncManager();

  /// Verifica se uma despesa local está desatualizada comparada com a remota
  bool isLocalStale(ExpenseModel local, ExpenseEntity remote) {
    // Se remote foi atualizado depois do local, está desatualizado
    if (remote.updatedAt != null && local.updatedAt != null) {
      return remote.updatedAt!.isAfter(local.updatedAt!);
    }

    return false;
  }

  /// Detecta conflitos entre versão local e remota
  SyncConflict? detectConflict(ExpenseModel local, ExpenseEntity remote) {
    // Se ambos foram modificados recentemente (< 5 min de diferença)
    if (local.updatedAt != null && remote.updatedAt != null) {
      final diff = local.updatedAt!.difference(remote.updatedAt!).abs();

      if (diff.inMinutes < 5 && !_areIdentical(local, remote)) {
        return SyncConflict(
          localVersion: local,
          remoteVersion: remote,
          conflictType: ConflictType.simultaneousEdit,
        );
      }
    }

    return null;
  }

  /// Verifica se local e remote são idênticos em dados
  bool _areIdentical(ExpenseModel local, ExpenseEntity remote) {
    return local.veiculoId == remote.vehicleId &&
        local.tipo == remote.type.name &&
        local.descricao == remote.description &&
        local.valor == remote.amount &&
        local.data == remote.date.millisecondsSinceEpoch &&
        local.odometro == remote.odometer;
  }

  /// Resolve conflito usando estratégia "last write wins"
  ExpenseEntity resolveConflict(SyncConflict conflict) {
    final local = conflict.localVersion;
    final remote = conflict.remoteVersion;

    // Usa a versão mais recente
    if (local.updatedAt != null && remote.updatedAt != null) {
      return local.updatedAt!.isAfter(remote.updatedAt!)
          ? _modelToEntity(local)
          : remote;
    }

    // Fallback para versão remota se não tiver timestamps
    return remote;
  }

  /// Identifica despesas que precisam ser sincronizadas
  List<ExpenseModel> findPendingSync(List<ExpenseModel> localExpenses) {
    final now = DateTime.now();

    return localExpenses.where((expense) {
      // Despesas marcadas para deletar
      if (expense.isDeleted) return true;

      // Despesas modificadas recentemente (< 1 hora)
      if (expense.updatedAt != null) {
        final diff = now.difference(expense.updatedAt!);
        return diff.inHours < 1;
      }

      return false;
    }).toList();
  }

  /// Agrupa despesas por status de sincronização
  SyncStatus analyzeSyncStatus(
    List<ExpenseModel> localExpenses,
    List<ExpenseEntity> remoteExpenses,
  ) {
    final localIds = localExpenses.map((e) => e.id).toSet();
    final remoteIds = remoteExpenses.map((e) => e.id).toSet();

    final onlyLocal = localIds.difference(remoteIds);
    final onlyRemote = remoteIds.difference(localIds);
    final inBoth = localIds.intersection(remoteIds);

    var needsUpload = 0;
    var needsDownload = 0;
    var conflicts = 0;

    // Analisa despesas em ambos
    for (final id in inBoth) {
      final local = localExpenses.firstWhere((e) => e.id == id);
      final remote = remoteExpenses.firstWhere((e) => e.id == id);

      if (isLocalStale(local, remote)) {
        needsDownload++;
      } else if (detectConflict(local, remote) != null) {
        conflicts++;
      }
    }

    needsUpload += onlyLocal.length;
    needsDownload += onlyRemote.length;

    return SyncStatus(
      needsUpload: needsUpload,
      needsDownload: needsDownload,
      conflicts: conflicts,
      isSynced: needsUpload == 0 && needsDownload == 0 && conflicts == 0,
    );
  }

  /// Converte ExpenseModel em ExpenseEntity
  ExpenseEntity _modelToEntity(ExpenseModel model) {
    return ExpenseEntity(
      id: model.id,
      vehicleId: model.veiculoId,
      type: ExpenseType.values.firstWhere(
        (e) => e.name == model.tipo,
        orElse: () => ExpenseType.other,
      ),
      description: model.descricao,
      amount: model.valor,
      date: DateTime.fromMillisecondsSinceEpoch(model.data),
      odometer: model.odometro,
      receiptImagePath: model.receiptImagePath,
      location: model.location,
      notes: model.notes,
      metadata: model.metadata,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}

/// Representa um conflito de sincronização
class SyncConflict {
  const SyncConflict({
    required this.localVersion,
    required this.remoteVersion,
    required this.conflictType,
  });

  final ExpenseModel localVersion;
  final ExpenseEntity remoteVersion;
  final ConflictType conflictType;
}

/// Tipos de conflito de sincronização
enum ConflictType { simultaneousEdit, deletedRemotely, deletedLocally }

/// Status geral de sincronização
class SyncStatus {
  const SyncStatus({
    required this.needsUpload,
    required this.needsDownload,
    required this.conflicts,
    required this.isSynced,
  });

  final int needsUpload;
  final int needsDownload;
  final int conflicts;
  final bool isSynced;

  @override
  String toString() {
    return 'SyncStatus(upload: $needsUpload, download: $needsDownload, '
        'conflicts: $conflicts, synced: $isSynced)';
  }
}
