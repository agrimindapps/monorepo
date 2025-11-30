/// Financial Conflict Resolution Strategy for GasOMeter
/// Provides specialized conflict resolution for financial data
library;
import 'package:core/core.dart';

import '../../../audit/domain/services/audit_trail_service.dart';
import '../../../expenses/data/models/expense_model.dart';
import '../../../fuel/data/models/fuel_supply_model.dart';
import 'financial_validator.dart';

/// Conflict resolution strategy options
enum FinancialConflictStrategy {
  manualReview('MANUAL_REVIEW'), // Always require manual review for financial data
  mostRecent('MOST_RECENT'), // Use most recently updated version
  localPreferred('LOCAL_PREFERRED'), // Prefer local changes (user was actively editing)
  remotePreferred('REMOTE_PREFERRED'), // Prefer remote changes (sync from other device)
  highestValue('HIGHEST_VALUE'), // For fuel/expenses, prefer higher monetary value
  preserveReceipts('PRESERVE_RECEIPTS'), // Prefer version with receipt images
  smartMerge('SMART_MERGE'); // Attempt intelligent field-by-field merge

  const FinancialConflictStrategy(this.value);
  final String value;
}

/// Conflict resolution result
class FinancialConflictResult {

  const FinancialConflictResult({
    required this.resolvedEntity,
    required this.strategyUsed,
    required this.requiresManualReview,
    this.resolutionDetails = const {},
    this.warnings = const [],
  });
  final BaseSyncEntity resolvedEntity;
  final FinancialConflictStrategy strategyUsed;
  final bool requiresManualReview;
  final Map<String, dynamic> resolutionDetails;
  final List<String> warnings;

  /// Get formatted resolution summary
  String get resolutionSummary {
    final details = <String>[];

    details.add('Strategy: ${strategyUsed.value}');

    if (requiresManualReview) {
      details.add('Requires manual review');
    }

    if (warnings.isNotEmpty) {
      details.add('Warnings: ${warnings.join('; ')}');
    }

    return details.join(' | ');
  }
}

/// Financial Conflict Resolver
class FinancialConflictResolver {

  FinancialConflictResolver(this._auditService);
  final FinancialAuditTrailService _auditService;

  /// Resolve conflict between local and remote financial entities
  Future<FinancialConflictResult> resolveConflict(
    BaseSyncEntity localEntity,
    BaseSyncEntity remoteEntity, {
    FinancialConflictStrategy? preferredStrategy,
    Map<String, dynamic>? userContext,
  }) async {
    if (localEntity.runtimeType != remoteEntity.runtimeType) {
      throw ArgumentError('Cannot resolve conflict between different entity types');
    }

    if (localEntity.id != remoteEntity.id) {
      throw ArgumentError('Cannot resolve conflict between different entities');
    }
    final isFinancialData = FinancialValidator.isFinancialData(localEntity);
    final strategy = preferredStrategy ??
        (isFinancialData ? FinancialConflictStrategy.manualReview : FinancialConflictStrategy.mostRecent);

    FinancialConflictResult result;

    switch (strategy) {
      case FinancialConflictStrategy.manualReview:
        result = _requireManualReview(localEntity, remoteEntity);
        break;

      case FinancialConflictStrategy.mostRecent:
        result = _resolveMostRecent(localEntity, remoteEntity);
        break;

      case FinancialConflictStrategy.localPreferred:
        result = _resolveLocalPreferred(localEntity, remoteEntity);
        break;

      case FinancialConflictStrategy.remotePreferred:
        result = _resolveRemotePreferred(localEntity, remoteEntity);
        break;

      case FinancialConflictStrategy.highestValue:
        result = _resolveHighestValue(localEntity, remoteEntity);
        break;

      case FinancialConflictStrategy.preserveReceipts:
        result = _resolvePreserveReceipts(localEntity, remoteEntity);
        break;

      case FinancialConflictStrategy.smartMerge:
        result = await _resolveSmartMerge(localEntity, remoteEntity);
        break;
    }
    await _auditService.logConflictResolution(
      localEntity,
      remoteEntity,
      result.resolvedEntity,
      strategy: strategy.value,
      description: result.resolutionSummary,
    );

    return result;
  }

  /// Flag for manual review (safest for financial data)
  FinancialConflictResult _requireManualReview(
    BaseSyncEntity localEntity,
    BaseSyncEntity remoteEntity,
  ) {
    return FinancialConflictResult(
      resolvedEntity: localEntity.copyWith(
        isDirty: true, // Keep dirty to prevent sync until resolved
        version: localEntity.version, // Don't increment version
      ),
      strategyUsed: FinancialConflictStrategy.manualReview,
      requiresManualReview: true,
      resolutionDetails: {
        'local_version': localEntity.version,
        'remote_version': remoteEntity.version,
        'resolution': 'Flagged for manual review',
      },
      warnings: ['Financial data conflict requires manual review'],
    );
  }

  /// Resolve using most recent timestamp
  FinancialConflictResult _resolveMostRecent(
    BaseSyncEntity localEntity,
    BaseSyncEntity remoteEntity,
  ) {
    final localTime = localEntity.updatedAt ?? localEntity.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final remoteTime = remoteEntity.updatedAt ?? remoteEntity.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

    final useLocal = localTime.isAfter(remoteTime);
    final chosenEntity = useLocal ? localEntity : remoteEntity;
    final requiresReview = FinancialValidator.isFinancialData(chosenEntity);

    return FinancialConflictResult(
      resolvedEntity: chosenEntity.copyWith(
        version: [localEntity.version, remoteEntity.version].reduce((a, b) => a > b ? a : b) + 1,
        isDirty: false,
        lastSyncAt: DateTime.now(),
      ),
      strategyUsed: FinancialConflictStrategy.mostRecent,
      requiresManualReview: requiresReview,
      resolutionDetails: {
        'chosen': useLocal ? 'local' : 'remote',
        'local_time': localTime.toIso8601String(),
        'remote_time': remoteTime.toIso8601String(),
      },
      warnings: requiresReview ? ['Financial data resolved automatically - please verify'] : [],
    );
  }

  /// Resolve preferring local changes
  FinancialConflictResult _resolveLocalPreferred(
    BaseSyncEntity localEntity,
    BaseSyncEntity remoteEntity,
  ) {
    final requiresReview = FinancialValidator.isFinancialData(localEntity);

    return FinancialConflictResult(
      resolvedEntity: localEntity.copyWith(
        version: [localEntity.version, remoteEntity.version].reduce((a, b) => a > b ? a : b) + 1,
        isDirty: false,
        lastSyncAt: DateTime.now(),
      ),
      strategyUsed: FinancialConflictStrategy.localPreferred,
      requiresManualReview: requiresReview,
      resolutionDetails: {
        'resolution': 'Local changes preserved',
        'local_version': localEntity.version,
        'remote_version': remoteEntity.version,
      },
      warnings: requiresReview ? ['Local financial data preserved - please verify accuracy'] : [],
    );
  }

  /// Resolve preferring remote changes
  FinancialConflictResult _resolveRemotePreferred(
    BaseSyncEntity localEntity,
    BaseSyncEntity remoteEntity,
  ) {
    final requiresReview = FinancialValidator.isFinancialData(remoteEntity);

    return FinancialConflictResult(
      resolvedEntity: remoteEntity.copyWith(
        version: [localEntity.version, remoteEntity.version].reduce((a, b) => a > b ? a : b) + 1,
        isDirty: false,
        lastSyncAt: DateTime.now(),
      ),
      strategyUsed: FinancialConflictStrategy.remotePreferred,
      requiresManualReview: requiresReview,
      resolutionDetails: {
        'resolution': 'Remote changes accepted',
        'local_version': localEntity.version,
        'remote_version': remoteEntity.version,
      },
      warnings: requiresReview ? ['Remote financial data accepted - please verify accuracy'] : [],
    );
  }

  /// Resolve preferring higher monetary value
  FinancialConflictResult _resolveHighestValue(
    BaseSyncEntity localEntity,
    BaseSyncEntity remoteEntity,
  ) {
    double localValue = 0.0;
    double remoteValue = 0.0;

    if (localEntity is FuelSupplyModel) {
      localValue = (localEntity).totalPrice;
      remoteValue = (remoteEntity as FuelSupplyModel).totalPrice;
    } else if (localEntity is ExpenseModel) {
      localValue = (localEntity).valor;
      remoteValue = (remoteEntity as ExpenseModel).valor;
    }

    final useLocal = localValue >= remoteValue;
    final chosenEntity = useLocal ? localEntity : remoteEntity;
    final chosenValue = useLocal ? localValue : remoteValue;

    return FinancialConflictResult(
      resolvedEntity: chosenEntity.copyWith(
        version: [localEntity.version, remoteEntity.version].reduce((a, b) => a > b ? a : b) + 1,
        isDirty: false,
        lastSyncAt: DateTime.now(),
      ),
      strategyUsed: FinancialConflictStrategy.highestValue,
      requiresManualReview: true, // Always review value-based decisions
      resolutionDetails: {
        'chosen': useLocal ? 'local' : 'remote',
        'chosen_value': chosenValue,
        'local_value': localValue,
        'remote_value': remoteValue,
      },
      warnings: ['Conflict resolved by highest value - please verify this is correct'],
    );
  }

  /// Resolve preferring version with receipt images
  FinancialConflictResult _resolvePreserveReceipts(
    BaseSyncEntity localEntity,
    BaseSyncEntity remoteEntity,
  ) {
    bool localHasReceipt = false;
    bool remoteHasReceipt = false;

    if (localEntity is FuelSupplyModel) {
      localHasReceipt = (localEntity).receiptImageUrl?.isNotEmpty == true ||
          (localEntity).receiptImagePath?.isNotEmpty == true;
      remoteHasReceipt = (remoteEntity as FuelSupplyModel).receiptImageUrl?.isNotEmpty == true ||
          (remoteEntity).receiptImagePath?.isNotEmpty == true;
    } else if (localEntity is ExpenseModel) {
      localHasReceipt = (localEntity).receiptImageUrl?.isNotEmpty == true ||
          (localEntity).receiptImagePath?.isNotEmpty == true;
      remoteHasReceipt = (remoteEntity as ExpenseModel).receiptImageUrl?.isNotEmpty == true ||
          (remoteEntity).receiptImagePath?.isNotEmpty == true;
    }

    final BaseSyncEntity chosenEntity;
    final String resolution;

    if (localHasReceipt && !remoteHasReceipt) {
      chosenEntity = localEntity;
      resolution = 'Local chosen - has receipt';
    } else if (!localHasReceipt && remoteHasReceipt) {
      chosenEntity = remoteEntity;
      resolution = 'Remote chosen - has receipt';
    } else {
      return _resolveMostRecent(localEntity, remoteEntity);
    }

    return FinancialConflictResult(
      resolvedEntity: chosenEntity.copyWith(
        version: [localEntity.version, remoteEntity.version].reduce((a, b) => a > b ? a : b) + 1,
        isDirty: false,
        lastSyncAt: DateTime.now(),
      ),
      strategyUsed: FinancialConflictStrategy.preserveReceipts,
      requiresManualReview: true,
      resolutionDetails: {
        'resolution': resolution,
        'local_has_receipt': localHasReceipt,
        'remote_has_receipt': remoteHasReceipt,
      },
      warnings: ['Conflict resolved by preserving receipt - please verify data accuracy'],
    );
  }

  /// Attempt intelligent field-by-field merge
  Future<FinancialConflictResult> _resolveSmartMerge(
    BaseSyncEntity localEntity,
    BaseSyncEntity remoteEntity,
  ) async {
    if (localEntity is FuelSupplyModel && remoteEntity is FuelSupplyModel) {
      return _smartMergeFuelSupply(localEntity, remoteEntity);
    } else if (localEntity is ExpenseModel && remoteEntity is ExpenseModel) {
      return _smartMergeExpense(localEntity, remoteEntity);
    }
    return _resolveMostRecent(localEntity, remoteEntity);
  }

  /// Smart merge for fuel supply records
  FinancialConflictResult _smartMergeFuelSupply(
    FuelSupplyModel local,
    FuelSupplyModel remote,
  ) {
    final warnings = <String>[];
    final String? receiptImageUrl = local.receiptImageUrl?.isNotEmpty == true
        ? local.receiptImageUrl
        : remote.receiptImageUrl;
    final String? receiptImagePath = local.receiptImagePath?.isNotEmpty == true
        ? local.receiptImagePath
        : remote.receiptImagePath;
    final String? gasStationName = local.gasStationName?.isNotEmpty == true
        ? local.gasStationName
        : remote.gasStationName;
    final String? notes = local.notes?.isNotEmpty == true
        ? local.notes
        : remote.notes;
    final useLocalFinancials = (local.updatedAt ?? local.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .isAfter(remote.updatedAt ?? remote.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0));

    final mergedEntity = local.copyWith(
      totalPrice: useLocalFinancials ? local.totalPrice : remote.totalPrice,
      liters: useLocalFinancials ? local.liters : remote.liters,
      pricePerLiter: useLocalFinancials ? local.pricePerLiter : remote.pricePerLiter,
      odometer: useLocalFinancials ? local.odometer : remote.odometer,
      receiptImageUrl: receiptImageUrl,
      receiptImagePath: receiptImagePath,
      gasStationName: gasStationName,
      notes: notes,
      version: [local.version, remote.version].reduce((a, b) => a > b ? a : b) + 1,
      isDirty: false,
      lastSyncAt: DateTime.now(),
    );

    if (!useLocalFinancials) {
      warnings.add('Financial values merged from remote version');
    }

    return FinancialConflictResult(
      resolvedEntity: mergedEntity,
      strategyUsed: FinancialConflictStrategy.smartMerge,
      requiresManualReview: true, // Always review smart merges
      resolutionDetails: {
        'financial_source': useLocalFinancials ? 'local' : 'remote',
        'receipt_preserved': receiptImageUrl != null || receiptImagePath != null,
        'notes_preserved': notes?.isNotEmpty == true,
      },
      warnings: warnings,
    );
  }

  /// Smart merge for expense records
  FinancialConflictResult _smartMergeExpense(
    ExpenseModel local,
    ExpenseModel remote,
  ) {
    final warnings = <String>[];
    final String? receiptImageUrl = local.receiptImageUrl?.isNotEmpty == true
        ? local.receiptImageUrl
        : remote.receiptImageUrl;
    final String? receiptImagePath = local.receiptImagePath?.isNotEmpty == true
        ? local.receiptImagePath
        : remote.receiptImagePath;
    final String? location = local.location?.isNotEmpty == true
        ? local.location
        : remote.location;
    final String? notes = local.notes?.isNotEmpty == true
        ? local.notes
        : remote.notes;
    final mergedMetadata = Map<String, dynamic>.from(remote.metadata);
    mergedMetadata.addAll(local.metadata);
    final useLocalFinancials = (local.updatedAt ?? local.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .isAfter(remote.updatedAt ?? remote.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0));

    final mergedEntity = local.copyWith(
      valor: useLocalFinancials ? local.valor : remote.valor,
      tipo: useLocalFinancials ? local.tipo : remote.tipo,
      descricao: useLocalFinancials ? local.descricao : remote.descricao,
      odometro: useLocalFinancials ? local.odometro : remote.odometro,
      receiptImageUrl: receiptImageUrl,
      receiptImagePath: receiptImagePath,
      location: location,
      notes: notes,
      metadata: mergedMetadata,
      version: [local.version, remote.version].reduce((a, b) => a > b ? a : b) + 1,
      isDirty: false,
      lastSyncAt: DateTime.now(),
    );

    if (!useLocalFinancials) {
      warnings.add('Financial values merged from remote version');
    }

    return FinancialConflictResult(
      resolvedEntity: mergedEntity,
      strategyUsed: FinancialConflictStrategy.smartMerge,
      requiresManualReview: true, // Always review smart merges
      resolutionDetails: {
        'financial_source': useLocalFinancials ? 'local' : 'remote',
        'receipt_preserved': receiptImageUrl != null || receiptImagePath != null,
        'metadata_merged': mergedMetadata.isNotEmpty,
      },
      warnings: warnings,
    );
  }

  /// Get recommended strategy for entities
  FinancialConflictStrategy getRecommendedStrategy(
    BaseSyncEntity localEntity,
    BaseSyncEntity remoteEntity,
  ) {
    if (FinancialValidator.isFinancialData(localEntity)) {
      if (_areEntitiesVerySimilar(localEntity, remoteEntity)) {
        return FinancialConflictStrategy.smartMerge;
      }
      return FinancialConflictStrategy.manualReview;
    }
    return FinancialConflictStrategy.mostRecent;
  }

  /// Check if entities are very similar (safe for auto-resolution)
  bool _areEntitiesVerySimilar(BaseSyncEntity local, BaseSyncEntity remote) {
    if (local is FuelSupplyModel && remote is FuelSupplyModel) {
      final priceDiff = (local.totalPrice - remote.totalPrice).abs();
      final litersDiff = (local.liters - remote.liters).abs();
      return priceDiff < 1.0 && litersDiff < 0.1;
    }

    if (local is ExpenseModel && remote is ExpenseModel) {
      final valueDiff = (local.valor - remote.valor).abs();
      return valueDiff < 1.0 && local.tipo == remote.tipo;
    }

    return false;
  }
}
